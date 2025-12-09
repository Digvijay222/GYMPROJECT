<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.EquipmentDAO, model.Equipment, java.util.List" %>
<%
    String ctx = request.getContextPath();
    EquipmentDAO equipmentDAO = new EquipmentDAO();
    List<Equipment> equipmentList = equipmentDAO.findAll();

    String searchTerm = request.getParameter("search");
    if (searchTerm != null && !searchTerm.trim().isEmpty()) {
        equipmentList = equipmentList.stream()
            .filter(e -> e.getName().toLowerCase().contains(searchTerm.toLowerCase()) ||
                        String.valueOf(e.getCost()).contains(searchTerm))
            .collect(java.util.stream.Collectors.toList());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Arnold Muscle Mechanic - Add Inventory</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        :root {
            --dark-blue-bg: #2c3e50;
            --light-grey-bg: #ecf0f1;
            --primary-blue: #3498db;
            --sidebar-text: white;
            --dark-text: #34495e;
            --card-dark-bg: #34495e;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; font-family: Arial, sans-serif; }
        body { background-color: var(--light-grey-bg); }

        .dashboard-container { display: flex; min-height: 100vh; }

        /* SIDEBAR */
        .sidebar { width: 250px; background-color: var(--dark-blue-bg); color: var(--sidebar-text); padding: 20px 0; display: flex; flex-direction: column; justify-content: space-between; }
        .admin-profile { display:flex; flex-direction:column; align-items:center; padding:0 20px 30px; border-bottom:1px solid rgba(255,255,255,0.1); }
        .profile-icon { font-size:60px; margin-bottom:10px; color:#ecf0f1; }
        .admin-name { font-weight: bold; font-size:1.1em; }
        .admin-email { font-size:0.8em; color:#bdc3c7; }

        .navigation ul { list-style:none; padding:0; margin:0; }
        .nav-item a { display:flex; align-items:center; padding:15px 20px; color:white; text-decoration:none; transition: background-color 0.2s; }
        .nav-item a i { margin-right:15px; font-size:1.1em; }
        .nav-item a:hover:not(.active-link) { background-color:#34495e; }
        .nav-item.active a, .nav-item a.active-link { background-color:var(--light-grey-bg); color:var(--dark-blue-bg); border-left:5px solid var(--primary-blue); padding-left:15px; }

        .logout { display:block; margin-top:auto; border-top:1px solid rgba(255,255,255,0.1); }
        .logout a { display:flex; align-items:center; padding:15px 20px; color:white; text-decoration:none; }

        /* MAIN */
        .main-content { flex-grow:1; padding:20px; background-color:var(--light-grey-bg); }
        .top-header { display:flex; justify-content:flex-start; align-items:center; margin-bottom:30px; gap:15px; }
        .gym-logo { width:50px; height:50px; background-color:var(--primary-blue); margin-right:15px; border-radius:5px; position:absolute; }
        .gym-title { font-size:1.5em; font-weight:bold; color:var(--dark-text); padding:10px 60px; }

        .inventory-page-container { display:flex; flex-direction:column; gap:20px; max-width:1000px; margin:0 auto; }
        .card { border-radius:8px; box-shadow:0 2px 4px rgba(0,0,0,0.1); }
        .inventory-card { background-color:var(--card-dark-bg); color:white; padding:25px 40px 35px 40px; }
        .card-title-pill { background-color:white; color:var(--dark-text); padding:5px 15px; border-radius:20px; font-weight:bold; display:inline-block; margin-bottom:20px; font-size:0.9em; }

        .inventory-header-row { display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; }
        .add-equipment-btn { background-color:#5d748d; color:white; border:none; padding:10px 18px; border-radius:4px; font-size:0.9em; cursor:pointer; font-weight:600; }
        .add-equipment-btn:hover { background-color:#7f8c98; }

        .table-controls { display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; font-size:0.9em; }
        .search-group { display:flex; align-items:center; background-color:white; border-radius:4px; padding:0 10px; }
        .search-group input { border:none; background:none; padding:8px 0; color:#2c3e50; outline:none; width:200px; }

        .inventory-table-wrapper table { width:100%; border-collapse:collapse; font-size:0.95em; }
        .inventory-table-wrapper table thead { background-color:#495d73; color:#bdc3c7; text-align:left; }
        .inventory-table-wrapper table th, .inventory-table-wrapper table td { padding:12px; border-bottom:1px solid rgba(255,255,255,0.1); }
        .status-active { color:#2ecc71; font-weight:600; }
        .status-error { color:#e74c3c; font-weight:600; }
        .status-warn { color:#f1c40f; font-weight:600; }

        /* Cost column styling */
        .inventory-table-wrapper th:nth-child(5),
        .inventory-table-wrapper td:nth-child(5) {
            text-align: right;
            width: 120px;
        }

        .action-btn { background-color:white; color:var(--primary-blue); border:1px solid var(--primary-blue); padding:5px 15px; border-radius:4px; cursor:pointer; font-size:0.8em; transition: background-color 0.2s, color 0.2s; }
        .action-btn:hover { background-color:var(--primary-blue); color:white; }
        .delete-btn { background-color:#e74c3c; color:white; border:1px solid #c0392b; margin-left:10px; }
        .delete-btn:hover { background-color:#c0392b; }

        /* MODAL */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0; top: 0;
            width: 100%; height: 100%;
            background-color: rgba(0,0,0,0.5);
        }

        .modal-content {
            background-color: white;
            margin: 5% auto;
            padding: 25px;
            border-radius: 8px;
            width: 500px;
            max-width: 90%;
            max-height: 80vh;
            overflow: visible;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
            position: relative;
            z-index: 1001;
        }

        .modal-title {
            font-size: 1.5em;
            color: #2c3e50;
            font-weight: bold;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #3498db;
        }

        .modal-body {
            max-height: calc(80vh - 200px);
            overflow-y: auto;
            padding-right: 8px;
            padding-bottom: 8px;
        }

        .form-group { margin-bottom: 20px; }
        .form-group label { display:block; margin-bottom:8px; color:#2c3e50; font-weight:600; font-size:14px; }
        .form-group input, .form-group select, .form-group textarea {
            width:100%; padding:10px; border:1px solid #bdc3c7; border-radius:4px; font-size:14px; background-color:white;
        }
        .form-group textarea { height:80px; resize: vertical; }

        .modal-buttons {
            display:flex; gap:10px; justify-content:flex-end;
            position:absolute; right:20px; bottom:18px; z-index:1010;
        }

        .modal-btn { padding:10px 20px; border:none; border-radius:4px; cursor:pointer; font-weight:600; font-size:14px; min-width:100px; }
        .modal-cancel { background-color:#95a5a6; color:white; }
        .modal-cancel:hover { background-color:#7f8c8d; }
        .modal-save { background-color:#3498db; color:white; }
        .modal-save:hover { background-color:#2980b9; }

        .inventory-table-wrapper th:last-child, .inventory-table-wrapper td:last-child { text-align:right; width:180px; }
    </style>
</head>
<body>
<div class="dashboard-container">
    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="admin-profile">
            <i class="fas fa-user-circle profile-icon"></i>
            <div class="admin-name">Admin Name</div>
            <div class="admin-email">arnoldmuscle07@gmail.com</div>
        </div>
        <nav class="navigation">
            <ul>
                <li class="nav-item">
                    <a href="<%=ctx%>/JSP/dashboard.jsp"><i class="fas fa-chart-line"></i><span>Dashboard</span></a>
                </li>
                <li class="nav-item">
                    <a href="<%=ctx%>/JSP/admin.jsp"><i class="fas fa-user-shield"></i><span>Admin</span></a>
                </li>
                <li class="nav-item">
                    <a href="<%=ctx%>/JSP/registration.jsp"><i class="fas fa-clipboard-list"></i><span>Registration</span></a>
                </li>
                <li class="nav-item">
                    <a href="<%=ctx%>/JSP/membership.jsp"><i class="fas fa-id-card"></i><span>Membership</span></a>
                </li>
                <li class="nav-item active">
                    <a href="<%=ctx%>/JSP/addinventory.jsp" class="active-link"><i class="fas fa-box-open"></i><span>Add Inventory</span></a>
                </li>
                <li class="nav-item">
                    <a href="<%=ctx%>/JSP/payment.jsp"><i class="fas fa-hand-holding-usd"></i><span>Payment</span></a>
                </li>
                <li class="nav-item"><a href="/JSP/viewmembers.jsp"><i class="fas fa-users"></i><span>View Members</span></a></li>
                <li class="nav-item"><a href="/JSP/profitExpenses.jsp"><i class="fas fa-file-invoice-dollar"></i><span>Profit & Expenses</span></a></li>
            </ul>
        </nav>
        <div class="logout">
            <a href="<%=ctx%>/JSP/login.jsp"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <header class="top-header">
            <div style="display:flex;align-items:center;">
                <img src="<%=ctx%>/images/Logo.jpg" alt="Logo" class="gym-logo">
                <div class="gym-title">ARNOLD MUSCLE MECHANIC</div>
            </div>
        </header>

        <div class="inventory-page-container">
            <div class="inventory-card card">
                <div class="card-title-pill">Manage Equipments</div>

                <div class="inventory-header-row">
                    <button class="add-equipment-btn" onclick="openAddModal()">Add Equipment</button>
                </div>

                <div class="table-controls">
                    <div class="show-entries">Showing <%= equipmentList.size() %> entries</div>
                    <form method="GET" action="addinventory.jsp" class="search-form">
                        <div class="search-group">
                            <input type="text" name="search" placeholder="Search equipment..." value="<%= searchTerm != null ? searchTerm : "" %>">
                            <button type="submit"><i class="fas fa-search"></i></button>
                        </div>
                    </form>
                </div>

                <div class="inventory-table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Equipment Name</th>
                                <th>Description</th>
                                <th>Quantity</th>
                                <th>Cost</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% for (Equipment equipment : equipmentList) { %>
                            <tr>
                                <td><%= equipment.getId() %></td>
                                <td><%= equipment.getName() %></td>
                                <td><%= equipment.getDescription() %></td>
                                <td><%= equipment.getQuantity() %></td>
                                <td>
                                    <%
                                        if (equipment.getCost() > 0) {
                                            out.print("₹" + String.format("%.2f", equipment.getCost()));
                                        } else {
                                            out.print("-");
                                        }
                                    %>
                                </td>
                                <td>
                                    <%
                                        String status = equipment.getStatus();
                                        if (status == null) status = "Unknown";

                                        String statusClass = "status-active";
                                        if (status.contains("ERROR") || status.contains("Broken") || status.contains("Maintenance")) {
                                            statusClass = "status-error";
                                        } else if (status.contains("Pending")) {
                                            statusClass = "status-warn";
                                        }
                                    %>
                                    <span class="<%= statusClass %>"><%= status %></span>
                                </td>
                                <td>
                                    <div style="display:flex;gap:8px;justify-content:flex-end;">
                                        <button type="button" class="action-btn" onclick="openEditModal(
                                            '<%= equipment.getId() %>',
                                            '<%= equipment.getName().replace("'", "\\'") %>',
                                            '<%= equipment.getDescription().replace("'", "\\'") %>',
                                            '<%= status.replace("'", "\\'") %>',
                                            '<%= equipment.getQuantity() %>',
                                            '<%= equipment.getCost() %>'
                                        )">Edit</button>
                                        <button type="button" class="action-btn delete-btn" onclick="confirmDelete(<%= equipment.getId() %>, '<%= equipment.getName().replace("'", "\\'") %>')">Delete</button>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- MODAL -->
<div id="equipmentModal" class="modal">
    <div class="modal-content">
        <h3 class="modal-title" id="modalTitle">Add New Equipment</h3>

        <form id="equipmentForm" method="POST" action="<%=ctx%>/InventoryServlet">
            <input type="hidden" id="equipmentId" name="equipmentId">
            <input type="hidden" id="action" name="action" value="add">

            <div class="modal-body">
                <div class="form-group">
                    <label for="name">Equipment Name *</label>
                    <input type="text" id="name" name="name" required>
                </div>

                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea id="description" name="description"></textarea>
                </div>

                <div class="form-group">
                    <label for="quantity">Quantity *</label>
                    <input type="number" id="quantity" name="quantity" min="0" required>
                </div>

                <div class="form-group">
                    <label for="cost">Cost (₹)</label>
                    <input type="number" id="cost" name="cost" min="0" step="0.01" placeholder="0.00">
                </div>

                <div class="form-group">
                    <label for="status">Status *</label>
                    <select id="status" name="status" required>
                        <option value="Active">Active</option>
                        <option value="MAJOR ERROR">MAJOR ERROR</option>
                        <option value="Pending Order">Pending Order</option>
                        <option value="Cable Broken">Cable Broken</option>
                         <option value="InActive">InActive</option>
                        <option value="Maintenance Soon">Maintenance Soon</option>
                        <option value="Under Repair">Under Repair</option>
                        <option value="Out of Service">Out of Service</option>
                        <option value="Under Maintenance">Under Maintenance</option>
                    </select>
                </div>
            </div>

            <div class="modal-buttons">
                <button type="button" class="modal-btn modal-cancel" onclick="closeModal()">Cancel</button>
                <button type="submit" class="modal-btn modal-save">Save Equipment</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openAddModal() {
        document.getElementById('modalTitle').textContent = 'Add New Equipment';
        document.getElementById('equipmentId').value = '';
        document.getElementById('action').value = 'add';
        document.getElementById('name').value = '';
        document.getElementById('description').value = '';
        document.getElementById('quantity').value = '1';
        document.getElementById('cost').value = '0.00';
        document.getElementById('status').value = 'Active';
        document.getElementById('equipmentModal').style.display = 'block';
        const mcBody = document.querySelector('.modal-body');
        if (mcBody) mcBody.scrollTop = 0;
    }

    function openEditModal(id, name, description, status, quantity, cost) {
        document.getElementById('modalTitle').textContent = 'Edit Equipment';
        document.getElementById('equipmentId').value = id;
        document.getElementById('action').value = 'edit';
        document.getElementById('name').value = name;
        document.getElementById('description').value = description;
        document.getElementById('quantity').value = quantity;
        document.getElementById('cost').value = parseFloat(cost).toFixed(2);
        document.getElementById('status').value = status;
        document.getElementById('equipmentModal').style.display = 'block';
        const mcBody = document.querySelector('.modal-body');
        if (mcBody) mcBody.scrollTop = 0;
    }

    function closeModal() {
        document.getElementById('equipmentModal').style.display = 'none';
    }

    function confirmDelete(id, name) {
        if (confirm('Are you sure you want to delete "' + name + '"?')) {
            window.location.href = '<%=ctx%>/InventoryServlet?action=delete&id=' + id;
        }
    }

    window.onclick = function(event) {
        const modal = document.getElementById('equipmentModal');
        if (event.target === modal) closeModal();
    }

    document.getElementById('equipmentForm').addEventListener('submit', function(e) {
        const name = document.getElementById('name').value.trim();
        const quantity = document.getElementById('quantity').value;
        const cost = document.getElementById('cost').value;
        const status = document.getElementById('status').value;

        if (!name) {
            e.preventDefault();
            alert('Please enter equipment name');
            return false;
        }
        if (quantity < 0) {
            e.preventDefault();
            alert('Quantity cannot be negative');
            return false;
        }
        if (cost < 0) {
            e.preventDefault();
            alert('Cost cannot be negative');
            return false;
        }
        if (!status) {
            e.preventDefault();
            alert('Please select a status');
            return false;
        }
        return true;
    });

    document.addEventListener('DOMContentLoaded', function() {
        const searchInput = document.querySelector('input[name="search"]');
        if (searchInput) searchInput.focus();
    });
</script>
</body>
</html>
