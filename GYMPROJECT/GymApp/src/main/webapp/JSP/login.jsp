<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    // Check for error message
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Arnold Gym | Admin Login</title>
    <link rel="stylesheet" href="<%=ctx%>/style.css">
</head>

<style>
body {
    margin: 0;
    padding: 0;
    background: #0c2340;
    font-family: Arial, sans-serif;
}

.container {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    background: #1f273d;
}

.login-box {
    text-align: center;
    background: #112d55;
    padding: 40px 50px;
    border-radius: 15px;
    box-shadow: 0 0 20px rgba(0, 0, 0, 0.4);
    width: 350px;
}

.logo {
    width: 150px;
    margin-bottom: 20px;
    border-radius: 20px;
}

h2 {
    color: white;
    margin-bottom: 30px;
}

/* Error message styling */
.error-message {
    color: #ff6b6b;
    background: rgba(255, 107, 107, 0.1);
    padding: 10px;
    border-radius: 5px;
    margin-bottom: 15px;
    font-size: 14px;
}

.input-group {
    position: relative;
    margin: 15px 0;
}

.input-group input {
    width: 100%;
    padding: 12px 45px 12px 15px;
    border: none;
    outline: none;
    border-radius: 10px;
    font-size: 15px;
    background: #c8d6f1;
    box-sizing: border-box;
}

.icon {
    position: absolute;
    right: 12px;
    top: 9px;
    font-size: 18px;
    cursor: pointer;
}

.forgot {
    display: block;
    margin-top: 5px;
    color: #bcd4ff;
    font-size: 13px;
    text-decoration: none;
    text-align: right;
}

.forgot:hover {
    text-decoration: underline;
}

.login-btn {
    margin-top: 20px;
    width: 100%;
    padding: 12px;
    border: none;
    font-size: 16px;
    background: #2e66ff;
    color: white;
    border-radius: 20px;
    cursor: pointer;
    transition: 0.3s;
}

.login-btn:hover {
    background: #1e49cc;
}
</style>

<body>

<div class="container">
    <div class="login-box">
        <img src="<%=ctx%>/images/Logo.jpg" class="logo" alt="Gym Logo">
        
        <h2>Login</h2>
        
        <%-- Display error message if login fails --%>
        <% if (error != null && !error.isEmpty()) { %>
            <div class="error-message">
                <%= error %>
            </div>
        <% } %>
        
        <%-- Login form --%>
        <form id="loginForm" method="POST" action="<%=ctx%>/login">
            <div class="input-group">
                <%-- Changed id to name for servlet parameter access --%>
                <input type="text" name="username" placeholder="Enter Username or Email" required>
                <span class="icon">👤</span>
            </div>
            
            <div class="input-group">
                <input type="password" name="password" id="password" placeholder="Enter Password" required>
                <span class="icon" id="togglePassword">👁️</span>
            </div>
            
            <a href="<%=ctx%>/JSP/otp.jsp" class="forgot">Forgot Password?</a>
            
            <button type="submit" class="login-btn">Login</button>
        </form>
    </div>
</div>

<script>
    // Password visibility toggle
    document.getElementById('togglePassword').addEventListener('click', function() {
        const passwordInput = document.getElementById('password');
        const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput.setAttribute('type', type);
        this.textContent = type === 'password' ? '👁️' : '🔒';
    });
</script>

</body>
</html>