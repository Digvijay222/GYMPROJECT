package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import dao.ExpenseDAO;
import dao.PaymentDAO;
import db.DBConnection;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.ProfitSummary;

@WebServlet("/profit-expenses")
public class ProfitExpensesServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Connection connection = null;
        try {
            // Get database connection
            connection = DBConnection.getConnection();
            
            // Initialize DAOs
            ExpenseDAO expenseDAO = new ExpenseDAO(connection);
            PaymentDAO paymentDAO = new PaymentDAO();
            
            // Get data from database
            double totalRevenue         = paymentDAO.getTotalRevenue();
            double totalExpenses        = expenseDAO.getTotalExpenses();
            double currentMonthRevenue  = paymentDAO.getCurrentMonthRevenue();
            double currentMonthExpenses = expenseDAO.getCurrentMonthExpenses();
            double lastMonthRevenue     = paymentDAO.getLastMonthRevenue();
            double lastMonthExpenses    = expenseDAO.getLastMonthExpenses();
            
            // Create profit summary
            ProfitSummary summary = new ProfitSummary(
                totalRevenue, totalExpenses,
                currentMonthRevenue, currentMonthExpenses,
                lastMonthRevenue, lastMonthExpenses
            );
            
            // Get current year
            int currentYear = java.time.Year.now().getValue();
            
            // Get monthly data (must return 12 elements each)
            List<Double> monthlyRevenue  = paymentDAO.getMonthlyRevenue(currentYear);
            List<Double> monthlyExpenses = expenseDAO.getMonthlyExpenses(currentYear);
            
            // Ensure size 12 to avoid IndexOutOfBounds
            while (monthlyRevenue.size() < 12)  monthlyRevenue.add(0.0);
            while (monthlyExpenses.size() < 12) monthlyExpenses.add(0.0);
            
            // Calculate monthly profit
            List<Double> monthlyProfit = new ArrayList<>();
            for (int i = 0; i < 12; i++) {
                double revenue  = monthlyRevenue.get(i);
                double expenses = monthlyExpenses.get(i);
                double profit   = revenue - expenses;
                monthlyProfit.add(profit);
            }
            
            // Month names
            String[] monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                                   "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
            
            // Get current page for pagination (0 or 1)
            String pageParam = request.getParameter("page");
            int currentPage = 0;
            if (pageParam != null && !pageParam.isEmpty()) {
                try {
                    currentPage = Integer.parseInt(pageParam);
                    if (currentPage < 0) currentPage = 0;
                    if (currentPage > 1) currentPage = 1; // Only 2 pages (0 and 1)
                } catch (NumberFormatException e) {
                    currentPage = 0;
                }
            }
            
            // Set request attributes
            request.setAttribute("profitSummary", summary);
            request.setAttribute("monthlyRevenue", monthlyRevenue);
            request.setAttribute("monthlyExpenses", monthlyExpenses);
            request.setAttribute("monthlyProfit", monthlyProfit);
            request.setAttribute("monthNames", monthNames);
            request.setAttribute("currentYear", currentYear);
            request.setAttribute("currentPage", currentPage);
            
            // Forward to JSP view
            RequestDispatcher dispatcher = request.getRequestDispatcher("/JSP/profitExpenses.jsp");
            dispatcher.forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            RequestDispatcher dispatcher = request.getRequestDispatcher("/error.jsp");
            dispatcher.forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "System error: " + e.getMessage());
            RequestDispatcher dispatcher = request.getRequestDispatcher("/error.jsp");
            dispatcher.forward(request, response);
        } finally {
            if (connection != null) {
                try { connection.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}
