package com.unispace.dao;

import com.unispace.model.Instructor;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InstructorDAO {

    // ================= GET BY ID =================
    public Instructor getById(String instId) {

        String sql = "SELECT id, name, dept_name FROM instructor WHERE id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, instId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }

        } catch (SQLException e) {
            System.err.println("❌ getById failed");
            e.printStackTrace();
        }

        return null;
    }

    // ================= GET ALL =================
    public List<Instructor> getAll() {

        List<Instructor> list = new ArrayList<>();
        String sql = "SELECT id, name, dept_name FROM instructor ORDER BY name";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }

        } catch (SQLException e) {
            System.err.println("❌ getAll failed");
            e.printStackTrace();
        }

        return list;
    }

    // ================= LOGIN =================
    public Instructor validateInstructor(String instId) {

        String sql = "SELECT id, name, dept_name FROM instructor WHERE id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, instId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }

        } catch (SQLException e) {
            System.err.println("❌ validateInstructor failed");
            e.printStackTrace();
        }

        return null;
    }

    // ================= MAPPER =================
    private Instructor mapRow(ResultSet rs) throws SQLException {
        Instructor i = new Instructor();
        i.setId(rs.getString("id"));          // safe (Postgres lowercase)
        i.setName(rs.getString("name"));
        i.setDeptName(rs.getString("dept_name"));
        return i;
    }
}