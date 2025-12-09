package servlet;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

import dao.AttendanceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Attendance;
import model.User;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== AdminServlet START ===");
        
        HttpSession session = request.getSession(false);

        // --------- LOGIN CHECK ----------
        if (session == null || session.getAttribute("loggedUser") == null) {
            System.out.println("User not logged in, redirecting to login page");
            response.sendRedirect(request.getContextPath() + "login.jsp");
            return;
        }
        // ---------------------------------

        User loggedUser = (User) session.getAttribute("loggedUser");
        System.out.println("User logged in: " + loggedUser.getName());
        
        request.setAttribute("adminName", loggedUser.getName());
        request.setAttribute("adminEmail", loggedUser.getEmail());

        // ====== Daily entries data from attendance table ======
        AttendanceDAO attendanceDAO = new AttendanceDAO();
        List<Attendance> dailyEntries = attendanceDAO.getTodayAttendance();
        
        System.out.println("Found " + dailyEntries.size() + " attendance entries for today");
        
        request.setAttribute("dailyEntries", dailyEntries);

        // Forward to JSP
        request.getRequestDispatcher("/JSP/admin.jsp").forward(request, response);
        
        System.out.println("=== AdminServlet END ===");
    }
}