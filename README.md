# UniSpace: AcWeb-Based Classroom Booking and Scheduling System

## With Conflict Detection and Periodic Reservation Support

**Author:** Debrato Ghosh
**Registration Number:** 240911734
**Branch:** Information Technology
**Section:** IT A
**Roll Number:** 62

---

## Abstract

The proposed system is a Web-Based Classroom Booking and Scheduling System designed to efficiently manage classroom allocations in a university environment. Manual scheduling methods often lead to double booking, inefficient room utilization, and difficulties in managing recurring lecture reservations as well as event and student club activity bookings. This system provides a centralized database-driven solution to handle classroom reservations for multiple purposes while enforcing strict integrity constraints.

The system supports both single and periodic bookings such as weekly lectures throughout a semester, one-time event bookings, and student club activities. It prevents overlapping reservations using database-level constraints and trigger-based validation mechanisms. The system also allows cancellation of specific sessions within a periodic booking without affecting the entire schedule. Role-based access ensures that only authorized faculty, administrators, and club organizers can perform booking operations.

The implementation uses PostgreSQL for database design with integrity constraints, stored procedures, functions, triggers, and complex queries. The application layer uses Java with JDBC connectivity following the three-tier architecture pattern, utilizing Servlets for business logic and JSP for presentation. The system ensures optimized classroom utilization, conflict detection, and reliable scheduling through database-enforced constraints.

---

## Technology Stack

### Database Layer

* **PostgreSQL 14+** – Relational Database Management System
* **PL/pgSQL** – Procedural Language for PostgreSQL

### Application Layer (Backend)

* **Java SE 8+** – Core Programming Language
* **JDBC (Java Database Connectivity)** – Database communication
* **Java Servlets** – Request handling and business logic
* **DAO (Data Access Object) Pattern** – Database abstraction layer
* **Apache Tomcat 9.0+** – Servlet Container / Application Server

### Presentation Layer (Frontend)

* **JSP (JavaServer Pages)** – Dynamic web page generation
* **JSTL (JSP Standard Tag Library)** – Simplified JSP development
* **HTML5** – Markup structure
* **CSS3** – Styling and layout
* **Bootstrap 5** – Responsive UI framework
* **JavaScript (Vanilla)** – Client-side validation and interactivity

### Development Tools

* VS Code
* pgAdmin 4
* Git

---

## Problem Statement

Universities require a structured and reliable system to manage classroom bookings for lectures, seminars, academic events, and student club activities. The system must:

* Prevent overlapping classroom bookings through database triggers
* Support periodic (weekly) bookings for an entire semester
* Allow cancellation of specific sessions within a recurring booking
* Handle multi-purpose room usage for courses, events, and club activities
* Maintain booking history and audit records using database triggers
* Enforce referential integrity and validation constraints at the database level
* Provide secure and authorized access for faculty, administrators, and club organizers
* Handle concurrent booking requests with proper transaction management
* Generate reports on classroom utilization

---

## System Architecture

The system follows a three-tier architecture pattern:

### Tier 1: Presentation Layer

* JSP pages for user interface
* HTML forms for data input
* JavaScript for client-side validation
* Bootstrap for responsive design

### Tier 2: Application Layer

* Java Servlets for handling HTTP requests
* DAO classes for database operations
* Model classes representing database entities
* Business logic implementation
* Session management for user authentication

### Tier 3: Database Layer

* PostgreSQL database with normalized tables
* Stored procedures for complex operations
* Functions for reusable logic
* Triggers for automatic constraint enforcement
* Views for complex queries and reporting

---

## Database Schema (Provisional)

The system uses an extended university database schema with additional tables for booking management.

---

### Core University Tables

#### 1. Department

* `dept_name VARCHAR(50)` – Primary Key

#### 2. Instructor

* `ID VARCHAR(5)` – Primary Key
* `name VARCHAR(20)` – NOT NULL
* `dept_name VARCHAR(50)` – Foreign Key → Department

#### 3. Course

* `course_id VARCHAR(8)` – Primary Key
* `title VARCHAR(50)`
* `dept_name VARCHAR(50)` – Foreign Key → Department
* `credits NUMERIC(2,0)` – CHECK (credits > 0)

#### 4. Classroom

* `building VARCHAR(15)`
* `room_number VARCHAR(7)`
* `capacity NUMERIC(4,0)`
* Composite Primary Key (`building`, `room_number`)

#### 5. Time_slot

* `time_slot_id VARCHAR(4)` – Primary Key
* `day VARCHAR(1)` – CHECK (M, T, W, R, F, S, U)
* `start_time TIME`
* `end_time TIME`

---

### Booking Management Tables

#### 6. Organizer

* `organizer_id SERIAL` – Primary Key
* `name VARCHAR(100)`
* `type VARCHAR(20)` – FACULTY / CLUB / ADMIN
* `contact_email VARCHAR(100)`
* `faculty_advisor_id VARCHAR(5)` – Foreign Key → Instructor

#### 7. Booking

* `booking_id SERIAL` – Primary Key
* `course_id VARCHAR(8)`
* `inst_id VARCHAR(5)`
* `building VARCHAR(15)`
* `room_number VARCHAR(7)`
* `time_slot_id VARCHAR(4)`
* `semester VARCHAR(6)`
* `year NUMERIC(4,0)`
* `booking_type VARCHAR(10)` – SINGLE / PERIODIC
* `booking_category VARCHAR(20)` – COURSE / EVENT / CLUB
* `organizer_id INTEGER`
* `status VARCHAR(10)` – ACTIVE / CANCELLED
* `created_at TIMESTAMP`

**Note:**

* For COURSE bookings → `inst_id` represents the teaching faculty
* For EVENT bookings → `inst_id` represents the faculty coordinator
* For CLUB bookings → `inst_id` represents the faculty advisor

#### 8. Booking_Exception

* Stores cancelled dates within periodic bookings

#### 9. Booking_Audit

* Maintains history of booking operations

---

## Key Features

### 1. Conflict Detection

* Trigger-based prevention of overlapping bookings
* Validation of classroom, time slot, semester, and year
* Pre-insertion validation using stored functions

### 2. Periodic Booking Management

* Weekly recurring bookings for entire semester
* Individual lecture cancellation
* Exception tracking through dedicated table

### 3. Transaction Management

* ACID compliance
* Rollback on conflicts
* Exception handling in JDBC layer

### 4. User Authentication & Authorization

* Role-based access control
* Session management
* Password hashing
* Login/Logout functionality

### 5. Multi-Purpose Room Usage

* Course bookings
* Event reservations
* Club activities
* Classroom utilization reporting

---

## Database Components (Provisional)

### Stored Procedures

* `sp_create_booking()`
* `sp_cancel_booking()`
* `sp_cancel_specific_lecture()`

### Functions

* `fn_check_room_availability()`
* `fn_is_date_cancelled()`
* `fn_get_instructor_bookings()`

### Triggers

* `trg_prevent_double_booking`
* `trg_log_booking_changes`
* `trg_validate_booking_category`

### Views

* `v_active_bookings`
* `v_available_rooms`
* `v_instructor_schedule`

---

## Expected Outcomes

* Fully functional web-based classroom booking system
* Zero double-booking through database-enforced constraints
* Seamless periodic booking with individual cancellation support
* Multi-purpose room usage support
* Comprehensive audit trail
* Real-time availability checking
* Scalable and maintainable architecture
* Secure authentication and authorization

---

## Conclusion

The Web-Based Classroom Booking and Scheduling System provides a comprehensive and structured solution for managing classroom reservations in a university environment. By leveraging PostgreSQL’s advanced database features and a Java-based three-tier architecture, the system ensures data consistency, conflict prevention, and optimized resource utilization.

The implementation demonstrates practical application of database integrity constraints, stored procedures, triggers, complex queries, and JDBC connectivity while maintaining scalability, security, and maintainability.
