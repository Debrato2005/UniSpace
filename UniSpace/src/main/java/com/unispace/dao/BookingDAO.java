package com.unispace.dao;

import com.unispace.model.Booking;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookingDAO {

    // ================================================================
    // CREATE BOOKING
    // ================================================================
    public boolean createBooking(String courseId, String instId,
                                 String building, String roomNumber,
                                 String timeSlotId, int semester, int year,
                                 String bookingType, String bookingCategory,
                                 Integer organizerId) {

        // ---------------- VALIDATION ----------------
        if ("COURSE".equalsIgnoreCase(bookingCategory) &&
                (courseId == null || courseId.trim().isEmpty())) {
            return false;
        }

        if (("EVENT".equalsIgnoreCase(bookingCategory) ||
             "CLUB".equalsIgnoreCase(bookingCategory)) &&
                organizerId == null) {
            return false;
        }

        String sql = "CALL sp_create_booking(?,?,?,?,?,?,?,?,?,?)";

        try (Connection con = DBConnection.getConnection()) {

            con.setAutoCommit(true); // ✅ ensure commit

            try (CallableStatement cs = con.prepareCall(sql)) {

                // safe null handling
                if (courseId == null || courseId.trim().isEmpty())
                    cs.setNull(1, Types.VARCHAR);
                else
                    cs.setString(1, courseId.trim());

                cs.setString(2, instId);
                cs.setString(3, building);
                cs.setString(4, roomNumber);
                cs.setString(5, timeSlotId);
                cs.setInt(6, semester);
                cs.setInt(7, year);
                cs.setString(8, bookingType);
                cs.setString(9, bookingCategory);

                if (organizerId == null)
                    cs.setNull(10, Types.INTEGER);
                else
                    cs.setInt(10, organizerId);

                cs.execute();
            }

            return true;

        } catch (SQLException e) {
            System.err.println("❌ createBooking failed: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ================================================================
    // CANCEL BOOKING
    // ================================================================
    public boolean cancelBooking(int bookingId, String changedBy) {

        String sql = "CALL sp_cancel_booking(?, ?)";

        try (Connection con = DBConnection.getConnection()) {

            con.setAutoCommit(true); // ✅ ensure commit

            try (CallableStatement cs = con.prepareCall(sql)) {

                cs.setInt(1, bookingId);
                cs.setString(2, changedBy);

                cs.execute();
            }

            return true;

        } catch (SQLException e) {
            System.err.println("❌ cancelBooking failed: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ================================================================
    // CANCEL SPECIFIC LECTURE
    // ================================================================
    public boolean cancelSpecificLecture(int bookingId, Date date, String reason) {

        String sql = "CALL sp_cancel_specific_lecture(?, ?, ?)";

        try (Connection con = DBConnection.getConnection()) {

            con.setAutoCommit(true); // ✅ ensure commit

            try (CallableStatement cs = con.prepareCall(sql)) {

                cs.setInt(1, bookingId);
                cs.setDate(2, date);
                cs.setString(3, reason);

                cs.execute();
            }

            return true;

        } catch (SQLException e) {
            System.err.println("❌ cancelSpecificLecture failed: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ================================================================
    // GET BOOKINGS
    // ================================================================
    public List<Booking> getBookingsByInstructor(String instId) {

        List<Booking> list = new ArrayList<>();

        String sql =
            "SELECT b.booking_id, " +
            "COALESCE(c.title, 'Event/Club') AS course_title, " +
            "i.name AS instructor_name, " +
            "b.inst_id, b.building, b.room_number, b.time_slot_id, " +
            "ts.day, ts.start_time, ts.end_time, " +
            "b.semester, b.year, b.booking_type, b.booking_category, b.status, " +
            "b.created_at, cl.capacity " +
            "FROM booking b " +
            "LEFT JOIN course c ON b.course_id = c.course_id " +
            "JOIN instructor i ON b.inst_id = i.id " +
            "JOIN time_slot ts ON b.time_slot_id = ts.time_slot_id " +
            "JOIN classroom cl ON b.building = cl.building AND b.room_number = cl.room_number " +
            "WHERE b.inst_id = ? AND b.status = 'ACTIVE' " +
            "ORDER BY ts.day, ts.start_time";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, instId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRowFromJoin(rs));
            }

        } catch (SQLException e) {
            System.err.println("❌ getBookingsByInstructor failed: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }

    // ================================================================
    // FILTERED BOOKINGS
    // ================================================================
    public List<Booking> getFilteredBookings(String instId,
                                             String semester,
                                             String year,
                                             String day,
                                             String category) {

        List<Booking> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT b.booking_id, " +
            "COALESCE(c.title, 'Event/Club') AS course_title, " +
            "i.name AS instructor_name, " +
            "b.inst_id, b.building, b.room_number, b.time_slot_id, " +
            "ts.day, ts.start_time, ts.end_time, " +
            "b.semester, b.year, b.booking_type, b.booking_category, b.status, " +
            "b.created_at, cl.capacity " +
            "FROM booking b " +
            "LEFT JOIN course c ON b.course_id = c.course_id " +
            "JOIN instructor i ON b.inst_id = i.id " +
            "JOIN time_slot ts ON b.time_slot_id = ts.time_slot_id " +
            "JOIN classroom cl ON b.building = cl.building AND b.room_number = cl.room_number " +
            "WHERE b.inst_id = ? AND b.status = 'ACTIVE' "
        );

        List<Object> params = new ArrayList<>();
        params.add(instId);

        if (semester != null && !semester.isEmpty()) {
            sql.append("AND b.semester = ? ");
            params.add(Integer.parseInt(semester));
        }

        if (year != null && !year.isEmpty()) {
            sql.append("AND b.year = ? ");
            params.add(Integer.parseInt(year));
        }

        if (day != null && !day.isEmpty()) {
            sql.append("AND ts.day = ? ");
            params.add(day);
        }

        if (category != null && !category.isEmpty()) {
            sql.append("AND b.booking_category = ? ");
            params.add(category);
        }

        sql.append("ORDER BY ts.day, ts.start_time");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++)
                ps.setObject(i + 1, params.get(i));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRowFromJoin(rs));
            }

        } catch (Exception e) {
            System.err.println("❌ getFilteredBookings failed: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }

    // ================================================================
    // COUNTS
    // ================================================================
    public int countTotal(String instId) {
        return getCount(
                "SELECT COUNT(*) FROM booking WHERE inst_id = ? AND status = 'ACTIVE'",
                instId);
    }

    public int countByCategory(String instId, String category) {
        return getCount(
                "SELECT COUNT(*) FROM booking WHERE inst_id = ? AND booking_category = ? AND status = 'ACTIVE'",
                instId, category);
    }

    private int getCount(String sql, String... params) {

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            for (int i = 0; i < params.length; i++)
                ps.setString(i + 1, params[i]);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }

        } catch (SQLException e) {
            System.err.println("❌ getCount failed: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    // ================================================================
    // MAPPER
    // ================================================================
    private Booking mapRowFromJoin(ResultSet rs) throws SQLException {

        Booking b = new Booking();

        b.setBookingId(rs.getInt("booking_id"));
        b.setCourseTitle(rs.getString("course_title"));
        b.setInstructorName(rs.getString("instructor_name"));
        b.setInstId(rs.getString("inst_id"));

        b.setBuilding(rs.getString("building"));
        b.setRoomNumber(rs.getString("room_number"));

        b.setTimeSlotId(rs.getString("time_slot_id"));
        b.setDay(rs.getString("day"));
        b.setStartTime(rs.getTime("start_time"));
        b.setEndTime(rs.getTime("end_time"));

        b.setSemester(rs.getInt("semester"));
        b.setYear(rs.getInt("year"));

        b.setBookingType(rs.getString("booking_type"));
        b.setBookingCategory(rs.getString("booking_category"));
        b.setStatus(rs.getString("status"));

        b.setCreatedAt(rs.getTimestamp("created_at"));
        b.setCapacity(rs.getInt("capacity"));

        return b;
    }
}