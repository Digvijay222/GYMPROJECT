package model;

public class ProfitSummary {
    private double totalRevenue;
    private double totalExpenses;
    private double netProfit;
    private double profitMargin;
    
    // Monthly data
    private double thisMonthRevenue;
    private double thisMonthExpenses;
    private double lastMonthRevenue;
    private double lastMonthExpenses;
    
    // Constructors
    public ProfitSummary() {}
    
    public ProfitSummary(double totalRevenue, double totalExpenses, 
                        double thisMonthRevenue, double thisMonthExpenses,
                        double lastMonthRevenue, double lastMonthExpenses) {
        this.totalRevenue = totalRevenue;
        this.totalExpenses = totalExpenses;
        this.thisMonthRevenue = thisMonthRevenue;
        this.thisMonthExpenses = thisMonthExpenses;
        this.lastMonthRevenue = lastMonthRevenue;
        this.lastMonthExpenses = lastMonthExpenses;
        calculateProfit();
    }
    
    private void calculateProfit() {
        this.netProfit = this.totalRevenue - this.totalExpenses;
        if (this.totalRevenue > 0) {
            this.profitMargin = (this.netProfit / this.totalRevenue) * 100;
        } else {
            this.profitMargin = 0;
        }
    }
    
    // Getters and Setters
    public double getTotalRevenue() { 
        return totalRevenue; 
    }
    
    public void setTotalRevenue(double totalRevenue) { 
        this.totalRevenue = totalRevenue; 
        calculateProfit();
    }
    
    public double getTotalExpenses() { 
        return totalExpenses; 
    }
    
    public void setTotalExpenses(double totalExpenses) { 
        this.totalExpenses = totalExpenses; 
        calculateProfit();
    }
    
    public double getNetProfit() { 
        return netProfit; 
    }
    
    public void setNetProfit(double netProfit) { 
        this.netProfit = netProfit; 
        calculateProfit();
    }
    
    public double getProfitMargin() { 
        return profitMargin; 
    }
    
    public void setProfitMargin(double profitMargin) { 
        this.profitMargin = profitMargin; 
    }
    
    public double getThisMonthRevenue() { 
        return thisMonthRevenue; 
    }
    
    public void setThisMonthRevenue(double thisMonthRevenue) { 
        this.thisMonthRevenue = thisMonthRevenue; 
    }
    
    public double getThisMonthExpenses() { 
        return thisMonthExpenses; 
    }
    
    public void setThisMonthExpenses(double thisMonthExpenses) { 
        this.thisMonthExpenses = thisMonthExpenses; 
    }
    
    public double getLastMonthRevenue() { 
        return lastMonthRevenue; 
    }
    
    public void setLastMonthRevenue(double lastMonthRevenue) { 
        this.lastMonthRevenue = lastMonthRevenue; 
    }
    
    public double getLastMonthExpenses() { 
        return lastMonthExpenses; 
    }
    
    public void setLastMonthExpenses(double lastMonthExpenses) { 
        this.lastMonthExpenses = lastMonthExpenses; 
    }
}