package db;

import java.sql.Connection;

import java.sql.DriverManager;
import java.sql.SQLException;


public class DBConnection {

	private static final String URL =
		    "jdbc:sqlserver://15.134.190.234:1433;databaseName=gymapplication;encrypt=false;trustServerCertificate=true";

    private static final String USER = "sa";            
    private static final String PASS = "Yas*123";   

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("SQL Server JDBC Driver not found.", e);
        }
        return DriverManager.getConnection(URL, USER, PASS);
    }
}



