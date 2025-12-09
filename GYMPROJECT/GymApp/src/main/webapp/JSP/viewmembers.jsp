<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Customer, java.net.URLEncoder, java.nio.charset.StandardCharsets" %>
<%
    String ctx = request.getContextPath();
    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    String searchTerm = (String) request.getAttribute("searchTerm");
    final int PAGE_SIZE = 5; // keep in sync with servlet

    if (customers == null) {
        response.sendRedirect(ctx + "/CustomerServlet?action=list");
        return;
    }
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 1;
    if (totalCount == null) totalCount = customers.size();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Arnold Muscle Mechanic - View Members</title>
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

        * { box-sizing: border-box; margin: 0; padding: 0; font-family: sans-serif; }

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

        .sidebar-nav ul { list-style: none; padding-left:0; }
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

        .page-title { color: var(--primary-dark); font-size: 1.8em; font-weight: bold; margin-bottom:25px; }

        .members-panel {
            background-color: var(--primary-dark);
            color: var(--text-light);
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            flex-grow: 1;
        }

        .panel-title { font-size:1.4em; font-weight:bold; margin-bottom:20px; }

        .controls-row { display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; gap:10px; flex-wrap:wrap; }

        .show-entries-label { font-size:0.9em; color:var(--text-light); }

        .search-box { display:flex; align-items:center; border:1px solid var(--secondary-dark); border-radius:4px; padding:5px 10px; background-color:white; }
        .search-box input[type="text"] { border:none; outline:none; padding:5px; width:250px; background:transparent; color:black; }
        .search-box button { background:none; border:none; cursor:pointer; color:var(--text-gray); }

        .members-table { width:100%; border-collapse:collapse; font-size:0.9em; }
        .members-table th, .members-table td { padding:12px 15px; text-align:left; border-bottom:1px solid var(--secondary-dark); vertical-align: middle; }
        .members-table th { color: var(--text-light); font-weight:500; }
        .members-table tbody tr:hover { background-color: var(--secondary-dark); }

        .status-red { color: var(--status-red); font-weight:bold; }
        .status-green { color: var(--status-green); font-weight:bold; }

        .action-btn { background-color: transparent; color: var(--text-light); border:1px solid var(--text-light); padding:5px 12px; border-radius:4px; cursor:pointer; font-size:0.85em; transition: background-color 0.2s; text-decoration:none; display:inline-block; }
        .action-btn:hover { background-color: var(--secondary-dark); }

        .pagination { display:flex; justify-content:center; align-items:center; gap:10px; margin-top:20px; flex-wrap:wrap; }
        .pagination-info { color: var(--text-light); font-size:0.9em; }
        .nav-btn { background-color: var(--secondary-dark); color: var(--text-light); border: none; padding:8px 15px; border-radius:4px; cursor:pointer; font-weight:bold; text-decoration:none; display:inline-block; }
        .nav-btn:hover:not(:disabled) { background-color:#3f4a5c; }
        .nav-btn:disabled { background-color:#4a5568; cursor:not-allowed; opacity:0.5; }

        .members-table td img { border-radius:10px; }

        .page-numbers { display:flex; gap:5px; }
        .page-number { padding:5px 10px; background-color: var(--secondary-dark); color: var(--text-light); border-radius:4px; text-decoration:none; display:inline-block; }
        .page-number.active { background-color: var(--accent-blue); color:white; }
        .page-number:hover:not(.active) { background-color:#3f4a5c; }
        
        /* Plan Badge Styles */
        .plan-badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 4px;
            font-size: 0.85em;
            font-weight: bold;
            text-align: center;
            min-width: 100px;
        }
        
        .plan-basic {
            background-color: #48bb78;
            color: white;
        }
        
        .plan-premium {
            background-color: #3b82f6;
            color: white;
        }
        
        .plan-vip {
            background-color: #9f7aea;
            color: white;
        }
        
        .plan-student {
            background-color: #ed8936;
            color: white;
        }
        
        .plan-family {
            background-color: #f56565;
            color: white;
        }
        
        .plan-corporate {
            background-color: #4299e1;
            color: white;
        }
        
        .plan-custom {
            background-color: #a0aec0;
            color: white;
        }
        
        .plan-expired {
            background-color: #718096;
            color: white;
            text-decoration: line-through;
        }
    </style>
</head>
<body>
<div class="dashboard-container">
    <!-- SIDEBAR -->
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

    <!-- MAIN CONTENT -->
    <main class="main-content">
        <header class="main-header">
            <img src="<%=ctx%>/images/Logo.jpg" width="40" height="80" alt="Logo">
            <div class="header-title">
                <h2>ARNOLD MUSCLE MECHANIC</h2>
            </div>
        </header>

        <h1 class="page-title">Active Members</h1>

        <div class="members-panel">
            <h3 class="panel-title">Gym Members</h3>

            <div class="controls-row">
                <div class="show-entries-label">
                    <%
                        // renamed local variable to avoid duplication in generated servlet class
                        int pageNum = (currentPage == null ? 1 : currentPage);
                        int start = (totalCount == 0) ? 0 : (pageNum - 1) * PAGE_SIZE + 1;
                        int end = (customers == null || customers.size() == 0) ? 0 : start + customers.size() - 1;
                    %>
                    Showing <%= start %> - <%= end %> of <%= totalCount %> entries
                </div>

                <form method="GET" action="<%=ctx%>/CustomerServlet" class="search-box" style="margin-left:auto;">
                    <input type="hidden" name="action" value="search">
                    <input type="hidden" name="page" value="1">
                    <input type="text" name="searchTerm" placeholder="Search By Member ID / Name / Mobile"
                           value="<%= (searchTerm == null ? "" : searchTerm) %>">
                    <button type="submit"><i class="fas fa-search"></i></button>
                </form>
            </div>

            <table class="members-table">
                <thead>
                <tr>
                    <th>Name</th>
                    <th>Member ID</th>
                    <th>Date Enrolled</th>
                    <th>Date Expiration</th>
                    <th>Payment Status</th>
                    <th>Plan Details</th> <!-- Changed to single Plan column -->
                    <th>Action</th>
                    <th>Message</th>
                </tr>
                </thead>
                <tbody>
                <% if (customers != null && !customers.isEmpty()) {
                       for (Customer customer : customers) { 
                           String planType = customer.getPlanType() != null ? customer.getPlanType() : "";
                           String planClass = "plan-custom";
                           
                           if (planType != null && !planType.isEmpty()) {
                               String planTypeLower = planType.toLowerCase();
                               if (planTypeLower.contains("basic")) {
                                   planClass = "plan-basic";
                               } else if (planTypeLower.contains("premium")) {
                                   planClass = "plan-premium";
                               } else if (planTypeLower.contains("vip")) {
                                   planClass = "plan-vip";
                               } else if (planTypeLower.contains("student")) {
                                   planClass = "plan-student";
                               } else if (planTypeLower.contains("family")) {
                                   planClass = "plan-family";
                               } else if (planTypeLower.contains("corporate")) {
                                   planClass = "plan-corporate";
                               }
                           }
                %>
                <tr>
                    <td><%= customer.getName() %></td>
                    <td>M<%= String.format("%03d", customer.getId()) %></td>
                    <td><%= customer.getEnrolledOn() != null ? customer.getEnrolledOn() : "N/A" %></td>
                    <td><%= customer.getExpiryDate() != null ? customer.getExpiryDate() : "N/A" %></td>
                    <td>
                        <% if ("Paid".equalsIgnoreCase(customer.getPaymentStatus())) { %>
                            <span class="status-green"><%= customer.getPaymentStatus() %></span>
                        <% } else { %>
                            <span class="status-red"><%= customer.getPaymentStatus() != null ? customer.getPaymentStatus() : "Unpaid" %></span>
                        <% } %>
                    </td>
                    <td>
                        <% if (planType != null && !planType.isEmpty()) { %>
                            <span class="plan-badge <%= planClass %>">
                                <%= planType %>
                            </span>
                        <% } else { %>
                            <span style="color: var(--text-gray); font-style: italic;">No Plan</span>
                        <% } %>
                    </td>
                    <td>
                        <a href="<%=ctx%>/CustomerServlet?action=view&id=<%= customer.getId() %>" class="action-btn">View</a>
                    </td>
                    <td>
                        <% if (customer.getMobileNumber() != null && !customer.getMobileNumber().isEmpty()) { %>
                            <a href="https://wa.me/91<%= customer.getMobileNumber() %>" target="_blank">
                                <img src="<%=ctx%>/images/whatsapp.png" width="40" height="40" alt="WhatsApp">
                            </a>
                        <% } else { %>
                            <span>No Phone</span>
                        <% } %>
                    </td>
                </tr>
                <%   }
                   } else { %>
                <tr>
                    <td colspan="8" style="text-align: center; padding: 20px;">No members found</td>
                </tr>
                <% } %>
                </tbody>
            </table>

            <!-- Pagination -->
            <div class="pagination">
                <% 
                    String encodedSearch = "";
                    if (searchTerm != null && !searchTerm.isEmpty()) {
                        encodedSearch = URLEncoder.encode(searchTerm, StandardCharsets.UTF_8.toString());
                    }
                %>

                <!-- Previous -->
                <% if (currentPage > 1) { 
                       int prevPage = currentPage - 1;
                       String prevHref = (searchTerm != null && !searchTerm.isEmpty()) 
                                ? (ctx + "/CustomerServlet?action=search&searchTerm=" + encodedSearch + "&page=" + prevPage)
                                : (ctx + "/CustomerServlet?action=list&page=" + prevPage);
                %>
                    <a href="<%= prevHref %>" class="nav-btn">Previous</a>
                <% } else { %>
                    <button class="nav-btn" disabled>Previous</button>
                <% } %>

                <!-- Page info -->
                <div class="pagination-info">Page <%= currentPage %> of <%= totalPages %></div>

                <!-- Next -->
                <% if (currentPage < totalPages) { 
                       int nextPage = currentPage + 1;
                       String nextHref = (searchTerm != null && !searchTerm.isEmpty()) 
                                ? (ctx + "/CustomerServlet?action=search&searchTerm=" + encodedSearch + "&page=" + nextPage)
                                : (ctx + "/CustomerServlet?action=list&page=" + nextPage);
                %>
                    <a href="<%= nextHref %>" class="nav-btn">Next</a>
                <% } else { %>
                    <button class="nav-btn" disabled>Next</button>
                <% } %>
            </div>
        </div>
    </main>
</div>
</body>
</html>