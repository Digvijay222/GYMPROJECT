package model;

public class MembershipPlan {

    private int id;
    private String planName;
    private int validityDays;
    private double price;

    public MembershipPlan() {
    }

    public MembershipPlan(int id, String planName, int validityDays, double price) {
        this.id = id;
        this.planName = planName;
        this.validityDays = validityDays;
        this.price = price;
    }

    public MembershipPlan(String planName, int validityDays, double price) {
        this.planName = planName;
        this.validityDays = validityDays;
        this.price = price;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getPlanName() {
        return planName;
    }

    public void setPlanName(String planName) {
        this.planName = planName;
    }

    public int getValidityDays() {
        return validityDays;
    }

    public void setValidityDays(int validityDays) {
        this.validityDays = validityDays;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    @Override
    public String toString() {
        return "MembershipPlan{" +
                "id=" + id +
                ", planName='" + planName + '\'' +
                ", validityDays=" + validityDays +
                ", price=" + price +
                '}';
    }
}
