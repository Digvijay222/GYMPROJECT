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
<title>Admin Login - Arnold Muscle Mechanic</title>
<link rel="stylesheet" href="styles.css">
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
	background-color: #1f273d;
	display: flex;
	justify-content: center;
	align-items: center;
	min-height: 100vh;
}

.login-container {
	display: flex;
	flex-direction: column;
	align-items: center;
}

.login-card {
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 30px;
}

.logo-area {
	background-color: #2c3e50;
	padding: 25px 35px;
	border-radius: 15px;
	display: flex;
	flex-direction: column;
	align-items: center;
	width: 200px;
	box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
	color: white;
	text-align: center;
}

.gym-logo {
	width: 100px;
	height: auto;
	filter: invert(1);
	margin-bottom: 5px;
}

.logo-text {
	font-size: 1.5em;
	font-weight: bold;
	letter-spacing: 1px;
	line-height: 1.2;
	margin-top: 5px;
}

.logo-text small {
	display: block;
	font-size: 0.6em;
	font-weight: normal;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	margin-top: 2px;
}

.gym-tag {
	font-size: 0.5em !important;
}

.login-form {
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 15px;
	width: 100%;
}

.input-group {
	display: flex;
	align-items: center;
	background-color: #c8d6f1;
	border-radius: 25px;
	padding: 5px 15px;
	width: 300px;
	box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

.input-group input {
	flex-grow: 1;
	border: none;
	padding: 10px 0;
	font-size: 1em;
	outline: none;
	background: none;
}

.input-group input::placeholder {
	color: #34495e;
}

.input-group i {
	color: #34495e;
	font-size: 1.1em;
	margin-left: 10px;
}

.otp-button {
	background-color: #3498db;
	color: white;
	border: none;
	padding: 12px 30px;
	border-radius: 25px;
	font-size: 1em;
	font-weight: bold;
	cursor: pointer;
	transition: background-color 0.2s, transform 0.1s;
	width: 150px;
	margin-top: 10px;
}

.otp-button:hover {
	background-color: #2980b9;
	transform: translateY(-1px);
}

.logo-area img {
	border-radius: 10px;
}

.otp-button a {
	color: white;
	text-decoration: none;
}
</style>
<body>
	<div class="login-container">
		<div class="login-card">
			<div class="logo-area">
				<img src="<%=ctx%>/images/Logo.jpg" width="150" height="250">

			</div>

			<form class="login-form">
				<div class="input-group">
					<input type="text" placeholder="Enter Phone/Email" required> <i
						class="fas fa-user-shield"></i>
				</div>

				<button type="submit" class="otp-button">
					<a href="conformPassword.jsp">Get OTP</a>
				</button>

			</form>
		</div>
	</div>
</body>
</html>