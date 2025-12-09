package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import db.DBConnection;
import model.Equipment;

public class EquipmentDAO {

    // Method to insert a new equipment
    public int insert(Equipment e) {
        String sql = "INSERT INTO Equipment (name, description, status, quantity, cost) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, e.getName());
            ps.setString(2, e.getDescription());
            ps.setString(3, e.getStatus());
            ps.setInt(4, e.getQuantity());
            ps.setDouble(5, e.getCost());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int id = rs.getInt(1);
                        e.setId(id);
                        return id;
                    }
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return -1;
    }

    // Method to update existing equipment
    public boolean update(Equipment e) {
        String sql = "UPDATE Equipment SET name=?, description=?, status=?, quantity=?, cost=? WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, e.getName());
            ps.setString(2, e.getDescription());
            ps.setString(3, e.getStatus());
            ps.setInt(4, e.getQuantity());
            ps.setDouble(5, e.getCost());
            ps.setInt(6, e.getId());

            return ps.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    // Method to delete equipment by ID
    public boolean delete(int id) {
        String sql = "DELETE FROM Equipment WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    // Method to get equipment by ID
    public Equipment getById(int id) {
        String sql = "SELECT id, name, description, status, quantity, cost FROM Equipment WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Equipment e = new Equipment();
                    e.setId(rs.getInt("id"));
                    e.setName(rs.getString("name"));
                    e.setDescription(rs.getString("description"));
                    e.setStatus(rs.getString("status"));
                    e.setQuantity(rs.getInt("quantity"));
                    e.setCost(rs.getDouble("cost"));
                    return e;
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

    // Method to get all equipment
    public List<Equipment> findAll() {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT id, name, description, status, quantity, cost FROM Equipment ORDER BY name";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Equipment e = new Equipment();
                e.setId(rs.getInt("id"));
                e.setName(rs.getString("name"));
                e.setDescription(rs.getString("description"));
                e.setStatus(rs.getString("status"));
                e.setQuantity(rs.getInt("quantity"));
                e.setCost(rs.getDouble("cost"));
                list.add(e);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    // Method to search equipment by name
    public List<Equipment> searchByName(String name) {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT id, name, description, status, quantity, cost FROM Equipment WHERE name LIKE ? ORDER BY name";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, "%" + name + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Equipment e = new Equipment();
                    e.setId(rs.getInt("id"));
                    e.setName(rs.getString("name"));
                    e.setDescription(rs.getString("description"));
                    e.setStatus(rs.getString("status"));
                    e.setQuantity(rs.getInt("quantity"));
                    e.setCost(rs.getDouble("cost"));
                    list.add(e);
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    // Method to get equipment by status
    public List<Equipment> findByStatus(String status) {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT id, name, description, status, quantity, cost FROM Equipment WHERE status = ? ORDER BY name";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Equipment e = new Equipment();
                    e.setId(rs.getInt("id"));
                    e.setName(rs.getString("name"));
                    e.setDescription(rs.getString("description"));
                    e.setStatus(rs.getString("status"));
                    e.setQuantity(rs.getInt("quantity"));
                    e.setCost(rs.getDouble("cost"));
                    list.add(e);
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    // Method to get total count of equipment
    public int getTotalCount() {
        String sql = "SELECT COUNT(*) as total FROM Equipment";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return 0;
    }

    // Method to get equipment with pagination
    public List<Equipment> findWithPagination(int start, int pageSize) {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT id, name, description, status, quantity, cost FROM Equipment ORDER BY name LIMIT ?, ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, start);
            ps.setInt(2, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Equipment e = new Equipment();
                    e.setId(rs.getInt("id"));
                    e.setName(rs.getString("name"));
                    e.setDescription(rs.getString("description"));
                    e.setStatus(rs.getString("status"));
                    e.setQuantity(rs.getInt("quantity"));
                    e.setCost(rs.getDouble("cost"));
                    list.add(e);
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    // Method to check if equipment name already exists
    public boolean existsByName(String name) {
        String sql = "SELECT COUNT(*) FROM Equipment WHERE name = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    // Method to update equipment quantity
    public boolean updateQuantity(int id, int quantity) {
        String sql = "UPDATE Equipment SET quantity=? WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, quantity);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    // Method to update equipment status
    public boolean updateStatus(int id, String status) {
        String sql = "UPDATE Equipment SET status=? WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    // Method to get equipment statistics
    public List<Object[]> getEquipmentStats() {
        List<Object[]> stats = new ArrayList<>();
        String sql = "SELECT status, COUNT(*) as count, SUM(quantity) as total FROM Equipment GROUP BY status";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Object[] stat = new Object[3];
                stat[0] = rs.getString("status");
                stat[1] = rs.getInt("count");
                stat[2] = rs.getInt("total");
                stats.add(stat);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return stats;
    }
    
    // New method to get total inventory value
    public double getTotalInventoryValue() {
        String sql = "SELECT SUM(cost * quantity) as total_value FROM Equipment";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getDouble("total_value");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return 0.0;
    }
}