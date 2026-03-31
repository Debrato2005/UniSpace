<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<head>
<title>New Booking</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

<div class="container mt-4">

<h3>Create Booking</h3>

<form action="BookingServlet" method="POST">

<select name="bookingCategory" class="form-control mb-2">
    <option value="COURSE">Course</option>
    <option value="EVENT">Event</option>
    <option value="CLUB">Club</option>
</select>

<input name="courseId" class="form-control mb-2" placeholder="Course ID (optional)">

<select name="building" class="form-control mb-2">
    <c:forEach var="r" items="${rooms}">
        <option value="${r.building}">${r.building}</option>
    </c:forEach>
</select>

<input name="roomNumber" class="form-control mb-2" placeholder="Room Number">

<input name="timeSlotId" class="form-control mb-2" placeholder="Time Slot ID">

<input name="semester" type="number" class="form-control mb-2">
<input name="year" type="number" class="form-control mb-2">

<select name="bookingType" class="form-control mb-2">
    <option value="SINGLE">Single</option>
    <option value="PERIODIC">Periodic</option>
</select>

<input name="organizerId" class="form-control mb-2" placeholder="Organizer ID">

<button class="btn btn-primary">Create</button>

</form>

<c:if test="${not empty error}">
<p class="text-danger">${error}</p>
</c:if>

</div>
</body>
</html>