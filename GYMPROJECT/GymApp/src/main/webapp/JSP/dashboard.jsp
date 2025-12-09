<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter, java.util.List, model.*, dao.*, java.text.SimpleDateFormat, java.util.Date, java.util.Calendar" %>
<%
    String ctx = request.getContextPath();

    // Data from servlet
    Double attendancePercent = (Double) request.getAttribute("attendancePercent");
    Integer totalMembers     = (Integer) request.getAttribute("totalMembers");
    Integer attendedToday    = (Integer) request.getAttribute("attendedToday");
    List<MembershipPlan> plans       = (List<MembershipPlan>) request.getAttribute("plans");
    List<Customer>        activeMembers = (List<Customer>) request.getAttribute("activeMembers");
    List<Equipment>       equipmentList = (List<Equipment>) request.getAttribute("equipmentList");
    Double totalRevenue = (Double) request.getAttribute("totalRevenue");
    Double totalExpenses = (Double) request.getAttribute("totalExpenses");
    Double totalProfit   = (Double) request.getAttribute("totalProfit");

    // Defaults
    if (attendancePercent == null) attendancePercent = 85.0;
    if (totalMembers == null)      totalMembers = 0;
    if (attendedToday == null)     attendedToday = 0;
    if (totalRevenue == null)      totalRevenue = 0.0;
    if (totalExpenses == null)     totalExpenses = 0.0;
    if (totalProfit == null)       totalProfit = 0.0;

    // Cap attendance percentage at 100%
    if (attendancePercent > 100.0) {
        attendancePercent = 100.0;
    }

    // Percentages for revenue donut & labels
    double revPercent = 0, expPercent = 0, profPercent = 0;
    double totalAbs = totalRevenue + totalExpenses + Math.abs(totalProfit);
    if (totalAbs > 0) {
        revPercent  = (totalRevenue  / totalAbs) * 100.0;
        expPercent  = (totalExpenses / totalAbs) * 100.0;
        profPercent = (Math.abs(totalProfit) / totalAbs) * 100.0;
    }
    double revEnd = revPercent;
    double expEnd = revPercent + expPercent;

    // formatted strings
    String revEndStr      = String.format("%.1f", revEnd);
    String expEndStr      = String.format("%.1f", expEnd);
    String revPercentStr  = String.format("%.1f", revPercent);
    String expPercentStr  = String.format("%.1f", expPercent);
    String profPercentStr = String.format("%.1f", profPercent);

    // date / time
    LocalDateTime now = LocalDateTime.now();
    DateTimeFormatter dayFormatter  = DateTimeFormatter.ofPattern("EEEE");
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("hh:mm a");

    User loggedUser = (User) session.getAttribute("loggedUser");
    
    // Get success/error messages for inventory update
    String inventorySuccess = (String) session.getAttribute("inventorySuccess");
    String inventoryError = (String) session.getAttribute("inventoryError");
    
    // Clear messages after displaying
    if (inventorySuccess != null) {
        session.removeAttribute("inventorySuccess");
    }
    if (inventoryError != null) {
        session.removeAttribute("inventoryError");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Gym Admin Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* ===== BASE ===== */
        *{
            box-sizing:border-box;
            margin:0;
            padding:0;
            font-family: "Segoe UI", Arial, sans-serif;
        }
        body{
            background:#e9edf2;
            color:#333;
        }
        a{ text-decoration:none; }

        /* ===== LAYOUT ===== */
        .dashboard-wrapper{
            min-height:100vh;
            display:flex;
        }

        /* ----- SIDEBAR ----- */
        .sidebar{
            width:250px;
            background:#1f3344;
            color:#fff;
            display:flex;
            flex-direction:column;
        }

        .sidebar-top{
            padding:25px 20px;
            border-bottom:1px solid rgba(255,255,255,0.1);
            text-align:center;
        }
        .sidebar-top .avatar{
            width:70px;
            height:70px;
            border-radius:50%;
            background:#314759;
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:34px;
            margin:0 auto 12px;
        }
        .sidebar-top .name{
            font-size:1.05rem;
            font-weight:600;
            margin-bottom:2px;
        }
        .sidebar-top .email{
            font-size:0.84rem;
            color:#c8d6e5;
        }

        .side-menu{
            list-style:none;
            padding:15px 0;
            flex:1;
        }
        .side-menu li{
            margin:2px 0;
        }
        .side-link{
            display:flex;
            align-items:center;
            padding:10px 20px;
            color:#ecf0f1;
            font-size:0.95rem;
            border-left:4px solid transparent;
        }
        .side-link i{
            margin-right:12px;
            width:18px;
            text-align:center;
            font-size:1.05rem;
        }
        .side-link:hover{
            background:#24384a;
        }
        .side-menu .active .side-link{
            background:#f5f7fb;
            color:#2c3e50;
            border-left-color:#3498db;
        }

        .logout-row{
            padding:10px 0 15px;
            border-top:1px solid rgba(255,255,255,0.1);
        }
        .logout-row .side-link{
            color:#f5f6fa;
        }
        .logout-row .side-link i{
            transform:rotate(180deg);
        }

        /* ----- MAIN AREA ----- */
        .main{
            flex:1;
            padding:0 25px 25px;
        }

        /* TOP BAR */
        .top-bar{
            height:70px;
            display:flex;
            align-items:center;
            justify-content:space-between;
            background:#f5f7fb;
            margin:0 -25px 20px -25px;
            padding:0 30px;
            box-shadow:0 1px 4px rgba(0,0,0,0.05);
        }
        .top-left{
            display:flex;
            align-items:center;
        }
        .top-left img{
            width:48px;
            height:48px;
            border-radius:4px;
            margin-right:12px;
            object-fit:cover;
            background:#ddd;
        }
        .top-title{
            font-size:1.4rem;
            font-weight:700;
            color:#274159;
            letter-spacing:0.05em;
        }
        .top-right{
            text-align:right;
            font-size:0.9rem;
            color:#555;
        }
        .top-right div{ line-height:1.4; }

        /* WELCOME BAR */
        .welcome-card{
            background:#ffffff;
            border-radius:6px;
            padding:15px 20px;
            margin-bottom:20px;
            display:flex;
            justify-content:space-between;
            align-items:center;
            box-shadow:0 2px 6px rgba(0,0,0,0.05);
        }
        .welcome-card span{
            font-size:1rem;
        }
        .welcome-card i{
            font-size:1.3rem;
            color:#6c7a89;
        }

        /* CONTENT ROWS */
        .row{
            display:flex;
            gap:20px;
            margin-bottom:20px;
        }
        .card{
            background:#ffffff;
            border-radius:6px;
            padding:18px 20px;
            box-shadow:0 2px 6px rgba(0,0,0,0.07);
        }

        .card-3{ flex:1; }
        .card-2{ flex:1; }

        .card h3{
            font-size:1rem;
            margin-bottom:15px;
            font-weight:600;
            color:#2d3e50;
        }

        /* Attendance circle */
        .attendance-center{
            display:flex;
            justify-content:center;
            align-items:center;
            margin:10px 0 5px;
        }
        .attendance-circle{
            width:150px;
            height:150px;
            border-radius:50%;
            display:flex;
            align-items:center;
            justify-content:center;
            position:relative;
        }
        .attendance-circle::before{
            content:"";
            width:130px;
            height:130px;
            background:#ffffff;
            border-radius:50%;
            position:absolute;
        }
        .attendance-text{
            position:relative;
            font-size:2rem;
            font-weight:700;
            color:#2980b9;
            z-index:1;
        }
        .attendance-info{
            text-align:center;
            font-size:0.9rem;
            margin-top:4px;
            color:#7f8c8d;
        }

        /* Plan card */
        .plan-search-box{
            margin-bottom:10px;
            display:flex;
            border-radius:4px;
            overflow:hidden;
            border:1px solid #dfe6ee;
        }
        .plan-search-box input{
            border:none;
            padding:7px 8px;
            flex:1;
            font-size:0.9rem;
            outline:none;
        }
        .plan-search-box button{
            border:none;
            background:#3498db;
            color:#fff;
            padding:0 12px;
            cursor:pointer;
        }
        .table-wrapper{
            max-height:300px;
            overflow-y:auto;
        }
        table{
            width:100%;
            border-collapse:collapse;
            font-size:0.9rem;
        }
        th{
            background:#f5f7fb;
            padding:8px 10px;
            text-align:left;
            border-bottom:1px solid #e1e6ef;
            font-weight:600;
            color:#556;
        }
        td{
            padding:7px 10px;
            border-bottom:1px solid #eef2f7;
        }

        /* Revenue card */
        .rev-layout{
            display:flex;
            align-items:center;
            gap:20px;
        }
        .rev-donut{
            width:120px;
            height:120px;
            border-radius:50%;
            position:relative;
            flex-shrink:0;
        }
        .rev-donut::after{
            content:"";
            position:absolute;
            top:50%;
            left:50%;
            width:70px;
            height:70px;
            border-radius:50%;
            background:#fff;
            transform:translate(-50%, -50%);
        }
        .rev-legend div{
            margin-bottom:6px;
            display:flex;
            align-items:center;
            font-size:0.9rem;
        }
        .rev-dot{
            width:10px;
            height:10px;
            border-radius:50%;
            margin-right:8px;
            display:inline-block;
        }
        .rev-r{ background:#3498db; }
        .rev-e{ background:#e74c3c; }
        .rev-p{ background:#2ecc71; }

        /* Bottom row */
        .sort-wrap{
            text-align:right;
            margin-bottom:8px;
            font-size:0.9rem;
        }
        .sort-wrap select{
            padding:4px 8px;
            border-radius:4px;
            border:1px solid #dfe4ea;
            font-size:0.85rem;
        }

        .status-active{ color:#27ae60; font-weight:600; }
        .status-pending{ color:#f39c12; font-weight:600; }
        .status-inactive{ color:#e74c3c; font-weight:600; }

        /* Inventory table actions */
        #inventoryTable td:last-child {
            white-space: nowrap;
            min-width: 140px;
        }

        .action-buttons {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }

        .inventory-btn{
            border:none;
            padding:4px 8px;
            border-radius:4px;
            font-size:0.8rem;
            background:#3498db;
            color:#fff;
            cursor:pointer;
            transition:background 0.3s;
            margin: 2px;
            display: inline-block;
        }
        .inventory-btn:hover{
            background:#2980b9;
        }
        
        .inventory-delete-btn {
            background:#e74c3c;
        }
        .inventory-delete-btn:hover{
            background:#c0392b;
        }

        /* MODAL STYLES */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            overflow: auto;
        }
        
        .modal-content {
            background-color: white;
            margin: 5% auto;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
            width: 50%;
            max-width: 500px;
            position: relative;
        }
        
        .close-modal {
            position: absolute;
            right: 20px;
            top: 15px;
            font-size: 28px;
            color: #7f8c8d;
            cursor: pointer;
            transition: color 0.3s;
        }
        
        .close-modal:hover {
            color: #e74c3c;
        }
        
        .modal h3 {
            color: #2c3e50;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #3498db;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #2c3e50;
            font-weight: 600;
        }
        
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            transition: border 0.3s;
        }
        
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            border-color: #3498db;
            outline: none;
            box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
        }
        
        .modal-buttons {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }
        
        .btn-save {
            background: #2ecc71;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
            transition: background 0.3s;
        }
        
        .btn-save:hover {
            background: #27ae60;
        }
        
        .btn-cancel {
            background: #e74c3c;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
            transition: background 0.3s;
        }
        
        .btn-cancel:hover {
            background: #c0392b;
        }
        
        .btn-delete {
            background: #e74c3c;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
            transition: background 0.3s;
            margin-right: auto;
        }
        
        .btn-delete:hover {
            background: #c0392b;
        }
        
        /* Message boxes */
        .message-box {
            padding: 12px 15px;
            border-radius: 4px;
            margin-bottom: 15px;
            animation: fadeIn 0.5s;
        }
        
        .success-box {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .error-box {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .no-data-message {
            text-align: center;
            padding: 30px 20px;
            color: #7f8c8d;
        }
        
        .no-data-message i {
            font-size: 2.5rem;
            margin-bottom: 15px;
            color: #bdc3c7;
        }
        
        .no-data-message p {
            font-size: 0.95rem;
            margin-top: 10px;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Active members summary */
        .active-members-summary {
            padding: 8px 10px;
            background: #f8f9fa;
            border-top: 1px solid #eee;
            font-size: 0.85rem;
            color: #2c3e50;
        }
        
        .active-members-summary i {
            margin-right: 5px;
        }

        /* Responsive */
        @media(max-width:900px){
            .dashboard-wrapper{
                flex-direction:column;
            }
            .sidebar{
                width:100%;
                flex-direction:row;
                overflow-x:auto;
                height:auto;
            }
            .main{
                padding:15px;
            }
            .top-bar{
                margin:-15px -15px 15px -15px;
            }
            .row{
                flex-direction:column;
            }
            .modal-content {
                width: 90%;
                margin: 10% auto;
                padding: 20px;
            }
            
            .action-buttons {
                flex-direction: column;
                align-items: stretch;
            }
            
            .inventory-btn {
                width: 100%;
                margin: 2px 0;
            }
        }
        
        /* Delete Confirmation Modal */
        .delete-confirmation {
            text-align: center;
            padding: 20px;
        }
        
        .delete-confirmation .modal-buttons {
            justify-content: center;
            border-top: none;
            padding-top: 0;
        }
        
        .delete-confirmation p {
            margin-bottom: 20px;
            font-size: 1.1em;
        }
        
        .warning-icon {
            font-size: 3em;
            color: #f39c12;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
<div class="dashboard-wrapper">
    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-top">
            <div class="avatar">
                <i class="fas fa-user"></i>
            </div>
            <div class="name">
                <%= (loggedUser != null) ? loggedUser.getName() : "Admin Name" %>
            </div>
            <div class="email">
                <%= (loggedUser != null) ? loggedUser.getEmail() : "arnoldmuscle07@gmail.com" %>
            </div>
        </div>

        <ul class="side-menu">
            <li class="active">
                <a class="side-link" href="<%=ctx%>/dashboard">
                    <i class="fas fa-columns"></i> <span>Dashboard</span>
                </a>
            </li>

            <li>
                <a class="side-link" href="<%=ctx%>/JSP/admin.jsp">
                    <i class="fas fa-user-shield"></i> <span>Admin</span>
                </a>
            </li>

            <li>
                <a class="side-link" href="<%=ctx%>/JSP/registration.jsp">
                    <i class="fas fa-clipboard-list"></i> <span>Registration</span>
                </a>
            </li>

            <li>
                <a class="side-link" href="<%=ctx%>/JSP/membership.jsp">
                    <i class="fas fa-id-card"></i> <span>Membership</span>
                </a>
            </li>

            <li>
                <a class="side-link" href="<%=ctx%>/JSP/inventory.jsp">
                    <i class="fas fa-dumbbell"></i> <span>Add Inventory</span>
                </a>
            </li>

            <li>
                <a class="side-link" href="<%=ctx%>/payment">
                    <i class="fas fa-rupee-sign"></i> <span>Payment</span>
                </a>
            </li>

            <li>
                <a class="side-link" href="<%=ctx%>/customers">
                    <i class="fas fa-users"></i> <span>View Members</span>
                </a>
            </li>

            <li>
                <a class="side-link" href="<%=ctx%>/expenses">
                    <i class="fas fa-file-invoice-dollar"></i> <span>Profit & Expenses</span>
                </a>
            </li>
        </ul>

        <div class="logout-row">
            <a class="side-link" href="<%=ctx%>/login.jsp">
                <i class="fas fa-sign-out-alt"></i> <span>Logout</span>
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="main">
        <!-- TOP BAR -->
        <div class="top-bar">
            <div class="top-left">
                <img src="<%=ctx%>/images/Logo.jpg" alt="Logo">
                <div class="top-title">ARNOLD MUSCLE MECHANIC</div>
            </div>
            <div class="top-right">
                <div>Day : <%= now.format(dayFormatter) %></div>
                <div>Date : <%= now.format(dateFormatter) %></div>
                <div>Time : <%= now.format(timeFormatter) %></div>
            </div>
        </div>

        <!-- WELCOME BAR -->
        <div class="welcome-card">
            <span>
                Welcome , 
                <%= (loggedUser != null) ? loggedUser.getName() : "Admin name" %>
            </span>
            <i class="fas fa-user-circle"></i>
        </div>

        <!-- Display Inventory Messages -->
        <% if (inventorySuccess != null && !inventorySuccess.isEmpty()) { %>
            <div class="message-box success-box">
                <i class="fas fa-check-circle"></i> <%= inventorySuccess %>
            </div>
        <% } %>
        
        <% if (inventoryError != null && !inventoryError.isEmpty()) { %>
            <div class="message-box error-box">
                <i class="fas fa-exclamation-circle"></i> <%= inventoryError %>
            </div>
        <% } %>

        <!-- TOP ROW -->
        <div class="row">
            <!-- Attendance -->
            <div class="card card-3">
                <h3>Today's Attendance</h3>
                <div class="attendance-center">
                    <div class="attendance-circle" 
                         style="background: conic-gradient(#3498db 0% <%= attendancePercent %>% , #eaf1f7 <%= attendancePercent %>% 100%);">
                        <div class="attendance-text">
                            <%= String.format("%.0f", attendancePercent) %>%
                        </div>
                    </div>
                </div>
                <div class="attendance-info">
                    <%= attendedToday %> / <%= totalMembers %> Members Present
                </div>
            </div>

            <!-- Plan -->
            <div class="card card-3" id="planCard">
                <h3>Membership Plans</h3>
                <div class="plan-search-box">
                    <input type="text" id="planSearch" placeholder="Search plans...">
                    <button type="button" onclick="searchPlan()">
                        <i class="fas fa-search"></i>
                    </button>
                </div>
                <div class="table-wrapper">
                    <table>
                        <thead>
                        <tr>
                            <th>Plan Name</th>
                            <th>Validity (Days)</th>
                            <th>Amount (₹)</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            if (plans != null && !plans.isEmpty()) {
                                for (MembershipPlan p : plans) {
                        %>
                        <tr>
                            <td><%= p.getPlanName() %></td>
                            <td><%= p.getValidityDays() %></td>
                            <td>₹<%= p.getPrice() %></td>
                        </tr>
                        <%      }
                            } else { %>
                        <tr>
                            <td colspan="3" style="text-align:center;">No plans found</td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Revenue -->
            <div class="card card-3">
                <h3>Revenue, Expenses and Profit (3 Months)</h3>
                <% if (totalRevenue == 0 && totalExpenses == 0 && totalProfit == 0) { %>
                    <div class="no-data-message">
                        <i class="fas fa-chart-line"></i>
                        <p>No financial data available for the last 3 months</p>
                    </div>
                <% } else { %>
                    <div class="rev-layout">
                        <!-- Donut -->
                        <div class="rev-donut"
                             style="background: conic-gradient(
                                 #3498db 0 <%= revEndStr %>%,
                                 #e74c3c <%= revEndStr %>% <%= expEndStr %>%,
                                 #2ecc71 <%= expEndStr %>% 100%
                             );">
                        </div>
                        <div class="rev-legend">
                            <div>
                                <span class="rev-dot rev-r"></span>
                                Revenue: ₹<%= String.format("%.2f", totalRevenue) %>
                            </div>
                            <div>
                                <span class="rev-dot rev-e"></span>
                                Expenses: ₹<%= String.format("%.2f", totalExpenses) %>
                            </div>
                            <div>
                                <span class="rev-dot rev-p"></span>
                                Profit: ₹<%= String.format("%.2f", totalProfit) %>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- BOTTOM ROW -->
        <div class="row">
            <!-- Active Members -->
            <div class="card card-2">
                <h3>Active Members (Eligible Today)</h3>
                <div class="sort-wrap">
                    Sort by:
                    <select onchange="sortActiveMembers(this.value)">
                        <option value="name">Name</option>
                        <option value="joined">Joined Date</option>
                        <option value="expiry">Expiry Date</option>
                    </select>
                </div>
                <div class="table-wrapper">
                    <table id="activeMembersTable">
                        <thead>
                        <tr>
                            <th>Name</th>
                            <th>Mobile</th>
                            <th>Joined Date</th>
                            <th>Expiry Date</th>
                            <th>Status</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            if (activeMembers != null && !activeMembers.isEmpty()) {
                                for (Customer m : activeMembers) {
                                    // Format dates
                                    String joinedDate = "-";
                                    String expiryDate = "-";
                                    
                                    if (m.getEnrolledOn() != null) {
                                        joinedDate = m.getEnrolledOn().toString();
                                    }
                                    
                                    if (m.getExpiryDate() != null) {
                                        expiryDate = m.getExpiryDate().toString();
                                    }
                        %>
                        <tr data-name="<%= m.getName() %>" 
                            data-joined="<%= joinedDate %>" 
                            data-expiry="<%= expiryDate %>">
                            <td><%= m.getName() %></td>
                            <td><%= m.getMobileNumber() != null ? m.getMobileNumber() : "-" %></td>
                            <td><%= joinedDate %></td>
                            <td><%= expiryDate %></td>
                            <td class="status-active">
                                <i class="fas fa-check-circle" style="margin-right: 5px;"></i> Active
                            </td>
                        </tr>
                        <%      }
                            } else { %>
                        <tr>
                            <td colspan="5" style="text-align:center;">
                                <i class="fas fa-users-slash" style="color: #95a5a6; font-size: 1.5rem; margin-bottom: 10px; display: block;"></i>
                                No active members found
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                
                <% if (activeMembers != null && !activeMembers.isEmpty()) { %>
                <div class="active-members-summary">
                    <i class="fas fa-user-check"></i>
                    Total active members: <strong><%= activeMembers.size() %></strong>
                </div>
                <% } %>
            </div>

            <!-- Inventory -->
            <div class="card card-2">
                <h3>Gym Equipment Inventory</h3>
                <div class="table-wrapper">
                    <table id="inventoryTable">
                        <thead>
                        <tr>
                            <th>Equipment Name</th>
                            <th>Quantity</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            if (equipmentList != null && !equipmentList.isEmpty()) {
                                for (Equipment eq : equipmentList) {
                                    String statusClass = "status-active";
                                    if (eq.getStatus() != null) {
                                        if (eq.getStatus().contains("Maintenance") || eq.getStatus().contains("Broken")) {
                                            statusClass = "status-inactive";
                                        } else if ("Regular".equalsIgnoreCase(eq.getStatus())) {
                                            statusClass = "status-pending";
                                        }
                                    }
                        %>
                        <tr data-id="<%= eq.getId() %>" data-name="<%= eq.getName() %>" 
                            data-quantity="<%= eq.getQuantity() %>" data-status="<%= eq.getStatus() %>"
                            data-description="<%= eq.getDescription() != null ? eq.getDescription() : "" %>">
                            <td><%= eq.getName() %></td>
                            <td><%= eq.getQuantity() %></td>
                            <td class="<%= statusClass %>"><%= eq.getStatus() %></td>
                            <td>
                                <div class="action-buttons">
                                    <button class="inventory-btn" type="button"
                                            onclick="editEquipment(<%= eq.getId() %>, this)">Edit</button>
                                    <button class="inventory-btn inventory-delete-btn" type="button"
                                            onclick="deleteEquipment(<%= eq.getId() %>, '<%= eq.getName().replace("'", "\\'") %>')">Delete</button>
                                </div>
                            </td>
                        </tr>
                        <%      }
                            } else { %>
                        <tr>
                            <td colspan="4" style="text-align:center;">
                                <i class="fas fa-dumbbell" style="color: #95a5a6; font-size: 1.5rem; margin-bottom: 10px; display: block;"></i>
                                No equipment found
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </main>
</div>

<!-- Edit Inventory Modal -->
<div id="editInventoryModal" class="modal">
    <div class="modal-content">
        <span class="close-modal" onclick="closeEditModal()">&times;</span>
        <h3>Edit Equipment</h3>
        
        <form id="editInventoryForm" action="<%=ctx%>/updateInventory" method="POST">
            <input type="hidden" id="equipmentId" name="equipmentId">
            
            <div class="form-group">
                <label for="equipmentName">Equipment Name</label>
                <input type="text" id="equipmentName" name="equipmentName" required>
            </div>
            
            <div class="form-group">
                <label for="equipmentQuantity">Quantity</label>
                <input type="number" id="equipmentQuantity" name="equipmentQuantity" min="1" required>
            </div>
            
            <div class="form-group">
                <label for="equipmentStatus">Status</label>
                <select id="equipmentStatus" name="equipmentStatus" required>
                    <option value="Good">Good</option>
                    <option value="Regular">Regular</option>
                    <option value="Need Maintenance">Need Maintenance</option>
                    <option value="Under Maintenance">Under Maintenance</option>
                    <option value="Broken">Broken</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="equipmentDescription">Description (Optional)</label>
                <textarea id="equipmentDescription" name="equipmentDescription" rows="3"></textarea>
            </div>
            
            <div class="modal-buttons">
                <button type="button" class="btn-delete" id="deleteEquipmentBtn">
                    <i class="fas fa-trash"></i> Delete Equipment
                </button>
                <button type="button" class="btn-cancel" onclick="closeEditModal()">Cancel</button>
                <button type="submit" class="btn-save">
                    <i class="fas fa-save"></i> Save Changes
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteConfirmationModal" class="modal">
    <div class="modal-content delete-confirmation">
        <span class="close-modal" onclick="closeDeleteModal()">&times;</span>
        <div class="warning-icon">
            <i class="fas fa-exclamation-triangle"></i>
        </div>
        <h3>Confirm Deletion</h3>
        <p>Are you sure you want to delete "<span id="deleteEquipmentName"></span>"?</p>
        <p style="color: #e74c3c; font-weight: bold;">This action cannot be undone!</p>
        
        <div class="modal-buttons">
            <button type="button" class="btn-cancel" onclick="closeDeleteModal()">Cancel</button>
            <button type="button" class="btn-delete" id="confirmDeleteBtn">
                <i class="fas fa-trash"></i> Delete
            </button>
        </div>
    </div>
</div>

<script>
    // DOM Ready
    document.addEventListener('DOMContentLoaded', function() {
        // Auto-hide messages after 5 seconds
        setTimeout(function() {
            const messages = document.querySelectorAll('.message-box');
            messages.forEach(function(msg) {
                msg.style.opacity = '0';
                setTimeout(function() {
                    msg.style.display = 'none';
                }, 500);
            });
        }, 5000);
    });

    // Plan search
    function searchPlan(){
        const term = document.getElementById("planSearch").value.toLowerCase();
        const rows = document.querySelectorAll("#planCard tbody tr");
        let visibleCount = 0;
        
        rows.forEach(r => {
            const txt = r.textContent.toLowerCase();
            if (txt.includes(term)) {
                r.style.display = "";
                visibleCount++;
            } else {
                r.style.display = "none";
            }
        });
        
        // Show message if no results
        const noResultsRow = document.querySelector("#planCard tbody tr td[colspan]");
        if (noResultsRow && visibleCount === 0 && term !== "") {
            noResultsRow.parentElement.style.display = "";
        }
    }

    // Edit Equipment
    let currentEquipmentId = null;
    let currentEquipmentName = null;
    
    function editEquipment(id, button) {
        const row = button.closest('tr');
        if (!row) return;
        
        currentEquipmentId = id;
        currentEquipmentName = row.getAttribute('data-name');
        
        // Get data from data attributes
        const equipmentName = row.getAttribute('data-name');
        const equipmentQuantity = row.getAttribute('data-quantity');
        const equipmentStatus = row.getAttribute('data-status');
        const equipmentDescription = row.getAttribute('data-description') || '';
        
        // Fill the form
        document.getElementById('equipmentId').value = id;
        document.getElementById('equipmentName').value = equipmentName;
        document.getElementById('equipmentQuantity').value = equipmentQuantity;
        document.getElementById('equipmentStatus').value = equipmentStatus;
        document.getElementById('equipmentDescription').value = equipmentDescription;
        
        // Set up delete button
        document.getElementById('deleteEquipmentBtn').onclick = function() {
            closeEditModal();
            setTimeout(() => {
                deleteEquipment(id, equipmentName);
            }, 300);
        };
        
        // Show modal
        document.getElementById('editInventoryModal').style.display = 'block';
        document.body.style.overflow = 'hidden';
    }
    
    function closeEditModal() {
        document.getElementById('editInventoryModal').style.display = 'none';
        document.body.style.overflow = 'auto';
        currentEquipmentId = null;
        currentEquipmentName = null;
    }
    
    // Delete Equipment
    function deleteEquipment(id, name) {
        document.getElementById('deleteEquipmentName').textContent = name;
        document.getElementById('deleteConfirmationModal').style.display = 'block';
        document.body.style.overflow = 'hidden';
        
        // Set up confirm button
        document.getElementById('confirmDeleteBtn').onclick = function() {
            // Show loading
            const deleteBtn = document.getElementById('confirmDeleteBtn');
            const originalText = deleteBtn.innerHTML;
            deleteBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting...';
            deleteBtn.disabled = true;
            
            // Send delete request
            fetch('<%=ctx%>/deleteInventory?id=' + id, {
                method: 'DELETE',
            })
            .then(response => {
                if (response.ok) {
                    // Reload the page to show updated list
                    window.location.reload();
                } else {
                    alert('Failed to delete equipment. Please try again.');
                    deleteBtn.innerHTML = originalText;
                    deleteBtn.disabled = false;
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred. Please try again.');
                deleteBtn.innerHTML = originalText;
                deleteBtn.disabled = false;
            });
        };
    }
    
    function closeDeleteModal() {
        document.getElementById('deleteConfirmationModal').style.display = 'none';
        document.body.style.overflow = 'auto';
    }
    
    // Form validation for edit
    document.getElementById('editInventoryForm').addEventListener('submit', function(e) {
        e.preventDefault();
        
        const quantity = document.getElementById('equipmentQuantity').value;
        const name = document.getElementById('equipmentName').value;
        
        // Validate quantity
        if (quantity < 1) {
            alert('Quantity must be at least 1');
            return;
        }
        
        // Validate name
        if (!name.trim()) {
            alert('Equipment name is required');
            return;
        }
        
        // Show loading
        const saveBtn = this.querySelector('.btn-save');
        const originalText = saveBtn.innerHTML;
        saveBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
        saveBtn.disabled = true;
        
        // Submit the form
        this.submit();
    });

    // Sort active members
    function sortActiveMembers(type) {
        const table = document.getElementById("activeMembersTable");
        const tbody = table.querySelector("tbody");
        const rows = Array.from(tbody.querySelectorAll("tr"));
        
        // Filter out the "no data" row
        const dataRows = rows.filter(row => !row.cells[0].colSpan);
        
        if (dataRows.length === 0) return;
        
        dataRows.sort((a, b) => {
            const aName = a.getAttribute('data-name');
            const bName = b.getAttribute('data-name');
            const aJoined = a.getAttribute('data-joined');
            const bJoined = b.getAttribute('data-joined');
            const aExpiry = a.getAttribute('data-expiry');
            const bExpiry = b.getAttribute('data-expiry');
            
            switch(type) {
                case "name":
                    return aName.localeCompare(bName);
                    
                case "joined":
                    // Sort by join date (most recent first)
                    if (aJoined === "-" && bJoined === "-") return 0;
                    if (aJoined === "-") return 1;  // Put nulls at end
                    if (bJoined === "-") return -1; // Put nulls at end
                    return bJoined.localeCompare(aJoined); // Descending
                    
                case "expiry":
                    // Sort by expiry date (earliest first)
                    if (aExpiry === "-" && bExpiry === "-") return 0;
                    if (aExpiry === "-") return 1;  // Put nulls at end
                    if (bExpiry === "-") return -1; // Put nulls at end
                    return aExpiry.localeCompare(bExpiry); // Ascending
                    
                default:
                    return 0;
            }
        });
        
        // Clear and re-add sorted rows
        dataRows.forEach(row => tbody.appendChild(row));
    }
    
    // Close modals when clicking outside
    window.addEventListener('click', function(event) {
        const editModal = document.getElementById('editInventoryModal');
        const deleteModal = document.getElementById('deleteConfirmationModal');
        
        if (event.target === editModal) {
            if (confirm('Are you sure you want to close? Any unsaved changes will be lost.')) {
                closeEditModal();
            }
        }
        
        if (event.target === deleteModal) {
            closeDeleteModal();
        }
    });
    
    // Keyboard shortcuts
    document.addEventListener('keydown', function(e) {
        // ESC key closes modals
        if (e.key === 'Escape') {
            const editModal = document.getElementById('editInventoryModal');
            const deleteModal = document.getElementById('deleteConfirmationModal');
            
            if (editModal.style.display === 'block') {
                if (confirm('Are you sure you want to close? Any unsaved changes will be lost.')) {
                    closeEditModal();
                }
            } else if (deleteModal.style.display === 'block') {
                closeDeleteModal();
            }
        }
        
        // Ctrl+S to save (only when edit modal is open)
        if ((e.ctrlKey || e.metaKey) && e.key === 's' && 
            document.getElementById('editInventoryModal').style.display === 'block') {
            e.preventDefault();
            document.querySelector('.btn-save').click();
        }
    });
    
    // Helper function to format dates
    function formatDate(dateStr) {
        if (!dateStr || dateStr === "-") return dateStr;
        
        try {
            // Try to parse and format the date
            const date = new Date(dateStr);
            if (isNaN(date.getTime())) return dateStr;
            
            return date.toLocaleDateString('en-GB', {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric'
            });
        } catch (e) {
            return dateStr;
        }
    }
</script>
</body>
</html>