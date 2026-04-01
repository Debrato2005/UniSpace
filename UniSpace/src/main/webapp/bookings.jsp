<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:if test="${empty sessionScope.instId}">
    <c:redirect url="${pageContext.request.contextPath}/LoginServlet"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>My Bookings</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body style="background:#f0f2f5;">

<!-- NAVBAR -->
<nav class="navbar navbar-light bg-white shadow-sm">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold"
           href="${pageContext.request.contextPath}/DashboardServlet">UniSpace</a>

        <div>
            <a href="${pageContext.request.contextPath}/BookingServlet"
               class="btn btn-primary btn-sm me-2">New Booking</a>

            <a href="${pageContext.request.contextPath}/LogoutServlet"
               class="btn btn-danger btn-sm">Logout</a>
        </div>
    </div>
</nav>

<div class="container mt-4">

<h4 class="mb-3">My Bookings</h4>

<!-- ERROR -->
<c:if test="${param.error == 'CancelFailed'}">
    <div class="alert alert-danger">Cancel failed.</div>
</c:if>

<!-- EMPTY STATE -->
<c:if test="${empty bookings}">
    <div class="alert alert-info">
        No bookings found. Create one!
    </div>
</c:if>

<!-- TABLE -->
<c:if test="${not empty bookings}">
<table class="table table-bordered table-hover bg-white shadow-sm">

    <thead class="table-dark">
        <tr>
            <th>ID</th>
            <th>Course/Event</th>
            <th>Room</th>
            <th>Day</th>
            <th>Time</th>
            <th>Semester</th>
            <th>Type</th>
            <th>Category</th>
            <th>Action</th>
        </tr>
    </thead>

    <tbody>
    <c:forEach var="b" items="${bookings}">
        <tr>
            <td>${b.bookingId}</td>
            <td>${b.courseTitle}</td>
            <td>${b.building}-${b.roomNumber}</td>
            <td>${b.day}</td>
            <td>${b.startTime} - ${b.endTime}</td>
            <td>${b.semester}</td>
            <td>${b.bookingType}</td>
            <td>${b.bookingCategory}</td>

            <!-- CANCEL -->
            <td>
                <form action="${pageContext.request.contextPath}/CancelBookingServlet"
                      method="post" style="display:inline;">

                    <input type="hidden" name="bookingId" value="${b.bookingId}"/>
                    <input type="hidden" name="type" value="full"/> <!-- ✅ FIX -->

                    <button class="btn btn-danger btn-sm"
                            onclick="return confirm('Cancel this booking?')">
                        Cancel
                    </button>
                </form>
            </td>

        </tr>
    </c:forEach>
    </tbody>

</table>
</c:if>

</div>

</body>
</html>