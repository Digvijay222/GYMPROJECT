<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
// Context path for using /GymApp correctly
String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Arnold Muscle Mechanic - View Members</title>
<link rel="stylesheet" href="styles.css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<style>

/* Color Variables */
:root {
	--primary-dark: #1e293b;
	/* Dark Indigo/Blue for sidebar and card background */
	--secondary-dark: #2d3748;
	/* Slightly lighter dark for inputs/buttons in dark card */
	--accent-blue: #3b82f6; /* Bright Blue for active/accent */
	--text-light: #ffffff;
	--text-gray: #a0aec0;
	--text-dark: #333; /* Dark text for main content background */
	--background-light: #e2e8f0; /* Very light background for body */
	--status-red: #f56565; /* Red for Due Amount */
	--status-green: #48bb78; /* Green for Paid/Call Icon */
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

/* Active State for View Members */
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
	/* Placeholder icon for the logo */
	content:
		url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%23FFFFFF"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm-1-13h2v6h-2zM9 11h2v2H9zM13 11h2v2h-2zM9 15h6v2H9z"/></svg>');
}

.header-title h2 {
	color: var(--primary-dark);
	font-size: 1.5em;
	font-weight: bold;
}

.page-title {
	color: var(--primary-dark);
	font-size: 1.8em;
	font-weight: bold;
	margin-bottom: 25px;
}

/* --- Members Panel Styling (The Dark Card) --- */
.members-panel {
	background-color: var(--primary-dark);
	color: var(--text-light);
	padding: 30px;
	border-radius: 8px;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
	flex-grow: 1;
}

.panel-title {
	font-size: 1.4em;
	font-weight: bold;
	margin-bottom: 20px;
}

/* Controls (Show Entities & Search) */
.controls-row {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 20px;
}

.show-entries-label {
	font-size: 0.9em;
	color: var(--text-light);
}

.show-entries-label select {
	padding: 5px 10px;
	border: 1px solid var(--secondary-dark);
	border-radius: 4px;
	margin-left: 5px;
	background-color: var(--secondary-dark);
	color: var(--text-light);
}

.search-box {
	display: flex;
	align-items: center;
	border: 1px solid var(--secondary-dark);
	border-radius: 4px;
	padding: 5px 10px;
	background-color: white;
}

.search-box input[type="text"] {
	border: none;
	outline: none;
	padding: 5px;
	width: 250px;
	background: transparent;
	color: var(--text-light);
}

.search-icon {
	color: var(--text-gray);
	cursor: pointer;
}

/* --- Members Table --- */
.members-table {
	width: 100%;
	border-collapse: collapse;
	font-size: 0.9em;
}

.members-table th, .members-table td {
	padding: 12px 15px;
	text-align: left;
	border-bottom: 1px solid var(--secondary-dark);
}

.members-table th {
	color: var(--text-light);
	font-weight: 500;
}

.members-table tbody tr:hover {
	background-color: var(--secondary-dark);
}

/* Due Amount Status */
.status-red {
	color: var(--status-red);
	font-weight: bold;
}

.status-green {
	color: var(--status-green);
	font-weight: bold;
}

/* Action Button (Clear) */
.action-btn {
	background-color: transparent;
	color: var(--text-light);
	border: 1px solid var(--text-light);
	padding: 5px 12px;
	border-radius: 4px;
	cursor: pointer;
	font-size: 0.85em;
	transition: background-color 0.2s;
}

.action-btn:hover {
	background-color: var(--secondary-dark);
}

/* Message Icon (Call Icon) */
.call-icon {
	font-size: 1.1em;
	color: var(--status-green);
	cursor: pointer;
	padding: 5px;
}

/* Pagination */
.pagination {
	display: flex;
	justify-content: flex-end;
	gap: 10px;
	margin-top: 20px;
}

.nav-btn {
	background-color: var(--secondary-dark);
	color: var(--text-light);
	border: none;
	padding: 8px 15px;
	border-radius: 4px;
	cursor: pointer;
	font-weight: bold;
	transition: background-color 0.2s;
}

.nav-btn:hover {
	background-color: #3f4a5c;
}

.main-header img {
	border-radius: 10px;
}

.header-title h2 {
	padding: 20px;
}

.action-btn a {
	color: white;
	text-decoration: none;
}

.members-table td img {
	border-radius: 10px;
}
</style>
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
                <li class="active">
                    <a href="<%=ctx%>/JSP/viewmembers.jsp"><i class="fas fa-users"></i> View Members</a>
                </li>
                <li><a href="<%=ctx%>/JSP/profitExpenses.jsp"><i class="fas fa-chart-line"></i> Profit & Expenses</a></li>
				</ul>
			</nav>
			<div class="logout-section">
				<a href="#"><i class="fas fa-sign-out-alt"></i> Logout</a>
			</div>
		</aside>

		<main class="main-content">
			<header class="main-header">
				<img src="<%=ctx%>/images/Logo.jpg" width="40" height="80">
				<div class="header-title">
					<h2>ARNOLD MUSCLE MECHANIC</h2>
				</div>
			</header>

			<h1 class="page-title">Active Members</h1>

			<div class="members-panel">
				<h3 class="panel-title">Gym Members</h3>

				<div class="controls-row">
					<label class="show-entries-label">Show entities <select>
							<option>2</option>
							<option>3</option>
					</select>
					</label>
					<div class="search-box">
						<input type="text" placeholder="Search By Member ID / Name">
						<i class="fas fa-search search-icon"></i>
					</div>
				</div>

				<table class="members-table">
					<thead>
						<tr>
							<th>photos</th>
							<th>Name</th>
							<th>Member ID</th>
							<th>Date Enrolled</th>
							<th>Date Expiration</th>
							<th>Due Amount</th>
							<th>Age</th>
							<th>Height</th>
							<th>Action</th>

						</tr>
					</thead>
					<tbody>
						<tr>
							<td><img src="photo.png" width="40" height="40"></td>
							<td>Ranjith</td>
							<td>002ranjith</td>
							<td>Jan 11</td>
							<td>Feb 8</td>
							<td><span class="status-red">Unpaid</span></td>
							<td>26</td>
							<td>7.6</td>
							<td><button class="action-btn">Edit</button></td>

						</tr>

					</tbody>
				</table>

				<div class="pagination">
					<button class="nav-btn">Previous</button>
					<button class="nav-btn">Next</button>
				</div>

			</div>
		</main>
	</div>
</body>
</html>