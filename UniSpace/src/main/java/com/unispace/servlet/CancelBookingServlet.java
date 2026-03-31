package com.unispace.servlet;

import com.unispace.dao.BookingDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;

@WebServlet("/CancelBookingServlet")
public class CancelBookingServlet extends HttpServlet {

    // POST — handles both full cancellation and single-lecture cancellation
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Guard: must be logged in
        if (!isLoggedIn(req)) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String cancelType = req.getParameter("cancelType");
        // cancelType = "FULL"    → cancel the entire booking
        // cancelType = "SINGLE"  → cancel one specific date (periodic booking)

        String bookingIdStr = req.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.isEmpty()) {
            resp.sendRedirect("bookings.jsp?msg=Invalid+booking+ID");
            return;
        }

        int    bookingId  = Integer.parseInt(bookingIdStr);
        String changedBy  = (String) req.getSession().getAttribute("instId");
        BookingDAO dao    = new BookingDAO();

        if ("FULL".equals(cancelType)) {
            // Cancel the entire booking
            boolean success = dao.cancelBooking(bookingId, changedBy);
            if (success) {
                resp.sendRedirect("bookings.jsp?msg=Booking+cancelled+successfully");
            } else {
                resp.sendRedirect("bookings.jsp?msg=Cancellation+failed.+Booking+may+not+exist.");
            }

        } else if ("SINGLE".equals(cancelType)) {
            // Cancel one specific date within a periodic booking
            String dateStr = req.getParameter("cancelDate");
            String reason  = req.getParameter("reason");

            if (dateStr == null || dateStr.isEmpty()) {
                resp.sendRedirect("bookings.jsp?msg=Please+provide+a+date+to+cancel");
                return;
            }

            Date cancelDate = Date.valueOf(dateStr); // expects yyyy-MM-dd format
            boolean success = dao.cancelSpecificLecture(bookingId, cancelDate, reason);

            if (success) {
                resp.sendRedirect("bookings.jsp?msg=Lecture+cancelled+successfully");
            } else {
                resp.sendRedirect("bookings.jsp?msg=Lecture+cancellation+failed.+Date+may+already+be+cancelled.");
            }

        } else {
            resp.sendRedirect("bookings.jsp?msg=Unknown+cancel+type");
        }
    }

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session != null && session.getAttribute("instId") != null;
    }
}