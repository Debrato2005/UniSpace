
INSERT INTO Classroom (building, room_number, capacity) VALUES
-- Main academic building (Fill in at least 5 rooms)
('Main Building', '101', 60),
('Main Building', '102', 60),
('Main Building', '103', 80),
('Lab Block', 'L101', 40),
('Lab Block', 'L102', 40),
('ECE Block', 'E101', 50),
('Auditorium', 'A1', 200),

INSERT INTO Time_slot (time_slot_id, day, start_time, end_time) VALUES
('M01', 'M', '08:00', '09:00'),
('M02', 'M', '09:00', '10:00'),
('M03', 'M', '10:00', '11:00'),
('T01', 'T', '08:00', '09:00'),
('S01', 'S', '08:00', '09:00'),

INSERT INTO Organizer (name, type, contact_email, faculty_advisor_id) VALUES
('IEEE Student Branch', 'CLUB', 'ieee@university.edu', '10201'),
('Robotics Club', 'CLUB', 'robotics@university.edu', '10202'),

INSERT INTO Booking (course_id, inst_id, building, room_number, time_slot_id, 
                     semester, year, booking_type, booking_category, status) VALUES
('ECE2121', '10201', 'ECE Block', 'E101', 'M02', 3, 2025, 'PERIODIC', 'COURSE', 'ACTIVE'),
('ECE2121', '10201', 'ECE Block', 'E101', 'W02', 3, 2025, 'PERIODIC', 'COURSE', 'ACTIVE');
