package servlet;

import java.io.IOException;
import java.time.LocalDateTime;

import dao.PaymentDAO;
import dao.CustomerDAO;
import dao.MembershipPlanDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Payment;
import model.Customer;
import model.MembershipPlan;

@WebServlet("/Payment")
public class PaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private PaymentDAO paymentDAO = new PaymentDAO();
    private CustomerDAO customerDAO = new CustomerDAO();
    private MembershipPlanDAO planDAO = new MembershipPlanDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect to payment.jsp for GET requests (use absolute path including context)
        response.sendRedirect(request.getContextPath() + "/JSP/payment.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            // Get parameters from form
            String customerIdStr = request.getParameter("customerId");
            String planIdStr = request.getParameter("planId");
            String amountStr = request.getParameter("amount");
            String paymentMethod = request.getParameter("paymentMethod");
            String notes = request.getParameter("notes");
            
            // Validate required fields
            if (customerIdStr == null || customerIdStr.isEmpty() ||
                planIdStr == null || planIdStr.isEmpty() ||
                amountStr == null || amountStr.isEmpty() ||
                paymentMethod == null || paymentMethod.isEmpty()) {
                
                session.setAttribute("error", "Please fill in all required fields.");
                response.sendRedirect(request.getContextPath() + "/JSP/payment.jsp");
                return;
            }
            
            int customerId = Integer.parseInt(customerIdStr);
            int planId = Integer.parseInt(planIdStr);
            double amount = Double.parseDouble(amountStr);
            
            System.out.println("Processing payment for customer: " + customerId + 
                             ", plan: " + planId + ", amount: " + amount + 
                             ", method: " + paymentMethod);
            
            // Create Payment object
            Payment payment = new Payment();
            payment.setCustomerId(customerId);
            payment.setPlanId(planId);
            payment.setAmount(amount);
            payment.setMethod(paymentMethod);
            payment.setPaidOn(LocalDateTime.now());
            payment.setNotes(notes != null ? notes : "");
            
            // Insert payment into database
            paymentDAO.insert(payment);
            
            // Update customer's payment status and expiry date
            updateCustomerPaymentStatus(customerId, planId, amount);
            
            // Set success message
            session.setAttribute("success", "Payment successfully recorded! Member ID: " + customerId);

            System.out.println("Payment recorded successfully with ID: " + payment.getId());
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Invalid input format. Please enter valid numbers.");
            e.printStackTrace();
        } catch (Exception e) {
            session.setAttribute("error", "Error processing payment: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Redirect back to payment page (absolute path using context)
        response.sendRedirect(request.getContextPath() + "/JSP/payment.jsp");
    }
    
    private void updateCustomerPaymentStatus(int customerId, int planId, double amount) {
        try {
            // Get customer and plan details
            Customer customer = getCustomerById(customerId);
            MembershipPlan plan = planDAO.findById(planId);
            
            if (customer != null && plan != null) {
                // Update customer's payment status and expiry date
                customer.setPaymentStatus("Paid");
                customer.setPlanId(planId);
                
                // Calculate expiry date based on plan validity
                java.time.LocalDate today = java.time.LocalDate.now();
                
                if (customer.getEnrolledOn() != null) {
                    // If already enrolled, extend from current expiry
                    if (customer.getExpiryDate() != null && 
                        customer.getExpiryDate().isAfter(today)) {
                        // Extend from current expiry date
                        customer.setExpiryDate(customer.getExpiryDate().plusDays(plan.getValidityDays()));
                    } else {
                        // Start from today
                        customer.setExpiryDate(today.plusDays(plan.getValidityDays()));
                    }
                } else {
                    // First time enrollment
                    customer.setEnrolledOn(today);
                    customer.setExpiryDate(today.plusDays(plan.getValidityDays()));
                }
                
                // Update customer in database using the DAO method you added
                boolean updated = customerDAO.updateCustomer(customer);
                System.out.println("Customer updateCustomer returned: " + updated);
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Don't fail the payment if status update fails
        }
    }
    
    private Customer getCustomerById(int customerId) {
        try {
            return customerDAO.getCustomerById(customerId);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
