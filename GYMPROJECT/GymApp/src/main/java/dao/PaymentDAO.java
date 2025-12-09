package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import db.DBConnection;
import model.Payment;

public class PaymentDAO {

    // Insert payment and set generated id on the Payment object
    public boolean insert(Payment p) throws SQLException {
        String sql = "INSERT INTO Payment (customerId, planId, amount, method, paidOn, notes) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            // customerId (nullable)
            if (p.getCustomerId() == null) ps.setNull(1, Types.INTEGER);
            else ps.setInt(1, p.getCustomerId());

            // planId (nullable)
            if (p.getPlanId() == null) ps.setNull(2, Types.INTEGER);
            else ps.setInt(2, p.getPlanId());

            // amount
            ps.setDouble(3, p.getAmount());

            // method
            ps.setString(4, p.getMethod());

            // paidOn (nullable) - use setNull for proper JDBC behavior
            LocalDateTime paidOn = p.getPaidOn();
            if (paidOn == null) ps.setNull(5, Types.TIMESTAMP);
            else ps.setTimestamp(5, Timestamp.valueOf(paidOn));

            // notes (nullable / empty -> null)
            if (p.getNotes() == null || p.getNotes().isEmpty()) ps.setNull(6, Types.VARCHAR);
            else ps.setString(6, p.getNotes());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        p.setId(rs.getInt(1));
                        return true;
                    }
                }
            }
            return false;
        }
    }

    // Find all payments ordered by paidOn desc
    public List<Payment> findAll() throws SQLException {
        List<Payment> list = new ArrayList<>();
        String sql = "SELECT id, customerId, planId, amount, method, paidOn, notes FROM Payment " +
                     "ORDER BY paidOn DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Payment p = mapResultSetToPayment(rs);
                list.add(p);
            }
        }
        return list;
    }

    // Helper to map ResultSet row to Payment object (avoids repetition)
    private Payment mapResultSetToPayment(ResultSet rs) throws SQLException {
        Payment p = new Payment();
        p.setId(rs.getInt("id"));

        int cid = rs.getInt("customerId");
        if (rs.wasNull()) p.setCustomerId(null);
        else p.setCustomerId(cid);

        int pid = rs.getInt("planId");
        if (rs.wasNull()) p.setPlanId(null);
        else p.setPlanId(pid);

        p.setAmount(rs.getDouble("amount"));
        p.setMethod(rs.getString("method"));

        Timestamp ts = rs.getTimestamp("paidOn");
        p.setPaidOn(ts != null ? ts.toLocalDateTime() : null);

        p.setNotes(rs.getString("notes"));

        // NOTE: status removed — do not attempt to read/write a status field here.

        return p;
    }

    // Get total revenue (sum of amount for all payments)
    public double getTotalRevenue() throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount), 0) AS total FROM Payment";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getDouble("total");
            }
        }
        return 0.0;
    }

    // Get current month's revenue (all payments)
    public double getCurrentMonthRevenue() throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount), 0) AS total FROM Payment " +
                     "WHERE MONTH(paidOn) = MONTH(GETDATE()) " +
                     "AND YEAR(paidOn) = YEAR(GETDATE())";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getDouble("total");
        }
        return 0.0;
    }

    // Get last month's revenue (all payments)
    public double getLastMonthRevenue() throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount), 0) AS total FROM Payment " +
                     "WHERE paidOn >= DATEADD(month, -1, DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)) " +
                     "AND paidOn < DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getDouble("total");
        }
        return 0.0;
    }

    // Get monthly revenue for a specific year (returns 12 items, index 0 -> Jan)
    public List<Double> getMonthlyRevenue(int year) throws SQLException {
        List<Double> monthlyRevenue = new ArrayList<>();
        for (int i = 0; i < 12; i++) monthlyRevenue.add(0.0);

        String sql = "SELECT MONTH(paidOn) AS month, COALESCE(SUM(amount), 0) AS total " +
                     "FROM Payment " +
                     "WHERE YEAR(paidOn) = ? " +
                     "GROUP BY MONTH(paidOn) " +
                     "ORDER BY month";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int month = rs.getInt("month");
                    double total = rs.getDouble("total");
                    // month is 1-based (1 = January)
                    if (month >= 1 && month <= 12) monthlyRevenue.set(month - 1, total);
                }
            }
        }
        return monthlyRevenue;
    }

    // Get all payments (previously "completed" filter removed — this returns all)
    public List<Payment> getAllPayments() throws SQLException {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT id, customerId, planId, amount, method, paidOn, notes " +
                     "FROM Payment ORDER BY paidOn DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                payments.add(mapResultSetToPayment(rs));
            }
        }
        return payments;
    }

    // Get recent payments (limit). For SQL Server we build query with TOP since parameterizing TOP(?) may not be supported in all drivers.
    public List<Payment> findRecentPayments(int limit) throws SQLException {
        if (limit <= 0) throw new IllegalArgumentException("limit must be > 0");

        List<Payment> list = new ArrayList<>();
        // Safe because 'limit' is an int validated above (not user-supplied string).
        String sql = "SELECT TOP " + limit + " id, customerId, planId, amount, method, paidOn, notes " +
                     "FROM Payment ORDER BY paidOn DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToPayment(rs));
            }
        }
        return list;
    }
}
