package servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;

import dao.AttendanceDAO;
import dao.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Customer;

@WebServlet("/markAttendance")
public class MarkAttendanceServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== MarkAttendanceServlet START ===");

        // 🔍 Debug: log basic request info
        System.out.println("Content-Type: " + request.getContentType());
        System.out.println("CharacterEncoding: " + request.getCharacterEncoding());

        // 🔍 Debug: log all parameter names & values Tomcat sees
        Map<String, String[]> paramMap = request.getParameterMap();
        if (paramMap.isEmpty()) {
            System.out.println("request.getParameterMap() is EMPTY");
        } else {
            System.out.println("Parameters in request.getParameterMap():");
            for (Map.Entry<String, String[]> e : paramMap.entrySet()) {
                String name = e.getKey();
                String[] vals = e.getValue();
                System.out.print(" - " + name + " = ");
                if (vals == null) {
                    System.out.println("null");
                } else if (vals.length == 1) {
                    System.out.println(vals[0]);
                } else {
                    System.out.print("[");
                    for (int i = 0; i < vals.length; i++) {
                        System.out.print(vals[i]);
                        if (i < vals.length - 1) System.out.print(", ");
                    }
                    System.out.println("]");
                }
            }
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        try (PrintWriter out = response.getWriter()) {

            // 1. Session check
            if (session == null || session.getAttribute("loggedUser") == null) {
                System.out.println("No session / user not logged in");
                out.write(jsonError("Session expired. Please refresh the page and log in again."));
                return;
            }

            // 2. Read parameters (must match names sent from JS)
            String mobileNumber = request.getParameter("mobileNumber");
            String status = request.getParameter("attendanceStatus");

            System.out.println("Parameters received via getParameter():");
            System.out.println("- mobileNumber: " + mobileNumber);
            System.out.println("- attendanceStatus: " + status);

            // 3. Basic validation
            if (mobileNumber == null || mobileNumber.trim().isEmpty()) {
                out.write(jsonError("Please enter mobile number"));
                return;
            }

            mobileNumber = mobileNumber.trim();

            if (mobileNumber.length() != 10 || !mobileNumber.matches("\\d{10}")) {
                out.write(jsonError("Please enter a valid 10-digit mobile number"));
                return;
            }

            if (status == null || (!"Present".equals(status) && !"Absent".equals(status))) {
                out.write(jsonError("Please select attendance status"));
                return;
            }

            // 4. Find customer by mobile number
            CustomerDAO customerDAO = new CustomerDAO();
            Customer customer = customerDAO.findByMobileNumber(mobileNumber);

            if (customer == null) {
                System.out.println("Customer not found for mobile: " + mobileNumber);
                out.write(jsonError("No customer found with mobile: " + mobileNumber));
                return;
            }

            System.out.println("Found customer: " + customer.getName() + " (ID: " + customer.getId() + ")");

            // 5. Check membership validity
            if (customer.getExpiryDate() != null &&
                    customer.getExpiryDate().isBefore(java.time.LocalDate.now())) {
                System.out.println("Membership expired for customer: " + customer.getId());
                out.write(jsonError("Membership expired for " + escape(customer.getName())
                        + ". Cannot mark attendance."));
                return;
            }

            // 6. Check if already marked today
            AttendanceDAO attendanceDAO = new AttendanceDAO();
            if (attendanceDAO.isAttendanceMarkedToday(customer.getId())) {
                System.out.println("Attendance already marked today for customer: " + customer.getId());
                out.write(jsonError("Attendance already marked for " + escape(customer.getName()) + " today"));
                return;
            }

            // 7. Prepare login time for "Present"
            LocalDateTime loginTime = null;
            if ("Present".equals(status)) {
                loginTime = LocalDateTime.now();
                System.out.println("Marking as Present with login time: " + loginTime);
            }

            // 8. Persist attendance
            boolean success = attendanceDAO.markAttendance(
                    customer.getId(),
                    customer.getName(),
                    customer.getMobileNumber(),
                    loginTime,
                    status
            );

            if (success) {
                System.out.println("Attendance marked successfully");
                String message = "Attendance marked as " + status + " for " + escape(customer.getName());
                if ("Present".equals(status) && loginTime != null) {
                    String timeStr = loginTime.format(DateTimeFormatter.ofPattern("hh:mm a"));
                    message += " at " + timeStr;
                }
                out.write(jsonSuccess(message));
            } else {
                System.out.println("Failed to mark attendance");
                out.write(jsonError("Failed to mark attendance. Please try again."));
            }

        } catch (Exception e) {
            System.err.println("Error in MarkAttendanceServlet: " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("=== MarkAttendanceServlet END ===");
    }

    // ---------- Helper methods ----------

    private String jsonError(String msg) {
        return "{\"status\":\"error\",\"message\":\"" + escape(msg) + "\"}";
    }

    private String jsonSuccess(String msg) {
        return "{\"status\":\"success\",\"message\":\"" + escape(msg) + "\"}";
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
