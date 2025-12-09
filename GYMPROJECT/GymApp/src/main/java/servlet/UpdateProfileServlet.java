package servlet;

import java.io.IOException;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet("/updateProfile")
public class UpdateProfileServlet extends HttpServlet {
    private UserDAO userDAO;
    
    @Override
    public void init() {
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get current session
        HttpSession session = request.getSession();
        
        // Get parameters from form
        String userIdStr = request.getParameter("userId");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String contact = request.getParameter("contact");
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        
        try {
            int userId = Integer.parseInt(userIdStr);
            
            // Verify current password
            if (!userDAO.verifyPassword(userId, currentPassword)) {
                session.setAttribute("updateError", "Current password is incorrect!");
                response.sendRedirect(request.getContextPath() + "/JSP/admin.jsp");
                return;
            }
            
            // Get user from database
            User user = userDAO.getUserById(userId);
            if (user == null) {
                session.setAttribute("updateError", "User not found!");
                response.sendRedirect(request.getContextPath() + "/JSP/admin.jsp");
                return;
            }
            
            // Update user information
            user.setName(name);
            user.setEmail(email);
            user.setContactNumber(contact); // Changed to setContactNumber()
            
            // Update user in database
            boolean profileUpdated = userDAO.updateUser(user);
            
            // Update password if provided
            boolean passwordUpdated = true;
            if (newPassword != null && !newPassword.trim().isEmpty()) {
                passwordUpdated = userDAO.updatePassword(userId, newPassword);
                user.setPassword(newPassword); // Update session object
            }
            
            if (profileUpdated && passwordUpdated) {
                // Update user in session
                session.setAttribute("loggedUser", user);
                session.setAttribute("updateSuccess", "Profile updated successfully!");
            } else {
                session.setAttribute("updateError", "Failed to update profile!");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("updateError", "Invalid user ID!");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("updateError", "An error occurred: " + e.getMessage());
        }
        
        // Redirect back to admin page
        response.sendRedirect(request.getContextPath() + "/JSP/admin.jsp");
    }
}