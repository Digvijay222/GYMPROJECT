package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import dao.EquipmentDAO;
import db.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Equipment;

@WebServlet("/InventoryServlet")
public class InventoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private EquipmentDAO equipmentDAO;

    public void init() {
        equipmentDAO = new EquipmentDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("add".equals(action)) {
            addEquipment(request, response);
        } else if ("edit".equals(action)) {
            updateEquipment(request, response);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("delete".equals(action)) {
            deleteEquipment(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/JSP/addinventory.jsp");
        }
    }

    private void addEquipment(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        Equipment equipment = new Equipment();
        equipment.setName(request.getParameter("name"));
        equipment.setDescription(request.getParameter("description"));
        equipment.setQuantity(Integer.parseInt(request.getParameter("quantity")));
        equipment.setStatus(request.getParameter("status"));
        
        // Handle cost parameter
        String costParam = request.getParameter("cost");
        if (costParam != null && !costParam.trim().isEmpty()) {
            equipment.setCost(Double.parseDouble(costParam));
        } else {
            equipment.setCost(0.0); // Default value if cost is not provided
        }
        
        equipmentDAO.insert(equipment);
        response.sendRedirect(request.getContextPath() + "/JSP/addinventory.jsp");
    }

    private void updateEquipment(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        try {
            Equipment equipment = new Equipment();
            equipment.setId(Integer.parseInt(request.getParameter("equipmentId")));
            equipment.setName(request.getParameter("name"));
            equipment.setDescription(request.getParameter("description"));
            equipment.setQuantity(Integer.parseInt(request.getParameter("quantity")));
            equipment.setStatus(request.getParameter("status"));
            
            // Handle cost parameter
            String costParam = request.getParameter("cost");
            if (costParam != null && !costParam.trim().isEmpty()) {
                equipment.setCost(Double.parseDouble(costParam));
            } else {
                equipment.setCost(0.0); // Default value if cost is not provided
            }
            
            // Use DAO's update method
            equipmentDAO.update(equipment);
            response.sendRedirect(request.getContextPath() + "/JSP/addinventory.jsp");
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/JSP/addinventory.jsp?error=Invalid+ID");
        }
    }

    private void deleteEquipment(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            // Use DAO's delete method
            equipmentDAO.delete(id);
            response.sendRedirect(request.getContextPath() + "/JSP/addinventory.jsp");
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/JSP/addinventory.jsp?error=Invalid+ID");
        }
    }
}