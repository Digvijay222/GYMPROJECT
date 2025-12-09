<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter"%>
<%@ page import="java.util.List"%>
<%@ page import="model.User, model.Attendance"%>
<%@ page import="dao.UserDAO, dao.AttendanceDAO"%>

<%
String ctx = request.getContextPath();

// logged in user from session
User loggedUser = (User) session.getAttribute("loggedUser");

// If no logged user, redirect to login
if (loggedUser == null) {
    response.sendRedirect(ctx + "/JSP/login.jsp");
    return;
}

String adminName = loggedUser.getName();
String adminEmail = loggedUser.getEmail();
String adminContact = (loggedUser.getContactNumber() != null) ? loggedUser.getContactNumber() : "799xxxx00";
String adminId = String.valueOf(loggedUser.getId());

// date / time
LocalDateTime now = LocalDateTime.now();
DateTimeFormatter dayFmt = DateTimeFormatter.ofPattern("EEEE");
DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("hh:mm a");

// Get daily entries from attendance table
AttendanceDAO attendanceDAO = new AttendanceDAO();
List<Attendance> dailyEntries = attendanceDAO.getTodayAttendance();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Gym Admin Page</title>

<link rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<style>
/* ---------------- COMMON STYLES ---------------- */
* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
    font-family: Arial, sans-serif;
}

body {
    background-color: #f4f4f4;
}

.dashboard-container {
    display: flex;
    min-height: 100vh;
}

/* ---------------- SIDEBAR ---------------- */
.sidebar {
    width: 250px;
    background-color: #2c3e50;
    color: white;
    padding: 20px 0;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}

.admin-profile {
    text-align: center;
    padding-bottom: 20px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.2);
}

.profile-icon {
    font-size: 60px;
    margin-bottom: 10px;
}

.navigation ul {
    list-style: none;
    padding: 0;
    margin: 0;
}

.nav-item {
    display: flex;
    align-items: center;
    padding: 15px 20px;
    cursor: pointer;
    transition: 0.2s;
}

.nav-item i {
    margin-right: 15px;
}

.nav-item:hover {
    background-color: #34495e;
}

.nav-item a {
    color: white;
    text-decoration: none;
    width: 100%;
    display: flex;
    align-items: center;
}

.nav-item.active {
    background-color: #f4f4f4;
    color: #2c3e50;
    border-left: 5px solid #3498db;
    padding-left: 15px;
}

.nav-item.active a {
    color: #2c3e50;
}

.logout {
    padding: 15px 20px;
    border-top: 1px solid rgba(255, 255, 255, 0.2);
    cursor: pointer;
}

.logout a {
    color: white;
    text-decoration: none;
}

/* ---------------- MAIN CONTENT ---------------- */
.main-content {
    flex-grow: 1;
    padding: 20px;
    background-color: #ecf0f1;
}

.top-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.gym-logo {
    width: 50px;
    height: 50px;
    background-color: #3498db;
    border-radius: 5px;
    margin-right: 10px;
    display: inline-block;
    object-fit: cover;
}

.gym-title {
    font-size: 1.5em;
    font-weight: bold;
    color: #34495e;
}

.date-time-info {
    padding: 10px 15px;
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    font-size: 0.9em;
    text-align: center;
}

.date-time-info div {
    margin: 2px 0;
}

/* ---------------- ADMIN PAGE: LAYOUT ADJUSTMENTS ---------------- */
.admin-page-container {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.top-cards-row {
    display: flex;
    gap: 20px;
    align-items: stretch;
}

/* Equal width for both cards */
.card-admin-info,
.card-attendance {
    flex: 1;
    min-width: 0;
    min-height: 300px; /* Equal height for both cards */
}

.card-attendance {
    display: flex;
    flex-direction: column;
}

/* ---------------- ADMIN PAGE: CARD STYLES ---------------- */
.card {
    background: white;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    height: 100%;
    display: flex;
    flex-direction: column;
}

.card h2 {
    margin-bottom: 15px;
    font-size: 20px;
    font-weight: 600;
    color: #2c3e50;
}

.profile-update {
    display: flex;
    align-items: flex-start;
    gap: 20px;
    border-bottom: 1px solid #eee;
    padding-bottom: 15px;
    flex-wrap: wrap;
}

.update-btn {
    background: #3498db;
    color: white;
    border: none;
    padding: 8px 20px;
    border-radius: 6px;
    cursor: pointer;
    transition: background 0.3s;
    white-space: nowrap;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    font-size: 13px;
    font-weight: 600;
}

.update-btn i {
    font-size: 13px;
}

.update-btn:hover {
    background: #2980b9;
}

.profile-update > div {
    flex: 1;
    min-width: 200px;
}

/* Daily Entries */
.entries-table {
    flex: 1;
    overflow: auto;
}

.entries-table table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 10px;
}

.entries-table th,
.entries-table td {
    padding: 12px 10px;
    text-align: left;
    border-bottom: 1px solid #eee;
}

.entries-table thead {
    background-color: #f7f9fa;
    position: sticky;
    top: 0;
}

.entries-table th {
    font-weight: 600;
    color: #2c3e50;
}

/* Attendance status icons */
.attendance-status {
    font-size: 1.2em;
}

.status-present {
    color: #2ecc71;
}

.status-absent {
    color: #e74c3c;
}

/* ---------------- ATTENDANCE FORM STYLES ---------------- */
.attendance-form {
    display: flex;
    flex-direction: column;
    gap: 15px;
    flex: 1;
}

.attendance-form-group {
    display: flex;
    flex-direction: column;
    gap: 5px;
}

.attendance-form-group label {
    font-weight: bold;
    color: #333;
    font-size: 14px;
}

.attendance-form-group input {
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 14px;
    background-color: #f9f9f9;
    width: 100%;
}

.attendance-form-group input:focus {
    outline: none;
    border-color: #3498db;
    background-color: white;
}

/* Radio button styles */
.attendance-radio-group {
    display: flex;
    gap: 20px;
    margin-top: 5px;
}

.radio-option {
    display: flex;
    align-items: center;
    gap: 8px;
    cursor: pointer;
}

.radio-option input[type="radio"] {
    margin: 0;
    width: 18px;
    height: 18px;
    cursor: pointer;
}

.radio-label {
    font-size: 14px;
    cursor: pointer;
}

.attendance-btn {
    background: #2ecc71;
    color: white;
    border: none;
    padding: 12px 20px;
    border-radius: 4px;
    cursor: pointer;
    font-weight: 600;
    transition: background 0.3s;
    font-size: 14px;
    margin-top: auto;
}

.attendance-btn:hover {
    background: #27ae60;
}

.attendance-btn:disabled {
    background: #95a5a6;
    cursor: not-allowed;
}

/* Customer info display */
.customer-info {
    background-color: #f8f9fa;
    padding: 12px;
    border-radius: 4px;
    border: 1px solid #dee2e6;
    margin-top: 5px;
    font-size: 13px;
}

.customer-info div {
    margin: 4px 0;
    display: flex;
    justify-content: space-between;
}

.customer-info-label {
    font-weight: bold;
    color: #495057;
}

.customer-info-value {
    color: #212529;
}

.membership-expired {
    background-color: #f8d7da;
    border-color: #f5c6cb;
    color: #721c24;
    padding: 8px;
    border-radius: 4px;
    margin-top: 8px;
    font-size: 12px;
    display: flex;
    align-items: center;
    gap: 8px;
}

/* ---------------- MODAL STYLES ---------------- */
.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    overflow: auto;
}

.modal-content {
    background-color: white;
    margin: 15% auto;
    padding: 0;
    border-radius: 8px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
    width: 90%;
    max-width: 500px;
    position: relative;
    animation: slideDown 0.3s ease;
}

@keyframes slideDown {
    from {
        transform: translateY(-50px);
        opacity: 0;
    }
    to {
        transform: translateY(0);
        opacity: 1;
    }
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

.success-modal-header {
    background-color: #d4edda;
    color: #155724;
    padding: 20px;
    border-radius: 8px 8px 0 0;
}

.error-modal-header {
    background-color: #f8d7da;
    color: #721c24;
    padding: 20px;
    border-radius: 8px 8px 0 0;
}

.info-modal-header {
    background-color: #d1ecf1;
    color: #0c5460;
    padding: 20px;
    border-radius: 8px 8px 0 0;
}

/* Toast Notification */
.toast {
    position: fixed;
    top: 20px;
    right: 20px;
    padding: 15px 20px;
    border-radius: 4px;
    color: white;
    font-weight: 600;
    z-index: 10000;
    animation: slideInRight 0.3s ease, fadeOut 0.3s ease 4.7s;
    max-width: 300px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    display: flex;
    align-items: center;
    gap: 10px;
}

.toast-success {
    background-color: #2ecc71;
}

.toast-error {
    background-color: #e74c3c;
}

.toast-info {
    background-color: #3498db;
}

@keyframes slideInRight {
    from {
        transform: translateX(100%);
        opacity: 0;
    }
    to {
        transform: translateX(0);
        opacity: 1;
    }
}

@keyframes fadeOut {
    from {
        opacity: 1;
    }
    to {
        opacity: 0;
    }
}

/* Loading spinner */
.spinner {
    display: inline-block;
    width: 20px;
    height: 20px;
    border: 3px solid #f3f3f3;
    border-top: 3px solid #3498db;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% {
        transform: rotate(0deg);
    }
    100% {
        transform: rotate(360deg);
    }
}

/* ---------- UPDATE PROFILE MODAL STYLES ---------- */
#updateProfileModal .modal-content {
    max-width: 520px;
    margin: 8% auto;
    padding: 24px 28px 20px;
    border-radius: 10px;
}

#updateProfileModal h2 {
    margin: 0 0 18px 0;
    font-size: 20px;
    font-weight: 600;
    color: #2c3e50;
    border-bottom: 1px solid #ecf0f1;
    padding-bottom: 10px;
}

#updateProfileModal .form-group {
    margin-bottom: 14px;
    display: flex;
    flex-direction: column;
    gap: 6px;
}

#updateProfileModal .form-group label {
    font-size: 13px;
    font-weight: 600;
    color: #34495e;
}

#updateProfileModal .form-group input {
    padding: 9px 10px;
    border-radius: 6px;
    border: 1px solid #dcdfe3;
    font-size: 13px;
    outline: none;
    transition: border 0.2s, box-shadow 0.2s, background-color 0.2s;
    background-color: #f9fbfd;
}

#updateProfileModal .form-group input:focus {
    border-color: #3498db;
    background-color: #ffffff;
    box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
}

/* password input + eye icon */
#updateProfileModal .password-wrapper {
    display: flex;
    align-items: center;
    border-radius: 6px;
    border: 1px solid #dcdfe3;
    background-color: #f9fbfd;
    overflow: hidden;
}

#updateProfileModal .password-wrapper input {
    border: none;
    flex: 1;
    background: transparent;
    padding: 9px 10px;
}

#updateProfileModal .password-wrapper input:focus {
    box-shadow: none;
}

#updateProfileModal .password-toggle {
    width: 40px;
    text-align: center;
    cursor: pointer;
    font-size: 14px;
    color: #7f8c8d;
    border-left: 1px solid #dcdfe3;
}

#updateProfileModal .password-toggle:hover {
    background-color: #ecf0f1;
    color: #2c3e50;
}

/* buttons */
#updateProfileModal .modal-buttons {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 18px;
    border-top: 1px solid #ecf0f1;
    padding-top: 12px;
}

#updateProfileModal .btn-cancel,
#updateProfileModal .btn-save {
    min-width: 110px;
    padding: 9px 14px;
    border-radius: 6px;
    border: none;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s, box-shadow 0.2s, transform 0.05s;
}

#updateProfileModal .btn-cancel {
    background-color: #ecf0f1;
    color: #7f8c8d;
}

#updateProfileModal .btn-cancel:hover {
    background-color: #d0d7de;
}

#updateProfileModal .btn-save {
    background-color: #3498db;
    color: #ffffff;
}

#updateProfileModal .btn-save:hover {
    background-color: #2980b9;
    box-shadow: 0 4px 10px rgba(41, 128, 185, 0.25);
    transform: translateY(-1px);
}

/* close (X) icon override for profile modal */
#updateProfileModal .close-modal {
    top: 14px;
    right: 16px;
    font-size: 22px;
}

/* Responsive */
@media (max-width: 1024px) {
    .top-cards-row {
        flex-direction: column;
    }
}

@media (max-width: 768px) {
    .modal-content {
        width: 90%;
        margin: 10% auto;
        padding: 20px;
    }
    .dashboard-container {
        flex-direction: column;
    }
    .sidebar {
        width: 100%;
        flex-direction: row;
        padding: 10px 0;
    }
    .admin-profile {
        flex-direction: row;
        padding: 0 20px;
        border-bottom: none;
        border-right: 1px solid rgba(255, 255, 255, 0.2);
    }
    .profile-icon {
        font-size: 40px;
        margin-bottom: 0;
        margin-right: 10px;
    }
    .navigation ul {
        display: flex;
        flex-wrap: wrap;
    }
    .nav-item {
        flex: 1;
        padding: 10px 5px;
        justify-content: center;
    }
    .nav-item i {
        margin-right: 0;
        margin-bottom: 5px;
        display: block;
    }
    .nav-item span {
        font-size: 0.8em;
        text-align: center;
    }
    .profile-update {
        flex-direction: column;
    }
    .profile-update > div {
        min-width: 100%;
    }
    .attendance-radio-group {
        flex-direction: column;
        gap: 10px;
    }
}
</style>
</head>

<body>

    <div class="dashboard-container">

        <div class="sidebar">

            <div class="admin-profile">
                <i class="fas fa-user-circle profile-icon"></i>
                <div><%=adminName%></div>
                <div style="font-size: 0.8em;"><%=adminEmail%></div>
            </div>

            <nav class="navigation">
                <ul>
                    <li class="nav-item">
                        <a href="<%=ctx%>/dashboard">
                            <i class="fas fa-chart-line"></i> <span>Dashboard</span>
                        </a>
                    </li>
                    <li class="nav-item active">
                        <a href="<%=ctx%>/JSP/admin.jsp">
                            <i class="fas fa-user-shield"></i> <span>Admin</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="<%=ctx%>/JSP/registration.jsp">
                            <i class="fas fa-clipboard-list"></i> <span>Registration</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="<%=ctx%>/JSP/membership.jsp">
                            <i class="fas fa-id-card"></i> <span>Membership</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="<%=ctx%>/JSP/addinventory.jsp">
                            <i class="fas fa-box-open"></i> <span>Add Inventory</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="<%=ctx%>/JSP/payment.jsp">
                            <i class="fas fa-hand-holding-usd"></i> <span>Payment</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="<%=ctx%>/customers">
                            <i class="fas fa-users"></i> <span>View Members</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="<%=ctx%>/JSP/profitExpenses.jsp">
                            <i class="fas fa-file-invoice-dollar"></i> <span>Profit & Expenses</span>
                        </a>
                    </li>
                </ul>
            </nav>

            <div class="logout">
                <i class="fas fa-sign-out-alt"></i> <a href="<%=ctx%>/logout">Logout</a>
            </div>
        </div>

        <div class="main-content">

            <header class="top-header">
                <div style="display: flex; align-items: center;">
                    <img src="<%=ctx%>/images/Logo.jpg" alt="Logo" class="gym-logo">
                    <div class="gym-title">ARNOLD MUSCLE MECHANIC</div>
                </div>

                <div class="date-time-info">
                    <div>Day : <%=now.format(dayFmt)%></div>
                    <div>Date : <%=now.format(dateFmt)%></div>
                    <div>Time : <%=now.format(timeFmt)%></div>
                </div>
            </header>

            <div class="admin-page-container">

                <div class="top-cards-row">

                    <div class="card card-admin-info">
                        <h2>Admin Information</h2>

                        <div class="profile-update">
                            <img src="<%=ctx%>/images/profile.png" alt="Profile"
                                class="gym-logo"
                                style="width: 90px; height: 90px; border-radius: 10px;">

                            <button class="update-btn" id="openUpdateModal">
                                <i class="fas fa-user-edit"></i> Update Profile
                            </button>

                            <div>
                                <div>
                                    <b>Username:</b>
                                    <span id="displayName"><%=adminName%></span>
                                </div>
                                <div>
                                    <b>Contact:</b>
                                    <span id="displayContact"><%=adminContact%></span>
                                </div>
                                <div>
                                    <b>Email:</b>
                                    <span id="displayEmail"><%=adminEmail%></span>
                                </div>
                                <div>
                                    <b>User ID:</b> <%=adminId%>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card card-attendance">
                        <h2>Mark Attendance</h2>

                        <form class="attendance-form" id="attendanceForm">
                            <div class="attendance-form-group">
                                <label for="mobileNumber">Mobile Number:</label>
                                <input
                                    type="text"
                                    id="mobileNumber"
                                    name="mobileNumber"
                                    placeholder="Enter 10-digit mobile number"
                                    pattern="[0-9]{10}"
                                    maxlength="10"
                                    oninput="fetchCustomerDetails()">
                                <div id="customerInfo" class="customer-info" style="display: none;">
                                    <div>
                                        <span class="customer-info-label">Name:</span>
                                        <span class="customer-info-value" id="customerName"></span>
                                    </div>
                                    <div>
                                        <span class="customer-info-label">Member ID:</span>
                                        <span class="customer-info-value" id="memberId"></span>
                                    </div>
                                    <div>
                                        <span class="customer-info-label">Email:</span>
                                        <span class="customer-info-value" id="customerEmail"></span>
                                    </div>
                                    <div>
                                        <span class="customer-info-label">Membership:</span>
                                        <span class="customer-info-value" id="membershipStatus"></span>
                                    </div>
                                    <div id="expiryWarning" class="membership-expired" style="display: none;">
                                        <i class="fas fa-exclamation-triangle"></i>
                                        Membership expired! Cannot mark attendance.
                                    </div>
                                </div>
                                <input type="hidden" id="customerId" name="customerId">
                            </div>

                            <div class="attendance-form-group">
                                <label>Attendance Status:</label>
                                <div class="attendance-radio-group">
                                    <label class="radio-option">
                                        <input type="radio" name="attendanceStatus" value="Present" checked>
                                        <span class="radio-label">Present</span>
                                    </label>
                                    <label class="radio-option">
                                        <input type="radio" name="attendanceStatus" value="Absent">
                                        <span class="radio-label">Absent</span>
                                    </label>
                                </div>
                            </div>

                            <button
                                type="button"
                                class="attendance-btn"
                                id="markAttendanceBtn"
                                onclick="submitAttendance()"
                                disabled>
                                <i></i> Mark Attendance
                            </button>
                        </form>
                    </div>

                </div>

                <div class="card">
                    <h2>Daily Entries :</h2>

                    <div class="entries-table">
                        <table>
                            <thead>
                                <tr>
                                    <th>NO:</th>
                                    <th>Name</th>
                                    <th>Member ID</th>
                                    <th>Login Time</th>
                                    <th>Attendance</th>
                                </tr>
                            </thead>

                            <tbody>
                                <%
                                int serial = 1;
                                if (dailyEntries != null && !dailyEntries.isEmpty()) {
                                    for (Attendance entry : dailyEntries) {
                                %>
                                <tr>
                                    <td><%=serial++%>.</td>
                                    <td><%=entry.getCustomerName()%></td>
                                    <td><%=String.format("%03d", entry.getCustomerId())%></td>
                                    <td>
                                        <%
                                        if ("Present".equals(entry.getStatus()) && entry.getLoginTime() != null) {
                                        %>
                                            <%=entry.getFormattedLoginTime()%>
                                        <%
                                        } else {
                                        %>
                                            N/A
                                        <%
                                        }
                                        %>
                                    </td>
                                    <td class="attendance-status">
                                        <%
                                        if ("Present".equals(entry.getStatus())) {
                                        %>
                                            <i class="fas fa-check-circle status-present"></i> Present
                                        <%
                                        } else {
                                        %>
                                            <i class="fas fa-times-circle status-absent"></i> Absent
                                        <%
                                        }
                                        %>
                                    </td>
                                </tr>
                                <%
                                    }
                                } else {
                                %>
                                <tr>
                                    <td colspan="5" style="text-align: center; padding: 20px;">
                                        No attendance marked for today
                                    </td>
                                </tr>
                                <%
                                }
                                %>
                            </tbody>

                        </table>
                    </div>
                </div>

            </div>

        </div>
    </div>

    <!-- Popup Modal for Messages -->
    <div id="messageModal" class="modal" style="display: none;">
        <div class="modal-content">
            <div id="modalHeader" style="padding: 20px; border-radius: 8px 8px 0 0;">
                <h2 id="modalTitle"
                    style="margin: 0; display: flex; align-items: center; gap: 10px;"></h2>
            </div>
            <div style="padding: 20px;">
                <p id="modalMessage" style="font-size: 16px; line-height: 1.5;"></p>
            </div>
            <div style="padding: 20px; text-align: right; border-top: 1px solid #eee;">
                <button id="closeModalBtn"
                    style="background: #3498db; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-weight: 600;">
                    OK
                </button>
            </div>
        </div>
    </div>

    <!-- Update Profile Modal -->
    <div id="updateProfileModal" class="modal" style="display: none;">
        <div class="modal-content">
            <span class="close-modal">&times;</span>
            <h2>Update Profile</h2>

            <form id="updateProfileForm" action="<%=ctx%>/updateProfile" method="POST">
                <input type="hidden" id="userId" name="userId" value="<%=adminId%>">

                <div class="form-group">
                    <label for="name">Full Name</label>
                    <input type="text" id="name" name="name" value="<%=adminName%>" required>
                </div>

                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" value="<%=adminEmail%>" required>
                </div>

                <div class="form-group">
                    <label for="contact">Contact Number</label>
                    <input
                        type="text"
                        id="contact"
                        name="contact"
                        value="<%=adminContact%>"
                        pattern="[0-9]{10}"
                        maxlength="10">
                </div>

                <div class="form-group">
                    <label for="currentPassword">Current Password (for verification)</label>
                    <div class="password-wrapper">
                        <input type="password" id="currentPassword" name="currentPassword" required>
                        <span class="password-toggle"
                            onclick="togglePassword('currentPassword', this)">
                            <i class="fas fa-eye"></i>
                        </span>
                    </div>
                </div>

                <div class="form-group">
                    <label for="newPassword">New Password (leave blank to keep current)</label>
                    <div class="password-wrapper">
                        <input type="password" id="newPassword" name="newPassword">
                        <span class="password-toggle"
                            onclick="togglePassword('newPassword', this)">
                            <i class="fas fa-eye"></i>
                        </span>
                    </div>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Confirm New Password</label>
                    <div class="password-wrapper">
                        <input type="password" id="confirmPassword" name="confirmPassword">
                        <span class="password-toggle"
                            onclick="togglePassword('confirmPassword', this)">
                            <i class="fas fa-eye"></i>
                        </span>
                    </div>
                </div>

                <div class="modal-buttons">
                    <button type="button" class="btn-cancel" id="cancelUpdate">Cancel</button>
                    <button type="submit" class="btn-save">
                        <i class="fas fa-save"></i> Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>

<script>
// DOM Ready
document.addEventListener('DOMContentLoaded', function() {
    console.log("Admin page loaded");
    
    // Initialize modal close button
    const closeModalBtn = document.getElementById('closeModalBtn');
    const messageModal = document.getElementById('messageModal');
    
    if (closeModalBtn && messageModal) {
        closeModalBtn.addEventListener('click', function() {
            messageModal.style.display = 'none';
            location.reload(); // Reload page to update attendance table
        });
        
        // Close modal when clicking outside
        window.addEventListener('click', function(event) {
            if (event.target === messageModal) {
                messageModal.style.display = 'none';
                location.reload(); // Reload page to update attendance table
            }
        });
    }
    
    // Initialize update profile modal
    const updateModal = document.getElementById('updateProfileModal');
    const openUpdateBtn = document.getElementById('openUpdateModal');
    const closeUpdateBtn = document.querySelector('#updateProfileModal .close-modal');
    const cancelUpdateBtn = document.getElementById('cancelUpdate');
    
    if (openUpdateBtn && updateModal) {
        openUpdateBtn.addEventListener('click', function() {
            updateModal.style.display = 'block';
        });
    }
    
    if (closeUpdateBtn && updateModal) {
        closeUpdateBtn.addEventListener('click', function() {
            updateModal.style.display = 'none';
        });
    }
    
    if (cancelUpdateBtn && updateModal) {
        cancelUpdateBtn.addEventListener('click', function() {
            updateModal.style.display = 'none';
        });
    }
    
    // Close update modal when clicking outside
    window.addEventListener('click', function(event) {
        const updateModalEl = document.getElementById('updateProfileModal');
        if (event.target === updateModalEl) {
            updateModalEl.style.display = 'none';
        }
    });
});

// Show toast notification
function showToast(message, type) {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    
    let iconClass;
    if (type === 'success') {
        iconClass = 'fa-check-circle';
    } else if (type === 'error') {
        iconClass = 'fa-exclamation-circle';
    } else {
        iconClass = 'fa-info-circle';
    }
    
    toast.innerHTML = `<i class="fas ${iconClass}"></i> <span>${message}</span>`;
    
    document.body.appendChild(toast);
    
    // Remove toast after 5 seconds
    setTimeout(() => {
        toast.remove();
    }, 5000);
}

// Show modal popup
function showModal(title, message, type) {
    const modal = document.getElementById('messageModal');
    const modalTitle = document.getElementById('modalTitle');
    const modalMessage = document.getElementById('modalMessage');
    const modalHeader = document.getElementById('modalHeader');
    
    if (modal && modalTitle && modalMessage && modalHeader) {
        let iconClass;
        if (type === 'success') {
            iconClass = 'fa-check-circle';
        } else if (type === 'error') {
            iconClass = 'fa-exclamation-circle';
        } else {
            iconClass = 'fa-info-circle';
        }
        
        modalTitle.innerHTML = `<i class="fas ${iconClass}"></i> ${title}`;
        modalMessage.textContent = message;
        modalHeader.className = `${type}-modal-header`;
        modal.style.display = 'block';
    }
}
//Submit attendance via AJAX
function submitAttendance() {
    console.log("submitAttendance called");
    
    const mobileNumber = document.getElementById('mobileNumber').value.trim();
    const status = document.querySelector('input[name="attendanceStatus"]:checked').value;
    const attendanceBtn = document.getElementById('markAttendanceBtn');
    const membershipStatusElement = document.getElementById('membershipStatus');
    
    console.log("Mobile (client):", mobileNumber, "Status (client):", status);
    
    if (!mobileNumber) {
        showToast('Please enter mobile number', 'error');
        return;
    }
    
    if (mobileNumber.length !== 10) {
        showToast('Please enter a valid 10-digit mobile number', 'error');
        return;
    }
    
    if (membershipStatusElement) {
        const memberStatus = membershipStatusElement.getAttribute('data-status');
        if (memberStatus === 'Expired') {
            showModal(
                'Membership Expired',
                'Cannot mark attendance for expired membership. Please renew membership first.',
                'error'
            );
            return;
        }
    }
    
    // Disable button and show loading
    if (attendanceBtn) {
        attendanceBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Marking...';
        attendanceBtn.disabled = true;
    }
    
    // 🔴 OLD (multipart/form-data that breaks getParameter):
    // const formData = new FormData();
    // formData.append('mobileNumber', mobileNumber);
    // formData.append('attendanceStatus', status);
    
    // ✅ NEW: send URL-encoded form data so getParameter() works
    const params = new URLSearchParams();
    params.append('mobileNumber', mobileNumber);
    params.append('attendanceStatus', status);
    
    // Send AJAX request
    fetch('<%=ctx%>/markAttendance', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
        },
        body: params.toString()
    })
    .then(response => {
        console.log("Response status:", response.status);
        return response.json();
    })
    .then(data => {
        console.log("Response data:", data);
        
        // Reset button state
        if (attendanceBtn) {
            attendanceBtn.innerHTML = '<i class="fas fa-fingerprint"></i> Mark Attendance';
            attendanceBtn.disabled = false;
        }
        
        if (data.status === 'success') {
            // Show success modal
            showModal('Success', data.message, 'success');
            
            // Clear the form
            document.getElementById('mobileNumber').value = '';
            document.getElementById('customerInfo').style.display = 'none';
            document.getElementById('markAttendanceBtn').disabled = true;
            
            // Also show a quick toast
            showToast('Attendance marked successfully!', 'success');
            
        } else {
            // Show error modal
            showModal('Error', data.message, 'error');
            
            // Show error toast
            showToast(data.message, 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        
        // Reset button state
        if (attendanceBtn) {
            attendanceBtn.innerHTML = '<i class="fas fa-fingerprint"></i> Mark Attendance';
            attendanceBtn.disabled = false;
        }
        
        showModal('Error', 'An error occurred. Please try again.', 'error');
        showToast('Network error. Please try again.', 'error');
    });
}

// Fetch customer details when mobile number is entered
let fetchTimeout;
function fetchCustomerDetails() {
    console.log("fetchCustomerDetails called");
    
    const mobileInput = document.getElementById('mobileNumber');
    if (!mobileInput) {
        console.error("mobileNumber input not found!");
        return;
    }
    
    const mobileNumber = mobileInput.value.trim().replace(/\D/g, '');
    const attendanceBtn = document.getElementById('markAttendanceBtn');
    const customerInfo = document.getElementById('customerInfo');
    const customerName = document.getElementById('customerName');
    const memberId = document.getElementById('memberId');
    const customerEmail = document.getElementById('customerEmail');
    const membershipStatus = document.getElementById('membershipStatus');
    const expiryWarning = document.getElementById('expiryWarning');
    
    console.log("Mobile number entered:", mobileNumber);
    
    // Clear previous timeout
    if (fetchTimeout) {
        clearTimeout(fetchTimeout);
    }
    
    // Update input with numbers only
    mobileInput.value = mobileNumber;
    
    // Hide customer info and disable button
    if (customerInfo) customerInfo.style.display = 'none';
    if (expiryWarning) expiryWarning.style.display = 'none';
    if (attendanceBtn) attendanceBtn.disabled = true;
    
    if (mobileNumber.length !== 10) {
        console.log("Mobile number not 10 digits yet:", mobileNumber.length);
        return;
    }
    
    // Set timeout to avoid too many requests
    fetchTimeout = setTimeout(() => {
        if (!mobileNumber || mobileNumber.length !== 10) {
            console.log("Invalid mobile number after timeout");
            return;
        }
        
        console.log("Fetching customer data for mobile:", mobileNumber);
        
        // Show loading in customer info
        if (customerName) customerName.textContent = 'Loading...';
        if (memberId) memberId.textContent = '...';
        if (customerEmail) customerEmail.textContent = '...';
        if (membershipStatus) {
            membershipStatus.textContent = 'Checking...';
            membershipStatus.removeAttribute('data-status');
        }
        if (customerInfo) customerInfo.style.display = 'block';
        
        // Fetch customer data
        const url = '<%=ctx%>/fetchCustomer?mobileNumber=' + encodeURIComponent(mobileNumber);
        console.log("Fetching from URL:", url);
        
        fetch(url)
            .then(response => {
                console.log("Response status:", response.status);
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.status);
                }
                return response.json();
            })
            .then(data => {
                console.log("Data received:", data);
                
                if (data.error) {
                    console.log("Error from server:", data.error);
                    if (customerName) customerName.textContent = data.error;
                    if (memberId) memberId.textContent = 'Not found';
                    if (customerEmail) customerEmail.textContent = 'N/A';
                    if (membershipStatus) {
                        membershipStatus.textContent = 'N/A';
                        membershipStatus.removeAttribute('data-status');
                        membershipStatus.style.color = '';
                    }
                    if (attendanceBtn) attendanceBtn.disabled = true;
                } else {
                    console.log("Customer found:", data.name);
                    if (customerName) customerName.textContent = data.name;
                    if (memberId) memberId.textContent = data.memberId;
                    if (customerEmail) customerEmail.textContent = data.email || 'N/A';
                    if (membershipStatus) {
                        membershipStatus.textContent = data.membershipStatus;
                        membershipStatus.setAttribute('data-status', data.membershipStatus);
                    }
                    
                    if (data.isActive) {
                        console.log("Customer is active");
                        if (attendanceBtn) attendanceBtn.disabled = false;
                        if (expiryWarning) expiryWarning.style.display = 'none';
                        if (membershipStatus) {
                            membershipStatus.style.color = '#28a745';
                            membershipStatus.innerHTML =
                                '<i class="fas fa-check-circle"></i> ' + data.membershipStatus;
                        }
                    } else {
                        console.log("Customer membership expired");
                        if (attendanceBtn) attendanceBtn.disabled = true;
                        if (expiryWarning) {
                            expiryWarning.style.display = 'block';
                            if (data.expiryDate) {
                                expiryWarning.innerHTML =
                                    '<i class="fas fa-exclamation-triangle"></i> Membership expired on ' +
                                    data.expiryDate +
                                    '! Cannot mark attendance.';
                            }
                        }
                        if (membershipStatus) {
                            membershipStatus.style.color = '#dc3545';
                            membershipStatus.innerHTML =
                                '<i class="fas fa-times-circle"></i> ' + data.membershipStatus;
                        }
                    }
                }
            })
            .catch(error => {
                console.error('Error in fetchCustomerDetails:', error);
                if (customerName) customerName.textContent = 'Error fetching data';
                if (memberId) memberId.textContent = 'Error';
                if (customerEmail) customerEmail.textContent = 'N/A';
                if (membershipStatus) {
                    membershipStatus.textContent = 'Error';
                    membershipStatus.removeAttribute('data-status');
                    membershipStatus.style.color = '';
                }
                if (attendanceBtn) attendanceBtn.disabled = true;
            });
    }, 800); // delay to avoid too many requests
}

// Toggle password visibility
function togglePassword(fieldId, toggleBtn) {
    const field = document.getElementById(fieldId);
    const icon = toggleBtn.querySelector('i');
    
    if (!field || !icon) return;
    
    if (field.type === 'password') {
        field.type = 'text';
        icon.className = 'fas fa-eye-slash';
    } else {
        field.type = 'password';
        icon.className = 'fas fa-eye';
    }
}

// Format mobile number input
document.getElementById('mobileNumber')?.addEventListener('input', function(e) {
    let value = e.target.value.replace(/\D/g, '');
    if (value.length > 10) {
        value = value.substring(0, 10);
    }
    e.target.value = value;
});

// Auto-focus on mobile number field
window.addEventListener('load', function() {
    setTimeout(function() {
        const mobileInput = document.getElementById('mobileNumber');
        if (mobileInput) {
            mobileInput.focus();
            console.log("Focused on mobile number input");
        }
    }, 100);
});
</script>
</body>
</html>
