package main;


import java.sql.Connection;

import db.DBConnection;

public class Main {
    public static void main(String[] args) {
    	  try {
              Connection con = DBConnection.getConnection();
              System.out.println("✅ Database connected successfully!");
              System.out.println("Connection: " + con);
              con.close();
          } catch (Exception e) {
              System.out.println("❌ Database connection failed!");
              e.printStackTrace();
          }
      }
}

