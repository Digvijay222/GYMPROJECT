package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import db.DBConnection;
import model.User;

public class UserDAO {

    // ---------------- LOGIN ----------------
    public User login(String usernameOrEmail, String password) {
        User user = null;
        String sql = "SELECT * FROM [User] WHERE (username = ? OR email = ?) AND password = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, usernameOrEmail);
            ps.setString(2, usernameOrEmail);
            ps.setString(3, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user = mapUser(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }

    // ---------------- REGISTER USER ----------------
    public boolean addUser(User user) {
        String sql = "INSERT INTO [User] (username, password, name, contactNumber, email) "
                   + "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getName());
            ps.setString(4, user.getContactNumber());
            ps.setString(5, user.getEmail());

            int rows = ps.executeUpdate();

            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        user.setId(rs.getInt(1)); // Set generated ID
                    }
                }
                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // ---------------- GET ALL USERS ----------------
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM [User]";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapUser(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    // ---------------- GET USER BY ID ----------------
    public User getUserById(int userId) {
        User user = null;
        String sql = "SELECT * FROM [User] WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user = mapUser(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }

    // ---------------- UPDATE USER PROFILE ----------------
    public boolean updateUser(User user) {
        String sql = "UPDATE [User] SET username = ?, name = ?, email = ?, contactNumber = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getUsername());
            ps.setString(2, user.getName());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getContactNumber());
            ps.setInt(5, user.getId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ---------------- UPDATE PASSWORD ----------------
    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE [User] SET password = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newPassword);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ---------------- VERIFY PASSWORD ----------------
    public boolean verifyPassword(int userId, String password) {
        String sql = "SELECT password FROM [User] WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String stored = rs.getString("password");
                    System.out.println("Stored: " + stored);
                    System.out.println("Entered: " + password);
                    return stored.equals(password);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // ---------------- MAP RESULTSET → USER OBJECT ----------------
    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        try { u.setUsername(rs.getString("username")); } catch (Exception ignored) {}
        try { u.setPassword(rs.getString("password")); } catch (Exception ignored) {}
        try { u.setName(rs.getString("name")); } catch (Exception ignored) {}
        try { u.setEmail(rs.getString("email")); } catch (Exception ignored) {}
        try { u.setContactNumber(rs.getString("contactNumber")); } catch (Exception ignored) {}
        return u;
    }
}
