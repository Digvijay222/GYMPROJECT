package model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Attendance {
    private int id;
    private int customerId;
    private String customerName;
    private String phoneNumber;
    private LocalDateTime loginTime;
    private String status; // "Present" or "Absent"
    
    // Constructors
    public Attendance() {}
    
    public Attendance(int customerId, String customerName, String phoneNumber, 
                     LocalDateTime loginTime, String status) {
        this.customerId = customerId;
        this.customerName = customerName;
        this.phoneNumber = phoneNumber;
        this.loginTime = loginTime;
        this.status = status;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }
    
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    
    public LocalDateTime getLoginTime() { return loginTime; }
    public void setLoginTime(LocalDateTime loginTime) { this.loginTime = loginTime; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    // Helper method to format time
    public String getFormattedLoginTime() {
        if (loginTime == null) return "N/A";
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("hh:mm a");
        return loginTime.format(formatter);
    }
}