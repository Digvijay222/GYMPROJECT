package model;

public class Equipment {

    private int id;
    private String name;
    private String description;
    private String status;
    private double cost;
    private int quantity;

    public Equipment() {
    }

    public Equipment(int id, String name, String description, String status, double cost, int quantity) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.status = status;   // ✅ correct
        this.cost = cost;       // ✅ fixed
        this.quantity = quantity;
    }

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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
    
    public double getCost() {
        return cost;
    }
    
    public void setCost(double cost) {
        this.cost = cost;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    @Override
    public String toString() {
        return "Equipment{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", status='" + status + '\'' +
                ", cost=" + cost +
                ", quantity=" + quantity +
                '}';
    }
}
