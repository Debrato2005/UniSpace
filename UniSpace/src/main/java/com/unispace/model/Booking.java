package com.unispace.model;

import java.sql.Time;
import java.sql.Timestamp;

public class Booking {

    // ================= CORE DB FIELDS =================
    private int bookingId;
    private String courseId;
    private String instId;
    private String building;
    private String roomNumber;
    private String timeSlotId;
    private int semester;
    private int year;
    private String bookingType;
    private String bookingCategory;
    private Integer organizerId;
    private String status;
    private Timestamp createdAt;

    // ================= VIEW / UI FIELDS =================
    private String instructorName;
    private String courseTitle;
    private String day;
    private Time startTime;
    private Time endTime;

    // ❌ REMOVED room (derived instead)
    // private String room;

    // ✅ FIX: nullable because comes from Classroom JOIN
    private Integer capacity;

    // ================= GETTERS =================
    public int getBookingId() { return bookingId; }
    public String getCourseId() { return courseId; }
    public String getInstId() { return instId; }
    public String getBuilding() { return building; }
    public String getRoomNumber() { return roomNumber; }
    public String getTimeSlotId() { return timeSlotId; }
    public int getSemester() { return semester; }
    public int getYear() { return year; }
    public String getBookingType() { return bookingType; }
    public String getBookingCategory() { return bookingCategory; }
    public Integer getOrganizerId() { return organizerId; }
    public String getStatus() { return status; }
    public Timestamp getCreatedAt() { return createdAt; }

    public String getInstructorName() { return instructorName; }
    public String getCourseTitle() { return courseTitle; }
    public String getDay() { return day; }
    public Time getStartTime() { return startTime; }
    public Time getEndTime() { return endTime; }

    public Integer getCapacity() { return capacity; }

    // ✅ ALWAYS DERIVED (no inconsistency)
    public String getRoom() {
        return building + "-" + roomNumber;
    }

    // ================= SETTERS =================
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }
    public void setCourseId(String courseId) { this.courseId = courseId; }
    public void setInstId(String instId) { this.instId = instId; }
    public void setBuilding(String building) { this.building = building; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    public void setTimeSlotId(String timeSlotId) { this.timeSlotId = timeSlotId; }
    public void setSemester(int semester) { this.semester = semester; }
    public void setYear(int year) { this.year = year; }
    public void setBookingType(String bookingType) { this.bookingType = bookingType; }
    public void setBookingCategory(String bookingCategory) { this.bookingCategory = bookingCategory; }
    public void setOrganizerId(Integer organizerId) { this.organizerId = organizerId; }
    public void setStatus(String status) { this.status = status; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public void setInstructorName(String instructorName) { this.instructorName = instructorName; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }
    public void setDay(String day) { this.day = day; }
    public void setStartTime(Time startTime) { this.startTime = startTime; }
    public void setEndTime(Time endTime) { this.endTime = endTime; }

    public void setCapacity(Integer capacity) { this.capacity = capacity; }

    // ================= HELPER =================
    public String getFullRoom() {
        return building + "-" + roomNumber;
    }

    @Override
    public String toString() {
        return "Booking{" +
                "bookingId=" + bookingId +
                ", instId='" + instId + '\'' +
                ", courseId='" + courseId + '\'' +
                ", room='" + getFullRoom() + '\'' +
                ", semester=" + semester +
                ", year=" + year +
                ", type='" + bookingType + '\'' +
                ", category='" + bookingCategory + '\'' +
                '}';
    }
}