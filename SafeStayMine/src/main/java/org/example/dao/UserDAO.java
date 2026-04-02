package org.example.dao;

import org.example.model.User;
import java.sql.*;

public class UserDAO {
    // Change to SQL Server connection
    private String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=false;trustServerCertificate=true;";
    private String dbUser = "admin";
    private String dbPass = "123456";

    public User login(String userId, String password) {
        User user = null;
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            Connection con = DriverManager.getConnection(dbURL, dbUser, dbPass);

            // Users table and student_details/staff_details table Join
            String sql = "SELECT u.userId, u.username, u.role, " +
                    "COALESCE(s.fullName, st.fullName) as fullName " +
                    "FROM users u " +
                    "LEFT JOIN student_details s ON u.userId = s.userId " +
                    "LEFT JOIN staff_details st ON u.userId = st.userId " +
                    "WHERE u.userId = ? AND u.password = ?";

            PreparedStatement pst = con.prepareStatement(sql);
            pst.setString(1, userId);
            pst.setString(2, password);

            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                user = new User();
                user.setUserId(rs.getString("userId"));
                user.setUsername(rs.getString("username"));
                user.setRole(rs.getString("role"));
                user.setFullName(rs.getString("fullName"));
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return user;
    }
}