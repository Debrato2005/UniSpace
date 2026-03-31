package com.unispace.dao;

import com.unispace.model.Booking;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookingDAO {

    public boolean createBooking(String courseId, String instId,
                                  String building, String roomNumber,
                                  String timeSlotId, int semester, int year,
                                  String bookingType, String bookingCategory,
                                  Integer organizerId) {

        String sql = "{CALL sp_create_booking(?,?,?,?,?,?,?,?,?,?)}";

        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {

            if (courseId != null) cs.setString(1, courseId);
            else                  cs.setNull(1, Types.VARCHAR);

            cs.setString(2, instId);
            cs.setString(3, building);
            cs.setString(4, roomNumber);
            cs.setString(5, timeSlotId);
            cs.setInt   (6, semester);
            cs.setInt   (7, year);
            cs.setString(8, bookingType);
            cs.setString(9, bookingCategory);

            if (organizerId != null) cs.setInt(10, organizerId);
            else                     cs.setNull(10, Types.INTEGER);

            cs.execute();
            return true;

        } catch (SQLException e) {
            System.err.println("createBooking failed: " + e.getMessage());
            return false;
        }
    }
    public boolean cancelBooking(int bookingId, String changedBy) {
        String sql = "{CALL sp_cancel_booking(?, ?)}";

        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt   (1, bookingId);
            cs.setString(2, changedBy);
            cs.execute();
            return true;

        } catch (SQLException e) {
            System.err.println("cancelBooking failed: " + e.getMessage());
            return false;
        }
    }

    public boolean cancelSpecificLecture(int bookingId, Date date, String reason) {
        String sql = "{CALL sp_cancel_specific_lecture(?, ?, ?)}";

        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt   (1, bookingId);
            cs.setDate  (2, date);
            cs.setString(3, reason);
            cs.execute();
            return true;

        } catch (SQLException e) {
            System.err.println("cancelSpecificLecture failed: " + e.getMessage());
            return false;
        }
    }
    public List<Booking> getActiveBookings() {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT * FROM v_active_bookings";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }

        } catch (SQLException e) {
            System.err.println("getActiveBookings failed: " + e.getMessage());
        }
        return list;
    }

    public List<Booking> getBookingsByInstructor(String instId) {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT * FROM v_instructor_schedule WHERE inst_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, instId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowFromView(rs));
                }
            }

        } catch (SQLException e) {
            System.err.println("getBookingsByInstructor failed: " + e.getMessage());
        }
        return list;
    }

    public Booking getBookingById(int bookingId) {
        String sql = "SELECT * FROM Booking WHERE booking_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }

        } catch (SQLException e) {
            System.err.println("getBookingById failed: " + e.getMessage());
        }
        return null;
    }

    private Booking mapRow(ResultSet rs) throws SQLException {
        Booking b = new Booking();
        b.setBookingId      (rs.getInt   ("booking_id"));
        b.setCourseId       (rs.getString("course_id"));
        b.setInstId         (rs.getString("inst_id"));
        b.setBuilding       (rs.getString("building"));
        b.setRoomNumber     (rs.getString("room_number"));
        b.setTimeSlotId     (rs.getString("time_slot_id"));
        b.setSemester       (rs.getInt   ("semester"));
        b.setYear           (rs.getInt   ("year"));
        b.setBookingType    (rs.getString("booking_type"));
        b.setBookingCategory(rs.getString("booking_category"));
        b.setStatus         (rs.getString("status"));
        int orgId = rs.getInt("organizer_id");
        b.setOrganizerId(rs.wasNull() ? null : orgId);
        return b;
    }

    private Booking mapRowFromView(ResultSet rs) throws SQLException {
    Booking b = new Booking();

    b.setInstId(rs.getString("inst_id"));
    b.setBuilding(rs.getString("building"));
    b.setRoomNumber(rs.getString("room_number"));
    b.setDay(rs.getString("day"));
    b.setStartTime(rs.getTime("start_time"));
    b.setEndTime(rs.getTime("end_time"));
    b.setSemester(rs.getInt("semester"));
    b.setYear(rs.getInt("year"));
    b.setBookingType(rs.getString("booking_type"));
    b.setBookingCategory(rs.getString("booking_category"));
    b.setCourseTitle(rs.getString("course_title"));

    return b;
    }
    public static void main(String[] args) {

    BookingDAO dao = new BookingDAO();

    System.out.println("=== TESTING getBookingsByInstructor ===");

    String testInstId = "CS001"; // change if needed

    List<Booking> list = dao.getBookingsByInstructor(testInstId);

    System.out.println("Total bookings: " + list.size());

    for (Booking b : list) {
        System.out.println("------------");
        System.out.println("Course Title: " + b.getCourseTitle());
        System.out.println("Day: " + b.getDay());
        System.out.println("Start Time: " + b.getStartTime());
        System.out.println("End Time: " + b.getEndTime());
        System.out.println("Room: " + b.getBuilding() + "-" + b.getRoomNumber());
        System.out.println("Semester: " + b.getSemester());
        System.out.println("Year: " + b.getYear());
        System.out.println("Type: " + b.getBookingType());
        System.out.println("Category: " + b.getBookingCategory());
    }

    System.out.println("=== DONE ===");
}
}
