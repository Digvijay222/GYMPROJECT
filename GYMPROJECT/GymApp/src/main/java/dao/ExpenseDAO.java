package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Expenses;

public class ExpenseDAO {
    private Connection connection;
    
    public ExpenseDAO(Connection connection) {
        this.connection = connection;
    }
    
    // Get all expenses
    public List<Expenses> getAllExpenses() throws SQLException {
        List<Expenses> expenses = new ArrayList<>();
        String sql = "SELECT * FROM expenses ORDER BY expenseDate DESC";
        
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Expenses expense = new Expenses();
                expense.setId(rs.getInt("id"));
                expense.setCategory(rs.getString("category"));
                expense.setAmount(rs.getDouble("amount"));
                expense.setExpenseDate(rs.getTimestamp("expenseDate").toLocalDateTime());
                expense.setNotes(rs.getString("notes"));
                expenses.add(expense);
            }
        }
        return expenses;
    }
    
    // Get total expenses
    public double getTotalExpenses() throws SQLException {
        String sql = "SELECT SUM(amount) as total FROM expenses";
        
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getDouble("total");
            }
        }
        return 0;
    }
    
    // Get current month expenses
    public double getCurrentMonthExpenses() throws SQLException {
        String sql = "SELECT SUM(amount) as total FROM expenses " +
                    "WHERE MONTH(expenseDate) = MONTH(GETDATE()) " +
                    "AND YEAR(expenseDate) = YEAR(GETDATE())";
        
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getDouble("total");
            }
        }
        return 0;
    }
    
    // Get last month expenses
    public double getLastMonthExpenses() throws SQLException {
        String sql = "SELECT SUM(amount) as total FROM expenses " +
                    "WHERE expenseDate >= DATEADD(month, -1, DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)) " +
                    "AND expenseDate < DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)";
        
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getDouble("total");
            }
        }
        return 0;
    }
    
    // Get monthly expenses for a specific year
    public List<Double> getMonthlyExpenses(int year) throws SQLException {
        List<Double> monthlyExpenses = new ArrayList<>();
        for (int i = 0; i < 12; i++) {
            monthlyExpenses.add(0.0);
        }
        
        String sql = "SELECT MONTH(expenseDate) as month, SUM(amount) as total " +
                    "FROM expenses " +
                    "WHERE YEAR(expenseDate) = ? " +
                    "GROUP BY MONTH(expenseDate) " +
                    "ORDER BY month";
        
        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setInt(1, year);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                int month = rs.getInt("month");
                double total = rs.getDouble("total");
                monthlyExpenses.set(month - 1, total);
            }
        }
        return monthlyExpenses;
    }
}