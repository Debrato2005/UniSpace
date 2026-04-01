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

<body>

<div class="container mt-4">
<div class="card p-4 shadow-sm">

<h4 class="mb-3">New Booking</h4>

<c:if test="${not empty error}">
    <div class="alert alert-danger">${error}</div>
</c:if>

<form id="bookingForm"
      action="${pageContext.request.contextPath}/BookingServlet"
      method="post">

<!-- CATEGORY -->
<select id="bookingCategory" name="bookingCategory" class="form-select mb-3">
    <option value="COURSE">COURSE</option>
    <option value="EVENT">EVENT</option>
    <option value="CLUB">CLUB</option>
</select>

<!-- COURSE -->
<input id="courseId" type="text" name="courseId"
       class="form-control mb-3"
       placeholder="Course ID (for COURSE only)">

<!-- ORGANIZER -->
<input id="organizerId" type="number" name="organizerId"
       class="form-control mb-3"
       placeholder="Organizer ID (for EVENT/CLUB only)">

<!-- TIME SLOT -->
<select id="timeSlotId" name="timeSlotId" class="form-select mb-3" required>
    <option value="">Select Time Slot</option>
    <option value="M1">Mon 08:00-08:50</option>
    <option value="M2">Mon 09:00-09:50</option>
    <option value="M3">Mon 10:00-10:50</option>
</select>

<!-- SEM -->
<select id="semester" name="semester" class="form-select mb-3" required>
    <option value="">Semester</option>
    <option value="1">1</option>
    <option value="2">2</option>
    <option value="3">3</option>
</select>

<!-- YEAR -->
<select id="year" name="year" class="form-select mb-3" required>
    <option value="">Year</option>
    <option value="2025">2025</option>
</select>

<!-- ROOM -->
<select id="roomSelect" name="roomFull" class="form-select mb-3" required>
    <option value="">Select time slot first</option>
</select>

<!-- TYPE -->
<select name="bookingType" class="form-select mb-3">
    <option value="SINGLE">SINGLE</option>
    <option value="PERIODIC">PERIODIC</option>
</select>

<button id="submitBtn" type="submit" class="btn btn-success w-100">
    Create Booking
</button>

</form>

</div>
</div>

<!-- ================= JS ================= -->
<script>
document.addEventListener("DOMContentLoaded", function () {

    const category = document.getElementById("bookingCategory");
    const course = document.getElementById("courseId");
    const organizer = document.getElementById("organizerId");
    const submitBtn = document.getElementById("submitBtn");

    // ================= CATEGORY VALIDATION =================
    function toggleFields() {
        if (category.value === "COURSE") {
            course.required = true;
            organizer.required = false;
            organizer.value = "";
        } else {
            course.required = false;
            organizer.required = true;
            course.value = "";
        }
    }

    category.addEventListener("change", toggleFields);
    toggleFields();

    // ================= ROOM FETCH =================
    function fetchRooms() {
        const timeSlot = document.getElementById("timeSlotId").value;
        const semester = document.getElementById("semester").value;
        const year = document.getElementById("year").value;

        const roomSelect = document.getElementById("roomSelect");

        if (!timeSlot || !semester || !year) {
            roomSelect.innerHTML = '<option>Select time slot, semester & year</option>';
            return;
        }

        roomSelect.innerHTML = '<option>Loading...</option>';

        fetch(`BookingServlet?action=availableRooms&timeSlotId=${timeSlot}&semester=${semester}&year=${year}`)
            .then(res => res.json())
            .then(data => {

                if (data.length === 0) {
                    roomSelect.innerHTML = '<option>No rooms available</option>';
                    return;
                }

                roomSelect.innerHTML = '<option value="">Select Room</option>';

                data.forEach(room => {
                    const opt = document.createElement("option");
                    opt.value = room.building + "-" + room.roomNumber;
                    opt.text = `${room.building}-${room.roomNumber} (Cap: ${room.capacity})`;
                    roomSelect.appendChild(opt);
                });
            })
            .catch(err => {
                console.error(err);
                roomSelect.innerHTML = '<option>Error loading rooms</option>';
            });
    }

    document.getElementById("timeSlotId").addEventListener("change", fetchRooms);
    document.getElementById("semester").addEventListener("change", fetchRooms);
    document.getElementById("year").addEventListener("change", fetchRooms);

    // ================= FINAL FORM VALIDATION =================
    document.getElementById("bookingForm").addEventListener("submit", function (e) {

        const room = document.getElementById("roomSelect").value;

        if (!room) {
            e.preventDefault();
            alert("Please select a valid room.");
        }
    });

});
</script>

</body>
</html>