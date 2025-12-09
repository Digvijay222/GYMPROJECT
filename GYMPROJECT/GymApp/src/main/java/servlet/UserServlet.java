/*
 * package servlet;
 * 
 * import java.io.IOException;
 * 
 * import java.io.PrintWriter;
 * 
 * import com.google.gson.Gson;
 * 
 * import dao.UserDAO; import jakarta.servlet.ServletException; import
 * jakarta.servlet.http.HttpServlet; import
 * jakarta.servlet.http.HttpServletRequest; import
 * jakarta.servlet.http.HttpServletResponse; import
 * jakarta.servlet.http.HttpSession; import model.User;
 * 
 * public class UserServlet extends HttpServlet { private static final long
 * serialVersionUID = 1L; private UserDAO userDAO;
 * 
 * @Override public void init() throws ServletException { userDAO = new
 * UserDAO(); }
 * 
 * protected void doPost(HttpServletRequest request, HttpServletResponse
 * response) throws ServletException, IOException {
 * 
 * response.setContentType("application/json");
 * response.setCharacterEncoding("UTF-8"); PrintWriter out =
 * response.getWriter(); String action = request.getParameter("action");
 * 
 * try { if (action == null) {
 * out.write("{\"error\": \"No action specified\"}"); return; }
 * 
 * switch (action) { case "login": loginUser(request, response, out); break;
 * case "register": registerUser(request, response, out); break; default:
 * out.write("{\"error\": \"Invalid action: " + action + "\"}"); } } catch
 * (Exception e) { out.write("{\"error\": \"Server error: " + e.getMessage() +
 * "\"}"); e.printStackTrace(); } }
 * 
 * private void loginUser(HttpServletRequest request, HttpServletResponse
 * response, PrintWriter out) throws IOException { String username =
 * request.getParameter("username"); String password =
 * request.getParameter("password");
 * 
 * System.out.println("Login attempt: " + username);
 * 
 * User user = userDAO.login(username, password); if (user != null) { // Create
 * session HttpSession session = request.getSession();
 * session.setAttribute("user", user); session.setAttribute("username",
 * user.getUsername()); session.setAttribute("userId", user.getId());
 * 
 * // Return user data as JSON Gson gson = new Gson();
 * out.write(gson.toJson(user)); System.out.println("Login successful for: " +
 * username); } else {
 * out.write("{\"error\": \"Invalid username or password\"}");
 * System.out.println("Login failed for: " + username); } }
 * 
 * private void registerUser(HttpServletRequest request, HttpServletResponse
 * response, PrintWriter out) { try { User user = new User();
 * user.setUsername(request.getParameter("username"));
 * user.setPassword(request.getParameter("password"));
 * user.setName(request.getParameter("name"));
 * user.setContactNumber(request.getParameter("contactNumber"));
 * user.setEmail(request.getParameter("email"));
 * 
 * boolean success = userDAO.addUser(user); if (success) {
 * out.write("{\"success\": \"User registered successfully\", \"id\": " +
 * user.getId() + "}"); } else {
 * out.write("{\"error\": \"Registration failed\"}"); } } catch (Exception e) {
 * out.write("{\"error\": \"Registration error: " + e.getMessage() + "\"}"); } }
 * 
 * // Add doGet for logout protected void doGet(HttpServletRequest request,
 * HttpServletResponse response) throws ServletException, IOException { String
 * action = request.getParameter("action");
 * 
 * if ("logout".equals(action)) { HttpSession session =
 * request.getSession(false); if (session != null) { session.invalidate(); }
 * response.sendRedirect("login.jsp"); } } }
 */