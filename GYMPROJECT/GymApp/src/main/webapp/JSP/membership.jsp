<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.MembershipPlan" %>
<%
    String ctx = request.getContextPath();
    List<MembershipPlan> plans = (List<MembershipPlan>) request.getAttribute("membershipPlans");
    if (plans == null) {
        // Load plans via servlet
        response.sendRedirect(ctx + "/membershipServlet");
        return;
    }
    
    // Get any success/error messages
    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
    
    // Get plan to edit if coming from edit link
    String editPlanId = request.getParameter("edit");
    MembershipPlan planToEdit = null;
    if (editPlanId != null && !editPlanId.isEmpty()) {
        try {
            int id = Integer.parseInt(editPlanId);
            for (MembershipPlan plan : plans) {
                if (plan.getId() == id) {
                    planToEdit = plan;
                    break;
                }
            }
        } catch (NumberFormatException e) {
            // Invalid ID, ignore
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gym Membership Plans</title>
    <link rel="stylesheet" href="styles.css">
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<style>
:root {
    --dark-blue-bg: #2c3e50;
    --light-grey-bg: #ecf0f1;
    --primary-blue: #3498db;
    --sidebar-text: white;
    --dark-text: #34495e;
    --card-dark-bg: #34495e;
    --success-green: #27ae60;
    --error-red: #e74c3c;
}

/* General Reset and Base Styles */
* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
    font-family: Arial, sans-serif;
}

body {
    background-color: var(--light-grey-bg);
}

/* Layout */
.dashboard-container {
    display: flex;
    min-height: 100vh;
}

/* Sidebar */
.sidebar {
    width: 250px;
    background-color: var(--dark-blue-bg);
    color: var(--sidebar-text);
    padding: 20px 0;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}

.admin-profile {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 0 20px 30px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.profile-icon {
    font-size: 60px;
    margin-bottom: 10px;
    color: #ecf0f1;
}

.admin-name {
    font-weight: bold;
    font-size: 1.1em;
}

.admin-email {
    font-size: 0.8em;
    color: #bdc3c7;
}

.navigation ul {
    list-style: none;
    padding: 0;
    margin: 0;
}

.nav-item {
    cursor: pointer;
}

.nav-item a{
    display:flex;
    align-items:center;
    padding: 15px 20px;
    color:white;
    text-decoration:none;
    transition: background-color 0.2s;
}

.nav-item a i {
    margin-right: 15px;
    font-size: 1.1em;
}

.nav-item a:hover:not(.active-link) {
    background-color: #34495e;
}

.nav-item.active a,
.nav-item a.active-link {
    background-color: var(--light-grey-bg);
    color: var(--dark-blue-bg);
    border-left: 5px solid var(--primary-blue);
    padding-left: 15px;
}

.logout {
    display: block;
    margin-top: auto;
    border-top: 1px solid rgba(255, 255, 255, 0.1);
}
.logout a{
    display:flex;
    align-items:center;
    padding: 15px 20px;
    cursor: pointer;
    color:white;
    text-decoration:none;
}
.logout a i {
    margin-right: 15px;
}

/* Main Content */
.main-content {
    flex-grow: 1;
    padding: 20px;
    background-color: var(--light-grey-bg);
}

/* Header */
.top-header {
    display: flex;
    justify-content: flex-start;
    align-items: center;
    margin-bottom: 30px;
    gap: 15px;
}

.gym-logo {
    width: 50px;
    height: 50px;
    background-color: var(--primary-blue);
    margin-right: 15px;
    border-radius: 5px;
    position: absolute;
}

.gym-title {
    font-size: 1.5em;
    font-weight: bold;
    color: var(--dark-text);
    padding: 10px 60px;
}

/* Messages */
.messages {
    margin-bottom: 20px;
}

.success-message {
    background-color: #d4edda;
    color: #155724;
    padding: 12px 20px;
    border-radius: 4px;
    margin-bottom: 15px;
    border: 1px solid #c3e6cb;
}

.error-message {
    background-color: #f8d7da;
    color: #721c24;
    padding: 12px 20px;
    border-radius: 4px;
    margin-bottom: 15px;
    border: 1px solid #f5c6cb;
}

/* Membership page content */
.membership-page-container {
    display: flex;
    flex-direction: column;
    gap: 20px;
    max-width: 900px;
    margin: 0 auto;
}

.card {
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

/* Add Plan Card */
.add-plan-card {
    background-color: var(--card-dark-bg);
    color: white;
    padding: 30px 40px;
}

.card-title-pill {
    background-color: white;
    color: var(--dark-text);
    padding: 5px 15px;
    border-radius: 20px;
    font-weight: bold;
    display: inline-block;
    margin-bottom: 25px;
    font-size: 0.9em;
}

.edit-mode .card-title-pill {
    background-color: #f39c12;
    color: white;
}

.plan-form {
    display: flex;
    flex-direction: column;
    gap: 25px;
}

.form-row {
    display: flex;
    gap: 20px;
}

.form-group {
    display: flex;
    flex-direction: column;
    flex-grow: 1;
}

.two-cols > .form-group {
    flex-basis: 50%;
}
.single-col > .form-group {
    max-width: 50%;
}

.form-group label {
    font-size: 0.9em;
    color: #bdc3c7;
    margin-bottom: 5px;
}

.form-group input {
    padding: 12px 15px;
    border: none;
    border-radius: 4px;
    font-size: 1em;
    background-color: white;
    color: #333;
}

.form-group input::placeholder {
    color: #95a5a6;
}

.form-group input:focus {
    outline: 2px solid var(--primary-blue);
    outline-offset: 2px;
}

/* Hidden input for plan ID */
.hidden-id {
    display: none;
}

/* Buttons */
.form-actions {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    padding-top: 10px;
}

.btn {
    padding: 10px 20px;
    border: 1px solid transparent;
    border-radius: 5px;
    font-weight: bold;
    cursor: pointer;
    transition: all 0.2s;
    font-size: 0.9em;
    display: inline-flex;
    align-items: center;
    gap: 5px;
}

.btn-primary {
    background-color: var(--primary-blue);
    color: white;
}

.btn-primary:hover {
    background-color: #2980b9;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}

.btn-secondary {
    background-color: #5d748d;
    color: white;
}

.btn-secondary:hover {
    background-color: #7f8c98;
    transform: translateY(-2px);
}

.btn-danger {
    background-color: var(--error-red);
    color: white;
    border: 1px solid var(--error-red);
}

.btn-danger:hover {
    background-color: #c0392b;
    transform: translateY(-2px);
}

.btn-cancel {
    background-color: #95a5a6;
    color: white;
}

.btn-cancel:hover {
    background-color: #7f8c8d;
    transform: translateY(-2px);
}

/* View Plans Card */
.view-plans-card {
    background-color: var(--card-dark-bg);
    color: white;
    padding: 20px 40px 40px 40px;
}

.table-controls {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    font-size: 0.9em;
}

.show-entries select {
    background-color: #495d73;
    color: white;
    border: none;
    padding: 5px 10px;
    border-radius: 4px;
    margin-left: 5px;
    cursor: pointer;
}

.show-entries select:focus {
    outline: 2px solid var(--primary-blue);
}

.search-group {
    display: flex;
    align-items: center;
    background-color: white;
    border-radius: 4px;
    padding: 5px 10px;
    width: 200px;
}

.search-group input {
    border: none;
    background: none;
    padding: 8px 0;
    color: #333;
    outline: none;
    width: 100%;
}

.search-group i {
    color: #7f8c8d;
    margin-left: 5px;
}

.plans-table-wrapper {
    overflow-x: auto;
    border-radius: 4px;
    border: 1px solid rgba(255, 255, 255, 0.1);
}

.plans-table-wrapper table {
    width: 100%;
    border-collapse: collapse;
    font-size: 0.95em;
}

.plans-table-wrapper table thead {
    background-color: #495d73;
    color: #bdc3c7;
    text-align: left;
}

.plans-table-wrapper table th,
.plans-table-wrapper table td {
    padding: 12px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.plans-table-wrapper table tbody tr:hover {
    background-color: rgba(255, 255, 255, 0.05);
}

.plans-table-wrapper table tbody tr:last-child td {
    border-bottom: none;
}

.action-buttons {
    display: flex;
    gap: 5px;
    justify-content: flex-end;
}

.edit-btn {
    background-color: white;
    color: var(--primary-blue);
    border: 1px solid var(--primary-blue);
    padding: 5px 15px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 0.8em;
    transition: all 0.2s;
    display: inline-flex;
    align-items: center;
    gap: 3px;
    text-decoration: none;
}

.edit-btn:hover {
    background-color: var(--primary-blue);
    color: white;
    transform: translateY(-1px);
}

.delete-btn {
    background-color: var(--error-red);
    color: white;
    border: 1px solid var(--error-red);
    padding: 5px 15px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 0.8em;
    transition: all 0.2s;
    display: inline-flex;
    align-items: center;
    gap: 3px;
}

.delete-btn:hover {
    background-color: #c0392b;
    transform: translateY(-1px);
}

.plans-table-wrapper th:last-child,
.plans-table-wrapper td:last-child {
    text-align: right;
    width: 200px;
}

/* No data message */
.no-data {
    text-align: center;
    padding: 20px;
    color: #bdc3c7;
    font-style: italic;
}

/* Field error */
.field-error {
    color: #e74c3c;
    font-size: 0.8em;
    margin-top: 5px;
}

/* Responsive */
@media (max-width: 768px) {
    .dashboard-container {
        flex-direction: column;
    }
    
    .sidebar {
        width: 100%;
    }
    
    .form-row {
        flex-direction: column;
    }
    
    .two-cols > .form-group,
    .single-col > .form-group {
        max-width: 100%;
    }
    
    .table-controls {
        flex-direction: column;
        gap: 10px;
        align-items: flex-start;
    }
    
    .search-group {
        width: 100%;
    }
    
    .action-buttons {
        flex-direction: column;
    }
}
</style>
<body>
<div class="dashboard-container">

    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="admin-profile">
            <i class="fas fa-user-circle profile-icon"></i>
            <div class="admin-name">Admin Name</div>
            <div class="admin-email">arnoldmuscle07@gamil.com</div>
        </div>
        <nav class="navigation">
            <ul>
                <li class="nav-item">
                    <a href="<%=ctx%>/JSP/dashboard.jsp">
                        <i class="fas fa-chart-line"></i>
                        <span>Dashboard</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%=ctx%>/JSP/admin.jsp">
                        <i class="fas fa-user-shield"></i>
                        <span>Admin</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%=ctx%>/JSP/registration.jsp">
                        <i class="fas fa-clipboard-list"></i>
                        <span>Registration</span>
                    </a>
                </li>
                <li class="nav-item active">
                    <a href="<%=ctx%>/membershipServlet" class="active-link">
                        <i class="fas fa-id-card"></i>
                        <span>Membership</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%=ctx%>/JSP/addinventory.jsp">
                        <i class="fas fa-box-open"></i>
                        <span>Add Inventory</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%=ctx%>/JSP/payment.jsp">
                        <i class="fas fa-hand-holding-usd"></i>
                        <span>Payment</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%=ctx%>/JSP/viewmembers.jsp">
                        <i class="fas fa-users"></i>
                        <span>View Members</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="profitExpenses">
                        <i class="fas fa-file-invoice-dollar"></i>
                        <span>Profit & Expenses</span>
                    </a>
                </li>
            </ul>
        </nav>
        <div class="logout">
            <a href="<%=ctx%>/JSP/login.jsp">
                <i class="fas fa-sign-out-alt"></i>
                <span>Logout</span>
            </a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <header class="top-header">
            <div class="logo-and-title">
                <img src="<%=ctx%>/images/Logo.jpg" alt="Logo" class="gym-logo">
                <div class="gym-title">ARNOLD MUSCLE MECHANIC</div>
            </div>
        </header>

        <!-- Success/Error Messages -->
        <div class="messages">
            <% if (successMessage != null) { %>
                <div class="success-message">
                    <i class="fas fa-check-circle"></i> <%= successMessage %>
                </div>
            <% } %>
            <% if (errorMessage != null) { %>
                <div class="error-message">
                    <i class="fas fa-exclamation-circle"></i> <%= errorMessage %>
                </div>
            <% } %>
        </div>

        <div class="membership-page-container">

            <div class="add-plan-card card <% if (planToEdit != null) { %>edit-mode<% } %>" id="addPlanCard">
                <div class="card-title-pill" id="formTitle">
                    <% if (planToEdit != null) { %>Edit Plan<% } else { %>Add Plan<% } %>
                </div>

                <form class="plan-form" action="<%=ctx%>/membershipServlet" method="POST" id="planForm">
                    <% if (planToEdit != null) { %>
                        <input type="hidden" id="planId" name="planId" value="<%= planToEdit.getId() %>">
                        <input type="hidden" id="actionType" name="action" value="update">
                    <% } else { %>
                        <input type="hidden" id="planId" name="planId" value="">
                        <input type="hidden" id="actionType" name="action" value="save">
                    <% } %>
                    
                    <div class="form-row two-cols">
                        <div class="form-group">
                            <label for="plan-name">Plan Name *</label>
                            <input type="text" id="plan-name" name="planName" required 
                                   placeholder="e.g., Monthly Premium" maxlength="100"
                                   value="<% if (planToEdit != null) { %><%= planToEdit.getPlanName() %><% } %>">
                        </div>
                        <div class="form-group">
                            <label for="validity">Validity (Days) *</label>
                            <input type="number" id="validity" name="validity" 
                                   placeholder="e.g., 30" required min="1" max="365"
                                   value="<% if (planToEdit != null) { %><%= planToEdit.getValidityDays() %><% } %>">
                        </div>
                    </div>

                    <div class="form-row single-col">
                        <div class="form-group amount-group">
                            <label for="amount">Amount (₹) *</label>
                            <input type="number" id="amount" name="amount" 
                                   step="0.01" placeholder="e.g., 1999.00" required min="0" max="999999.99"
                                   value="<% if (planToEdit != null) { %><%= planToEdit.getPrice() %><% } %>">
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary" id="submitBtn">
                            <% if (planToEdit != null) { %>
                                <i class="fas fa-sync-alt"></i> Update Plan
                            <% } else { %>
                                <i class="fas fa-save"></i> Save Plan
                            <% } %>
                        </button>
                        <% if (planToEdit != null) { %>
                            <a href="<%=ctx%>/membershipServlet" class="btn btn-cancel">
                                <i class="fas fa-times"></i> Cancel Edit
                            </a>
                        <% } else { %>
                            <button type="reset" class="btn btn-secondary">
                                <i class="fas fa-times"></i> Clear Form
                            </button>
                        <% } %>
                    </div>
                </form>
            </div>

            <div class="view-plans-card card">
                <div class="table-controls">
                    <div class="show-entries">
                        Show 
                        <select id="entriesSelect">
                            <option value="5">5</option>
                            <option value="10" selected>10</option>
                            <option value="25">25</option>
                            <option value="50">50</option>
                            <option value="100">100</option>
                            <option value="all">All</option>
                        </select>
                        entries
                    </div>
                    <div class="search-group">
                        <input type="text" id="searchInput" placeholder="Search plans...">
                        <i class="fas fa-search"></i>
                    </div>
                </div>

                <div class="plans-table-wrapper">
                    <table id="plansTable">
                        <thead>
                        <tr>
                            <th>ID</th>
                            <th>Plan Name</th>
                            <th>Validity (Days)</th>
                            <th>Amount (₹)</th>
                            <th>Actions</th>
                        </tr>
                        </thead>
                        <tbody id="plansTableBody">
                            <% if (plans != null && !plans.isEmpty()) { 
                                for (MembershipPlan plan : plans) { 
                            %>
                                <tr data-id="<%= plan.getId() %>">
                                    <td><%= plan.getId() %></td>
                                    <td><%= plan.getPlanName() %></td>
                                    <td><%= plan.getValidityDays() %></td>
                                    <td>₹<%= String.format("%.2f", plan.getPrice()) %></td>
                                    <td>
                                        <div class="action-buttons">
                                            <a href="<%=ctx%>/membershipServlet?edit=<%= plan.getId() %>" class="edit-btn">
                                                <i class="fas fa-edit"></i> Edit
                                            </a>
                                            <form method="POST" action="<%=ctx%>/membershipServlet" 
                                                  style="display: inline;">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="planId" value="<%= plan.getId() %>">
                                                <button type="submit" class="delete-btn" 
                                                        onclick="return confirm('Are you sure you want to delete this plan?')">
                                                    <i class="fas fa-trash"></i> Delete
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            <% } 
                            } else { %>
                                <tr>
                                    <td colspan="5" class="no-data">No membership plans found. Add your first plan above.</td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

            </div>

        </div>
    </div>
</div>

<script>
// Search functionality
document.getElementById('searchInput').addEventListener('keyup', function() {
    const searchTerm = this.value.toLowerCase();
    const rows = document.querySelectorAll('#plansTableBody tr');
    let visibleCount = 0;
    
    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        if (text.includes(searchTerm)) {
            row.style.display = '';
            visibleCount++;
        } else {
            row.style.display = 'none';
        }
    });
    
    // Show no results message
    const tbody = document.getElementById('plansTableBody');
    let noResults = tbody.querySelector('.no-results');
    
    if (visibleCount === 0 && !noResults) {
        noResults = document.createElement('tr');
        noResults.className = 'no-results';
        noResults.innerHTML = '<td colspan="5" style="text-align: center; padding: 20px; color: #bdc3c7;">No matching plans found</td>';
        tbody.appendChild(noResults);
    } else if (noResults && visibleCount > 0) {
        noResults.remove();
    }
});

// Show entries functionality
document.getElementById('entriesSelect').addEventListener('change', function() {
    const rowsPerPage = this.value;
    const rows = document.querySelectorAll('#plansTableBody tr:not(.no-data):not(.no-results)');
    
    if (rowsPerPage === 'all') {
        rows.forEach(row => row.style.display = '');
    } else {
        const limit = parseInt(rowsPerPage);
        rows.forEach((row, index) => {
            if (index < limit) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }
});

// Auto-hide messages after 5 seconds
setTimeout(function() {
    const messages = document.querySelectorAll('.success-message, .error-message');
    messages.forEach(message => {
        message.style.opacity = '0';
        message.style.transition = 'opacity 0.5s';
        setTimeout(() => {
            if (message.parentNode) {
                message.style.display = 'none';
            }
        }, 500);
    });
}, 5000);

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    // Trigger entries display
    const entriesSelect = document.getElementById('entriesSelect');
    if (entriesSelect) {
        setTimeout(() => {
            entriesSelect.dispatchEvent(new Event('change'));
        }, 100);
    }
    
    // Clear search on escape
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                this.value = '';
                this.dispatchEvent(new Event('keyup'));
            }
        });
    }
    
    // If we're in edit mode, scroll to form
    <% if (planToEdit != null) { %>
        document.getElementById('addPlanCard').scrollIntoView({ 
            behavior: 'smooth', 
            block: 'start' 
        });
    <% } %>
});
</script>
</body>
</html>