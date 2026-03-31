package com.unispace.servlet;

import com.unispace.dao.InstructorDAO;
import com.unispace.model.Instructor;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    // GET — show the login page
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    // POST — process login form submission
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String instId = req.getParameter("instId");

        if (instId == null || instId.trim().isEmpty()) {
            req.setAttribute("error", "Please enter your Instructor ID.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        instId = instId.trim().toUpperCase();
        InstructorDAO dao = new InstructorDAO();

        // Validate instructor exists in DB
        if (dao.validateInstructor(instId)) {
            Instructor instructor = dao.getById(instId);

            // Store in session so all pages can access it
            HttpSession session = req.getSession();
            session.setAttribute("instId",     instructor.getId());
            session.setAttribute("instName",   instructor.getName());
            session.setAttribute("deptName",   instructor.getDeptName());

            resp.sendRedirect("dashboard.jsp");
        } else {
            req.setAttribute("error", "Instructor ID not found. Please try again.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }
}