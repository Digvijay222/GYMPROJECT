package dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import db.DBConnection;
import model.Customer;

public class CustomerDAO {

    // -----------------------
    // INSERT
    // -----------------------
    public boolean addCustomer(Customer customer) {
        String sql = "INSERT INTO Customer " +
                "(name, mobileNumber, email, gender, dateOfBirth, address, height, weight, " +
                "planId, enrolledOn, expiryDate, paymentStatus, medicalNotes, attendanceHistory, " +
                "timeSlot, planType) " +                         // ✅ added planType column
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, customer.getName());
            ps.setString(2, customer.getMobileNumber());
            ps.setString(3, customer.getEmail());
            ps.setString(4, customer.getGender());

            if (customer.getDateOfBirth() != null)
                ps.setDate(5, Date.valueOf(customer.getDateOfBirth()));
            else
                ps.setNull(5, Types.DATE);

            ps.setString(6, customer.getAddress());
            ps.setFloat(7, customer.getHeight());
            ps.setDouble(8, customer.getWeight());

            if (customer.getPlanId() != null) ps.setInt(9, customer.getPlanId());
            else ps.setNull(9, Types.INTEGER);

            if (customer.getEnrolledOn() != null)
                ps.setDate(10, Date.valueOf(customer.getEnrolledOn()));
            else
                ps.setNull(10, Types.DATE);

            if (customer.getExpiryDate() != null)
                ps.setDate(11, Date.valueOf(customer.getExpiryDate()));
            else
                ps.setNull(11, Types.DATE);

            ps.setString(12, customer.getPaymentStatus());
            ps.setString(13, customer.getMedicalNotes());
            ps.setString(14, customer.getAttendanceHistory());
            ps.setString(15, customer.getTimeSlot());
            ps.setString(16, customer.getPlanType());           // ✅ set planType

            int rows = ps.executeUpdate();

            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        customer.setId(rs.getInt(1));
                    }
                }
            }

            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // -----------------------
    // GET ALL (non-paginated)
    // -----------------------
    public List<Customer> getAllCustomers() {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT * FROM Customer ORDER BY enrolledOn DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                customers.add(mapResultSetToCustomer(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return customers;
    }

    // Backwards-compatible alias
    public List<Customer> findAll() {
        return getAllCustomers();
    }

    // -----------------------
    // GET BY ID
    // -----------------------
    public Customer getCustomerById(int customerId) {
        Customer c = null;
        String sql = "SELECT * FROM Customer WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) c = mapResultSetToCustomer(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return c;
    }

    // -----------------------
    // UPDATE (full)
    // -----------------------
    public boolean updateCustomer(Customer customer) {
        String sql = "UPDATE Customer SET " +
                "name = ?, mobileNumber = ?, email = ?, gender = ?, " +
                "dateOfBirth = ?, address = ?, height = ?, weight = ?, planId = ?, " +
                "enrolledOn = ?, expiryDate = ?, paymentStatus = ?, medicalNotes = ?, " +
                "attendanceHistory = ?, timeSlot = ?, planType = ? " +   // ✅ update planType
                "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, customer.getName());
            ps.setString(2, customer.getMobileNumber());
            ps.setString(3, customer.getEmail());
            ps.setString(4, customer.getGender());

            if (customer.getDateOfBirth() != null) ps.setDate(5, Date.valueOf(customer.getDateOfBirth()));
            else ps.setNull(5, Types.DATE);

            ps.setString(6, customer.getAddress());
            ps.setFloat(7, customer.getHeight());
            ps.setDouble(8, customer.getWeight());

            if (customer.getPlanId() != null) ps.setInt(9, customer.getPlanId());
            else ps.setNull(9, Types.INTEGER);

            if (customer.getEnrolledOn() != null) ps.setDate(10, Date.valueOf(customer.getEnrolledOn()));
            else ps.setNull(10, Types.DATE);

            if (customer.getExpiryDate() != null) ps.setDate(11, Date.valueOf(customer.getExpiryDate()));
            else ps.setNull(11, Types.DATE);

            ps.setString(12, customer.getPaymentStatus());
            ps.setString(13, customer.getMedicalNotes());
            ps.setString(14, customer.getAttendanceHistory());
            ps.setString(15, customer.getTimeSlot());
            ps.setString(16, customer.getPlanType());            // ✅ planType
            ps.setInt(17, customer.getId());

            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // -----------------------
    // UPDATE PLAN / PAYMENT INFO
    // -----------------------
    public boolean updateCustomerPlan(Customer customer) {
        String sql = "UPDATE Customer SET planId = ?, enrolledOn = ?, expiryDate = ?, paymentStatus = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (customer.getPlanId() != null) ps.setInt(1, customer.getPlanId());
            else ps.setNull(1, Types.INTEGER);

            if (customer.getEnrolledOn() != null) ps.setDate(2, Date.valueOf(customer.getEnrolledOn()));
            else ps.setNull(2, Types.DATE);

            if (customer.getExpiryDate() != null) ps.setDate(3, Date.valueOf(customer.getExpiryDate()));
            else ps.setNull(3, Types.DATE);

            ps.setString(4, customer.getPaymentStatus());
            ps.setInt(5, customer.getId());

            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // -----------------------
    // DELETE
    // -----------------------
    public boolean deleteCustomer(int customerId) {
        String sql = "DELETE FROM Customer WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // -----------------------
    // SEARCH (non-paginated)
    // -----------------------
    public List<Customer> searchCustomers(String searchTerm) {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT * FROM Customer WHERE name LIKE ? OR CAST(id AS VARCHAR(10)) LIKE ? OR mobileNumber LIKE ? ORDER BY enrolledOn DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String likeTerm = "%" + searchTerm + "%";
            ps.setString(1, likeTerm);
            ps.setString(2, likeTerm);
            ps.setString(3, likeTerm);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) customers.add(mapResultSetToCustomer(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return customers;
    }

    // -----------------------
    // PAGINATION HELPERS (SQL Server OFFSET FETCH style)
    // -----------------------
    public int getTotalCustomers() {
        String sql = "SELECT COUNT(*) as total FROM Customer";
        int total = 0;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) total = rs.getInt("total");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }

    public int getTotalCustomersBySearch(String searchTerm) {
        String sql = "SELECT COUNT(*) as total FROM Customer WHERE name LIKE ? OR CAST(id AS VARCHAR(10)) LIKE ? OR mobileNumber LIKE ?";
        int total = 0;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String like = "%" + searchTerm + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) total = rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }

    public List<Customer> getCustomersPaginated(int page, int pageSize) {
        List<Customer> customers = new ArrayList<>();
        if (page < 1) page = 1;
        int offset = (page - 1) * pageSize;

        String sql = "SELECT * FROM Customer ORDER BY id OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, offset);
            ps.setInt(2, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) customers.add(mapResultSetToCustomer(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return customers;
    }

    public List<Customer> getCustomersBySearchPaginated(String searchTerm, int page, int pageSize) {
        List<Customer> customers = new ArrayList<>();
        if (page < 1) page = 1;
        int offset = (page - 1) * pageSize;

        String sql = "SELECT * FROM Customer WHERE name LIKE ? OR CAST(id AS VARCHAR(10)) LIKE ? OR mobileNumber LIKE ? " +
                "ORDER BY id OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String like = "%" + searchTerm + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            ps.setInt(4, offset);
            ps.setInt(5, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) customers.add(mapResultSetToCustomer(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return customers;
    }

    // -----------------------
    // SPECIAL QUERIES
    // -----------------------
    public List<Customer> getActiveCustomers() {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT * FROM Customer WHERE expiryDate >= GETDATE() AND paymentStatus = 'Paid' ORDER BY enrolledOn DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) customers.add(mapResultSetToCustomer(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return customers;
    }

    public List<Customer> getUnpaidCustomers() {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT * FROM Customer WHERE paymentStatus IN ('Unpaid', 'Pending') ORDER BY enrolledOn DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) customers.add(mapResultSetToCustomer(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return customers;
    }

    public List<Customer> getExpiringSoonCustomers() {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT * FROM Customer WHERE expiryDate BETWEEN GETDATE() AND DATEADD(day, 7, GETDATE()) ORDER BY expiryDate ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) customers.add(mapResultSetToCustomer(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return customers;
    }

    public boolean updatePaymentStatus(int customerId, String paymentStatus) {
        String sql = "UPDATE Customer SET paymentStatus = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, paymentStatus);
            ps.setInt(2, customerId);

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Customer> getCustomersByPlanId(int planId) {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT * FROM Customer WHERE planId = ? ORDER BY enrolledOn DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, planId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) customers.add(mapResultSetToCustomer(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return customers;
    }

    public List<Customer> getCustomersByTimeSlot(String timeSlot) {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT * FROM Customer WHERE timeSlot = ? ORDER BY name ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, timeSlot);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) customers.add(mapResultSetToCustomer(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return customers;
    }

    public boolean customerExists(String email, String mobileNumber) {
        String sql = "SELECT COUNT(*) as count FROM Customer WHERE email = ? OR mobileNumber = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, mobileNumber);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("count") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Integer getCustomerIdByEmail(String email) {
        String sql = "SELECT id FROM Customer WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("id");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Integer getCustomerIdByMobile(String mobileNumber) {
        String sql = "SELECT id FROM Customer WHERE mobileNumber = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, mobileNumber);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("id");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // -----------------------
    // STATISTICS
    // -----------------------
    public Object[] getCustomerStatistics() {
        Object[] stats = new Object[4];
        String sql = "SELECT " +
                "(SELECT COUNT(*) FROM Customer) as total, " +
                "(SELECT COUNT(*) FROM Customer WHERE paymentStatus = 'Paid') as paid, " +
                "(SELECT COUNT(*) FROM Customer WHERE paymentStatus IN ('Unpaid', 'Pending')) as unpaid, " +
                "(SELECT COUNT(*) FROM Customer WHERE expiryDate >= GETDATE()) as active";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                stats[0] = rs.getInt("total");
                stats[1] = rs.getInt("paid");
                stats[2] = rs.getInt("unpaid");
                stats[3] = rs.getInt("active");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    // -----------------------
    // RESULTSET -> OBJECT MAPPING
    // -----------------------
    private Customer mapResultSetToCustomer(ResultSet rs) throws SQLException {
        Customer customer = new Customer();

        customer.setId(rs.getInt("id"));
        customer.setName(rs.getString("name"));
        customer.setMobileNumber(rs.getString("mobileNumber"));
        customer.setEmail(rs.getString("email"));
        customer.setGender(rs.getString("gender"));

        Date dob = rs.getDate("dateOfBirth");
        if (dob != null) customer.setDateOfBirth(dob.toLocalDate());

        customer.setAddress(rs.getString("address"));
        customer.setHeight(rs.getFloat("height"));
        customer.setWeight(rs.getDouble("weight"));

        int planId = rs.getInt("planId");
        customer.setPlanId(rs.wasNull() ? null : planId);

        Date enrolledOn = rs.getDate("enrolledOn");
        if (enrolledOn != null) customer.setEnrolledOn(enrolledOn.toLocalDate());

        Date expiry = rs.getDate("expiryDate");
        if (expiry != null) customer.setExpiryDate(expiry.toLocalDate());

        customer.setPaymentStatus(rs.getString("paymentStatus"));
        customer.setMedicalNotes(rs.getString("medicalNotes"));
        customer.setAttendanceHistory(rs.getString("attendanceHistory"));
        customer.setTimeSlot(rs.getString("timeSlot"));
        customer.setPlanType(rs.getString("planType"));      // ✅ read planType

        return customer;
    }

    public Customer findByMobileNumber(String mobileNumber) {
        String sql = "SELECT * FROM Customer WHERE mobileNumber = ?";   // ✅ table name capitalized for consistency

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, mobileNumber);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                Customer customer = new Customer();
                customer.setId(rs.getInt("id"));
                customer.setName(rs.getString("name"));
                customer.setMobileNumber(rs.getString("mobileNumber"));
                customer.setEmail(rs.getString("email"));
                customer.setGender(rs.getString("gender"));
                customer.setDateOfBirth(rs.getDate("dateOfBirth") != null ?
                        rs.getDate("dateOfBirth").toLocalDate() : null);
                customer.setAddress(rs.getString("address"));
                customer.setHeight(rs.getFloat("height"));
                customer.setWeight(rs.getDouble("weight"));
                int planId = rs.getInt("planId");
                customer.setPlanId(rs.wasNull() ? null : planId);
                customer.setEnrolledOn(rs.getDate("enrolledOn") != null ?
                        rs.getDate("enrolledOn").toLocalDate() : null);
                customer.setExpiryDate(rs.getDate("expiryDate") != null ?
                        rs.getDate("expiryDate").toLocalDate() : null);
                customer.setPaymentStatus(rs.getString("paymentStatus"));
                customer.setMedicalNotes(rs.getString("medicalNotes"));
                customer.setTimeSlot(rs.getString("timeSlot"));
                customer.setPlanType(rs.getString("planType"));   // ✅ planType here too
                return customer;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
