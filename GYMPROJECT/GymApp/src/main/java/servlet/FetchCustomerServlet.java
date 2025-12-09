package servlet;

import java.io.IOException;
import java.io.PrintWriter;

import dao.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Customer;

@WebServlet("/fetchCustomer")
public class FetchCustomerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String mobileNumber = request.getParameter("mobileNumber");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try (PrintWriter out = response.getWriter()) {
            if (mobileNumber == null || mobileNumber.trim().isEmpty()) {
                out.write("{\"error\":\"Mobile number is required\"}");
                return;
            }
            
            CustomerDAO customerDAO = new CustomerDAO();
            Customer customer = customerDAO.findByMobileNumber(mobileNumber.trim());
            
            if (customer == null) {
                out.write("{\"error\":\"No customer found with this mobile number\"}");
            } else {
                // Check if membership is active
                boolean isActive = true;
                String membershipStatus = "Active";
                
                if (customer.getExpiryDate() != null && 
                    customer.getExpiryDate().isBefore(java.time.LocalDate.now())) {
                    isActive = false;
                    membershipStatus = "Expired";
                }
                
                // Build JSON response safely
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"id\":").append(customer.getId()).append(",");
                json.append("\"name\":\"").append(escapeJson(customer.getName())).append("\",");
                json.append("\"memberId\":\"").append(String.format("%03d", customer.getId())).append("\",");
                json.append("\"email\":\"").append(escapeJson(customer.getEmail() != null ? customer.getEmail() : "")).append("\",");
                json.append("\"membershipStatus\":\"").append(membershipStatus).append("\",");
                json.append("\"isActive\":").append(isActive).append(",");
                json.append("\"expiryDate\":\"").append(customer.getExpiryDate() != null ? customer.getExpiryDate().toString() : "").append("\"");
                json.append("}");
                
                out.write(json.toString());
                System.out.println("Sent customer data: " + json.toString());
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"error\":\"Server error: " + e.getMessage() + "\"}");
        }
    }
    
    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
}