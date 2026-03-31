package com.unispace.servlet;

import com.unispace.dao.BookingDAO;
import com.unispace.model.Booking;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/ScheduleServlet")
public class ScheduleServlet extends HttpServlet {

    // GET — load schedule for the logged-in instructor
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Guard: must be logged in
        if (!isLoggedIn(req)) {
            resp.sendRedirect("login.jsp");
            return;
        }

        // Get instId from session (set during login)
        String instId = (String) req.getSession().getAttribute("instId");

        // Allow admins to view any instructor's schedule via ?instId=CS001
        String viewId = req.getParameter("instId");
        if (viewId != null && !viewId.isEmpty()) {
            instId = viewId.trim().toUpperCase();
        }

        BookingDAO dao          = new BookingDAO();
        List<Booking> bookings  = dao.getBookingsByInstructor(instId);

        req.setAttribute("bookings",      bookings);
        req.setAttribute("viewInstId",    instId);
        req.getRequestDispatcher("/schedule.jsp").forward(req, resp);
    }

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session != null && session.getAttribute("instId") != null;
    }
}