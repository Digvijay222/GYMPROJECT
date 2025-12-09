package servlet;

import java.io.IOException;
import java.time.LocalDate;

import dao.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Customer;

@WebServlet("/register")
public class RegistrationServlet extends HttpServlet {

    private CustomerDAO customerDAO;

    @Override
    public void init() {
        customerDAO = new CustomerDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // ---------------- FORM PARAMETERS ----------------
        String name      = request.getParameter("name");
        String dobStr    = request.getParameter("dob");
        String email     = request.getParameter("email");
        String contact   = request.getParameter("contact");
        String gender    = request.getParameter("gender");
        String heightStr = request.getParameter("height");
        String weightStr = request.getParameter("weight");
        String address   = request.getParameter("address");
        String planIdStr = request.getParameter("plan");
        String medical   = request.getParameter("medical");

        // ---------------- BASIC VALIDATION ----------------
        if (name == null || name.trim().isEmpty() ||
            dobStr == null || dobStr.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            contact == null || contact.trim().isEmpty()) {

            request.setAttribute("error", "Please fill in all required fields.");
            request.getRequestDispatcher("/JSP/registration.jsp").forward(request, response);
            return;
        }

        try {
            Customer customer = new Customer();

            // ---------------- BASIC DATA ----------------
            customer.setName(name.trim());
            customer.setEmail(email.trim());
            customer.setMobileNumber(contact.trim());
            customer.setGender(gender != null ? gender : "male");
            customer.setAddress(address != null ? address.trim() : "");

            // ---------------- DATE OF BIRTH ----------------
            try {
                customer.setDateOfBirth(LocalDate.parse(dobStr));
            } catch (Exception e) {
                customer.setDateOfBirth(LocalDate.now().minusYears(18));
            }

            // ---------------- HEIGHT & WEIGHT ----------------
            customer.setHeight(
                (heightStr != null && !heightStr.isEmpty()) ?
                Float.parseFloat(heightStr) : 0.0f
            );

            customer.setWeight(
                (weightStr != null && !weightStr.isEmpty()) ?
                Double.parseDouble(weightStr) : 0.0
            );

            // ---------------- PLAN ID & PLAN TYPE ----------------
            Integer planId = null;
            String planType = null;

            if (planIdStr != null && !planIdStr.isEmpty()) {
                planId = Integer.parseInt(planIdStr);

                switch (planId) {
                    case 1 -> planType = "Basic";
                    case 2 -> planType = "Premium";
                    case 3 -> planType = "Gold";
                    case 4 -> planType = "Platinum";
                    default -> planType = "Custom";
                }
            }

            customer.setPlanId(planId);
            customer.setPlanType(planType);

            // ---------------- DEFAULT VALUES ----------------
            customer.setEnrolledOn(LocalDate.now());
            customer.setExpiryDate(LocalDate.now().plusMonths(1));
            customer.setPaymentStatus("Paid");
            customer.setMedicalNotes(medical != null ? medical.trim() : "");
            customer.setAttendanceHistory("[]");
            customer.setTimeSlot("Not Assigned");

            // ---------------- SAVE TO DB ----------------
            boolean success = customerDAO.addCustomer(customer);

            if (success) {
                response.sendRedirect(request.getContextPath()
                        + "/JSP/registration.jsp?success=true");
            } else {
                request.setAttribute("error", "Registration failed. Please try again.");
                request.getRequestDispatcher("/JSP/registration.jsp")
                       .forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("/JSP/registration.jsp")
                   .forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/JSP/registration.jsp").forward(request, response);
    }
}
