DROP TABLE IF EXISTS Booking_Audit CASCADE;
DROP TABLE IF EXISTS Booking_Exception CASCADE;
DROP TABLE IF EXISTS Booking CASCADE;
DROP TABLE IF EXISTS Organizer CASCADE;
DROP TABLE IF EXISTS Time_slot CASCADE;
DROP TABLE IF EXISTS Classroom CASCADE;
DROP TABLE IF EXISTS Course CASCADE;
DROP TABLE IF EXISTS Instructor CASCADE;
DROP TABLE IF EXISTS Department CASCADE;
-- 1. Department
CREATE TABLE Department (
    dept_name VARCHAR(50) PRIMARY KEY
);

-- 2. Instructor
CREATE TABLE Instructor (
    ID VARCHAR(5) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    dept_name VARCHAR(50),
    FOREIGN KEY (dept_name) REFERENCES Department(dept_name) ON DELETE SET NULL
);

-- 3. Course
CREATE TABLE Course (
    course_id VARCHAR(8) PRIMARY KEY,
    title VARCHAR(50),
    dept_name VARCHAR(50),
    credits INTEGER NOT NULL CHECK (credits > 0),
    FOREIGN KEY (dept_name) REFERENCES Department(dept_name) ON DELETE SET NULL
);

-- 4. Classroom
CREATE TABLE Classroom (
    building VARCHAR(15),
    room_number VARCHAR(7),
    capacity INTEGER NOT NULL,
    PRIMARY KEY (building, room_number),
    CONSTRAINT chk_capacity CHECK (capacity > 0)
);

-- 5. Time_slot
CREATE TABLE Time_slot (
    time_slot_id VARCHAR(4) PRIMARY KEY,
    day VARCHAR(1) CHECK (day IN ('M','T','W','R','F','S','U')),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    CONSTRAINT chk_time CHECK (end_time > start_time)
);

-- 6. Organizer
CREATE TABLE Organizer (
    organizer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL,
    contact_email VARCHAR(100),
    faculty_advisor_id VARCHAR(5),
    CONSTRAINT chk_organizer_type CHECK (type IN ('FACULTY', 'CLUB', 'ADMIN')),
    FOREIGN KEY (faculty_advisor_id) REFERENCES Instructor(ID) ON DELETE SET NULL
);

-- 7. Booking
CREATE TABLE Booking (
    booking_id SERIAL PRIMARY KEY,
    course_id VARCHAR(8),
    inst_id VARCHAR(5) NOT NULL,
    building VARCHAR(15) NOT NULL,
    room_number VARCHAR(7) NOT NULL,
    time_slot_id VARCHAR(4) NOT NULL,
    semester INTEGER NOT NULL,
    year INTEGER NOT NULL,
    booking_type VARCHAR(10) NOT NULL,
    booking_category VARCHAR(20) NOT NULL,
    organizer_id INTEGER,
    status VARCHAR(10) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES Course(course_id) ON DELETE CASCADE,
    FOREIGN KEY (inst_id) REFERENCES Instructor(ID) ON DELETE CASCADE,
    FOREIGN KEY (building, room_number) REFERENCES Classroom(building, room_number),
    FOREIGN KEY (time_slot_id) REFERENCES Time_slot(time_slot_id),
    FOREIGN KEY (organizer_id) REFERENCES Organizer(organizer_id) ON DELETE SET NULL,
    CONSTRAINT chk_booking_type CHECK (booking_type IN ('SINGLE', 'PERIODIC')),
    CONSTRAINT chk_booking_category CHECK (booking_category IN ('COURSE', 'EVENT', 'CLUB')),
    CONSTRAINT chk_status CHECK (status IN ('ACTIVE', 'CANCELLED')),
    CONSTRAINT chk_semester CHECK (semester BETWEEN 1 AND 8),
    CONSTRAINT chk_year CHECK (year >= 2025)
);


-- 8. Booking_Exception
CREATE TABLE Booking_Exception (
    exception_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL,
    cancelled_date DATE NOT NULL,
    reason TEXT,
    cancelled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE CASCADE,
    CONSTRAINT unique_exception UNIQUE (booking_id, cancelled_date)
);

-- 9. Booking_Audit
CREATE TABLE Booking_Audit (
    audit_id SERIAL PRIMARY KEY,
    booking_id INTEGER,
    action VARCHAR(10),
    old_status VARCHAR(10),
    new_status VARCHAR(10),
    changed_by VARCHAR(50),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);