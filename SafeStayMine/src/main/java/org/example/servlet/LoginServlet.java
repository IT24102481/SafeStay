package org.example.servlet;

import org.example.dao.UserDAO;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userId = request.getParameter("userId");
        String password = request.getParameter("password");

        UserDAO userDAO = new UserDAO();
        User user = userDAO.login(userId, password);

        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("loginTime", new java.util.Date());

            // IMPORTANT: Remove any existing attributes that might cause loops
            session.removeAttribute("error");
            session.removeAttribute("errorMessage");

            // Redirect to DashboardServlet
            response.sendRedirect("dashboard");

        } else {
            request.setAttribute("errorMessage", "Invalid ID or Password!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}