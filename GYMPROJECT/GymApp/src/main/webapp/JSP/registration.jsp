<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gym Member Registration</title>

    <!-- correct css path -->
    <link rel="stylesheet" href="<%=ctx%>/styles.css">
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>

<style>
* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
    font-family: Arial, sans-serif;
}

body {
    background-color: #f4f4f4;
}

/* Layout */
.dashboard-container {
    display: flex;
    min-height: 100vh;
}

/* Sidebar */
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

/* make whole row clickable */
.nav-item {
    cursor: pointer;
}

.nav-item a {
    display: flex;
    align-items: center;
    padding: 15px 20px;
    color: white;
    text-decoration: none;
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
    background-color: #f4f4f4;   /* Light grey for active link */
    color: #2c3e50;              /* Dark text for active link */
    border-left: 5px solid #3498db;
    padding-left: 15px;
}

.logout {
    margin-top: auto;
    border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.logout a {
    display: flex;
    align-items: center;
    padding: 15px 20px;
    color: white;
    text-decoration: none;
}

.logout a i {
    margin-right: 15px;
}

/* Main content */
.main-content {
    flex-grow: 1;
    padding: 20px;
    background-color: #ecf0f1;
}

.top-header {
    display: flex;
    justify-content: flex-start;
    align-items: center;
    margin-bottom: 20px;
}

.gym-logo {
    width: 50px;
    height: 50px;
    margin-right: 15px;
    border-radius: 5px;
    object-fit: cover;
}

.gym-title {
    font-size: 1.5em;
    font-weight: bold;
    color: #34495e;
}

/* --- Registration Form Specific Styles --- */

.registration-form-card {
    background-color: white;
    padding: 30px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.registration-form-card h2 {
    margin-top: 0;
    margin-bottom: 20px;
    font-size: 1.8em;
    color: #34495e;
    font-weight: bold;
}

.registration-form {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.form-row {
    display: flex;
    gap: 20px;
    width: 100%;
}

.form-group {
    display: flex;
    flex-direction: column;
    flex-grow: 1;
}

/* 2-column layout */
.two-cols .form-group {
    flex-basis: 50%;
}

/* 3-column layout */
.three-cols {
    grid-template-columns: 2fr 1.5fr 0.5fr;
    display: grid;
    gap: 20px;
}

/* 4-column layout */
.four-cols {
    grid-template-columns: 2fr 1fr 1fr 1fr;
    display: grid;
    gap: 20px;
}

/* small inputs */
.small-input {
    min-width: 100px;
}

.form-group label {
    font-size: 0.9em;
    color: #7f8c8d;
    margin-bottom: 5px;
}

.form-group input, .form-group textarea, .form-group select {
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 4px;
    font-size: 1em;
    background-color: #f7f9fa;
    transition: border-color 0.2s;
}

.form-group input:focus, .form-group textarea:focus, .form-group select:focus {
    border-color: #3498db;
    outline: none;
    background-color: white;
}

/* Gender Radio Buttons */
.gender-group {
    display: block;
}

.radio-options {
    display: flex;
    align-items: center;
    gap: 20px;
    margin-top: 5px;
    padding-top: 10px;
}

.radio-options input[type="radio"] {
    appearance: none;
    background-color: #fff;
    margin: 0;
    font: inherit;
    color: currentColor;
    width: 1.15em;
    height: 1.15em;
    border: 0.15em solid currentColor;
    border-radius: 50%;
    transform: translateY(-0.075em);
    display: grid;
    place-content: center;
    cursor: pointer;
}

.radio-options input[type="radio"]::before {
    content: "";
    width: 0.65em;
    height: 0.65em;
    border-radius: 50%;
    transform: scale(0);
    transition: 120ms transform ease-in-out;
    box-shadow: inset 1em 1em #3498db;
}

.radio-options input[type="radio"]:checked::before {
    transform: scale(1);
}

/* Address + Time Slot */
.timeslot-row {
    grid-template-columns: 4fr 1fr;
    display: grid;
    align-items: flex-end;
    gap: 20px;
}

.address-group textarea {
    resize: vertical;
    min-height: 80px;
}

.timeslot-group {
    text-align: center;
}

.timeslot-container {
    background-color: #f7f9fa;
    border: 1px solid #ccc;
    border-radius: 4px;
    padding: 10px;
    height: 80px;
    display: flex;
    flex-direction: column;
    justify-content: center;
}

.timeslot-container i {
    font-size: 1.5em;
    color: #3498db;
    margin-bottom: 5px;
}

.timeslot-container select {
    width: 100%;
    padding: 8px;
    border: 1px solid #ddd;
    border-radius: 4px;
    background-color: white;
    font-size: 0.9em;
}

.timeslot-container select:focus {
    outline: none;
    border-color: #3498db;
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
    border: none;
    border-radius: 5px;
    font-weight: bold;
    cursor: pointer;
    transition: opacity 0.2s;
}

.btn-primary {
    background-color: #2c3e50;
    color: white;
}

.btn-primary:hover {
    opacity: 0.9;
}

.btn-secondary {
    background-color: white;
    color: #2c3e50;
    border: 1px solid #ccc;
}

.btn-secondary:hover {
    background-color: #f0f0f0;
}
</style>

<body>
<div class="dashboard-container">

    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="admin-profile">
            <i class="fas fa-user-circle profile-icon"></i>
            <div class="admin-details">
                <div class="admin-name">Admin Name</div>
                <div class="admin-email">arnoldmuscle07@gamil.com</div>
            </div>
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

                <li class="nav-item active">
                    <a href="<%=ctx%>/JSP/registration.jsp" class="active-link">
                        <i class="fas fa-clipboard-list"></i>
                        <span>Registration</span>
                    </a>
                </li>

                <li class="nav-item">
                    <a href="<%=ctx%>/JSP/membership.jsp">
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
                    <a href="<%=ctx%>/JSP/paymentExpenses.jsp">
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
                <!-- logo from /webapp/images/Logo.jpg -->
                <img src="<%=ctx%>/images/Logo.jpg" alt="Logo" class="gym-logo">
                <div class="gym-title">ARNOLD MUSCLE MECHANIC</div>
            </div>
        </header>

        <div class="registration-form-card">
            <h2>Register</h2>
            
            <!-- Success/Error Messages -->
            <%
                String success = request.getParameter("success");
                String error = (String) request.getAttribute("error");
                
                if (success != null && success.equals("true")) {
            %>
                <div style="background-color: #d4edda; color: #155724; padding: 10px; border-radius: 5px; margin-bottom: 20px;">
                    Registration successful! Member has been added to the database.
                </div>
            <%
                } else if (error != null) {
            %>
                <div style="background-color: #f8d7da; color: #721c24; padding: 10px; border-radius: 5px; margin-bottom: 20px;">
                    <%= error %>
                </div>
            <%
                }
            %>

            <form class="registration-form" action="<%=ctx%>/register" method="POST">
                <div class="form-row three-cols">
                    <div class="form-group">
                        <label for="name">Name of Member</label>
                        <input type="text" id="name" name="name" required>
                    </div>
                    <div class="form-group">
                        <label for="dob">Date of Birth</label>
                        <input type="date" id="dob" name="dob" required>
                    </div>
                    <div class="form-group small-input">
                        <label for="age">Age</label>
                        <input type="number" id="age" name="age">
                    </div>
                </div>

                <div class="form-row two-cols">
                    <div class="form-group">
                        <label for="email">Email Address</label>
                        <input type="email" id="email" name="email" required>
                    </div>
                    <div class="form-group">
                        <label for="contact">Contact No.</label>
                        <input type="tel" id="contact" name="contact" required>
                    </div>
                </div>

                <div class="form-row four-cols">
                    <div class="form-group gender-group">
                        <label>Gender</label>
                        <div class="radio-options">
                            <input type="radio" id="male" name="gender" value="male" checked>
                            <label for="male">Male</label>

                            <input type="radio" id="female" name="gender" value="female">
                            <label for="female">Female</label>

                            <input type="radio" id="others" name="gender" value="others">
                            <label for="others">Others</label>
                        </div>
                    </div>
                    <div class="form-group small-input">
                        <label for="height">Height (ft)</label>
                        <input type="number" id="height" name="height" step="0.01">
                    </div>
                    <div class="form-group small-input">
                        <label for="weight">Weight (kg)</label>
                        <input type="number" id="weight" name="weight" step="0.1">
                    </div>
                    <div class="form-group small-input">
                        <label for="bmi">BMI</label>
                        <input type="text" id="bmi" name="bmi" readonly>
                    </div>
                </div>

                <div class="form-row timeslot-row">
                    <div class="form-group address-group">
                        <label for="address">Address</label>
                        <textarea id="address" name="address" rows="3"></textarea>
                    </div>
                    <div class="form-group timeslot-group">
                        <label for="timeslot">Preferred Time Slot</label>
                        <div class="timeslot-container">
                            <i class="fas fa-clock"></i>
                            <select id="timeslot" name="timeslot" required>
                                <option value="">Select Time Slot</option>
                                <option value="6-8">6:00 AM - 8:00 AM</option>
                                <option value="8-10">8:00 AM - 10:00 AM</option>
                                <option value="17-19">5:00 PM - 7:00 PM</option>
                                <option value="19-21">7:00 PM - 9:00 PM</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="form-row three-cols">
                    <div class="form-group">
                        <label for="plan">Plan</label>
                        <select id="plan" name="plan">
                            <option value="">Select Plan</option>
                            <option value="1">Basic - 1 Month</option>
                            <option value="2">Premium - 3 Months</option>
                            <option value="3">Gold - 6 Months</option>
                            <option value="4">Platinum - 12 Months</option>
                        </select>
                    </div>
                    <div class="form-group small-input">
                        <label for="price">Price</label>
                        <input type="number" id="price" name="price">
                    </div>
                    <div class="form-group">
                        <label for="medical">Any medical Issue</label>
                        <input type="text" id="medical" name="medical">
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Avail Membership</button>
                    <button type="button" class="btn btn-secondary" onclick="resetForm()">Cancel</button>
                </div>
            </form>
        </div>

    </div>
</div>

<script>
// Calculate BMI when height or weight changes
document.getElementById('height').addEventListener('input', calculateBMI);
document.getElementById('weight').addEventListener('input', calculateBMI);

function calculateBMI() {
    const height = parseFloat(document.getElementById('height').value);
    const weight = parseFloat(document.getElementById('weight').value);
    
    if (height && weight && height > 0) {
        // Convert height from feet to meters
        const heightInMeters = height * 0.3048;
        const bmi = weight / (heightInMeters * heightInMeters);
        document.getElementById('bmi').value = bmi.toFixed(2);
    }
}

// Calculate age from date of birth
document.getElementById('dob').addEventListener('change', calculateAge);

function calculateAge() {
    const dob = new Date(document.getElementById('dob').value);
    const today = new Date();
    let age = today.getFullYear() - dob.getFullYear();
    const monthDiff = today.getMonth() - dob.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < dob.getDate())) {
        age--;
    }
    
    document.getElementById('age').value = age;
}

// Update price based on selected plan
document.getElementById('plan').addEventListener('change', updatePrice);

function updatePrice() {
    const plan = document.getElementById('plan').value;
    const priceMap = {
        '1': 1000,
        '2': 2500,
        '3': 4500,
        '4': 8000
    };
    
    if (priceMap[plan]) {
        document.getElementById('price').value = priceMap[plan];
    } else {
        document.getElementById('price').value = '';
    }
}

// Reset form
function resetForm() {
    if (confirm('Are you sure you want to clear all fields?')) {
        document.querySelector('form').reset();
        document.getElementById('bmi').value = '';
        document.getElementById('age').value = '';
        document.getElementById('timeslot').value = '';
    }
}

// Form validation
document.querySelector('form').addEventListener('submit', function(e) {
    const email = document.getElementById('email').value;
    const contact = document.getElementById('contact').value;
    const timeslot = document.getElementById('timeslot').value;
    
    // Email validation
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailPattern.test(email)) {
        alert('Please enter a valid email address');
        e.preventDefault();
        return;
    }
    
    // Contact validation (10 digits)
    const contactPattern = /^[0-9]{10}$/;
    if (!contactPattern.test(contact)) {
        alert('Please enter a valid 10-digit contact number');
        e.preventDefault();
        return;
    }
    
    // Time slot validation
    if (!timeslot) {
        alert('Please select a preferred time slot');
        e.preventDefault();
        return;
    }
});

// Auto-format contact number
document.getElementById('contact').addEventListener('input', function(e) {
    let value = e.target.value.replace(/\D/g, '');
    if (value.length > 10) {
        value = value.substring(0, 10);
    }
    e.target.value = value;
});

// Set today's date as max for date of birth
document.getElementById('dob').max = new Date().toISOString().split('T')[0];

// Set min date (100 years ago)
const today = new Date();
const minDate = new Date(today.getFullYear() - 100, today.getMonth(), today.getDate());
document.getElementById('dob').min = minDate.toISOString().split('T')[0];
</script>
</body>
</html>