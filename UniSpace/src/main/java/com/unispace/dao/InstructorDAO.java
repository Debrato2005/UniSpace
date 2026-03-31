package com.unispace.dao;

import com.unispace.model.Instructor;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InstructorDAO {

    // ----------------------------------------------------------------
    // GET instructor by ID — used after login to load profile
    // ----------------------------------------------------------------
    public Instructor getById(String instId) {
        String sql = "SELECT * FROM Instructor WHERE ID = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, instId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }

        } catch (SQLException e) {
            System.err.println("getById failed: " + e.getMessage());
        }
        return null;
    }

    // ----------------------------------------------------------------
    // GET all instructors — for dropdowns in booking form
    // ----------------------------------------------------------------
    public List<Instructor> getAll() {
        List<Instructor> list = new ArrayList<>();
        String sql = "SELECT * FROM Instructor ORDER BY name";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) list.add(mapRow(rs));

        } catch (SQLException e) {
            System.err.println("getAll instructors failed: " + e.getMessage());
        }
        return list;
    }

    // ----------------------------------------------------------------
    // LOGIN check — verifies inst_id exists (extend with password later)
    // ----------------------------------------------------------------
    public boolean validateInstructor(String instId) {
        String sql = "SELECT 1 FROM Instructor WHERE ID = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, instId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (SQLException e) {
            System.err.println("validateInstructor failed: " + e.getMessage());
        }
        return false;
    }

    // ----------------------------------------------------------------
    // Private helper — maps one ResultSet row to an Instructor object
    // ----------------------------------------------------------------
    private Instructor mapRow(ResultSet rs) throws SQLException {
        Instructor i = new Instructor();
        i.setId      (rs.getString("id"));
        i.setName    (rs.getString("name"));
        i.setDeptName(rs.getString("dept_name"));
        return i;
    }
}