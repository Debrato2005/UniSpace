package com.unispace.servlet;

import com.unispace.dao.BookingDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;

@WebServlet("/CancelBookingServlet")
public class CancelBookingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        // ================= AUTH =================
        if (session == null || session.getAttribute("instId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String instId = (String) session.getAttribute("instId");

        String bookingIdStr = req.getParameter("bookingId");
        String actionType = req.getParameter("type");

        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() +
                    "/BookingServlet?action=myBookings&error=InvalidRequest");
            return;
        }

        BookingDAO dao = new BookingDAO();

        try {
            int bookingId = Integer.parseInt(bookingIdStr.trim());
            boolean success;

            // ================= SINGLE DAY CANCEL =================
            if ("single".equalsIgnoreCase(actionType)) {

                String dateStr = req.getParameter("date");
                String reason = req.getParameter("reason");

                if (dateStr == null || dateStr.trim().isEmpty()
                        || reason == null || reason.trim().isEmpty()) {

                    resp.sendRedirect(req.getContextPath() +
                            "/BookingServlet?action=myBookings&error=InvalidInput");
                    return;
                }

                Date date = Date.valueOf(dateStr.trim());

                success = dao.cancelSpecificLecture(
                        bookingId,
                        date,
                        reason.trim()
                );

            } else if ("full".equalsIgnoreCase(actionType) || actionType == null) {

                // default = full cancel
                success = dao.cancelBooking(bookingId, instId);

            } else {
                // invalid type
                resp.sendRedirect(req.getContextPath() +
                        "/BookingServlet?action=myBookings&error=InvalidType");
                return;
            }

            // ================= RESULT =================
            if (success) {
                resp.sendRedirect(req.getContextPath() +
                        "/BookingServlet?action=myBookings");
            } else {
                resp.sendRedirect(req.getContextPath() +
                        "/BookingServlet?action=myBookings&error=CancelFailed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() +
                    "/BookingServlet?action=myBookings&error=Exception");
        }
    }
}