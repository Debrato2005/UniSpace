package com.unispace.model;

import java.sql.Time;

public class Booking {
    private int    bookingId;
    private String courseId;
    private String instId;
    private String building;
    private String roomNumber;
    private String timeSlotId;
    private int    semester;
    private int    year;
    private String bookingType;
    private String bookingCategory;
    private Integer organizerId;
    private String status;
    private String createdAt;
    private String instructorName;
private String courseTitle;
private String day;
private Time startTime;
private Time endTime;

    // --- Getters ---
    public int     getBookingId()       { return bookingId; }
    public String  getCourseId()        { return courseId; }
    public String  getInstId()          { return instId; }
    public String  getBuilding()        { return building; }
    public String  getRoomNumber()      { return roomNumber; }
    public String  getTimeSlotId()      { return timeSlotId; }
    public int     getSemester()        { return semester; }
    public int     getYear()            { return year; }
    public String  getBookingType()     { return bookingType; }
    public String  getBookingCategory() { return bookingCategory; }
    public Integer getOrganizerId()     { return organizerId; }
    public String  getStatus()          { return status; }
    public String  getCreatedAt()       { return createdAt; }
    

    // --- Setters ---
    public void setBookingId(int bookingId)             { this.bookingId = bookingId; }
    public void setCourseId(String courseId)            { this.courseId = courseId; }
    public void setInstId(String instId)                { this.instId = instId; }
    public void setBuilding(String building)            { this.building = building; }
    public void setRoomNumber(String roomNumber)        { this.roomNumber = roomNumber; }
    public void setTimeSlotId(String timeSlotId)        { this.timeSlotId = timeSlotId; }
    public void setSemester(int semester)               { this.semester = semester; }
    public void setYear(int year)                       { this.year = year; }
    public void setBookingType(String bookingType)      { this.bookingType = bookingType; }
    public void setBookingCategory(String bookingCategory) { this.bookingCategory = bookingCategory; }
    public void setOrganizerId(Integer organizerId)     { this.organizerId = organizerId; }
    public void setStatus(String status)                { this.status = status; }
    public void setCreatedAt(String createdAt)          { this.createdAt = createdAt; }
    
    // --- View fields (for schedule.jsp) ---

public String getInstructorName() { return instructorName; }
public void setInstructorName(String instructorName) { this.instructorName = instructorName; }

public String getCourseTitle() { return courseTitle; }
public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

public String getDay() { return day; }
public void setDay(String day) { this.day = day; }

public Time getStartTime() { return startTime; }
public void setStartTime(Time startTime) { this.startTime = startTime; }

public Time getEndTime() { return endTime; }
public void setEndTime(Time endTime) { this.endTime = endTime; }

    @Override
public String toString() {
    return "Booking{" +
            "instId='" + instId + '\'' +
            ", courseId='" + courseId + '\'' +
            ", building='" + building + '\'' +
            ", roomNumber='" + roomNumber + '\'' +
            ", timeSlotId='" + timeSlotId + '\'' +
            ", semester=" + semester +
            ", year=" + year +
            ", type='" + bookingType + '\'' +
            ", category='" + bookingCategory + '\'' +
            '}';
}
}