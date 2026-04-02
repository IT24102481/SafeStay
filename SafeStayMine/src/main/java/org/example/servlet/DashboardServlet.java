package org.example.servlet;

import org.example.dao.*;
import org.example.model.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Session check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        String role = user.getRole().toLowerCase();

        // Role-based redirect
        switch(role) {
            case "student":
                response.sendRedirect(request.getContextPath() + "/dashboard/student/");
                break;
            case "owner":
                response.sendRedirect(request.getContextPath() + "/dashboard/owner/");
                break;
            case "cleaning_staff":
            case "laundry_staff":
            case "kitchen_staff":
            case "it_supporter":
                response.sendRedirect(request.getContextPath() + "/dashboard/staff/");
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/dashboard/student/");
        }
    }
}
