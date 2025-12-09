package dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import db.DBConnection;
import model.Attendance;

public class AttendanceDAO {
    
    // Mark attendance
    public boolean markAttendance(int customerId, String customerName, 
                                  String mobileNumber, LocalDateTime loginTime, 
                                  String status) {
        String sql = "INSERT INTO attendance " +
                     "(customer_id, customer_name, phone_number, attendance_date, login_time, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, customerId);
            pstmt.setString(2, customerName);
            pstmt.setString(3, mobileNumber);
            pstmt.setDate(4, Date.valueOf(LocalDate.now())); // 👈 attendance_date
            
            if (loginTime != null) {
                pstmt.setTimestamp(5, Timestamp.valueOf(loginTime));
            } else {
                pstmt.setNull(5, java.sql.Types.TIMESTAMP);
            }
            
            pstmt.setString(6, status);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Get attendance for today
    public List<Attendance> getTodayAttendance() {
        List<Attendance> attendanceList = new ArrayList<>();
        String sql = "SELECT * FROM attendance WHERE attendance_date = ? ORDER BY login_time DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setDate(1, Date.valueOf(LocalDate.now()));  // 👈 attendance_date
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Attendance attendance = new Attendance();
                attendance.setId(rs.getInt("id"));
                attendance.setCustomerId(rs.getInt("customer_id"));
                attendance.setCustomerName(rs.getString("customer_name"));
                attendance.setPhoneNumber(rs.getString("phone_number"));
                
                Timestamp loginTimeStamp = rs.getTimestamp("login_time");
                if (loginTimeStamp != null) {
                    attendance.setLoginTime(loginTimeStamp.toLocalDateTime());
                } else {
                    attendance.setLoginTime(null);
                }
                attendance.setStatus(rs.getString("status"));
                
                attendanceList.add(attendance);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return attendanceList;
    }
    
    // Check if customer already marked attendance today
    public boolean isAttendanceMarkedToday(int customerId) {
        String sql = "SELECT COUNT(*) FROM attendance " +
                     "WHERE customer_id = ? AND attendance_date = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, customerId);
            pstmt.setDate(2, Date.valueOf(LocalDate.now()));  // 👈 attendance_date
            
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get customer attendance history
    public List<Attendance> getCustomerAttendance(int customerId) {
        List<Attendance> attendanceList = new ArrayList<>();
        String sql = "SELECT * FROM attendance " +
                     "WHERE customer_id = ? " +
                     "ORDER BY attendance_date DESC, login_time DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, customerId);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Attendance attendance = new Attendance();
                attendance.setId(rs.getInt("id"));
                attendance.setCustomerId(rs.getInt("customer_id"));
                attendance.setCustomerName(rs.getString("customer_name"));
                attendance.setPhoneNumber(rs.getString("phone_number"));
                
                Timestamp loginTimeStamp = rs.getTimestamp("login_time");
                if (loginTimeStamp != null) {
                    attendance.setLoginTime(loginTimeStamp.toLocalDateTime());
                } else {
                    attendance.setLoginTime(null);
                }
                attendance.setStatus(rs.getString("status"));
                
                attendanceList.add(attendance);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return attendanceList;
    }
}
