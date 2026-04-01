<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:if test="${empty sessionScope.instId}">
    <c:redirect url="${pageContext.request.contextPath}/LoginServlet"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>New Booking</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body style="background:#f0f2f5;">

<nav class="navbar navbar-light bg-white shadow-sm mb-4">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/DashboardServlet">UniSpace</a>
        <div>
            <a href="${pageContext.request.contextPath}/BookingServlet?action=myBookings" class="btn btn-outline-secondary btn-sm me-2">My Bookings</a>
            <a href="${pageContext.request.contextPath}/LogoutServlet" class="btn btn-danger btn-sm">Logout</a>
        </div>
    </div>
</nav>

<div class="container" style="max-width:680px;">
<div class="card p-4 shadow-sm">

<h4 class="mb-4">New Booking</h4>

<c:if test="${not empty error}">
    <div class="alert alert-danger">${error}</div>
</c:if>

<form id="bookingForm" action="${pageContext.request.contextPath}/BookingServlet" method="post">

<!-- CATEGORY -->
<div class="mb-3">
    <label class="form-label fw-semibold">Booking Category</label>
    <select id="bookingCategory" name="bookingCategory" class="form-select" required>
        <option value="COURSE">COURSE</option>
        <option value="EVENT">EVENT</option>
        <option value="CLUB">CLUB</option>
    </select>
</div>

<!-- COURSE ID -->
<div class="mb-3" id="courseRow">
    <label class="form-label fw-semibold">Course ID <span class="text-muted fw-normal">(COURSE only)</span></label>
    <input id="courseId" type="text" name="courseId" class="form-control"
           placeholder="e.g. CSS1001, ECE1002, MAT1001">
    <div class="form-text">66 courses available — enter exact course_id</div>
</div>

<!-- ORGANIZER ID -->
<div class="mb-3" id="orgRow">
    <label class="form-label fw-semibold">Organizer <span class="text-muted fw-normal">(EVENT/CLUB only)</span></label>
    <select id="organizerId" name="organizerId" class="form-select">
        <option value="">Select Organizer</option>
        <optgroup label="ADMIN">
            <option value="1">1 — Academic Administration</option>
            <option value="2">2 — Examination Cell</option>
        </optgroup>
        <optgroup label="FACULTY">
            <option value="3">3 — Dr. Rajesh Kumar</option>
            <option value="4">4 — Dr. Priya Sharma</option>
            <option value="5">5 — Dr. Suresh Iyer</option>
            <option value="6">6 — Dr. Lakshmi Nair</option>
        </optgroup>
        <optgroup label="CLUB">
            <option value="7">7 — ACM Student Chapter</option>
            <option value="8">8 — CodeChef Campus Chapter</option>
            <option value="9">9 — Google Developer Student Club</option>
            <option value="10">10 — AI/ML Club</option>
            <option value="11">11 — Cybersecurity Club</option>
            <option value="12">12 — Competitive Programming Club</option>
            <option value="13">13 — Data Science Club</option>
            <option value="14">14 — Web Development Club</option>
            <option value="15">15 — IEEE Student Branch</option>
            <option value="16">16 — Robotics Club</option>
            <option value="17">17 — Electronics Club</option>
            <option value="18">18 — VLSI Design Club</option>
            <option value="19">19 — Wireless Communication Club</option>
            <option value="20">20 — Signal Processing Club</option>
        </optgroup>
    </select>
</div>

<!-- TIME SLOT — all slots from DB -->
<div class="mb-3">
    <label class="form-label fw-semibold">Time Slot</label>
    <select id="timeSlotId" name="timeSlotId" class="form-select" required>
        <option value="">Select Time Slot</option>
        <optgroup label="Monday">
            <option value="M1">Mon 08:00–08:50</option>
            <option value="M2">Mon 09:00–09:50</option>
            <option value="M3">Mon 10:00–10:50</option>
            <option value="M4">Mon 11:00–11:50</option>
            <option value="M5">Mon 13:00–13:50</option>
            <option value="M6">Mon 14:00–14:50</option>
            <option value="M7">Mon 15:00–15:50</option>
            <option value="M8">Mon 16:00–16:50</option>
        </optgroup>
        <optgroup label="Tuesday">
            <option value="T1">Tue 08:00–08:50</option>
            <option value="T2">Tue 09:00–09:50</option>
            <option value="T3">Tue 10:00–10:50</option>
            <option value="T4">Tue 11:00–11:50</option>
            <option value="T5">Tue 13:00–13:50</option>
            <option value="T6">Tue 14:00–14:50</option>
            <option value="T7">Tue 15:00–15:50</option>
            <option value="T8">Tue 16:00–16:50</option>
        </optgroup>
        <optgroup label="Wednesday">
            <option value="W1">Wed 08:00–08:50</option>
            <option value="W2">Wed 09:00–09:50</option>
            <option value="W3">Wed 10:00–10:50</option>
            <option value="W4">Wed 11:00–11:50</option>
            <option value="W5">Wed 13:00–13:50</option>
            <option value="W6">Wed 14:00–14:50</option>
            <option value="W7">Wed 15:00–15:50</option>
            <option value="W8">Wed 16:00–16:50</option>
        </optgroup>
        <optgroup label="Thursday">
            <option value="R1">Thu 08:00–08:50</option>
            <option value="R2">Thu 09:00–09:50</option>
            <option value="R3">Thu 10:00–10:50</option>
            <option value="R4">Thu 11:00–11:50</option>
            <option value="R5">Thu 13:00–13:50</option>
            <option value="R6">Thu 14:00–14:50</option>
            <option value="R7">Thu 15:00–15:50</option>
            <option value="R8">Thu 16:00–16:50</option>
        </optgroup>
        <optgroup label="Friday">
            <option value="F1">Fri 08:00–08:50</option>
            <option value="F2">Fri 09:00–09:50</option>
            <option value="F3">Fri 10:00–10:50</option>
            <option value="F4">Fri 11:00–11:50</option>
            <option value="F5">Fri 13:00–13:50</option>
            <option value="F6">Fri 14:00–14:50</option>
            <option value="F7">Fri 15:00–15:50</option>
        </optgroup>
        <optgroup label="Saturday">
            <option value="S1">Sat 08:00–08:50</option>
            <option value="S2">Sat 09:00–09:50</option>
            <option value="S3">Sat 10:00–10:50</option>
            <option value="S4">Sat 11:00–11:50</option>
        </optgroup>
    </select>
</div>

<!-- SEMESTER -->
<div class="mb-3">
    <label class="form-label fw-semibold">Semester</label>
    <select id="semester" name="semester" class="form-select" required>
        <option value="">Select Semester</option>
        <option value="1">1</option><option value="2">2</option>
        <option value="3">3</option><option value="4">4</option>
        <option value="5">5</option><option value="6">6</option>
        <option value="7">7</option><option value="8">8</option>
    </select>
</div>

<!-- YEAR -->
<div class="mb-3">
    <label class="form-label fw-semibold">Year</label>
    <select id="year" name="year" class="form-select" required>
        <option value="">Select Year</option>
        <option value="2025">2025</option>
        <option value="2026">2026</option>
    </select>
</div>

<!-- AVAILABLE ROOM (AJAX) -->
<div class="mb-3">
    <label class="form-label fw-semibold">Available Room</label>
    <select id="roomSelect" name="roomFull" class="form-select" required>
        <option value="">Select time slot, semester &amp; year first</option>
    </select>
    <div class="form-text" id="roomHint"></div>
</div>

<!-- BOOKING TYPE -->
<div class="mb-3">
    <label class="form-label fw-semibold">Booking Type</label>
    <select name="bookingType" class="form-select" required>
        <option value="SINGLE">SINGLE</option>
        <option value="PERIODIC">PERIODIC</option>
    </select>
</div>

<button id="submitBtn" type="submit" class="btn btn-success w-100 mt-2">
    Create Booking
</button>

</form>
</div>
</div>

<script>
(function () {
    const category   = document.getElementById("bookingCategory");
    const courseInp  = document.getElementById("courseId");
    const orgSel     = document.getElementById("organizerId");
    const courseRow  = document.getElementById("courseRow");
    const orgRow     = document.getElementById("orgRow");
    const roomSelect = document.getElementById("roomSelect");
    const roomHint   = document.getElementById("roomHint");
    const ctx        = "<%= request.getContextPath() %>";

    function toggleFields() {
        if (category.value === "COURSE") {
            courseInp.required = true;
            orgSel.required    = false;
            orgSel.value       = "";
            courseRow.style.display = "";
            orgRow.style.display    = "none";
        } else {
            courseInp.required = false;
            orgSel.required    = true;
            courseInp.value    = "";
            courseRow.style.display = "none";
            orgRow.style.display    = "";
        }
    }
    category.addEventListener("change", toggleFields);
    toggleFields();

    function fetchRooms() {
        const timeSlot = document.getElementById("timeSlotId").value;
        const semester = document.getElementById("semester").value;
        const year     = document.getElementById("year").value;

        if (!timeSlot || !semester || !year) {
            roomSelect.innerHTML = '<option value="">Select time slot, semester &amp; year first</option>';
            roomHint.textContent = "";
            return;
        }

        roomSelect.innerHTML = '<option value="">Loading rooms...</option>';
        roomHint.textContent = "";

        fetch(ctx + "/BookingServlet?action=availableRooms" +
              "&timeSlotId=" + encodeURIComponent(timeSlot) +
              "&semester="   + encodeURIComponent(semester) +
              "&year="       + encodeURIComponent(year))
            .then(function(res) {
                if (!res.ok) throw new Error("HTTP " + res.status);
                return res.json();
            })
            .then(function(data) {
                if (!data || data.length === 0) {
                    roomSelect.innerHTML = '<option value="">No rooms available for this slot</option>';
                    roomHint.textContent = "All rooms are booked for this time slot/semester/year.";
                    return;
                }
                roomSelect.innerHTML = '<option value="">Select Room</option>';
                data.forEach(function(room) {
                    const opt = document.createElement("option");
                    opt.value = room.building + "-" + room.roomNumber;
                    opt.text  = room.building + "-" + room.roomNumber + " (Capacity: " + room.capacity + ")";
                    roomSelect.appendChild(opt);
                });
                roomHint.textContent = data.length + " room(s) available.";
            })
            .catch(function(err) {
                console.error("Room fetch error:", err);
                roomSelect.innerHTML = '<option value="">Error loading rooms — check console</option>';
                roomHint.textContent = "Server error. Check Tomcat logs.";
            });
    }

    document.getElementById("timeSlotId").addEventListener("change", fetchRooms);
    document.getElementById("semester").addEventListener("change", fetchRooms);
    document.getElementById("year").addEventListener("change", fetchRooms);

    document.getElementById("bookingForm").addEventListener("submit", function(e) {
        if (!roomSelect.value) {
            e.preventDefault();
            alert("Please select a valid room before submitting.");
        }
    });
}());
</script>
</body>
</html>
