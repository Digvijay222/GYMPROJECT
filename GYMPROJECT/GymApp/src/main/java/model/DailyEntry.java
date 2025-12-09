package model;


public class DailyEntry {

    private int serialNo;      // 1,2,3...
    private String name;       // customer name
    private String memberId;   // formatted customer id (001,002,...)
    private String loginTime;  // dummy time
    private boolean biometric; // true = ✅

    public DailyEntry(int serialNo, String name, String memberId, String loginTime, boolean biometric) {
        this.serialNo = serialNo;
        this.name = name;
        this.memberId = memberId;
        this.loginTime = loginTime;
        this.biometric = biometric;
    }

    public int getSerialNo() {
        return serialNo;
    }

    public String getName() {
        return name;
    }

    public String getMemberId() {
        return memberId;
    }

    public String getLoginTime() {
        return loginTime;
    }

    public boolean isBiometric() {
        return biometric;
    }
}
