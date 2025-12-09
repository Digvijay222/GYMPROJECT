package model;

import java.time.LocalDateTime;

public class Payment {
    private int id;
    private Integer customerId;
    private Integer planId;
    private double amount;
    private String method;
    private LocalDateTime paidOn;
    private String notes;
    

    public Payment() {
    }

    public Payment(int id, Integer customerId, Integer planId,
                   double amount, String method,
                   LocalDateTime paidOn, String notes, String status) {
        this.id = id;
        this.customerId = customerId;
        this.planId = planId;
        this.amount = amount;
        this.method = method;
        this.paidOn = paidOn;
        this.notes = notes;
       
    }

   

    // ... rest of your existing getters and setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
    }

    public Integer getPlanId() {
        return planId;
    }

    public void setPlanId(Integer planId) {
        this.planId = planId;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public String getMethod() {
        return method;
    }

    public void setMethod(String method) {
        this.method = method;
    }

    public LocalDateTime getPaidOn() {
        return paidOn;
    }

    public void setPaidOn(LocalDateTime paidOn) {
        this.paidOn = paidOn;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    @Override
    public String toString() {
        return "Payment{" +
                "id=" + id +
                ", customerId=" + customerId +
                ", planId=" + planId +
                ", amount=" + amount +
                ", method='" + method + '\'' +
                ", paidOn=" + paidOn +
                ", notes='" + notes + '\'' +
                '}';
    }
}