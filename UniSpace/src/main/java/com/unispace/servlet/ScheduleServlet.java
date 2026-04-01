package com.unispace.servlet;

import com.unispace.dao.BookingDAO;
import com.unispace.model.Booking;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/ScheduleServlet")
public class ScheduleServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ---------------- AUTH ----------------
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("instId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String instId = ((String) session.getAttribute("instId")).trim();

        // ---------------- OPTIONAL ADMIN VIEW (SAFE) ----------------
        String viewId = req.getParameter("instId");

        // ⚠️ Only allow override if you explicitly support admin (disabled by default)
        if (viewId != null && !viewId.trim().isEmpty()) {
            // You can enable this later with role check
            // instId = viewId.trim().toUpperCase();
        }

        // ---------------- FILTERS ----------------
        String semester = safe(req.getParameter("semester"));
        String year     = safe(req.getParameter("year"));
        String day      = safe(req.getParameter("day"));
        String category = safe(req.getParameter("category"));

        BookingDAO dao = new BookingDAO();
        List<Booking> bookings;

        boolean hasFilters =
                !semester.isEmpty() ||
                !year.isEmpty() ||
                !day.isEmpty() ||
                !category.isEmpty();

        try {
            if (hasFilters) {
                bookings = dao.getFilteredBookings(instId, semester, year, day, category);
            } else {
                bookings = dao.getBookingsByInstructor(instId);
            }
        } catch (Exception e) {
            e.printStackTrace();
            bookings = new ArrayList<>();
        }

        // ---------------- ATTRIBUTES ----------------
        req.setAttribute("bookings", bookings);
        req.setAttribute("viewInstId", instId);

        // ---------------- VIEW ----------------
        req.getRequestDispatcher("/schedule.jsp").forward(req, resp);
    }

    // ---------------- HELPERS ----------------
    private String safe(String val) {
        return (val == null) ? "" : val.trim();
    }
}