package model;

import java.time.LocalDateTime;

public class Expenses {

    private int id;
    private String category;
    private double amount;
    private LocalDateTime expenseDate;
    private String notes;

    public Expenses() {
    }

    public Expenses(int id, String category, double amount, LocalDateTime expenseDate, String notes) {
        this.id = id;
        this.category = category;
        this.amount = amount;
        this.expenseDate = expenseDate;
        this.notes = notes;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public LocalDateTime getExpenseDate() {
        return expenseDate;
    }

    public void setExpenseDate(LocalDateTime expenseDate) {
        this.expenseDate = expenseDate;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    @Override
    public String toString() {
        return "Expenses{" +
                "id=" + id +
                ", category='" + category + '\'' +
                ", amount=" + amount +
                ", expenseDate=" + expenseDate +
                ", notes='" + notes + '\'' +
                '}';
    }
}
