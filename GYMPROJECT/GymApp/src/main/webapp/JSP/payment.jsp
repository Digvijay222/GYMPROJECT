<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.CustomerDAO, dao.MembershipPlanDAO, model.Customer, model.MembershipPlan, java.util.List" %>
<%
    String ctx = request.getContextPath();
%>
<%
    // Get messages from session
    String successMsg = (String) session.getAttribute("success");
    String errorMsg = (String) session.getAttribute("error");
    
    // Clear messages after displaying
    if (successMsg != null) {
        session.removeAttribute("success");
    }
    if (errorMsg != null) {
        session.removeAttribute("error");
    }
    
    // Fetch data for dropdowns
    CustomerDAO customerDAO = new CustomerDAO();
    MembershipPlanDAO planDAO = new MembershipPlanDAO();
    
    List<Customer> customers = customerDAO.findAll();
    List<MembershipPlan> plans = planDAO.findAll();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Arnold Muscle Mechanic - Add Payment</title>
    <link rel="stylesheet" href="styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

    <!-- Tom Select (vanilla) - CDN -->
    <link href="https://cdn.jsdelivr.net/npm/tom-select/dist/css/tom-select.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/tom-select/dist/js/tom-select.complete.min.js"></script>
    <style>
    /* Color Variables */
    :root {
        --primary-dark: #1e293b;
        --secondary-dark: #2d3748;
        --accent-blue: #3b82f6;
        --text-light: #ffffff;
        --text-gray: #a0aec0;
        --text-dark: #333;
        --background-light: #e2e8f0;
        --button-green: #48bb78;
        --button-dark: #4a5568;
        --border-color: #4a5568;
    }

    /* Base Styles */
    * {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
        font-family: sans-serif;
    }

    body {
        background-color: var(--background-light);
        color: var(--text-light);
    }

    .dashboard-container {
        display: flex;
        min-height: 100vh;
    }

    /* --- Sidebar Styling --- */
    .sidebar {
        width: 280px;
        background-color: var(--primary-dark);
        padding: 20px 0;
        display: flex;
        flex-direction: column;
        box-shadow: 2px 0 5px rgba(0, 0, 0, 0.2);
    }

    .admin-profile {
        text-align: center;
        padding: 20px;
        border-bottom: 1px solid var(--border-color);
        margin-bottom: 20px;
    }

    .profile-icon {
        font-size: 50px;
        color: var(--text-light);
        margin-bottom: 10px;
    }

    .admin-name {
        font-size: 1.2em;
        margin: 5px 0;
    }

    .admin-email {
        font-size: 0.85em;
        color: var(--text-gray);
    }

    .sidebar-nav ul {
        list-style: none;
    }

    .sidebar-nav li a {
        display: block;
        padding: 15px 25px;
        text-decoration: none;
        color: var(--text-light);
        font-size: 1em;
        transition: background-color 0.2s;
    }

    .sidebar-nav li a i {
        margin-right: 15px;
        width: 20px;
        text-align: center;
    }

    .sidebar-nav li.active a {
        background-color: white;
        color: black;
        border-left: 5px solid var(--accent-blue);
        padding-left: 20px;
    }

    .logout-section {
        margin-top: auto;
        padding: 15px 25px;
        border-top: 1px solid var(--border-color);
    }

    .logout-section a {
        text-decoration: none;
        color: var(--text-light);
        display: block;
        font-size: 1em;
    }

    /* --- Main Content Styling --- */
    .main-content {
        flex-grow: 1;
        display: flex;
        flex-direction: column;
        padding: 30px;
        color: var(--text-dark);
    }

    .main-header {
        display: flex;
        align-items: center;
        padding: 15px 0;
        margin-bottom: 20px;
    }

    .header-logo {
        width: 40px;
        height: 40px;
        background-color: var(--accent-blue);
        border-radius: 50%;
        margin-right: 10px;
        content: url('data:image/svg+xml;utf8,<svg xmlns="https://upload.wikimedia.org/wikipedia/commons/d/d0/QR_code_for_mobile_English_Wikipedia.svg" viewBox="0 0 24 24" fill="%23FFFFFF"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm-1-13h2v6h-2zM9 11h2v2H9zM13 11h2v2h-2zM9 15h6v2H9z"/></svg>');
    }

    .header-title h2 {
        color: var(--primary-dark);
        font-size: 1.5em;
        font-weight: bold;
    }

    .page-title {
        color: var(--primary-dark);
        font-size: 1.8em;
        margin-bottom: 25px;
    }

    /* --- Payment Section Cards --- */
    .payment-section {
        padding: 30px;
        border-radius: 8px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        margin-bottom: 25px;
    }

    /* Form Card Styling (Top Card - Dark Blue) */
    .form-card {
        background-color: var(--primary-dark);
        color: var(--text-light);
    }

    .payment-form {
        display: flex;
        flex-direction: column;
    }

    .form-row {
        display: flex;
        gap: 20px;
        margin-bottom: 10px;
        align-items: center;
    }

    .form-row label {
        font-weight: 500;
        margin-bottom: 5px;
        font-size: 0.95em;
    }

    /* Adjust labels widths to match fields: first label (Member ID) wider */
    .form-row.labels-row label:first-child {
        flex: 2;
    }
    .form-row.labels-row label:nth-child(2),
    .form-row.labels-row label:nth-child(3) {
        flex: 1;
    }

    /* original input/select rules */
    .form-row select,
    .form-row input[type="text"],
    .form-row input[type="number"] {
        min-width: 0; /* important for flex children */
        padding: 10px 15px;
        border: none;
        border-radius: 4px;
        background-color: white;
        color: var(--text-dark);
        font-size: 1em;
    }

    /* Increase Member ID width: assign class member-select */
    .form-row .member-select {
        flex: 2; /* make Member ID roughly twice as wide */
        width: auto;
    }

    /* Keep plan and amount at normal width */
    .form-row select#planId,
    .form-row input#amount {
        flex: 1;
    }

    .form-row select {
        appearance: none;
        -webkit-appearance: none;
        -moz-appearance: none;
        background-image: url('data:image/svg+xml;utf8,<svg fill="black" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="M7 10l5 5 5-5z"/></svg>');
        background-repeat: no-repeat;
        background-position: right 10px center;
        padding-right: 30px;
    }

    .date-row label {
        flex-basis: calc((100% - 40px) / 3);
    }

    .date-input-container {
        flex-basis: calc((100% - 40px) / 3);
        position: relative;
    }

    .date-input-container input[type="date"] {
        width: 100%;
        padding: 10px 15px;
        border: none;
        border-radius: 4px;
        background-color: var(--secondary-dark);
        color: var(--text-light);
        font-size: 1em;
        appearance: none;
        -webkit-appearance: none;
        -moz-appearance: none;
        color-scheme: dark;
    }

    .date-input-container input[type="date"]::-webkit-calendar-picker-indicator {
        opacity: 0;
        cursor: pointer;
        width: 100%;
        height: 100%;
        position: absolute;
        top: 0;
        left: 0;
    }

    .date-input-container .calendar-icon {
        position: absolute;
        right: 15px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--button-green);
        pointer-events: none;
        z-index: 1;
    }

    .form-actions {
        display: flex;
        justify-content: flex-end;
        gap: 15px;
        margin-top: 30px;
    }

    .save-btn, .cancel-btn {
        padding: 10px 25px;
        border: none;
        border-radius: 4px;
        font-weight: bold;
        cursor: pointer;
        transition: background-color 0.2s;
    }

    .save-btn {
        background-color: var(--button-green);
        color: var(--text-light);
    }

    .save-btn:hover {
        background-color: #38a169;
    }

    .cancel-btn {
        background-color: var(--button-dark);
        color: var(--text-light);
    }

    .cancel-btn:hover {
        background-color: #2d3748;
    }

    /* QR Code Card Styling (Bottom Card - White) */
    .qr-card {
        background-color: var(--text-light);
        color: var(--text-dark);
    }

    .qr-card h3 {
        font-size: 1.4em;
        color: var(--primary-dark);
        margin-bottom: 20px;
    }

    .qr-content {
        display: flex;
        align-items: center;
        gap: 50px;
    }

    /* FIXED: use an <img> or background-image; remove incorrect content:url usage */
    .qr-code-placeholder {
        width: 150px;
        height: 150px;
        background-color: transparent;
        border-radius: 6px;
        display: flex;
        justify-content: center;
        align-items: center;
        overflow: hidden;
        border: 1px solid #e2e8f0;
    }

    .qr-code-placeholder img {
        width: 100%;
        height: 100%;
        object-fit: contain;
        display: block;
    }

    .payment-logos {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 20px;
    }

    .logo-box {
        width: 80px;
        height: 40px;
        display: flex;
        justify-content: center;
        align-items: center;
        background-color: #f7fafc;
        border-radius: 4px;
        border: 1px solid #e2e8f0;
    }

    .main-header img {
        border-radius: 10px;
    }

    .header-title h2 {
        padding: 20px;
    }

    /* Custom logo placeholders */
    .logo-box img {
        max-width: 100%;
        max-height: 100%;
        object-fit: contain;
    }

    /* Message styling */
    .message {
        padding: 12px 20px;
        margin-bottom: 20px;
        border-radius: 4px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 10px;
    }

 .success-message span,
.success-message i {
    color: #0f7224 !important;
    font-weight: bold;
}

.success-message {
    background-color: #d4edda;
    border: 1px solid #c3e6cb;
    padding: 12px 20px;
    border-radius: 5px;
    display: flex;
    align-items: center;
    gap: 10px;
}

.error-message {
    background-color: #f8d7da;
    color: #721c24;
    padding: 12px 20px;
    border-radius: 5px;
    border: 1px solid #f5c6cb;
    display: flex;
    align-items: center;
    gap: 10px;
}

    .loading-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 1000;
        display: none;
    }

    .spinner {
        border: 8px solid #f3f3f3;
        border-top: 8px solid #3498db;
        border-radius: 50%;
        width: 60px;
        height: 60px;
        animation: spin 1s linear infinite;
    }

    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    /* === Tom Select appearance tweaks to match existing input style === */
    .ts-control, .ts-control .items {
        background-color: white;
        color: var(--text-dark);
        border-radius: 4px;
        padding: 6px 10px;
        line-height: 1.6;
        min-height: 44px; /* match your inputs */
        border: none;
        box-shadow: none;
        font-size: 1em;
    }

    .ts-control input[type="text"] {
        padding: 6px 0;
        margin: 0;
        font-size: 1em;
        color: var(--text-dark);
    }

    .ts-dropdown {
        background: white;
        color: var(--text-dark);
        border-radius: 4px;
        border: 1px solid #ddd;
        box-shadow: 0 6px 20px rgba(0,0,0,0.12);
        z-index: 9999;
    }

    .ts-dropdown .option.highlight {
        background: rgba(59,130,246,0.06);
    }

    /* Ensure Tom Select fits inside the same flex layout */
    select.ts-hidden-select {
        display: none;
    }

    /* ===== Keep Member ID Tom Select control wider to match the select's flex ===== */
    /* Tom Select inserts .ts-control after the select; target that control for customerId */
    select#customerId + .ts-control,
    .ts-control[data-field="customerId"],
    .ts-control[data-control-field="customerId"] {
        flex: 2 !important;
        width: auto !important;
        min-width: 0 !important;
        box-sizing: border-box;
    }

    /* Ensure dropdown min width doesn't force horizontal scroll */
    select#customerId + .ts-control + .ts-dropdown,
    .ts-control .ts-dropdown {
        min-width: 100% !important;
    }

    /* Keep options inside dropdown visually constrained */
    .ts-dropdown .option {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    /* Responsive tweaks: stack on small screens */
    @media (max-width: 700px) {
        .form-row {
            flex-direction: column;
        }
        .form-row.labels-row label:first-child,
        .form-row.labels-row label:nth-child(2),
        .form-row.labels-row label:nth-child(3) {
            flex: none;
            width: 100%;
        }
        .form-row .member-select,
        .form-row select#planId,
        .form-row input#amount {
            width: 100%;
            flex: none;
        }
        aside.sidebar { display: none; } /* conserve space on mobile */
        .main-content { padding: 15px; }
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
                    <li><a href="dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                    <li><a href="admin.jsp"><i class="fas fa-user-shield"></i> Admin</a></li>
                    <li><a href="registration.jsp"><i class="fas fa-user-plus"></i> Registration</a></li>
                    <li><a href="membership.jsp"><i class="fas fa-address-card"></i> Membership plan</a></li>
                    <li><a href="addinventory.jsp"><i class="fas fa-box"></i> Add Inventory</a></li>
                    <li class="active"><a href="#"><i class="fas fa-credit-card"></i> Payment</a></li>
                    <li><a href="viewmembers.jsp"><i class="fas fa-users"></i> View Members</a></li>
                    <li><a href="profitExpenses.jsp"><i class="fas fa-chart-line"></i> Profit & Expenses</a></li>
                </ul>
            </nav>
            <div class="logout-section">
                <a href="#"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </aside>

        <main class="main-content">
            <header class="main-header">
                <img src="<%=ctx%>/images/Logo.jpg" width="40" height="70" alt="Logo">
                <div class="header-title">
                    <h2>ARNOLD MUSCLE MECHANIC</h2>
                </div>
            </header>
            
            <h1 class="page-title">Add Payment</h1>

           <%-- SUCCESS MESSAGE --%>
            <% if (successMsg != null && !successMsg.isEmpty()) { %>
                <div class="message success-message">
                    <i class="fas fa-check-circle"></i>
                    <span><%= successMsg %></span>
                </div>
            <% } %>

            <%-- ERROR MESSAGE --%>
            <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
                <div class="message error-message">
                    <i class="fas fa-exclamation-triangle"></i>
                    <span><%= errorMsg %></span>
                </div>
            <% } %>

            <div class="payment-section form-card">
                <form class="payment-form" action="<%= request.getContextPath() %>/Payment" method="POST" id="paymentForm">
                    <div class="form-row labels-row">
                        <label for="customerId">Member ID</label>
                        <label for="planId">Plan</label>
                        <label for="amount">Amount (₹)</label>
                    </div>
                    <div class="form-row">
                        <select id="customerId" name="customerId" class="member-select" required>
                            <option value="">Select Member</option>
                            <% for (Customer customer : customers) { %>
                                <option value="<%= customer.getId() %>">
                                    <%= customer.getId() %> - <%= customer.getName() %>
                                </option>
                            <% } %>
                        </select>

                        <select id="planId" name="planId" required>
                            <option value="">Select Plan</option>
                            <% for (MembershipPlan plan : plans) { %>
                                <option value="<%= plan.getId() %>" data-price="<%= plan.getPrice() %>">
                                    <%= plan.getPlanName() %> - ₹<%= plan.getPrice() %> (<%= plan.getValidityDays() %> days)
                                </option>
                            <% } %>
                        </select>
                        <input type="number" id="amount" name="amount" step="0.01" min="0" required placeholder="Enter amount">
                    </div>

                    <div class="form-row">
                        <label for="paymentMethod">Payment Method</label>
                        <label for="notes">Notes (Optional)</label>
                    </div>
                    <div class="form-row">
                        <select id="paymentMethod" name="paymentMethod" required>
                            <option value="">Select Method</option>
                            <option value="Cash">Cash</option>
                            <option value="Card">Card</option>
                            <option value="UPI">UPI</option>
                            <option value="Net Banking">Net Banking</option>
                            <option value="Cheque">Cheque</option>
                        </select>
                        <input type="text" id="notes" name="notes" placeholder="Enter any notes...">
                    </div>
                    
                    <div class="form-actions">
                        <button type="submit" class="save-btn" id="saveBtn">
                            <i class="fas fa-save"></i> Save Payment
                        </button>
                        <button type="button" class="cancel-btn" onclick="resetForm()">
                            <i class="fas fa-times"></i> Cancel
                        </button>
                    </div>
                </form>
            </div>

            <div class="payment-section qr-card">
                <h3>Scan to Pay</h3>
                <div class="qr-content">
                    <!-- Use an <img> so the QR is reliably shown.
                         First tries /images/qr.png; if that fails, onerror falls back to an embedded SVG placeholder. -->
                    <div class="qr-code-placeholder">
                        <img alt="QR Code"
                             src="<%=ctx%>/images/qr-code.png"
                             onerror="this.onerror=null;
                                      this.src='data:image/svg+xml;utf8,<svg xmlns=&quot;http://www.w3.org/2000/svg&quot; width=&quot;300&quot; height=&quot;300&quot; viewBox=&quot;0 0 300 300&quot;><rect width=&quot;100%&quot; height=&quot;100%&quot; fill=&quot;%23ffffff&quot;/><text x=&quot;50%&quot; y=&quot;50%&quot; dominant-baseline=&quot;middle&quot; text-anchor=&quot;middle&quot; font-family=&quot;Arial, Helvetica, sans-serif&quot; font-size=&quot;18&quot; fill=&quot;%23000&quot;>QR image not found</text></svg>';">
                    </div>

                    <div class="payment-logos">
                        <div class="logo-box"><img src="<%=ctx%>/images/paytm.jpg" alt="Paytm"></div>
                        <div class="logo-box"><img src="<%=ctx%>/images/phonepe.jpg" alt="PhonePe"></div>
                        <div class="logo-box"><img src="<%=ctx%>/images/google-pay.jpg" alt="GPay"></div>
                        <div class="logo-box"><img src="<%=ctx%>/images/amazon-pay.jpg" alt="AmazonPay"></div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Loading overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="spinner"></div>
    </div>

    <script>
        // JavaScript for dynamic behavior
        
        // Auto-fill amount when plan is selected
        document.getElementById('planId').addEventListener('change', function() {
            var selectedOption = this.options[this.selectedIndex];
            var price = selectedOption.getAttribute('data-price');
            if (price) {
                document.getElementById('amount').value = parseFloat(price).toFixed(2);
            } else {
                document.getElementById('amount').value = '';
            }
        });
        
        // Auto-fill plan when amount is manually entered (optional feature)
        document.getElementById('amount').addEventListener('input', function() {
            var amount = parseFloat(this.value);
            if (!isNaN(amount)) {
                var planSelect = document.getElementById('planId');
                for (var i = 0; i < planSelect.options.length; i++) {
                    var option = planSelect.options[i];
                    var optionPrice = option.getAttribute('data-price');
                    if (optionPrice && Math.abs(parseFloat(optionPrice) - amount) < 0.01) {
                        planSelect.selectedIndex = i;
                        break;
                    }
                }
            }
        });
        
        // Form validation
        document.getElementById('paymentForm').addEventListener('submit', function(e) {
            var customerId = document.getElementById('customerId').value;
            var planId = document.getElementById('planId').value;
            var amount = document.getElementById('amount').value;
            var paymentMethod = document.getElementById('paymentMethod').value;
            
            // Basic validation
            if (!customerId || !planId || !amount || !paymentMethod) {
                e.preventDefault();
                alert('Please fill in all required fields');
                return false;
            }
            
            if (parseFloat(amount) <= 0) {
                e.preventDefault();
                alert('Amount must be greater than 0');
                return false;
            }
            
            // Show loading overlay
            document.getElementById('loadingOverlay').style.display = 'flex';
            
            return true;
        });
        
        // Reset form function
        function resetForm() {
            document.getElementById('paymentForm').reset();
            document.getElementById('amount').value = '';
            // If Tom Select changed underlying UI, also clear its control (safe to attempt)
            if (window.customerSelect && typeof window.customerSelect.clear === 'function') {
                window.customerSelect.clear();
            }
        }
        
        // Initialize form with current date
        document.addEventListener('DOMContentLoaded', function() {
            // Set today's date as default for renewal date if the field exists
            var renewalDateField = document.getElementById('renewalDate');
            if (renewalDateField) {
                var today = new Date().toISOString().split('T')[0];
                renewalDateField.value = today;
            }
            
            // Focus on first field
            var cust = document.getElementById('customerId');
            if (cust) cust.focus();
            
            // Hide loading overlay if it's visible
            document.getElementById('loadingOverlay').style.display = 'none';
        });
        
        // Handle page unload to hide loading overlay
        window.addEventListener('beforeunload', function() {
            document.getElementById('loadingOverlay').style.display = 'none';
        });
    </script>

    <!-- Tom Select initialization: searchable by both id (value) and text ("id - name") -->
    <script>
        (function(){
            var custEl = document.getElementById('customerId');
            if (!custEl) return;

            // Initialize Tom Select and keep reference to clear/select programmatically if needed
            window.customerSelect = new TomSelect('#customerId', {
                create: false,
                hideSelected: true,
                maxOptions: 200,
                dropdownDirection: 'auto',
                searchField: ['text','value'],
                // Use default scoring/search; render option/item using the original text
                render: {
                    option: function(data, escape) {
                        return '<div class="option">' + escape(data.text) + '</div>';
                    },
                    item: function(data, escape) {
                        return '<div class="item">' + escape(data.text) + '</div>';
                    }
                }
            });
        })();
    </script>
</body>
</html>
