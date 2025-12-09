package model;

import java.time.LocalDate;

public class Customer {

    private int id;
    private String name;
    private String mobileNumber;
    private String email;
    private String gender;
    private LocalDate dateOfBirth;
    private String address;
    private float height;
    private double weight;
    private Integer planId;
    private LocalDate enrolledOn;
    private LocalDate expiryDate;
    private String paymentStatus;
    private String medicalNotes;
    private String attendanceHistory;
    private String timeSlot;   
    private String planType;        // NEW FIELD: e.g., "Basic", "Premium", "VIP", "Student"
   

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getMobileNumber() {
        return mobileNumber;
    }

    public void setMobileNumber(String mobileNumber) {
        this.mobileNumber = mobileNumber;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(LocalDate dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public float getHeight() {
        return height;
    }

    public void setHeight(float height) {
        this.height = height;
    }

    public double getWeight() {
        return weight;
    }

    public void setWeight(double weight) {
        this.weight = weight;
    }

    public Integer getPlanId() {
        return planId;
    }

    public void setPlanId(Integer planId) {
        this.planId = planId;
    }

    public LocalDate getEnrolledOn() {
        return enrolledOn;
    }

    public void setEnrolledOn(LocalDate enrolledOn) {
        this.enrolledOn = enrolledOn;
    }

    public LocalDate getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(LocalDate string) {
        this.expiryDate = string;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getMedicalNotes() {
        return medicalNotes;
    }

    public void setMedicalNotes(String medicalNotes) {
        this.medicalNotes = medicalNotes;
    }

    public String getAttendanceHistory() {
        return attendanceHistory;
    }

    public void setAttendanceHistory(String attendanceHistory) {
        this.attendanceHistory = attendanceHistory;
    }

    public String getTimeSlot() {
        return timeSlot;
    }

    public void setTimeSlot(String timeSlot) {
        this.timeSlot = timeSlot;
    }

    public String getPlanType() { return planType; }
    public void setPlanType(String planType) { this.planType = planType; }
    
    
    @Override
    public String toString() {
        return "Customer{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", mobileNumber='" + mobileNumber + '\'' +
                ", email='" + email + '\'' +
                ", gender='" + gender + '\'' +
                ", dateOfBirth=" + dateOfBirth +
                ", address='" + address + '\'' +
                ", height=" + height +
                ", weight=" + weight +
                ", planId=" + planId +
                ", enrolledOn=" + enrolledOn +
                ", expiryDate=" + expiryDate +
                ", paymentStatus='" + paymentStatus + '\'' +
                ", medicalNotes='" + medicalNotes + '\'' +
                ", attendanceHistory='" + attendanceHistory + '\'' +
                ", timeSlot='" + timeSlot + '\'' +
                ", planType='" + planType + '\'' +
              
                '}';
    }

    
}
