package com.unispace.servlet;

import com.unispace.dao.InstructorDAO;
import com.unispace.model.Instructor;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    // ================= GET =================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        // If already logged in → go to dashboard
        if (session != null && session.getAttribute("instId") != null) {
            resp.sendRedirect(req.getContextPath() + "/DashboardServlet");
            return;
        }

        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    // ================= POST =================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String instId = req.getParameter("instId");

        if (instId == null || instId.trim().isEmpty()) {
            req.setAttribute("error", "Enter Instructor ID");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        instId = instId.trim().toUpperCase();

        InstructorDAO dao = new InstructorDAO();
        Instructor instructor = dao.validateInstructor(instId);

        if (instructor != null) {

            // ================= SESSION FIXATION FIX =================
            HttpSession oldSession = req.getSession(false);
            if (oldSession != null) oldSession.invalidate();

            HttpSession session = req.getSession(true);

            session.setAttribute("instId", instructor.getId());
            session.setAttribute("instName", instructor.getName());
            session.setAttribute("deptName", instructor.getDeptName());

            resp.sendRedirect(req.getContextPath() + "/DashboardServlet");

        } else {
            req.setAttribute("error", "Invalid Instructor ID");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }
}