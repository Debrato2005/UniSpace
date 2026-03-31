package com.unispace.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL      = "jdbc:postgresql://localhost:5432/classroom_booking";
    private static final String USERNAME = "postgres";
    private static final String PASSWORD = "#Bengali2356";

    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(
                "PostgreSQL JDBC driver not found. Check pom.xml dependency.", e
            );
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }
}
