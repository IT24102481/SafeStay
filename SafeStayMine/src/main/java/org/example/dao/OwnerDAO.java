package org.example.dao;

import org.example.model.Owner;
import org.example.model.Hostel;
import java.sql.*;

public class OwnerDAO {

    private Connection getConnection() throws SQLException {
        String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=false;trustServerCertificate=true;";
        String dbUser = "admin";
        String dbPass = "123456";
        return DriverManager.getConnection(dbURL, dbUser, dbPass);
    }

    // Get Owner by userId
    public Owner getOwnerByUserId(String userId) {
        Owner owner = null;
        String sql = "SELECT * FROM owner WHERE userId = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, userId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                owner = new Owner();
                owner.setUserId(rs.getString("userId"));
                owner.setFullName(rs.getString("fullName"));
                owner.setEmail(rs.getString("email"));
                owner.setPhone(rs.getString("phone"));
                owner.setAddress(rs.getString("address"));
                owner.setCompanyName(rs.getString("company_name"));
                owner.setCreatedAt(rs.getTimestamp("created_at"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return owner;
    }

    // Get Hostel by ownerId
    public Hostel getHostelByOwnerId(String ownerId) {
        Hostel hostel = null;
        String sql = "SELECT * FROM hostel WHERE ownerId = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, ownerId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                hostel = new Hostel();
                hostel.setId(rs.getInt("id"));
                hostel.setOwnerId(rs.getString("ownerId"));
                hostel.setHostelName(rs.getString("hostel_name"));
                hostel.setAddress(rs.getString("address"));
                hostel.setCity(rs.getString("city"));
                hostel.setTotalRooms(rs.getInt("total_rooms"));
                hostel.setAvailableRooms(rs.getInt("available_rooms"));
                hostel.setContactNumber(rs.getString("contact_number"));
                hostel.setEmail(rs.getString("email"));
                hostel.setWardenName(rs.getString("warden_name"));
                hostel.setWardenPhone(rs.getString("warden_phone"));
                hostel.setStatus(rs.getString("status"));
                hostel.setCreatedAt(rs.getTimestamp("created_at"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return hostel;
    }

    // Get Dashboard Statistics
    public int getTotalStudents() {
        String sql = "SELECT COUNT(*) as total FROM users WHERE role = 'Student'";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getTotalStaff() {
        String sql = "SELECT COUNT(*) as total FROM staff_details";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public double getMonthlyRevenue() {
        String sql = "SELECT ISNULL(SUM(amount), 0) as total FROM payment " +
                "WHERE MONTH(payment_date) = MONTH(GETDATE()) " +
                "AND YEAR(payment_date) = YEAR(GETDATE())";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {
            if (rs.next()) return rs.getDouble("total");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getPendingMaintenance() {
        String sql = "SELECT COUNT(*) as total FROM maintenance WHERE status = 'Pending'";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}