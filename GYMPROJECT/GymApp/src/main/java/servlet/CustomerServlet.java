package servlet;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

import dao.CustomerDAO;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Customer;

@WebServlet("/CustomerServlet")
public class CustomerServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private CustomerDAO customerDAO = new CustomerDAO();
    private final int PAGE_SIZE = 5; // show 5 entries per page

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {

                case "search":
                    search(request, response);
                    break;

                case "view":
                    // View single member details
                    viewCustomer(request, response);
                    break;

                case "list":
                default:
                    list(request, response);
                    break;
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if ("update".equals(action)) {
            try {
                updateCustomer(request, response);
            } catch (Exception e) {
                throw new ServletException(e);
            }
        } else {
            // fallback to existing GET logic (add/search etc if you add later)
            doGet(request, response);
        }
    }

    // ------------------------------
    // LIST MEMBERS WITH PAGINATION
    // ------------------------------
    private void list(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        int page = getPage(req.getParameter("page"));
        int totalCount = customerDAO.getTotalCustomers();
        int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);

        if (totalPages == 0) {
            totalPages = 1;
        }

        if (page > totalPages) page = totalPages;
        if (page < 1) page = 1;

        List<Customer> customers = customerDAO.getCustomersPaginated(page, PAGE_SIZE);

        req.setAttribute("customers", customers);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("searchTerm", null);

        RequestDispatcher rd = req.getRequestDispatcher("/JSP/viewmembers.jsp");
        rd.forward(req, res);
    }

    // ------------------------------
    // SEARCH WITH PAGINATION
    // ------------------------------
    private void search(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        String term = req.getParameter("searchTerm");
        if (term == null) term = "";

        int page = getPage(req.getParameter("page"));
        int totalCount = customerDAO.getTotalCustomersBySearch(term);
        int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);

        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;
        if (page < 1) page = 1;

        List<Customer> customers = customerDAO.getCustomersBySearchPaginated(term, page, PAGE_SIZE);

        req.setAttribute("customers", customers);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("searchTerm", term);

        RequestDispatcher rd = req.getRequestDispatcher("/JSP/viewmembers.jsp");
        rd.forward(req, res);
    }

    // ------------------------------
    // VIEW SINGLE MEMBER DETAILS
    // ------------------------------
    private void viewCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Customer customer = customerDAO.getCustomerById(id);

            if (customer != null) {
                request.setAttribute("customer", customer);

                RequestDispatcher dispatcher =
                        request.getRequestDispatcher("/JSP/viewMemberDetails.jsp");
                dispatcher.forward(request, response);
            } else {
                response.sendRedirect(
                        request.getContextPath()
                        + "/CustomerServlet?action=list&error=CustomerNotFound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/CustomerServlet?action=list&error=InvalidID");
        }
    }

    // ------------------------------
    // UPDATE MEMBER (from edit page)
    // ------------------------------
    private void updateCustomer(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        request.setCharacterEncoding("UTF-8");

        int id = Integer.parseInt(request.getParameter("id"));

        String name = request.getParameter("name");
        String mobileNumber = request.getParameter("mobileNumber");
        String email = request.getParameter("email");
        String gender = request.getParameter("gender");
        String dateOfBirthStr = request.getParameter("dateOfBirth");
        String address = request.getParameter("address");
        String heightStr = request.getParameter("height");
        String weightStr = request.getParameter("weight");
        String planIdStr = request.getParameter("planId");
        String enrolledOnStr = request.getParameter("enrolledOn");
        String expiryDateStr = request.getParameter("expiryDate");
        String paymentStatus = request.getParameter("paymentStatus");
        String medicalNotes = request.getParameter("medicalNotes");
        String attendanceHistory = request.getParameter("attendanceHistory");
        String timeSlot = request.getParameter("timeSlot");
        String planType = request.getParameter("planType");

        Customer customer = new Customer();
        customer.setId(id);
        customer.setName(name);
        customer.setMobileNumber(mobileNumber);
        customer.setEmail(email);
        customer.setGender(gender);

        if (dateOfBirthStr != null && !dateOfBirthStr.isBlank()) {
            customer.setDateOfBirth(LocalDate.parse(dateOfBirthStr));
        }

        customer.setAddress(address);

        if (heightStr != null && !heightStr.isBlank()) {
            customer.setHeight(Float.parseFloat(heightStr));
        }

        if (weightStr != null && !weightStr.isBlank()) {
            customer.setWeight(Double.parseDouble(weightStr));
        }

        if (planIdStr != null && !planIdStr.isBlank()) {
            customer.setPlanId(Integer.parseInt(planIdStr));
        } else {
            customer.setPlanId(null);
        }

        if (enrolledOnStr != null && !enrolledOnStr.isBlank()) {
            customer.setEnrolledOn(LocalDate.parse(enrolledOnStr));
        }

        if (expiryDateStr != null && !expiryDateStr.isBlank()) {
            customer.setExpiryDate(LocalDate.parse(expiryDateStr));
        }

        customer.setPaymentStatus(paymentStatus);
        customer.setMedicalNotes(medicalNotes);
        customer.setAttendanceHistory(attendanceHistory);
        customer.setTimeSlot(timeSlot);
        customer.setPlanType(planType);

        boolean updated = customerDAO.updateCustomer(customer);

        if (updated) {
            // you can redirect back to list or stay on same member view
            response.sendRedirect(request.getContextPath()
                    + "/CustomerServlet?action=view&id=" + id + "&updated=1");
        } else {
            request.setAttribute("customer", customer);
            request.setAttribute("error", "Unable to update member.");
            RequestDispatcher rd = request.getRequestDispatcher("/JSP/viewMemberDetails.jsp");
            rd.forward(request, response);
        }
    }

    // ------------------------------
    // HELPER: PAGE PARSING
    // ------------------------------
    private int getPage(String p) {
        try {
            return Integer.parseInt(p);
        } catch (Exception e) {
            return 1;
        }
    }
}
