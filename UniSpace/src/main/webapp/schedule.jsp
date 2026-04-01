<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:if test="${empty sessionScope.instId}">
    <c:redirect url="${pageContext.request.contextPath}/LoginServlet"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>Schedule</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body>

<nav class="navbar navbar-light bg-light">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/DashboardServlet">UniSpace</a>
        <a href="${pageContext.request.contextPath}/LogoutServlet" class="btn btn-danger btn-sm">Logout</a>
    </div>
</nav>

<div class="container mt-4">

<h4>Schedule</h4>

<!-- FILTER -->
<form action="${pageContext.request.contextPath}/ScheduleServlet" method="get" class="row g-2 mb-3">

<select name="semester" class="form-select col-md-2">
<option value="">All Sem</option>
<option value="1" ${param.semester=='1' ? 'selected' : ''}>1</option>
<option value="2" ${param.semester=='2' ? 'selected' : ''}>2</option>
<option value="3" ${param.semester=='3' ? 'selected' : ''}>3</option>
<option value="4" ${param.semester=='4' ? 'selected' : ''}>4</option>
<option value="5" ${param.semester=='5' ? 'selected' : ''}>5</option>
</select>

<select name="year" class="form-select col-md-2">
<option value="">All Year</option>
<option value="2025" ${param.year=='2025' ? 'selected' : ''}>2025</option>
</select>

<select name="day" class="form-select col-md-2">
<option value="">All Days</option>
<option value="M" ${param.day=='M' ? 'selected' : ''}>Mon</option>
<option value="T" ${param.day=='T' ? 'selected' : ''}>Tue</option>
<option value="W" ${param.day=='W' ? 'selected' : ''}>Wed</option>
<option value="R" ${param.day=='R' ? 'selected' : ''}>Thu</option>
<option value="F" ${param.day=='F' ? 'selected' : ''}>Fri</option>
<option value="S" ${param.day=='S' ? 'selected' : ''}>Sat</option>
</select>

<select name="category" class="form-select col-md-2">
<option value="">All Categories</option>
<option value="COURSE" ${param.category=='COURSE' ? 'selected' : ''}>Course</option>
<option value="EVENT" ${param.category=='EVENT' ? 'selected' : ''}>Event</option>
<option value="CLUB" ${param.category=='CLUB' ? 'selected' : ''}>Club</option>
</select>

<button class="btn btn-primary col-md-2">Filter</button>

</form>

<!-- TABLE -->
<c:if test="${empty bookings}">
    <div class="alert alert-info">No schedule found</div>
</c:if>

<c:if test="${not empty bookings}">
<table class="table table-striped table-bordered">

<thead>
<tr>
<th>ID</th>
<th>Title</th>
<th>Instructor</th>
<th>Room</th>
<th>Day</th>
<th>Time</th>
<th>Sem/Year</th>
<th>Type</th>
<th>Category</th>
</tr>
</thead>

<tbody>
<c:forEach var="b" items="${bookings}">
<tr>

<td>#${b.bookingId}</td>

<td>${empty b.courseTitle ? 'Event/Club' : b.courseTitle}</td>

<td>${empty b.instructorName ? '-' : b.instructorName}</td>

<td>${b.room}</td>

<td>
<c:choose>
    <c:when test="${b.day == 'M'}">Mon</c:when>
    <c:when test="${b.day == 'T'}">Tue</c:when>
    <c:when test="${b.day == 'W'}">Wed</c:when>
    <c:when test="${b.day == 'R'}">Thu</c:when>
    <c:when test="${b.day == 'F'}">Fri</c:when>
    <c:when test="${b.day == 'S'}">Sat</c:when>
    <c:otherwise>${b.day}</c:otherwise>
</c:choose>
</td>

<td>
<c:if test="${b.startTime != null}">
    ${b.startTime} - ${b.endTime}
</c:if>
<c:if test="${b.startTime == null}">
    ${b.timeSlotId}
</c:if>
</td>

<td>${b.semester}/${b.year}</td>

<td>${b.bookingType}</td>
<td>${b.bookingCategory}</td>

</tr>
</c:forEach>
</tbody>

</table>
</c:if>

</div>

</body>
</html>