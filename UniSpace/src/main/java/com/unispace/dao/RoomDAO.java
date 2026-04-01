package com.unispace.dao;

import com.unispace.model.Room;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoomDAO {

    // ================================================================
    // GET ALL ROOMS
    // ================================================================
    public List<Room> getAllRooms() {

        List<Room> rooms = new ArrayList<>();

        String sql = "SELECT building, room_number, capacity " +
                     "FROM classroom ORDER BY building, room_number";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                rooms.add(mapRow(rs));
            }

        } catch (SQLException e) {
            System.err.println("❌ getAllRooms failed");
            e.printStackTrace();
        }

        return rooms;
    }

    // ================================================================
    // CHECK ROOM AVAILABILITY (CRITICAL FIX: CASTING)
    // ================================================================
    public boolean isRoomAvailable(String building, String roomNumber,
                                  String timeSlotId, int semester, int year) {

        String sql =
            "SELECT fn_check_room_availability(" +
            "?::text, ?::text, ?::text, ?::int, ?::int)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, building);
            ps.setString(2, roomNumber);
            ps.setString(3, timeSlotId);
            ps.setInt(4, semester);
            ps.setInt(5, year);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBoolean(1);
                }
            }

        } catch (SQLException e) {
            System.err.println("❌ isRoomAvailable failed");
            e.printStackTrace();
        }

        return false;
    }

    // ================================================================
    // GET AVAILABLE ROOMS (ACTUAL AVAILABILITY FILTER)
    // ================================================================
    public List<Room> getAvailableRooms(String timeSlotId,
                                        int semester,
                                        int year) {

        List<Room> rooms = new ArrayList<>();

        String sql =
            "SELECT building, room_number, capacity " +
            "FROM classroom " +
            "WHERE fn_check_room_availability(" +
            "building::text, room_number::text, ?::text, ?::int, ?::int) = true " +
            "ORDER BY building, room_number";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, timeSlotId);
            ps.setInt(2, semester);
            ps.setInt(3, year);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rooms.add(mapRow(rs));
                }
            }

        } catch (SQLException e) {
            System.err.println("❌ getAvailableRooms failed");
            e.printStackTrace();
        }

        return rooms;
    }

    // ================================================================
    // GET ROOMS BY CAPACITY (NOT AVAILABILITY)
    // ================================================================
    public List<Room> getRoomsByCapacity(int minCapacity) {

        List<Room> rooms = new ArrayList<>();

        String sql =
            "SELECT building, room_number, capacity " +
            "FROM classroom " +
            "WHERE capacity >= ? " +
            "ORDER BY building, room_number";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, minCapacity);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rooms.add(mapRow(rs));
                }
            }

        } catch (SQLException e) {
            System.err.println("❌ getRoomsByCapacity failed");
            e.printStackTrace();
        }

        return rooms;
    }

    // ================================================================
    // OPTIONAL: GET SINGLE ROOM
    // ================================================================
    public Room getRoom(String building, String roomNumber) {

        String sql =
            "SELECT building, room_number, capacity " +
            "FROM classroom WHERE building = ? AND room_number = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, building);
            ps.setString(2, roomNumber);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }

        } catch (SQLException e) {
            System.err.println("❌ getRoom failed");
            e.printStackTrace();
        }

        return null;
    }

    // ================================================================
    // MAPPER
    // ================================================================
    private Room mapRow(ResultSet rs) throws SQLException {

        Room r = new Room();
        r.setBuilding(rs.getString("building"));
        r.setRoomNumber(rs.getString("room_number"));
        r.setCapacity(rs.getInt("capacity"));

        return r;
    }
}