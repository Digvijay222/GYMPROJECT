<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.ProfitSummary" %>
<%@ page import="java.util.List" %>
<%
    String ctx = request.getContextPath();
    ProfitSummary summary       = (ProfitSummary) request.getAttribute("profitSummary");
    List<Double> monthlyRevenue = (List<Double>) request.getAttribute("monthlyRevenue");
    List<Double> monthlyExpenses= (List<Double>) request.getAttribute("monthlyExpenses");
    List<Double> monthlyProfit  = (List<Double>) request.getAttribute("monthlyProfit");
    String[] monthNames         = (String[]) request.getAttribute("monthNames");
    Integer currentYear         = (Integer) request.getAttribute("currentYear");
    Integer currentPage         = (Integer) request.getAttribute("currentPage");
    
    // Default values (safety, but servlet should provide real data)
    if (summary == null) {
        summary = new ProfitSummary(0, 0, 0, 0, 0, 0);
    }
    
    if (monthlyRevenue == null) {
        monthlyRevenue = new java.util.ArrayList<>();
        for (int i = 0; i < 12; i++) monthlyRevenue.add(0.0);
    }
    
    if (monthlyExpenses == null) {
        monthlyExpenses = new java.util.ArrayList<>();
        for (int i = 0; i < 12; i++) monthlyExpenses.add(0.0);
    }
    
    if (monthlyProfit == null) {
        monthlyProfit = new java.util.ArrayList<>();
        for (int i = 0; i < 12; i++) monthlyProfit.add(0.0);
    }
    
    if (monthNames == null) {
        monthNames = new String[]{"Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
    }
    
    if (currentYear == null) {
        currentYear = java.time.Year.now().getValue();
    }
    
    if (currentPage == null) {
        currentPage = 0; // first 6 months in ordered list
    }
    
    // === month order from current month backwards ===
    int currentMonthIndex = java.time.LocalDate.now().getMonthValue() - 1; // 0-based
    int[] displayOrder = new int[12];
    for (int k = 0; k < 12; k++) {
        // current month, then previous, wrapping around
        displayOrder[k] = (currentMonthIndex - k + 12) % 12;
    }
    
    // 6 months per page
    int startMonth = currentPage * 6; // index in displayOrder
    int endMonth   = Math.min(startMonth + 6, 12);
    
    // Donut-chart percentages
    double yearlyRevenue = summary.getTotalRevenue();
    double yearlyExpenses = summary.getTotalExpenses();
    double yearlyProfitVal = summary.getNetProfit();
    double totalForChart = yearlyRevenue + yearlyExpenses + Math.abs(yearlyProfitVal);
    
    double revenuePercent  = totalForChart > 0 ? (yearlyRevenue / totalForChart) * 100 : 0;
    double expensesPercent = totalForChart > 0 ? (yearlyExpenses / totalForChart) * 100 : 0;
    double profitPercent   = totalForChart > 0 ? (Math.abs(yearlyProfitVal) / totalForChart) * 100 : 0;
    
    // Expense increase %
    double expenseIncrease = 0;
    if (summary.getLastMonthExpenses() > 0) {
        expenseIncrease = ((summary.getThisMonthExpenses() - summary.getLastMonthExpenses()) /
                           summary.getLastMonthExpenses()) * 100;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profit & Expenses</title>
    <link rel="stylesheet" href="<%=ctx%>/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: "Poppins", sans-serif;
        }
        body {
            background: #e6e6e6;
        }
        .container {
            display: flex;
            min-height: 100vh;
        }
        /* Sidebar Styles */
        .sidebar {
            width: 260px;
            background: #0c1d35;
            color: white;
            padding: 25px 20px;
            display: flex;
            flex-direction: column;
        }
        .profile {
            text-align: center;
            margin-bottom: 40px;
        }
        .avatar {
            width: 75px;
            height: 75px;
            background: #c6d2e1;
            border-radius: 50%;
            margin: auto;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 32px;
            color: #0c1d35;
        }
        .profile h3 {
            margin-top: 10px;
        }
        .profile p {
            font-size: 12px;
            color: #c9c9c9;
        }
        .menu {
            list-style: none;
            margin-top: 20px;
        }
        .menu li {
            padding: 12px 10px;
            margin: 6px 0;
            border-radius: 10px;
            display: flex;
            align-items: center;
            gap: 12px;
            cursor: pointer;
            font-size: 15px;
        }
        .menu .active {
            background: white;
            color: black;
        }
        .logout {
            margin-top: auto;
            padding: 30px;
            border-radius: 10px;
            text-align: center;
            cursor: pointer;
            color: white;
        }
        /* Main Content */
        .content {
            flex: 1;
            padding: 40px;
            overflow-y: auto;
        }
        .title-logo {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .title-logo img {
            border-radius: 10px;
        }
        h1 {
            margin: 20px 0;
            font-size: 26px;
        }
        /* Cards */
        .cards {
            display: flex;
            gap: 25px;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }
        .card {
            width: 250px;
            padding: 20px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .card h2 {
            margin-bottom: 10px;
            font-size: 20px;
        }
        .revenue-card {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            display: flex;
            flex-direction: column;
            gap: 10px;
            flex: 1;
            min-width: 300px;
        }
        /* Chart */
        .chart-area {
            display: flex;
            align-items: center;
            gap: 25px;
        }
        .donut-chart-placeholder {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: conic-gradient(
                #3498db 0% <%= revenuePercent %>%,
                #e74c3c <%= revenuePercent %>% <%= revenuePercent + expensesPercent %>%,
                #2ecc71 <%= revenuePercent + expensesPercent %>% 100%
            );
            position: relative;
        }
        .donut-chart-placeholder::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 60px;
            height: 60px;
            background: white;
            border-radius: 50%;
            transform: translate(-50%, -50%);
        }
        .legend {
            font-size: 0.9em;
        }
        .legend div {
            margin-bottom: 5px;
        }
        .dot {
            display: inline-block;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            margin-right: 5px;
        }
        .revenue-dot { background-color: #3498db; }
        .expenses-dot{ background-color: #e74c3c; }
        .profit-dot  { background-color: #2ecc71; }
        /* Table */
        .table-box {
            background: white;
            padding: 25px;
            border-radius: 15px;
            color: black;
            margin-bottom: 20px;
        }
        .profit-table {
            width: 100%;
            border-collapse: collapse;
        }
        .profit-table th,
        .profit-table td {
            padding: 15px;
            text-align: left;
            font-size: 15px;
            border-bottom: 1px solid #ddd;
        }
        .profit-table thead th {
            background-color: #f2f2f2;
            font-weight: 600;
            border-top: 2px solid #0c1d35;
        }
        .profit-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        .trend-up {
            color: #2ecc71;
            font-weight: 600;
        }
        .trend-down {
            color: #e74c3c;
            font-weight: 600;
        }
        .no-data {
            text-align: center;
            color: #666;
            font-style: italic;
            padding: 20px;
        }
        /* Pagination */
        .pagination-controls {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 20px;
            margin-top: 20px;
            padding: 15px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .page-btn {
            padding: 10px 25px;
            background-color: #0c1d35;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .page-btn:hover {
            background-color: #1a2f4a;
        }
        .page-btn:disabled {
            background-color: #cccccc;
            cursor: not-allowed;
        }
        .page-info {
            font-size: 16px;
            font-weight: 500;
            color: #333;
        }
        .current-year {
            text-align: center;
            margin-bottom: 15px;
            font-size: 18px;
            color: #333;
            font-weight: 600;
        }
    </style>
</head>
<body>
<div class="container">
    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="profile">
            <div class="avatar"><i class="fa-solid fa-user"></i></div>
            <h3>Admin Name</h3>
            <p>arnoldmuscle07@gmail.com</p>
        </div>

        <ul class="menu">
            <li onclick="location.href='<%=ctx%>/JSP/dashboard.jsp'">
                <i class="fa-solid fa-gauge"></i> Dashboard
            </li>
            <li onclick="location.href='<%=ctx%>/JSP/admin.jsp'">
                <i class="fa-solid fa-user-gear"></i> Admin
            </li>
            <li onclick="location.href='<%=ctx%>/JSP/registration.jsp'">
                <i class="fa-solid fa-id-badge"></i> Registration
            </li>
            <li onclick="location.href='<%=ctx%>/JSP/membership.jsp'">
                <i class="fa-solid fa-users"></i> Membership
            </li>
            <li onclick="location.href='<%=ctx%>/JSP/addinventory.jsp'">
                <i class="fa-solid fa-box"></i> Add Inventory
            </li>
            <li onclick="location.href='<%=ctx%>/JSP/payment.jsp'">
                <i class="fa-solid fa-credit-card"></i> Payment
            </li>
            <li onclick="location.href='<%=ctx%>/JSP/viewmembers.jsp'">
                <i class="fa-solid fa-eye"></i> View Members
            </li>
            <li class="active" onclick="location.href='<%=ctx%>/profit-expenses'">
                <i class="fa-solid fa-chart-line"></i> Profit & Expenses
            </li>
        </ul>

        <div class="logout" onclick="location.href='<%=ctx%>/JSP/login.jsp'">
            <i class="fa-solid fa-right-from-bracket"></i> Logout
        </div>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="content">
        <div class="title-logo">
            <img src="<%=ctx%>/images/Logo.jpg" width="40" height="80" alt="Logo">
            <div>
                <h2>ARNOLD MUSCLE MECHANIC</h2>
            </div>
        </div>

        <h1>Profit & Expenses</h1>

        <div class="cards">
            <div class="card">
                <h2>Total Profit</h2>
                <p><strong>Net Amount :</strong> ₹ <%= String.format("%,.2f", summary.getNetProfit()) %></p>
                <p><strong>Profit Margin :</strong> <%= String.format("%.1f", summary.getProfitMargin()) %>%</p>
            </div>

            <div class="card">
                <h2>Total Expenses</h2>
                <p><strong>This Month :</strong> ₹ <%= String.format("%,.2f", summary.getThisMonthExpenses()) %></p>
                <p><strong>Last Month :</strong> ₹ <%= String.format("%,.2f", summary.getLastMonthExpenses()) %></p>
                <p><strong>Increase :</strong> 
                    <span class="<%= expenseIncrease >= 0 ? "trend-up" : "trend-down" %>">
                        <%= String.format("%+.1f", expenseIncrease) %>%
                    </span> (Trend)
                </p>
            </div>

            <div class="revenue-card">
                <h3>Revenue, Expenses and Profit</h3>
                <div class="chart-area">
                    <div class="donut-chart-placeholder"></div>
                    <div class="legend">
                        <div><span class="dot revenue-dot"></span> Revenue <%= String.format("%.1f", revenuePercent) %>%</div>
                        <div><span class="dot expenses-dot"></span> Expenses <%= String.format("%.1f", expensesPercent) %>%</div>
                        <div><span class="dot profit-dot"></span> Profit <%= String.format("%.1f", profitPercent) %>%</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="table-box">
            <div class="current-year">Monthly Breakdown - <%= currentYear %></div>
            <table class="profit-table">
                <thead>
                    <tr>
                        <th>Month</th>
                        <th>Revenue</th>
                        <th>Expenses</th>
                        <th>Profit</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    boolean hasData = false;
                    for (int pos = startMonth; pos < endMonth; pos++) {
                        int i = displayOrder[pos]; // map position to actual month index
                        double revenue  = monthlyRevenue.get(i);
                        double expenses = monthlyExpenses.get(i);
                        double profit   = monthlyProfit.get(i);
                        hasData = hasData || revenue > 0 || expenses > 0 || profit != 0;
                %>
                <tr>
                    <td><strong><%= monthNames[i] %></strong></td>
                    <td>₹ <%= String.format("%,.2f", revenue) %></td>
                    <td>₹ <%= String.format("%,.2f", expenses) %></td>
                    <td>
                        <span class="<%= profit >= 0 ? "trend-up" : "trend-down" %>">
                            ₹ <%= String.format("%,.2f", profit) %>
                        </span>
                    </td>
                </tr>
                <%
                    }
                    if (!hasData) {
                %>
                <tr>
                    <td colspan="4" class="no-data">
                        No financial data available for these months. Add payments and expenses to see statistics.
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>

        <!-- Pagination Controls -->
        <div class="pagination-controls">
            <button class="page-btn"
                    onclick="location.href='<%=ctx%>/profit-expenses?page=<%= currentPage - 1 %>'"
                    <%= currentPage == 0 ? "disabled" : "" %>>
                <i class="fa-solid fa-chevron-left"></i> Previous
            </button>

            <div class="page-info">
                Showing Months:
                <strong>
                    <%= monthNames[displayOrder[startMonth]] %> -
                    <%= monthNames[displayOrder[endMonth - 1]] %>
                </strong>
                &nbsp;|&nbsp;
                Page <%= currentPage + 1 %> of 2
            </div>

            <button class="page-btn"
                    onclick="location.href='<%=ctx%>/profit-expenses?page=<%= currentPage + 1 %>'"
                    <%= currentPage >= 1 ? "disabled" : "" %>>
                Next <i class="fa-solid fa-chevron-right"></i>
            </button>
        </div>

    </main>
</div>

<script>
    // Keyboard navigation
    document.addEventListener('keydown', function(event) {
        if (event.key === 'ArrowLeft' && <%= currentPage > 0 %>) {
            location.href = '<%=ctx%>/profit-expenses?page=<%= currentPage - 1 %>';
        }
        if (event.key === 'ArrowRight' && <%= currentPage < 1 %>) {
            location.href = '<%=ctx%>/profit-expenses?page=<%= currentPage + 1 %>';
        }
    });
</script>
</body>
</html>
