package com.unispace.servlet;

import com.unispace.dao.BookingDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        // ================= AUTH CHECK =================
        if (session == null || session.getAttribute("instId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp"); // ✅ FIX
            return;
        }

        String instId = ((String) session.getAttribute("instId")).trim();

        BookingDAO dao = new BookingDAO();

        try {
            int total  = dao.countTotal(instId);
            int course = dao.countByCategory(instId, "COURSE");
            int event  = dao.countByCategory(instId, "EVENT");
            int club   = dao.countByCategory(instId, "CLUB");

            req.setAttribute("totalBookings", total);
            req.setAttribute("courseBookings", course);
            req.setAttribute("eventBookings", event);
            req.setAttribute("clubBookings", club);

        } catch (Exception e) {
            e.printStackTrace();

            // safe fallback
            req.setAttribute("totalBookings", 0);
            req.setAttribute("courseBookings", 0);
            req.setAttribute("eventBookings", 0);
            req.setAttribute("clubBookings", 0);
        }

        req.getRequestDispatcher("/dashboard.jsp").forward(req, resp);
    }
}