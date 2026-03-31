
DROP TRIGGER IF EXISTS trg_prevent_double_booking ON Booking;
DROP TRIGGER IF EXISTS trg_log_booking_changes ON Booking;
DROP TRIGGER IF EXISTS trg_validate_booking_category ON Booking;

DROP FUNCTION IF EXISTS trg_fn_prevent_double_booking();
DROP FUNCTION IF EXISTS trg_fn_log_booking_changes();
DROP FUNCTION IF EXISTS trg_fn_validate_booking_category();

DROP FUNCTION IF EXISTS fn_check_room_availability(VARCHAR,VARCHAR,VARCHAR,INTEGER,INTEGER,DATE);
DROP FUNCTION IF EXISTS fn_is_date_cancelled(INTEGER,DATE);
DROP FUNCTION IF EXISTS fn_get_instructor_bookings(VARCHAR,INTEGER,INTEGER);

DROP PROCEDURE IF EXISTS sp_create_booking(VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,INTEGER,INTEGER,VARCHAR,VARCHAR,INTEGER);
DROP PROCEDURE IF EXISTS sp_cancel_booking(INTEGER,VARCHAR);
DROP PROCEDURE IF EXISTS sp_cancel_specific_lecture(INTEGER,DATE,TEXT,VARCHAR);

DROP VIEW IF EXISTS v_active_bookings;
DROP VIEW IF EXISTS v_available_rooms;
DROP VIEW IF EXISTS v_instructor_schedule;

-- Function 1: Check Room Availability
CREATE OR REPLACE FUNCTION fn_check_room_availability(
    p_building VARCHAR(15),
    p_room_number VARCHAR(7),
    p_time_slot_id VARCHAR(4),
    p_semester INTEGER,
    p_year INTEGER,
    p_check_date DATE DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_conflict_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_conflict_count
    FROM Booking b
    WHERE b.building = p_building
      AND b.room_number = p_room_number
      AND b.time_slot_id = p_time_slot_id
      AND b.semester = p_semester
      AND b.year = p_year
      AND b.status = 'ACTIVE'
      AND (p_check_date IS NULL OR NOT fn_is_date_cancelled(b.booking_id, p_check_date));
    
    RETURN v_conflict_count = 0;
END;
$$ LANGUAGE plpgsql;

-- Function 2: Check if Date is Cancelled
CREATE OR REPLACE FUNCTION fn_is_date_cancelled(
    p_booking_id INTEGER,
    p_check_date DATE
)
RETURNS BOOLEAN AS $$
DECLARE
    v_cancelled_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_cancelled_count
    FROM Booking_Exception
    WHERE booking_id = p_booking_id
      AND cancelled_date = p_check_date;
    
    RETURN v_cancelled_count > 0;
END;
$$ LANGUAGE plpgsql;

-- Function 3: Get Instructor Bookings
CREATE OR REPLACE FUNCTION fn_get_instructor_bookings(
    p_inst_id VARCHAR(5),
    p_semester INTEGER,
    p_year INTEGER
)
RETURNS TABLE (
    booking_id INTEGER,
    course_title VARCHAR(50),
    room VARCHAR(30),
    day VARCHAR(1),
    start_time TIME,
    end_time TIME,
    booking_type VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.booking_id,
           COALESCE(c.title, 'Event/Club Activity'),
           b.building || '-' || b.room_number,
           ts.day,
           ts.start_time,
           ts.end_time,
           b.booking_type
    FROM Booking b
    LEFT JOIN Course c ON b.course_id = c.course_id
    JOIN Time_slot ts ON b.time_slot_id = ts.time_slot_id
    WHERE b.inst_id = p_inst_id
      AND b.semester = p_semester
      AND b.year = p_year
      AND b.status = 'ACTIVE';
END;
$$ LANGUAGE plpgsql;

-- Procedure 1: Create Booking
CREATE OR REPLACE PROCEDURE sp_create_booking(
    p_course_id VARCHAR(8),
    p_inst_id VARCHAR(5),
    p_building VARCHAR(15),
    p_room_number VARCHAR(7),
    p_time_slot_id VARCHAR(4),
    p_semester INTEGER,
    p_year INTEGER,
    p_booking_type VARCHAR(10),
    p_booking_category VARCHAR(20),
    p_organizer_id INTEGER DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT fn_check_room_availability(p_building, p_room_number, p_time_slot_id, p_semester, p_year) THEN
        RAISE EXCEPTION 'Room % in building % is already booked for time slot % in semester % year %', 
                        p_room_number, p_building, p_time_slot_id, p_semester, p_year;
    END IF;

    INSERT INTO Booking (course_id, inst_id, building, room_number, time_slot_id, 
                        semester, year, booking_type, booking_category, organizer_id)
    VALUES (p_course_id, p_inst_id, p_building, p_room_number, p_time_slot_id, 
            p_semester, p_year, p_booking_type, p_booking_category, p_organizer_id);
    
    RAISE NOTICE 'Booking created successfully';
END;
$$;

-- Procedure 2: Cancel Booking
CREATE OR REPLACE PROCEDURE sp_cancel_booking(
    p_booking_id INTEGER,
    p_user_id VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_status VARCHAR(10);
BEGIN
    SELECT status INTO v_old_status FROM Booking WHERE booking_id = p_booking_id;
    
    IF v_old_status IS NULL THEN
        RAISE EXCEPTION 'Booking ID % does not exist', p_booking_id;
    END IF;
    
    IF v_old_status = 'CANCELLED' THEN
        RAISE EXCEPTION 'Booking is already cancelled';
    END IF;
    UPDATE Booking SET status = 'CANCELLED' WHERE booking_id = p_booking_id;
    INSERT INTO Booking_Audit (booking_id, action, old_status, new_status, changed_by)
    VALUES (p_booking_id, 'CANCEL', v_old_status, 'CANCELLED', p_user_id);
    
    RAISE NOTICE 'Booking % cancelled successfully', p_booking_id;
END;
$$;

-- Procedure 3: Cancel Specific Lecture
CREATE OR REPLACE PROCEDURE sp_cancel_specific_lecture(
    p_booking_id INTEGER,
    p_cancelled_date DATE,
    p_reason TEXT,
    p_user_id VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_booking_type VARCHAR(10);
BEGIN
    SELECT booking_type INTO v_booking_type FROM Booking WHERE booking_id = p_booking_id;
    
    IF v_booking_type IS NULL THEN
        RAISE EXCEPTION 'Booking ID % does not exist', p_booking_id;
    END IF;
    
    IF v_booking_type != 'PERIODIC' THEN
        RAISE EXCEPTION 'Can only cancel specific lectures for PERIODIC bookings';
    END IF;
    INSERT INTO Booking_Exception (booking_id, cancelled_date, reason)
    VALUES (p_booking_id, p_cancelled_date, p_reason);
    INSERT INTO Booking_Audit (booking_id, action, changed_by)
    VALUES (p_booking_id, 'CANCEL_LECTURE', p_user_id);
    
    RAISE NOTICE 'Lecture on % cancelled for booking %', p_cancelled_date, p_booking_id;
END;
$$;

-- Trigger 1: Prevent Double Booking
CREATE OR REPLACE FUNCTION trg_fn_prevent_double_booking()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT fn_check_room_availability(NEW.building, NEW.room_number, NEW.time_slot_id, 
                                       NEW.semester, NEW.year) THEN
        RAISE EXCEPTION 'Room %-% is already booked for time slot % in semester % year %', 
                        NEW.building, NEW.room_number, NEW.time_slot_id, NEW.semester, NEW.year;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_double_booking
BEFORE INSERT ON Booking
FOR EACH ROW
EXECUTE FUNCTION trg_fn_prevent_double_booking();

-- Trigger 2: Log Booking Changes
CREATE OR REPLACE FUNCTION trg_fn_log_booking_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO Booking_Audit (booking_id, action, old_status, new_status, changed_by)
        VALUES (NEW.booking_id, 'UPDATE', OLD.status, NEW.status, CURRENT_USER);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_booking_changes
AFTER UPDATE ON Booking
FOR EACH ROW
EXECUTE FUNCTION trg_fn_log_booking_changes();

-- Trigger 3: Validate Booking Category
CREATE OR REPLACE FUNCTION trg_fn_validate_booking_category()
RETURNS TRIGGER AS $$
DECLARE
    v_faculty_advisor_id VARCHAR(5);
BEGIN
    IF NEW.booking_category = 'COURSE' AND NEW.course_id IS NULL THEN
        RAISE EXCEPTION 'COURSE bookings must have a course_id';
    END IF;
    IF NEW.booking_category = 'CLUB' AND NEW.organizer_id IS NULL THEN
        RAISE EXCEPTION 'CLUB bookings must have an organizer_id';
    END IF;
    IF NEW.booking_category = 'CLUB' AND NEW.organizer_id IS NOT NULL THEN
        SELECT faculty_advisor_id INTO v_faculty_advisor_id
        FROM Organizer
        WHERE organizer_id = NEW.organizer_id;
        
        IF v_faculty_advisor_id IS NULL THEN
            RAISE EXCEPTION 'CLUB organizer must have a faculty advisor assigned';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_booking_category
BEFORE INSERT ON Booking
FOR EACH ROW
EXECUTE FUNCTION trg_fn_validate_booking_category();

-- View 1: Active Bookings
CREATE VIEW v_active_bookings AS
SELECT 
    b.booking_id,
    COALESCE(c.title, 'Event/Club Activity') AS course_title,
    i.name AS instructor_name,
    b.building || '-' || b.room_number AS room,
    cl.capacity,
    ts.day,
    ts.start_time,
    ts.end_time,
    b.semester,
    b.year,
    b.booking_type,
    b.booking_category,
    b.status
FROM Booking b
LEFT JOIN Course c ON b.course_id = c.course_id
JOIN Instructor i ON b.inst_id = i.ID
JOIN Classroom cl ON b.building = cl.building AND b.room_number = cl.room_number
JOIN Time_slot ts ON b.time_slot_id = ts.time_slot_id
WHERE b.status = 'ACTIVE'
ORDER BY b.year, b.semester, ts.day, ts.start_time;

-- View 2: Available Rooms
CREATE VIEW v_available_rooms AS
SELECT 
    c.building,
    c.room_number,
    c.capacity,
    ts.time_slot_id,
    ts.day,
    ts.start_time,
    ts.end_time
FROM Classroom c
CROSS JOIN Time_slot ts
WHERE NOT EXISTS (
    SELECT 1
    FROM Booking b
    WHERE b.building = c.building
      AND b.room_number = c.room_number
      AND b.time_slot_id = ts.time_slot_id
      AND b.status = 'ACTIVE'
)
ORDER BY c.building, c.room_number, ts.day, ts.start_time;

-- View 3: Instructor Schedule
CREATE VIEW v_instructor_schedule AS
SELECT 
    i.ID,
    i.name AS instructor_name,
    COALESCE(c.course_id, 'N/A') AS course_id,
    COALESCE(c.title, 'Event/Club') AS course_title,
    b.building || '-' || b.room_number AS room,
    ts.day,
    ts.start_time,
    ts.end_time,
    b.semester,
    b.year,
    b.booking_type,
    b.booking_category
FROM Instructor i
JOIN Booking b ON i.ID = b.inst_id
LEFT JOIN Course c ON b.course_id = c.course_id
JOIN Time_slot ts ON b.time_slot_id = ts.time_slot_id
WHERE b.status = 'ACTIVE'
ORDER BY i.ID, b.year, b.semester, ts.day, ts.start_time;