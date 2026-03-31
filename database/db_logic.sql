DROP TRIGGER IF EXISTS trg_prevent_double_booking    ON Booking;
DROP TRIGGER IF EXISTS trg_log_booking_changes       ON Booking;
DROP TRIGGER IF EXISTS trg_validate_booking_category ON Booking;

DROP FUNCTION IF EXISTS prevent_double_booking();
DROP FUNCTION IF EXISTS log_booking_changes();
DROP FUNCTION IF EXISTS validate_booking_category();

DROP FUNCTION IF EXISTS fn_check_room_availability(VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS fn_is_date_cancelled(INTEGER, DATE);
DROP FUNCTION IF EXISTS fn_get_instructor_bookings(VARCHAR);

DROP PROCEDURE IF EXISTS sp_create_booking(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER, VARCHAR, VARCHAR, INTEGER);
DROP PROCEDURE IF EXISTS sp_cancel_booking(INTEGER, VARCHAR);
DROP PROCEDURE IF EXISTS sp_cancel_specific_lecture(INTEGER, DATE, TEXT);

DROP VIEW IF EXISTS v_active_bookings;
DROP VIEW IF EXISTS v_available_rooms;
DROP VIEW IF EXISTS v_instructor_schedule;



CREATE OR REPLACE FUNCTION fn_check_room_availability(
    p_building     VARCHAR,
    p_room_number  VARCHAR,
    p_time_slot_id VARCHAR,
    p_semester     INTEGER,
    p_year         INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM   Booking
        WHERE  building      = p_building
        AND    room_number   = p_room_number
        AND    time_slot_id  = p_time_slot_id
        AND    semester      = p_semester
        AND    year          = p_year
        AND    status        = 'ACTIVE'
    ) THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END;
$$;


CREATE OR REPLACE FUNCTION fn_is_date_cancelled(
    p_booking_id INTEGER,
    p_date       DATE
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM   Booking_Exception
        WHERE  booking_id     = p_booking_id
        AND    cancelled_date = p_date
    ) THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$;



CREATE OR REPLACE FUNCTION fn_get_instructor_bookings(
    p_inst_id VARCHAR
)
RETURNS TABLE (
    booking_id       INTEGER,
    course_title     VARCHAR,
    building         VARCHAR,
    room_number      VARCHAR,
    time_slot_id     VARCHAR,
    day              VARCHAR,
    start_time       TIME,
    end_time         TIME,
    semester         INTEGER,
    year             INTEGER,
    booking_type     VARCHAR,
    booking_category VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            b.booking_id,
            c.title          AS course_title,
            b.building,
            b.room_number,
            b.time_slot_id,
            ts.day,
            ts.start_time,
            ts.end_time,
            b.semester,
            b.year,
            b.booking_type,
            b.booking_category
        FROM   Booking b
        LEFT JOIN Course    c  ON  b.course_id    = c.course_id
        JOIN      Time_slot ts ON  b.time_slot_id = ts.time_slot_id
        WHERE  b.inst_id = p_inst_id
        AND    b.status  = 'ACTIVE'
        ORDER BY ts.day, ts.start_time;
END;
$$;



CREATE OR REPLACE FUNCTION prevent_double_booking()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT fn_check_room_availability(
        NEW.building,
        NEW.room_number,
        NEW.time_slot_id,
        NEW.semester,
        NEW.year
    ) THEN
        RAISE EXCEPTION
            'Double booking conflict: room % % is already booked for time slot % in semester % year %',
            NEW.building, NEW.room_number,
            NEW.time_slot_id, NEW.semester, NEW.year;
    END IF;

    RETURN NEW;
END;
$$;



CREATE OR REPLACE FUNCTION log_booking_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_changed_by VARCHAR(50);
BEGIN
    -- Prefer app-level user set by the Java layer; fall back to DB role
    v_changed_by := COALESCE(
        current_setting('app.current_user', true),
        CURRENT_USER
    );

    INSERT INTO Booking_Audit(
        booking_id,
        action,
        old_status,
        new_status,
        changed_by,
        changed_at
    )
    VALUES (
        NEW.booking_id,
        TG_OP,           -- 'UPDATE'
        OLD.status,
        NEW.status,
        v_changed_by,
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$;


CREATE OR REPLACE FUNCTION validate_booking_category()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- COURSE: must have course_id, must NOT have organizer_id
    IF NEW.booking_category = 'COURSE' THEN
        IF NEW.course_id IS NULL THEN
            RAISE EXCEPTION 'COURSE booking must have a course_id';
        END IF;
    END IF;

    -- EVENT and CLUB: must have organizer_id
    IF NEW.booking_category IN ('EVENT', 'CLUB') THEN
        IF NEW.organizer_id IS NULL THEN
            RAISE EXCEPTION '% booking must have an organizer_id', NEW.booking_category;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;



CREATE TRIGGER trg_prevent_double_booking
    BEFORE INSERT ON Booking
    FOR EACH ROW
    EXECUTE FUNCTION prevent_double_booking();



CREATE TRIGGER trg_log_booking_changes
    AFTER UPDATE ON Booking
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION log_booking_changes();


CREATE TRIGGER trg_validate_booking_category
    BEFORE INSERT ON Booking
    FOR EACH ROW
    EXECUTE FUNCTION validate_booking_category();



CREATE OR REPLACE PROCEDURE sp_create_booking(
    p_course_id    VARCHAR,
    p_inst_id      VARCHAR,
    p_building     VARCHAR,
    p_room_number  VARCHAR,
    p_time_slot_id VARCHAR,
    p_semester     INTEGER,
    p_year         INTEGER,
    p_type         VARCHAR,   
    p_category     VARCHAR,  
    p_organizer_id INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Instructor WHERE ID = p_inst_id
    ) THEN
        RAISE EXCEPTION 'Instructor % not found', p_inst_id;
    END IF;

    IF NOT fn_check_room_availability(
        p_building, p_room_number, p_time_slot_id, p_semester, p_year
    ) THEN
        RAISE EXCEPTION
            'Room % % is already booked for slot % in semester % year %',
            p_building, p_room_number, p_time_slot_id, p_semester, p_year;
    END IF;

    INSERT INTO Booking(
        course_id,    inst_id,       building,    room_number,
        time_slot_id, semester,      year,
        booking_type, booking_category, organizer_id, status
    )
    VALUES (
        p_course_id,    p_inst_id,     p_building,  p_room_number,
        p_time_slot_id, p_semester,    p_year,
        p_type,         p_category,    p_organizer_id, 'ACTIVE'
    );
END;
$$;


CREATE OR REPLACE PROCEDURE sp_cancel_booking(
    p_booking_id INTEGER,
    p_changed_by VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Booking
        WHERE  booking_id = p_booking_id
        AND    status     = 'ACTIVE'
    ) THEN
        RAISE EXCEPTION
            'Booking % does not exist or is already cancelled', p_booking_id;
    END IF;

    IF p_changed_by IS NOT NULL THEN
        PERFORM set_config('app.current_user', p_changed_by, true);
    END IF;

    UPDATE Booking
    SET    status = 'CANCELLED'
    WHERE  booking_id = p_booking_id;
END;
$$;



CREATE OR REPLACE PROCEDURE sp_cancel_specific_lecture(
    p_booking_id INTEGER,
    p_date       DATE,
    p_reason     TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Guard 1: booking must exist and be PERIODIC
    IF NOT EXISTS (
        SELECT 1 FROM Booking
        WHERE  booking_id    = p_booking_id
        AND    booking_type  = 'PERIODIC'
        AND    status        = 'ACTIVE'
    ) THEN
        RAISE EXCEPTION
            'Booking % is not an active PERIODIC booking', p_booking_id;
    END IF;

    -- Guard 2: date must not already be cancelled
    IF EXISTS (
        SELECT 1 FROM Booking_Exception
        WHERE  booking_id     = p_booking_id
        AND    cancelled_date = p_date
    ) THEN
        RAISE EXCEPTION
            'Date % is already cancelled for booking %', p_date, p_booking_id;
    END IF;

    -- Insert the exception
    INSERT INTO Booking_Exception(booking_id, cancelled_date, reason)
    VALUES (p_booking_id, p_date, p_reason);
END;
$$;



CREATE VIEW v_active_bookings AS
    SELECT
        b.booking_id,
        b.booking_category,
        b.booking_type,
        b.semester,
        b.year,
        i.name           AS instructor_name,
        co.title         AS course_title,
        b.building,
        b.room_number,
        cl.capacity,
        ts.day,
        ts.start_time,
        ts.end_time,
        b.status,
        b.created_at
    FROM      Booking     b
    JOIN      Instructor  i   ON  b.inst_id      = i.ID
    LEFT JOIN Course      co  ON  b.course_id    = co.course_id
    JOIN      Classroom   cl  ON  b.building     = cl.building
                             AND  b.room_number  = cl.room_number
    JOIN      Time_slot   ts  ON  b.time_slot_id = ts.time_slot_id
    WHERE     b.status = 'ACTIVE'
    ORDER BY  ts.day, ts.start_time;



CREATE VIEW v_available_rooms AS
    SELECT
        c.building,
        c.room_number,
        c.capacity
    FROM  Classroom c
    WHERE NOT EXISTS (
        SELECT 1
        FROM   Booking b
        WHERE  b.building    = c.building
        AND    b.room_number = c.room_number
        AND    b.status      = 'ACTIVE'
    )
    ORDER BY c.building, c.room_number;



CREATE VIEW v_instructor_schedule AS
    SELECT
        b.inst_id,
        i.name           AS instructor_name,
        b.booking_category,
        b.booking_type,
        co.title         AS course_title,
        b.building,
        b.room_number,
        ts.day,
        ts.start_time,
        ts.end_time,
        b.semester,
        b.year
    FROM      Booking     b
    JOIN      Instructor  i   ON  b.inst_id      = i.ID
    LEFT JOIN Course      co  ON  b.course_id    = co.course_id
    JOIN      Time_slot   ts  ON  b.time_slot_id = ts.time_slot_id
    WHERE     b.status = 'ACTIVE'
    ORDER BY  b.inst_id, ts.day, ts.start_time;