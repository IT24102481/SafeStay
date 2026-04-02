package org.example.dao;

import org.example.model.Attendance;
import java.sql.*;
import java.util.*;

public class AttendanceDAO {

    private Connection getConnection() throws SQLException {
        String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=false;trustServerCertificate=true;";
        String dbUser = "admin";
        String dbPass = "123456";
        return DriverManager.getConnection(dbURL, dbUser, dbPass);
    }

    // ============ 1. CHECK-IN (FOR ANY DATE) ============
    public boolean checkIn(String studentId, String status, String markedBy, String remarks) {
        // Check if already checked in TODAY
        if (isCheckedInToday(studentId)) {
            return false;
        }

        String sql = "INSERT INTO attendance (studentId, attendance_date, check_in_time, status, marked_by, remarks) " +
                "VALUES (?, CAST(GETDATE() AS DATE), GETDATE(), ?, ?, ?)";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            pst.setString(2, status);
            pst.setString(3, markedBy);
            pst.setString(4, remarks != null ? remarks : "");

            int result = pst.executeUpdate();
            System.out.println("✅ Check-in at " + new Timestamp(System.currentTimeMillis()) + " for: " + studentId);
            return result > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ============ 2. CHECK-OUT (FOR ANY DATE) ============
    public boolean checkOut(String studentId) {
        // Check if checked in today
        if (!isCheckedInToday(studentId)) {
            System.out.println("❌ No check-in record for today: " + studentId);
            return false;
        }

        // Check if already checked out
        if (isCheckedOutToday(studentId)) {
            System.out.println("❌ Already checked out today: " + studentId);
            return false;
        }

        String sql = "UPDATE attendance SET check_out_time = GETDATE() " +
                "WHERE studentId = ? AND attendance_date = CAST(GETDATE() AS DATE)";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            int result = pst.executeUpdate();

            if (result > 0) {
                System.out.println("✅ Check-out at " + new Timestamp(System.currentTimeMillis()) + " for: " + studentId);
                return true;
            }
            return false;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ============ 3. GET ATTENDANCE FOR SPECIFIC DATE ============
    public Attendance getAttendanceForDate(String studentId, String date) {
        String sql = "SELECT a.*, u.fullName as studentName FROM attendance a " +
                "JOIN users u ON a.studentId = u.userId " +
                "WHERE a.studentId = ? AND a.attendance_date = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            pst.setString(2, date);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                Attendance a = new Attendance();
                a.setId(rs.getInt("id"));
                a.setStudentId(rs.getString("studentId"));
                a.setStudentName(rs.getString("studentName"));
                a.setAttendanceDate(rs.getDate("attendance_date"));
                a.setCheckInTime(rs.getTimestamp("check_in_time"));
                a.setCheckOutTime(rs.getTimestamp("check_out_time"));
                a.setStatus(rs.getString("status"));
                a.setRemarks(rs.getString("remarks"));
                return a;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ============ 4. GET ALL ATTENDANCE FOR STUDENT ============
    public List<Attendance> getAllAttendance(String studentId) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, u.fullName as studentName FROM attendance a " +
                "JOIN users u ON a.studentId = u.userId " +
                "WHERE a.studentId = ? " +
                "ORDER BY a.attendance_date DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            while (rs.next()) {
                Attendance a = new Attendance();
                a.setId(rs.getInt("id"));
                a.setStudentId(rs.getString("studentId"));
                a.setStudentName(rs.getString("studentName"));
                a.setAttendanceDate(rs.getDate("attendance_date"));
                a.setCheckInTime(rs.getTimestamp("check_in_time"));
                a.setCheckOutTime(rs.getTimestamp("check_out_time"));
                a.setStatus(rs.getString("status"));
                a.setRemarks(rs.getString("remarks"));
                list.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ============ 5. GET ATTENDANCE FOR DATE RANGE ============
    public List<Attendance> getAttendanceInRange(String studentId, int days) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, u.fullName as studentName FROM attendance a " +
                "JOIN users u ON a.studentId = u.userId " +
                "WHERE a.studentId = ? " +
                "AND a.attendance_date >= DATEADD(day, -?, GETDATE()) " +
                "ORDER BY a.attendance_date DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            pst.setInt(2, days);
            ResultSet rs = pst.executeQuery();

            while (rs.next()) {
                Attendance a = new Attendance();
                a.setId(rs.getInt("id"));
                a.setStudentId(rs.getString("studentId"));
                a.setStudentName(rs.getString("studentName"));
                a.setAttendanceDate(rs.getDate("attendance_date"));
                a.setCheckInTime(rs.getTimestamp("check_in_time"));
                a.setCheckOutTime(rs.getTimestamp("check_out_time"));
                a.setStatus(rs.getString("status"));
                a.setRemarks(rs.getString("remarks"));
                list.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ============ 6. GET STATISTICS ============
    public Map<String, Object> getStats(String studentId, int days) {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT " +
                "COUNT(*) as total_days, " +
                "SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) as present_days, " +
                "SUM(CASE WHEN status = 'Late' THEN 1 ELSE 0 END) as late_days, " +
                "SUM(CASE WHEN status = 'Absent' THEN 1 ELSE 0 END) as absent_days " +
                "FROM attendance WHERE studentId = ? " +
                "AND attendance_date >= DATEADD(day, -?, GETDATE())";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            pst.setInt(2, days);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                int total = rs.getInt("total_days");
                int present = rs.getInt("present_days");
                stats.put("totalDays", total);
                stats.put("presentDays", present);
                stats.put("lateDays", rs.getInt("late_days"));
                stats.put("absentDays", rs.getInt("absent_days"));
                stats.put("percentage", total > 0 ? (present * 100 / total) : 0);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    // ============ 7. CHECK IF CHECKED IN TODAY ============
    public boolean isCheckedInToday(String studentId) {
        String sql = "SELECT COUNT(*) as count FROM attendance WHERE studentId = ? AND attendance_date = CAST(GETDATE() AS DATE)";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                return rs.getInt("count") > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ============ 8. CHECK IF CHECKED OUT TODAY ============
    public boolean isCheckedOutToday(String studentId) {
        String sql = "SELECT check_out_time FROM attendance WHERE studentId = ? AND attendance_date = CAST(GETDATE() AS DATE)";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                return rs.getTimestamp("check_out_time") != null;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ============ 9. GET TODAY'S CHECK-IN TIME ============
    public String getCheckInTime(String studentId) {
        String sql = "SELECT check_in_time FROM attendance WHERE studentId = ? AND attendance_date = CAST(GETDATE() AS DATE)";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                Timestamp ts = rs.getTimestamp("check_in_time");
                if (ts != null) {
                    return new java.text.SimpleDateFormat("hh:mm a").format(ts);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ============ 10. GET TODAY'S CHECK-OUT TIME ============
    public String getCheckOutTime(String studentId) {
        String sql = "SELECT check_out_time FROM attendance WHERE studentId = ? AND attendance_date = CAST(GETDATE() AS DATE)";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                Timestamp ts = rs.getTimestamp("check_out_time");
                if (ts != null) {
                    return new java.text.SimpleDateFormat("hh:mm a").format(ts);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}