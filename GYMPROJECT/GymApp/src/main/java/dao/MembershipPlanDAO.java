package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import db.DBConnection;
import model.MembershipPlan;

public class MembershipPlanDAO {
    
    // Database table and column names
    private static final String TABLE_NAME = "MembershipPlan";
    private static final String COLUMN_ID = "id";
    private static final String COLUMN_PLAN_NAME = "planName";
    private static final String COLUMN_VALIDITY_DAYS = "validityDays";
    private static final String COLUMN_PRICE = "price";
    
    // SQL Queries
    private static final String INSERT_SQL = "INSERT INTO " + TABLE_NAME + " (" + 
            COLUMN_PLAN_NAME + ", " + COLUMN_VALIDITY_DAYS + ", " + COLUMN_PRICE + 
            ") VALUES (?, ?, ?)";
    
    private static final String UPDATE_SQL = "UPDATE " + TABLE_NAME + " SET " + 
            COLUMN_PLAN_NAME + " = ?, " + COLUMN_VALIDITY_DAYS + " = ?, " + 
            COLUMN_PRICE + " = ? WHERE " + COLUMN_ID + " = ?";
    
    private static final String DELETE_SQL = "DELETE FROM " + TABLE_NAME + 
            " WHERE " + COLUMN_ID + " = ?";
    
    private static final String SELECT_ALL_SQL = "SELECT * FROM " + TABLE_NAME + 
            " ORDER BY " + COLUMN_ID;
    
    private static final String SELECT_BY_ID_SQL = "SELECT * FROM " + TABLE_NAME + 
            " WHERE " + COLUMN_ID + " = ?";
    
    private static final String SELECT_BY_NAME_SQL = "SELECT * FROM " + TABLE_NAME + 
            " WHERE " + COLUMN_PLAN_NAME + " = ?";
    
    private static final String CHECK_EXISTS_SQL = "SELECT COUNT(*) FROM " + TABLE_NAME + 
            " WHERE " + COLUMN_ID + " = ?";

    // INSERT a new plan
    public boolean insert(MembershipPlan plan) throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet generatedKeys = null;
        
        try {
            connection = DBConnection.getConnection();
            preparedStatement = connection.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS);
            
            preparedStatement.setString(1, plan.getPlanName());
            preparedStatement.setInt(2, plan.getValidityDays());
            preparedStatement.setDouble(3, plan.getPrice());
            
            int affectedRows = preparedStatement.executeUpdate();
            
            if (affectedRows > 0) {
                // Get the generated ID
                generatedKeys = preparedStatement.getGeneratedKeys();
                if (generatedKeys.next()) {
                    int generatedId = generatedKeys.getInt(1);
                    plan.setId(generatedId);
                    System.out.println("Plan inserted successfully with ID: " + generatedId);
                    return true;
                }
            }
            return false;
            
        } catch (SQLException e) {
            System.err.println("Error inserting plan: " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            closeResources(connection, preparedStatement, generatedKeys);
        }
    }

    // UPDATE an existing plan
    public boolean update(MembershipPlan plan) throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        
        try {
            connection = DBConnection.getConnection();
            preparedStatement = connection.prepareStatement(UPDATE_SQL);
            
            preparedStatement.setString(1, plan.getPlanName());
            preparedStatement.setInt(2, plan.getValidityDays());
            preparedStatement.setDouble(3, plan.getPrice());
            preparedStatement.setInt(4, plan.getId());
            
            int affectedRows = preparedStatement.executeUpdate();
            
            if (affectedRows > 0) {
                System.out.println("Plan updated successfully. ID: " + plan.getId());
                return true;
            } else {
                System.out.println("No plan found with ID: " + plan.getId());
                return false;
            }
            
        } catch (SQLException e) {
            System.err.println("Error updating plan with ID " + plan.getId() + ": " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            closeResources(connection, preparedStatement, null);
        }
    }

    // DELETE a plan by ID
    public boolean delete(int planId) throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        
        try {
            connection = DBConnection.getConnection();
            preparedStatement = connection.prepareStatement(DELETE_SQL);
            
            preparedStatement.setInt(1, planId);
            
            int affectedRows = preparedStatement.executeUpdate();
            
            if (affectedRows > 0) {
                System.out.println("Plan deleted successfully. ID: " + planId);
                return true;
            } else {
                System.out.println("No plan found with ID: " + planId);
                return false;
            }
            
        } catch (SQLException e) {
            System.err.println("Error deleting plan with ID " + planId + ": " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            closeResources(connection, preparedStatement, null);
        }
    }

    // GET ALL plans
    public List<MembershipPlan> findAll() throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        List<MembershipPlan> plans = new ArrayList<>();
        
        try {
            connection = DBConnection.getConnection();
            preparedStatement = connection.prepareStatement(SELECT_ALL_SQL);
            resultSet = preparedStatement.executeQuery();
            
            while (resultSet.next()) {
                MembershipPlan plan = extractPlanFromResultSet(resultSet);
                plans.add(plan);
            }
            
            System.out.println("Retrieved " + plans.size() + " plans from database.");
            return plans;
            
        } catch (SQLException e) {
            System.err.println("Error retrieving all plans: " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            closeResources(connection, preparedStatement, resultSet);
        }
    }

    // GET plan by ID
    public MembershipPlan findById(int planId) throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        
        try {
            connection = DBConnection.getConnection();
            preparedStatement = connection.prepareStatement(SELECT_BY_ID_SQL);
            preparedStatement.setInt(1, planId);
            resultSet = preparedStatement.executeQuery();
            
            if (resultSet.next()) {
                MembershipPlan plan = extractPlanFromResultSet(resultSet);
                System.out.println("Found plan with ID: " + planId);
                return plan;
            } else {
                System.out.println("No plan found with ID: " + planId);
                return null;
            }
            
        } catch (SQLException e) {
            System.err.println("Error finding plan by ID " + planId + ": " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            closeResources(connection, preparedStatement, resultSet);
        }
    }

    // GET plan by name (for checking duplicates)
    public MembershipPlan findByName(String planName) throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        
        try {
            connection = DBConnection.getConnection();
            preparedStatement = connection.prepareStatement(SELECT_BY_NAME_SQL);
            preparedStatement.setString(1, planName);
            resultSet = preparedStatement.executeQuery();
            
            if (resultSet.next()) {
                return extractPlanFromResultSet(resultSet);
            }
            return null;
            
        } catch (SQLException e) {
            System.err.println("Error finding plan by name " + planName + ": " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            closeResources(connection, preparedStatement, resultSet);
        }
    }

    // CHECK if plan exists by ID
    public boolean exists(int planId) throws SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        
        try {
            connection = DBConnection.getConnection();
            preparedStatement = connection.prepareStatement(CHECK_EXISTS_SQL);
            preparedStatement.setInt(1, planId);
            resultSet = preparedStatement.executeQuery();
            
            if (resultSet.next()) {
                int count = resultSet.getInt(1);
                return count > 0;
            }
            return false;
            
        } catch (SQLException e) {
            System.err.println("Error checking if plan exists with ID " + planId + ": " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            closeResources(connection, preparedStatement, resultSet);
        }
    }

    // Helper method to extract plan from ResultSet
    private MembershipPlan extractPlanFromResultSet(ResultSet resultSet) throws SQLException {
        MembershipPlan plan = new MembershipPlan();
        plan.setId(resultSet.getInt(COLUMN_ID));
        plan.setPlanName(resultSet.getString(COLUMN_PLAN_NAME));
        plan.setValidityDays(resultSet.getInt(COLUMN_VALIDITY_DAYS));
        plan.setPrice(resultSet.getDouble(COLUMN_PRICE));
        return plan;
    }

    // Helper method to close resources
    private void closeResources(Connection connection, PreparedStatement preparedStatement, ResultSet resultSet) {
        try {
            if (resultSet != null && !resultSet.isClosed()) {
                resultSet.close();
            }
        } catch (SQLException e) {
            System.err.println("Error closing ResultSet: " + e.getMessage());
        }
        
        try {
            if (preparedStatement != null && !preparedStatement.isClosed()) {
                preparedStatement.close();
            }
        } catch (SQLException e) {
            System.err.println("Error closing PreparedStatement: " + e.getMessage());
        }
        
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException e) {
            System.err.println("Error closing Connection: " + e.getMessage());
        }
    }

    // Test method to verify database connection and table
    public boolean testConnection() {
        Connection connection = null;
        
        try {
            connection = DBConnection.getConnection();
            if (connection != null && !connection.isClosed()) {
                System.out.println("Database connection successful!");
                return true;
            }
            return false;
        } catch (SQLException e) {
            System.err.println("Database connection failed: " + e.getMessage());
            return false;
        } finally {
            try {
                if (connection != null && !connection.isClosed()) {
                    connection.close();
                }
            } catch (SQLException e) {
                System.err.println("Error closing connection: " + e.getMessage());
            }
        }
    }
    
    // Create table if not exists (for testing)
    public void createTableIfNotExists() throws SQLException {
        Connection connection = null;
        Statement statement = null;
        
        try {
            connection = DBConnection.getConnection();
            statement = connection.createStatement();
            
            String createTableSQL = "IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='" + TABLE_NAME + "' AND xtype='U') " +
                                   "CREATE TABLE " + TABLE_NAME + " (" +
                                   COLUMN_ID + " INT PRIMARY KEY IDENTITY(1,1), " +
                                   COLUMN_PLAN_NAME + " NVARCHAR(100) NOT NULL, " +
                                   COLUMN_VALIDITY_DAYS + " INT NOT NULL, " +
                                   COLUMN_PRICE + " DECIMAL(10,2) NOT NULL, " +
                                   "createdDate DATETIME DEFAULT GETDATE())";
            
            statement.executeUpdate(createTableSQL);
            System.out.println("Table checked/created successfully.");
            
        } catch (SQLException e) {
            System.err.println("Error creating table: " + e.getMessage());
            throw e;
        } finally {
            try {
                if (statement != null && !statement.isClosed()) {
                    statement.close();
                }
            } catch (SQLException e) {
                System.err.println("Error closing statement: " + e.getMessage());
            }
            
            try {
                if (connection != null && !connection.isClosed()) {
                    connection.close();
                }
            } catch (SQLException e) {
                System.err.println("Error closing connection: " + e.getMessage());
            }
        }
    }
}