package com.unispace.dao;

import com.unispace.model.Room;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoomDAO {

    // ----------------------------------------------------------------
    // GET all classrooms — for dropdowns in booking form
    // ----------------------------------------------------------------
    public List<Room> getAllRooms() {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM Classroom ORDER BY building, room_number";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) list.add(mapRow(rs));

        } catch (SQLException e) {
            System.err.println("getAllRooms failed: " + e.getMessage());
        }
        return list;
    }

    // ----------------------------------------------------------------
    // CHECK availability — wraps fn_check_room_availability function
    // Returns true if the room is free for the given slot/sem/year
    // ----------------------------------------------------------------
    public boolean isRoomAvailable(String building, String roomNumber,
                                    String timeSlotId, int semester, int year) {

        String sql = "SELECT fn_check_room_availability(?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, building);
            ps.setString(2, roomNumber);
            ps.setString(3, timeSlotId);
            ps.setInt   (4, semester);
            ps.setInt   (5, year);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBoolean(1);
            }

        } catch (SQLException e) {
            System.err.println("isRoomAvailable failed: " + e.getMessage());
        }
        return false;
    }

    // ----------------------------------------------------------------
    // GET available rooms — queries v_available_rooms view
    // Optionally filter by minimum capacity
    // ----------------------------------------------------------------
    public List<Room> getAvailableRooms(int minCapacity) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM v_available_rooms WHERE capacity >= ? ORDER BY building, room_number";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, minCapacity);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }

        } catch (SQLException e) {
            System.err.println("getAvailableRooms failed: " + e.getMessage());
        }
        return list;
    }

    // ----------------------------------------------------------------
    // Private helper — maps one ResultSet row to a Room object
    // ----------------------------------------------------------------
    private Room mapRow(ResultSet rs) throws SQLException {
        Room r = new Room();
        r.setBuilding  (rs.getString("building"));
        r.setRoomNumber(rs.getString("room_number"));
        r.setCapacity  (rs.getInt   ("capacity"));
        return r;
    }
}