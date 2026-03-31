package com.unispace.servlet;

import com.unispace.dao.BookingDAO;
import com.unispace.dao.InstructorDAO;
import com.unispace.dao.RoomDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/BookingServlet")
public class BookingServlet extends HttpServlet {

    // GET — load the booking form with rooms and instructors for dropdowns
    @Override
protected void doGet(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {

    // Guard: must be logged in
    if (!isLoggedIn(req)) {
        resp.sendRedirect("login.jsp");
        return;
    }

    String action = req.getParameter("action");

    if ("myBookings".equals(action)) {
        String instId = (String) req.getSession().getAttribute("instId");

        BookingDAO dao = new BookingDAO();
        req.setAttribute("bookings", dao.getBookingsByInstructor(instId));

        req.getRequestDispatcher("/bookings.jsp").forward(req, resp);
        return;
    }

    RoomDAO roomDAO = new RoomDAO();
    InstructorDAO instructorDAO = new InstructorDAO();

    req.setAttribute("rooms", roomDAO.getAllRooms());
    req.setAttribute("instructors", instructorDAO.getAll());

    req.getRequestDispatcher("/booking-form.jsp").forward(req, resp);
}

    // POST — process the booking form submission
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Guard: must be logged in
        if (!isLoggedIn(req)) {
            resp.sendRedirect("login.jsp");
            return;
        }

        // Read all form parameters
        String  courseId        = emptyToNull(req.getParameter("courseId"));
        String instId = (String) req.getSession().getAttribute("instId");
        String  building        = req.getParameter("building");
        String  roomNumber      = req.getParameter("roomNumber");
        String  timeSlotId      = req.getParameter("timeSlotId");
        int     semester        = Integer.parseInt(req.getParameter("semester"));
        int     year            = Integer.parseInt(req.getParameter("year"));
        String  bookingType     = req.getParameter("bookingType");
        String  bookingCategory = req.getParameter("bookingCategory");
        String  orgIdStr        = req.getParameter("organizerId");
        Integer organizerId     = (orgIdStr != null && !orgIdStr.isEmpty())
                                    ? Integer.parseInt(orgIdStr) : null;

        // Basic server-side validation
        if (instId == null || building == null || roomNumber == null
                || timeSlotId == null || bookingType == null || bookingCategory == null) {
            req.setAttribute("error", "All required fields must be filled.");
            doGet(req, resp);
            return;
        }

        BookingDAO dao = new BookingDAO();
        boolean success = dao.createBooking(
            courseId, instId, building, roomNumber,
            timeSlotId, semester, year,
            bookingType, bookingCategory, organizerId
        );

        if (success) {
            resp.sendRedirect("BookingServlet?action=myBookings");
        } else {
            // Room conflict or DB error — reload form with error
            req.setAttribute("error",
                "Booking failed. The room may already be booked at that time, " +
                "or a required field is missing.");
            doGet(req, resp);
        }
    }

    // Null if empty string — for optional fields like courseId
    private String emptyToNull(String val) {
        return (val == null || val.trim().isEmpty()) ? null : val.trim();
    }

    // Session guard — check instructor is logged in
    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session != null && session.getAttribute("instId") != null;
    }
}