package com.unispace.servlet;

import com.unispace.dao.BookingDAO;
import com.unispace.dao.RoomDAO;
import com.unispace.model.Room;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/BookingServlet")
public class BookingServlet extends HttpServlet {

    // =========================================================
    // ======================== GET =============================
    // =========================================================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        // =====================================================
        // 🔒 AUTH CHECK (MOVED TO TOP — FIXED)
        // =====================================================
        if (!isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // =====================================================
        // 🔵 AJAX: AVAILABLE ROOMS (SECURE + FIXED)
        // =====================================================
        if ("availableRooms".equals(action)) {

            String timeSlotId = req.getParameter("timeSlotId");
            String semesterStr = req.getParameter("semester");
            String yearStr = req.getParameter("year");

            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");

            if (timeSlotId == null || semesterStr == null || yearStr == null ||
                timeSlotId.isEmpty() || semesterStr.isEmpty() || yearStr.isEmpty()) {

                resp.getWriter().write("[]");
                return;
            }

            try {
                int semester = Integer.parseInt(semesterStr.trim());
                int year = Integer.parseInt(yearStr.trim());

                RoomDAO roomDAO = new RoomDAO();

                List<Room> available =
                        roomDAO.getAvailableRooms(timeSlotId, semester, year);

                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < available.size(); i++) {
                    Room r = available.get(i);

                    json.append("{")
                        .append("\"building\":\"").append(r.getBuilding()).append("\",")
                        .append("\"roomNumber\":\"").append(r.getRoomNumber()).append("\",")
                        .append("\"capacity\":").append(r.getCapacity())
                        .append("}");

                    if (i < available.size() - 1) json.append(",");
                }
                json.append("]");

                resp.getWriter().write(json.toString());

            } catch (Exception e) {
                e.printStackTrace();
                resp.getWriter().write("[]");
            }

            return;
        }

        // =====================================================
        // 📄 MY BOOKINGS
        // =====================================================
        if ("myBookings".equals(action)) {

            String instId = (String) req.getSession().getAttribute("instId");

            BookingDAO dao = new BookingDAO();
            req.setAttribute("bookings", dao.getBookingsByInstructor(instId));

            req.getRequestDispatcher("/bookings.jsp").forward(req, resp);
            return;
        }

        // =====================================================
        // 📝 DEFAULT → BOOKING FORM
        // =====================================================
        RoomDAO roomDAO = new RoomDAO();
        req.setAttribute("rooms", roomDAO.getAllRooms());

        req.getRequestDispatcher("/booking-form.jsp").forward(req, resp);
    }

    // =========================================================
    // ======================== POST ============================
    // =========================================================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String instId = (String) req.getSession().getAttribute("instId");

        try {
            String courseId        = emptyToNull(req.getParameter("courseId"));
            String timeSlotId      = safeTrim(req.getParameter("timeSlotId"));
            String bookingType     = safeTrim(req.getParameter("bookingType"));
            String bookingCategory = safeTrim(req.getParameter("bookingCategory"));
            String semesterStr     = req.getParameter("semester");
            String yearStr         = req.getParameter("year");

            // =====================================================
            // ✅ ROOM PARSING (ROBUST FIX)
            // =====================================================
            String building = safeTrim(req.getParameter("building"));
            String roomNumber = safeTrim(req.getParameter("roomNumber"));

            // fallback to roomFull if needed
            if ((building == null || roomNumber == null)) {
                String roomFull = req.getParameter("roomFull");

                if (roomFull != null && roomFull.contains("-")) {
                    int lastHyphen = roomFull.lastIndexOf("-");
                    building = roomFull.substring(0, lastHyphen);
                    roomNumber = roomFull.substring(lastHyphen + 1);
                }
            }

            // =====================================================
            // VALIDATION
            // =====================================================
            if (instId == null || building == null || roomNumber == null
                    || timeSlotId == null || timeSlotId.isEmpty()
                    || bookingType == null || bookingType.isEmpty()
                    || bookingCategory == null || bookingCategory.isEmpty()
                    || semesterStr == null || semesterStr.isEmpty()
                    || yearStr == null || yearStr.isEmpty()) {

                req.setAttribute("error", "All required fields must be filled.");
                doGet(req, resp);
                return;
            }

            int semester;
            int year;

            try {
                semester = Integer.parseInt(semesterStr.trim());
                year = Integer.parseInt(yearStr.trim());
            } catch (NumberFormatException e) {
                req.setAttribute("error", "Invalid semester/year.");
                doGet(req, resp);
                return;
            }

            String orgStr = req.getParameter("organizerId");
            Integer orgId = (orgStr != null && !orgStr.trim().isEmpty())
                    ? Integer.parseInt(orgStr.trim())
                    : null;

            // =====================================================
            // CATEGORY VALIDATION (MATCHES DB TRIGGER)
            // =====================================================
            if ("COURSE".equalsIgnoreCase(bookingCategory) && courseId == null) {
                req.setAttribute("error", "Course ID required for COURSE booking.");
                doGet(req, resp);
                return;
            }

            if (!"COURSE".equalsIgnoreCase(bookingCategory) && orgId == null) {
                req.setAttribute("error", "Organizer ID required for EVENT/CLUB.");
                doGet(req, resp);
                return;
            }

            // =====================================================
            // CREATE BOOKING
            // =====================================================
            BookingDAO dao = new BookingDAO();

            boolean ok = dao.createBooking(
                    courseId, instId,
                    building, roomNumber,
                    timeSlotId, semester, year,
                    bookingType, bookingCategory,
                    orgId
            );

            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/BookingServlet?action=myBookings");
            } else {
                req.setAttribute("error",
                        "Booking failed. Room unavailable or constraint violated.");
                doGet(req, resp);
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Unexpected error: " + e.getMessage());
            doGet(req, resp);
        }
    }

    // =========================================================
    // HELPERS
    // =========================================================
    private String emptyToNull(String v) {
        return (v == null || v.trim().isEmpty()) ? null : v.trim();
    }

    private String safeTrim(String v) {
        return v == null ? null : v.trim();
    }

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("instId") != null;
    }
}