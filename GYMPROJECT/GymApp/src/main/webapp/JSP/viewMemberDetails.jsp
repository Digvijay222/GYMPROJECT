<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Customer, java.time.LocalDate, java.time.Period" %>
<%
    String ctx = request.getContextPath();
    Customer customer = (Customer) request.getAttribute("customer");
    if (customer == null) {
        response.sendRedirect(ctx + "/CustomerServlet?action=list");
        return;
    }

    Integer age = null;
    if (customer.getDateOfBirth() != null) {
        age = Period.between(customer.getDateOfBirth(), LocalDate.now()).getYears();
    }
    
    // Check if we're in edit mode from request parameter
    boolean editMode = "true".equals(request.getParameter("edit"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Arnold Muscle Mechanic - Member Details</title>
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        :root {
            --primary-dark: #1e293b;
            --secondary-dark: #2d3748;
            --accent-blue: #3b82f6;
            --text-light: #ffffff;
            --text-gray: #a0aec0;
            --text-dark: #333;
            --background-light: #e2e8f0;
            --status-red: #f56565;
            --status-green: #48bb78;
            --border-color: #4a5568;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }

        body {
            background-color: var(--background-light);
            color: var(--text-light);
        }

        .dashboard-container { display: flex; min-height: 100vh; }

        .sidebar {
            width: 280px;
            background-color: var(--primary-dark);
            padding: 20px 0;
            display: flex;
            flex-direction: column;
            box-shadow: 2px 0 5px rgba(0,0,0,0.2);
        }

        .admin-profile { text-align: center; padding: 20px; border-bottom: 1px solid var(--border-color); margin-bottom: 20px; }
        .profile-icon { font-size: 50px; color: var(--text-light); margin-bottom: 10px; }
        .admin-name { font-size: 1.2em; margin: 5px 0; }
        .admin-email { font-size: 0.85em; color: var(--text-gray); }

        .sidebar-nav ul { list-style: none; }
        .sidebar-nav li a { display: block; padding: 15px 25px; text-decoration: none; color: var(--text-light); font-size: 1em; transition: background-color 0.2s; }
        .sidebar-nav li a i { margin-right: 15px; width: 20px; text-align: center; }
        .sidebar-nav li.active a { background-color: white; color: black; border-left: 5px solid var(--accent-blue); padding-left: 20px; }

        .logout-section { margin-top: auto; padding: 15px 25px; border-top: 1px solid var(--border-color); }
        .logout-section a { text-decoration: none; color: var(--text-light); display: block; font-size: 1em; }

        .main-content {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            padding: 30px;
            color: var(--text-dark);
        }

        .main-header { display:flex; align-items:center; padding:15px 0; margin-bottom:20px; }
        .main-header img { border-radius:10px; }
        .header-title h2 { color: var(--primary-dark); font-size:1.5em; font-weight:bold; padding:20px; }

        .page-title { 
            color: var(--primary-dark); 
            font-size: 1.8em; 
            font-weight: bold; 
            margin-bottom:25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .members-panel {
            background-color: var(--primary-dark);
            color: var(--text-light);
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            flex-grow: 1;
        }

        .panel-title { 
            font-size:1.4em; 
            font-weight:bold; 
            margin-bottom:20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border-color);
        }

        .back-link { margin-bottom: 15px; }
        .back-link a { color: var(--text-gray); text-decoration: none; font-size: 0.9em; }
        .back-link a:hover { text-decoration: underline; }

        .member-details-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }

        .detail-section {
            background-color: var(--secondary-dark);
            padding: 20px;
            border-radius: 6px;
        }

        .detail-section h4 {
            color: var(--accent-blue);
            margin-bottom: 15px;
            font-size: 1.1em;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 8px;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
            padding-bottom: 8px;
            border-bottom: 1px dashed rgba(255,255,255,0.1);
        }

        .detail-label {
            color: var(--text-gray);
            font-weight: 500;
            font-size: 0.9em;
        }

        .detail-value {
            color: var(--text-light);
            font-weight: 500;
            text-align: right;
            max-width: 60%;
        }

        .detail-value input,
        .detail-value textarea,
        .detail-value select {
            width: 100%;
            padding: 6px 8px;
            border-radius: 4px;
            border: 1px solid var(--border-color);
            background-color: #0f172a;
            color: var(--text-light);
            font-size: 0.9em;
        }

        .detail-value input:focus,
        .detail-value textarea:focus,
        .detail-value select:focus {
            outline: none;
            border-color: var(--accent-blue);
        }

        .detail-value textarea {
            resize: vertical;
            min-height: 80px;
        }

        .button-container {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid var(--border-color);
        }

        .btn {
            padding: 10px 25px;
            border-radius: 4px;
            border: none;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.95em;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }

        .btn-edit {
            background-color: var(--accent-blue);
            color: white;
        }

        .btn-edit:hover {
            background-color: #2563eb;
        }

        .btn-save {
            background-color: var(--status-green);
            color: white;
        }

        .btn-save:hover {
            background-color: #38a169;
        }

        .btn-cancel {
            background-color: var(--secondary-dark);
            color: var(--text-light);
            border: 1px solid var(--border-color);
        }

        .btn-cancel:hover {
            background-color: #374151;
        }

        .status-badge {
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 0.8em;
            font-weight: 600;
        }

        .status-active {
            background-color: rgba(72, 187, 120, 0.2);
            color: var(--status-green);
        }

        .status-inactive {
            background-color: rgba(245, 101, 101, 0.2);
            color: var(--status-red);
        }

        .read-only {
            background: transparent;
            border: none;
            color: var(--text-light);
            font-weight: 500;
            pointer-events: none;
        }

        .member-id {
            background-color: rgba(59, 130, 246, 0.1);
            color: var(--accent-blue);
            padding: 5px 15px;
            border-radius: 4px;
            font-weight: 600;
        }
        
        /* New style for form display */
        .display-text {
            padding: 5px 0;
            min-height: 32px;
            display: block;
        }
    </style>
</head>
<body>
<div class="dashboard-container">
    <aside class="sidebar">
        <div class="admin-profile">
            <i class="fas fa-user-circle profile-icon"></i>
            <h3 class="admin-name">Admin Name</h3>
            <p class="admin-email">arnoldmuscle07@gml.com</p>
        </div>
        <nav class="sidebar-nav">
            <ul>
                <li><a href="<%=ctx%>/JSP/dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="<%=ctx%>/JSP/admin.jsp"><i class="fas fa-user-shield"></i> Admin</a></li>
                <li><a href="<%=ctx%>/JSP/registration.jsp"><i class="fas fa-user-plus"></i> Registration</a></li>
                <li><a href="<%=ctx%>/JSP/membership.jsp"><i class="fas fa-address-card"></i> Membership</a></li>
                <li><a href="<%=ctx%>/JSP/addinventory.jsp"><i class="fas fa-box"></i> Add Inventory</a></li>
                <li><a href="<%=ctx%>/JSP/payment.jsp"><i class="fas fa-credit-card"></i> Payment</a></li>
                <li class="active"><a href="<%=ctx%>/CustomerServlet?action=list"><i class="fas fa-users"></i> View Members</a></li>
                <li><a href="<%=ctx%>/profit-expenses"><i class="fas fa-chart-line"></i> Profit & Expenses</a></li>
            </ul>
        </nav>
        <div class="logout-section">
            <a href="<%=ctx%>/JSP/login.jsp"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </aside>

    <main class="main-content">
        <header class="main-header">
            <img src="<%=ctx%>/images/Logo.jpg" width="40" height="80" alt="Logo">
            <div class="header-title">
                <h2>ARNOLD MUSCLE MECHANIC</h2>
            </div>
        </header>

        <div class="page-title">
            <span>Member Details</span>
            <div class="member-id">M<%= String.format("%03d", customer.getId()) %></div>
        </div>

        <div class="members-panel">
            <div class="back-link">
                <a href="<%=ctx%>/CustomerServlet?action=list">&larr; Back to Members</a>
            </div>
            
            <h3 class="panel-title">
                <i class="fas fa-user"></i> <%= customer.getName() != null ? customer.getName() : "N/A" %>
            </h3>

            <form method="post" action="<%=ctx%>/CustomerServlet" id="memberForm">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="id" value="<%= customer.getId() %>">

                <div class="member-details-container">
                    <!-- Personal Information -->
                    <div class="detail-section">
                        <h4><i class="fas fa-id-card"></i> Personal Information</h4>
                        
                        <div class="detail-row">
                            <span class="detail-label">Full Name:</span>
                            <span class="detail-value">
                                <% if(editMode) { %>
                                    <input type="text" name="name" value="<%= customer.getName() != null ? customer.getName() : "" %>">
                                <% } else { %>
                                    <span class="display-text"><%= customer.getName() != null ? customer.getName() : "N/A" %></span>
                                <% } %>
                            </span>
                        </div>
                        
                        <div class="detail-row">
                            <span class="detail-label">Gender:</span>
                            <span class="detail-value">
                                <% if(editMode) { %>
                                    <select name="gender">
                                        <option value="Male" <%= "Male".equals(customer.getGender()) ? "selected" : "" %>>Male</option>
                                        <option value="Female" <%= "Female".equals(customer.getGender()) ? "selected" : "" %>>Female</option>
                                        <option value="Other" <%= "Other".equals(customer.getGender()) ? "selected" : "" %>>Other</option>
                                    </select>
                                <% } else { %>
                                    <span class="display-text"><%= customer.getGender() != null ? customer.getGender() : "N/A" %></span>
                                <% } %>
                            </span>
                        </div>
                        
                        <div class="detail-row">
                            <span class="detail-label">Date of Birth:</span>
                            <span class="detail-value">
                                <% if(editMode) { %>
                                    <input type="date" name="dateOfBirth" 
                                           value="<%= customer.getDateOfBirth() != null ? customer.getDateOfBirth().toString() : "" %>">
                                <% } else { %>
                                    <span class="display-text"><%= customer.getDateOfBirth() != null ? customer.getDateOfBirth() : "N/A" %></span>
                                <% } %>
                            </span>
                        </div>
                        
                        <div class="detail-row">
                            <span class="detail-label">Age:</span>
                            <span class="detail-value">
                                <span class="display-text"><%= age != null ? age : "N/A" %></span>
                            </span>
                        </div>
                        
                        <div class="detail-row">
                            <span class="detail-label">Height:</span>
                            <span class="detail-value">
                                <% if(editMode) { %>
                                    <input type="text" name="height" value="<%= customer.getHeight() > 0 ? customer.getHeight() : "" %>">
                                <% } else { %>
                                    <span class="display-text"><%= customer.getHeight() > 0 ? customer.getHeight() : "N/A" %></span>
                                <% } %>
                            </span>
                        </div>
                        
                        <div class="detail-row">
                            <span class="detail-label">Weight:</span>
                            <span class="detail-value">
                                <% if(editMode) { %>
                                    <input type="text" name="weight" value="<%= customer.getWeight() > 0 ? customer.getWeight() : "" %>">
                                <% } else { %>
                                    <span class="display-text"><%= customer.getWeight() > 0 ? customer.getWeight() : "N/A" %></span>
                                <% } %>
                            </span>
                        </div>
                    </div>

                    <!-- Contact Information -->
                    <div class="detail-section">
                        <h4><i class="fas fa-address-book"></i> Contact Information</h4>
                        
                        <div class="detail-row">
                            <span class="detail-label">Mobile:</span>
                            <span class="detail-value">
                                <% if(editMode) { %>
                                    <input type="text" name="mobileNumber" 
                                           value="<%= customer.getMobileNumber() != null ? customer.getMobileNumber() : "" %>">
                                <% } else { %>
                                    <span class="display-text"><%= customer.getMobileNumber() != null ? customer.getMobileNumber() : "N/A" %></span>
                                <% } %>
                            </span>
                        </div>
                        
                        <div class="detail-row">
                            <span class="detail-label">Email:</span>
                            <span class="detail-value">
                                <% if(editMode) { %>
                                    <input type="email" name="email" 
                                           value="<%= customer.getEmail() != null ? customer.getEmail() : "" %>">
                                <% } else { %>
                                    <span class="display-text"><%= customer.getEmail() != null ? customer.getEmail() : "N/A" %></span>
                                <% } %>
                            </span>
                        </div>
                        
                        <div class="detail-row">
                            <span class="detail-label">Address:</span>
                            <span class="detail-value">
                                <% if(editMode) { %>
                                    <textarea name="address"><%= customer.getAddress() != null ? customer.getAddress() : "" %></textarea>
                                <% } else { %>
                                    <span class="display-text"><%= customer.getAddress() != null ? customer.getAddress() : "N/A" %></span>
                                <% } %>
                            </span>
                        </div>
                    </div>

                    <!-- Membership Information -->
                    <div class="detail-section">
                        <h4><i class="fas fa-id-badge"></i> Membership Information</h4>
                        
                        <div class="detail-row">
                            <span class="detail-label">Date Enrolled:</span>
                            <span class="detail-value">
                                <% if(editMode) { %>
                                    <input type="date" name="enrolledOn" 
                                           value="<%= customer.getEnrolledOn() != null ? customer.getEnrolledOn().toString() : "" %>">
                                <% } else { %>
                                    <span class="display-text"><%= customer.getEnrolledOn() != null ? customer.getEnrolledOn() : "N/A" %></span>
                                <% } %>
                            </span>
                        </div>
                        
                        <div class="detail-row">
                            <span class="detail-label">Expiry Date:</span>
                            <span class="detail-value">
                                <% if(editMode) { %>
                                    <input type="date" name="expiryDate" 
                                           value="<%= customer.getExpiryDate() != null ? customer.getExpiryDate().toString() : "" %>">
                                <% } else { %>
                                    <span class="display-text"><%= customer.getExpiryDate() != null ? customer.getExpiryDate() : "N/A" %></span>
                                <% } %>
                            </span>
                        </div>
                        
                        <div class="detail-row">
                            <span class="detail-label">Payment Status:</span>
                            <span class="detail-value">
                                <% if(editMode) { %>
                                    <select name="paymentStatus">
                                        <option value="Paid" <%= "Paid".equals(customer.getPaymentStatus()) ? "selected" : "" %>>Paid</option>
                                        <option value="Pending" <%= "Pending".equals(customer.getPaymentStatus()) ? "selected" : "" %>>Pending</option>
                                        <option value="Overdue" <%= "Overdue".equals(customer.getPaymentStatus()) ? "selected" : "" %>>Overdue</option>
                                    </select>
                                <% } else { %>
                                    <span class="status-badge <%= "Paid".equals(customer.getPaymentStatus()) ? "status-active" : "status-inactive" %>">
                                        <%= customer.getPaymentStatus() != null ? customer.getPaymentStatus() : "N/A" %>
                                    </span>
                                <% } %>
                            </span>
                        </div>
                        
                        <div class="detail-row">
                            <span class="detail-label">Plan ID:</span>
                            <span class="detail-value">
                                <% if(editMode) { %>
                                    <input type="text" name="planId" 
                                           value="<%= customer.getPlanId() != null ? customer.getPlanId() : "" %>">
                                <% } else { %>
                                    <span class="display-text"><%= customer.getPlanId() != null ? customer.getPlanId() : "N/A" %></span>
                                <% } %>
                            </span>
                        </div>
                        
                        <div class="detail-row">
                            <span class="detail-label">Plan Type:</span>
                            <span class="detail-value">
                                <% if(editMode) { %>
                                    <input type="text" name="planType" 
                                           value="<%= customer.getPlanType() != null ? customer.getPlanType() : "" %>">
                                <% } else { %>
                                    <span class="display-text"><%= customer.getPlanType() != null ? customer.getPlanType() : "N/A" %></span>
                                <% } %>
                            </span>
                        </div>
                        
                        <div class="detail-row">
                            <span class="detail-label">Time Slot:</span>
                            <span class="detail-value">
                                <% if(editMode) { %>
                                    <input type="text" name="timeSlot" 
                                           value="<%= customer.getTimeSlot() != null ? customer.getTimeSlot() : "" %>">
                                <% } else { %>
                                    <span class="display-text"><%= customer.getTimeSlot() != null ? customer.getTimeSlot() : "N/A" %></span>
                                <% } %>
                            </span>
                        </div>
                    </div>

                    <!-- Medical Information -->
                    <div class="detail-section">
                        <h4><i class="fas fa-heartbeat"></i> Medical Information</h4>
                        
                        <div class="detail-row">
                            <span class="detail-label">Medical Notes:</span>
                            <span class="detail-value">
                                <% if(editMode) { %>
                                    <textarea name="medicalNotes"><%= customer.getMedicalNotes() != null ? customer.getMedicalNotes() : "" %></textarea>
                                <% } else { %>
                                    <span class="display-text"><%= customer.getMedicalNotes() != null && !customer.getMedicalNotes().isEmpty() 
                                        ? customer.getMedicalNotes() : "No medical notes available" %></span>
                                <% } %>
                            </span>
                        </div>
                    </div>
                </div>

                <div class="button-container">
                    <% if(!editMode) { %>
                        <a href="<%=ctx%>/CustomerServlet?action=list" class="btn btn-cancel">
                            <i class="fas fa-arrow-left"></i> Back to List
                        </a>
                        <a href="<%=ctx%>/CustomerServlet?action=view&id=<%= customer.getId() %>&edit=true" class="btn btn-edit">
                            <i class="fas fa-edit"></i> Edit Member
                        </a>
                    <% } else { %>
                        <a href="<%=ctx%>/CustomerServlet?action=view&id=<%= customer.getId() %>" class="btn btn-cancel">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                        <button type="submit" class="btn btn-save">
                            <i class="fas fa-save"></i> Save Changes
                        </button>
                    <% } %>
                </div>
            </form>
        </div>
    </main>
</div>

<script>
    // Form validation before submission
    document.getElementById('memberForm')?.addEventListener('submit', function(e) {
        const mobileInput = document.querySelector('input[name="mobileNumber"]');
        const emailInput = document.querySelector('input[name="email"]');
        
        // Validate mobile number
        if(mobileInput && mobileInput.value) {
            const mobileRegex = /^[0-9+\-\s()]{10,}$/;
            if(!mobileRegex.test(mobileInput.value)) {
                alert('Please enter a valid mobile number');
                mobileInput.focus();
                e.preventDefault();
                return;
            }
        }
        
        // Validate email
        if(emailInput && emailInput.value) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if(!emailRegex.test(emailInput.value)) {
                alert('Please enter a valid email address');
                emailInput.focus();
                e.preventDefault();
                return;
            }
        }
        
        // Validate date sequence
        const enrolledDate = document.querySelector('input[name="enrolledOn"]');
        const expiryDate = document.querySelector('input[name="expiryDate"]');
        const dobDate = document.querySelector('input[name="dateOfBirth"]');
        
        if(enrolledDate && expiryDate && enrolledDate.value && expiryDate.value) {
            if(new Date(expiryDate.value) <= new Date(enrolledDate.value)) {
                alert('Expiry date must be after enrollment date');
                expiryDate.focus();
                e.preventDefault();
                return;
            }
        }
        
        if(dobDate && dobDate.value) {
            const dob = new Date(dobDate.value);
            const today = new Date();
            const age = today.getFullYear() - dob.getFullYear();
            
            if(age < 16) {
                alert('Member must be at least 16 years old');
                dobDate.focus();
                e.preventDefault();
                return;
            }
        }
    });
</script>
</body>
</html>