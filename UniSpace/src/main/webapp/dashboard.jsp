<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - UniSpace</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

<nav class="navbar bg-light px-3">
    <span class="navbar-brand">UniSpace</span>
    <div>
        ${sessionScope.instId}
        <a href="LogoutServlet" class="btn btn-danger btn-sm">Logout</a>
    </div>
</nav>

<div class="container mt-4">

    <div class="row text-center mb-4">
        <div class="col"><div class="card p-3">Total<br>${totalBookings}</div></div>
        <div class="col"><div class="card p-3">Active<br>${activeBookings}</div></div>
        <div class="col"><div class="card p-3">Cancelled<br>${cancelledBookings}</div></div>
    </div>

    <div class="mb-3">
        <a href="BookingServlet" class="btn btn-success">New Booking</a>
        <a href="ScheduleServlet" class="btn btn-primary">My Schedule</a>
    </div>

    <table class="table">
        <thead><tr><th>ID</th><th>Course</th><th>Room</th></tr></thead>
        <tbody>
        <c:forEach var="b" items="${recentBookings}">
            <tr>
                <td>${b.bookingId}</td>
                <td>${b.courseId}</td>
                <td>${b.building}-${b.roomNumber}</td>
            </tr>
        </c:forEach>
        </tbody>
    </table>

</div>
</body>
</html>