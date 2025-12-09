package servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import dao.MembershipPlanDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.MembershipPlan;

@WebServlet("/membershipServlet")
public class MembershipServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MembershipPlanDAO membershipPlanDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        membershipPlanDAO = new MembershipPlanDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if we're coming from an edit link
        String editParam = request.getParameter("edit");
        
        try {
            // Load all plans from database
            List<MembershipPlan> plans = membershipPlanDAO.findAll();
            request.setAttribute("membershipPlans", plans);
            
            // If we're editing a specific plan, get it and set as attribute
            if (editParam != null && !editParam.isEmpty()) {
                try {
                    int planId = Integer.parseInt(editParam);
                    MembershipPlan planToEdit = membershipPlanDAO.findById(planId);
                    if (planToEdit != null) {
                        request.setAttribute("planToEdit", planToEdit);
                    }
                } catch (NumberFormatException e) {
                    // Invalid ID, ignore
                    e.printStackTrace();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            
            // Forward to membership page
            request.getRequestDispatcher("/JSP/membership.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading membership plans: " + e.getMessage());
            request.getRequestDispatcher("/JSP/membership.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("save".equals(action)) {
            savePlan(request, response);
        } else if ("update".equals(action)) {
            updatePlan(request, response);
        } else if ("delete".equals(action)) {
            deletePlan(request, response);
        } else {
            // Default action - load plans
            doGet(request, response);
        }
    }

    private void savePlan(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // Get form parameters
            String planName = request.getParameter("planName");
            String validityStr = request.getParameter("validity");
            String amountStr = request.getParameter("amount");
            
            System.out.println("Saving plan - Name: " + planName + ", Validity: " + validityStr + ", Amount: " + amountStr);
            
            // Validate input
            if (planName == null || planName.trim().isEmpty() ||
                validityStr == null || validityStr.trim().isEmpty() ||
                amountStr == null || amountStr.trim().isEmpty()) {
                
                request.setAttribute("errorMessage", "All fields are required!");
                doGet(request, response);
                return;
            }
            
            // Parse values
            int validity = Integer.parseInt(validityStr);
            double amount = Double.parseDouble(amountStr);
            
            // Create and save plan
            MembershipPlan plan = new MembershipPlan();
            plan.setPlanName(planName);
            plan.setValidityDays(validity);
            plan.setPrice(amount);
            
            boolean saved = membershipPlanDAO.insert(plan);
            
            if (saved) {
                request.setAttribute("successMessage", "Plan saved successfully!");
                System.out.println("Plan saved successfully with ID: " + plan.getId());
            } else {
                request.setAttribute("errorMessage", "Failed to save plan!");
                System.out.println("Failed to save plan");
            }
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Invalid number format. Please enter valid numbers!");
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        
        // Reload the page with updated data
        doGet(request, response);
    }

    private void updatePlan(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // Get form parameters
            String planIdStr = request.getParameter("planId");
            String planName = request.getParameter("planName");
            String validityStr = request.getParameter("validity");
            String amountStr = request.getParameter("amount");
            
            System.out.println("Updating plan - ID: " + planIdStr + ", Name: " + planName + 
                               ", Validity: " + validityStr + ", Amount: " + amountStr);
            
            // Validate input
            if (planIdStr == null || planIdStr.trim().isEmpty() ||
                planName == null || planName.trim().isEmpty() ||
                validityStr == null || validityStr.trim().isEmpty() ||
                amountStr == null || amountStr.trim().isEmpty()) {
                
                request.setAttribute("errorMessage", "All fields are required for update!");
                doGet(request, response);
                return;
            }
            
            // Parse values
            int planId = Integer.parseInt(planIdStr);
            int validity = Integer.parseInt(validityStr);
            double amount = Double.parseDouble(amountStr);
            
            // Create and update plan
            MembershipPlan plan = new MembershipPlan();
            plan.setId(planId);
            plan.setPlanName(planName);
            plan.setValidityDays(validity);
            plan.setPrice(amount);
            
            boolean updated = membershipPlanDAO.update(plan);
            
            if (updated) {
                request.setAttribute("successMessage", "Plan updated successfully!");
                System.out.println("Plan updated successfully for ID: " + planId);
            } else {
                request.setAttribute("errorMessage", "Failed to update plan! Plan may not exist.");
                System.out.println("Failed to update plan with ID: " + planId);
            }
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Invalid number format. Please enter valid numbers!");
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        
        // Reload the page with updated data
        doGet(request, response);
    }

    private void deletePlan(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            String planIdStr = request.getParameter("planId");
            
            System.out.println("Deleting plan - ID: " + planIdStr);
            
            if (planIdStr == null || planIdStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Plan ID is required for deletion!");
                doGet(request, response);
                return;
            }
            
            int planId = Integer.parseInt(planIdStr);
            boolean deleted = membershipPlanDAO.delete(planId);
            
            if (deleted) {
                request.setAttribute("successMessage", "Plan deleted successfully!");
                System.out.println("Plan deleted successfully for ID: " + planId);
            } else {
                request.setAttribute("errorMessage", "Failed to delete plan! Plan may not exist.");
                System.out.println("Failed to delete plan with ID: " + planId);
            }
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Invalid plan ID!");
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        
        // Reload the page with updated data
        doGet(request, response);
    }
}