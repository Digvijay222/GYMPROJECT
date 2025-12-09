package servlet;

import java.io.IOException;
import java.util.List;

import dao.AttendanceDAO;
import dao.CustomerDAO;
import dao.EquipmentDAO;
import dao.ExpenseDAO;
import dao.MembershipPlanDAO;
import dao.PaymentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Attendance;
import model.Customer;
import model.Equipment;
import model.MembershipPlan;
import model.User;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");

        // Check if user is logged in
        if (loggedUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Initialize DAOs
            CustomerDAO customerDAO = new CustomerDAO();
            MembershipPlanDAO planDAO = new MembershipPlanDAO();
            EquipmentDAO equipmentDAO = new EquipmentDAO();
            PaymentDAO paymentDAO = new PaymentDAO();
            ExpenseDAO expenseDAO = new ExpenseDAO(null); // adjust constructor if needed
            AttendanceDAO attendanceDAO = new AttendanceDAO();

            // 1. Get total members (all customers)
            List<Customer> allCustomers = customerDAO.findAll();
            int totalMembers = allCustomers.size();

            // 2. Get active members (with paid/active status)
            List<Customer> activeMembers = customerDAO.getActiveCustomers();
            int totalActiveMembers = activeMembers.size();

            // 3. Calculate today's attendance
            List<Attendance> todayAttendance = attendanceDAO.getTodayAttendance();
            int attendedToday = todayAttendance.size();
            double attendancePercent = 0.0;

            if (totalActiveMembers > 0) {
                attendancePercent = (attendedToday * 100.0) / totalActiveMembers;
            }

            // 4. Get membership plans
            List<MembershipPlan> plans = planDAO.findAll();

            // 5. Get equipment list
            List<Equipment> equipmentList = equipmentDAO.findAll();

            // 6. Get financial data
            double totalRevenue = 0.0;
            double totalExpenses = 0.0;

            try {
                // Get total revenue from payments
                totalRevenue = paymentDAO.getTotalRevenue();

                // Get total expenses (replace with real DAO method when ready)
                // totalExpenses = expenseDAO.getTotalExpenses();
                totalExpenses = getTotalExpenses(); // currently dummy
            } catch (Exception e) {
                e.printStackTrace();
                // Set fallback values if there's an error
                totalRevenue = 10000.0; // Example default
                totalExpenses = 4000.0; // Example default
            }

            double totalProfit = totalRevenue - totalExpenses;

            // Set all attributes for the JSP
            request.setAttribute("attendancePercent", attendancePercent);
            request.setAttribute("totalMembers", totalMembers);       // all members
            request.setAttribute("attendedToday", attendedToday);
            request.setAttribute("plans", plans);
            request.setAttribute("activeMembers", activeMembers);      // active list
            request.setAttribute("equipmentList", equipmentList);
            request.setAttribute("totalRevenue", totalRevenue);
            request.setAttribute("totalExpenses", totalExpenses);
            request.setAttribute("totalProfit", totalProfit);
            request.setAttribute("user", loggedUser);

        } catch (Exception e) {
            e.printStackTrace();
            // Set default values in case of error
            setDefaultAttributes(request);
            request.setAttribute("user", loggedUser);
        }

        // Forward to dashboard JSP
        request.getRequestDispatcher("/JSP/dashboard.jsp").forward(request, response);
    }

    // TODO: replace with real ExpenseDAO logic
    private double getTotalExpenses() {
        try {
            // implement using ExpenseDAO when ready
            return 4000.0; // dummy value
        } catch (Exception e) {
            return 0.0;
        }
    }

    private void setDefaultAttributes(HttpServletRequest request) {
        request.setAttribute("attendancePercent", 0.0);
        request.setAttribute("totalMembers", 0);
        request.setAttribute("attendedToday", 0);
        request.setAttribute("totalRevenue", 0.0);
        request.setAttribute("totalExpenses", 0.0);
        request.setAttribute("totalProfit", 0.0);
        // Lists (plans, equipmentList, activeMembers) can be null/empty and handled in JSP
    }
}
