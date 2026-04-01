<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:if test="${empty sessionScope.instId}">
    <c:redirect url="${pageContext.request.contextPath}/LoginServlet"/>
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - UniSpace</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body style="background: #f0f2f5;">

<!-- ================= NAVBAR ================= -->
<nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm">
    <div class="container-fluid">

        <a class="navbar-brand fw-bold"
           href="${pageContext.request.contextPath}/DashboardServlet">
           UniSpace
        </a>

        <ul class="navbar-nav ms-auto">

            <li class="nav-item">
                <a class="nav-link fw-semibold active"
                   href="${pageContext.request.contextPath}/DashboardServlet">
                   Dashboard
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link"
                   href="${pageContext.request.contextPath}/ScheduleServlet">
                   Schedule
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link"
                   href="${pageContext.request.contextPath}/BookingServlet">
                   New Booking
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link"
                   href="${pageContext.request.contextPath}/BookingServlet?action=myBookings">
                   My Bookings
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link text-danger"
                   href="${pageContext.request.contextPath}/LogoutServlet">
                   Logout
                </a>
            </li>

        </ul>
    </div>
</nav>

<!-- ================= CONTENT ================= -->
<div class="container mt-4">

    <!-- Header -->
    <h3 class="fw-bold">Welcome, ${sessionScope.instName} 👋</h3>
    <p class="text-muted">Here’s your booking overview</p>

    <!-- Empty state -->
    <c:if test="${totalBookings == 0}">
        <div class="alert alert-info mt-3">
            No bookings yet. Start by creating one!
        </div>
    </c:if>

    <!-- Stats -->
    <div class="row text-center mt-4">

        <div class="col-lg-3 col-md-6 mb-3">
            <div class="p-3 bg-primary text-white rounded shadow">
                <h1>${totalBookings != null ? totalBookings : 0}</h1>
                <p>Total Bookings</p>
            </div>
        </div>

        <div class="col-lg-3 col-md-6 mb-3">
            <div class="p-3 bg-secondary text-white rounded shadow">
                <h1>${courseBookings != null ? courseBookings : 0}</h1>
                <p>Course Bookings</p>
            </div>
        </div>

        <div class="col-lg-3 col-md-6 mb-3">
            <div class="p-3 bg-success text-white rounded shadow">
                <h1>${eventBookings != null ? eventBookings : 0}</h1>
                <p>Event Bookings</p>
            </div>
        </div>

        <div class="col-lg-3 col-md-6 mb-3">
            <div class="p-3 bg-warning text-dark rounded shadow">
                <h1>${clubBookings != null ? clubBookings : 0}</h1>
                <p>Club Activities</p>
            </div>
        </div>

    </div>

    <!-- ================= QUICK ACTIONS ================= -->
    <div class="row mt-4">

        <!-- Create Booking -->
        <div class="col-md-6 mb-3">
            <div class="card text-center shadow-sm h-100">
                <div class="card-body d-flex flex-column justify-content-center">
                    <h5>Create New Booking</h5>
                    <p class="text-muted">Reserve a classroom for courses or events.</p>

                    <a href="${pageContext.request.contextPath}/BookingServlet"
                       class="btn btn-primary">
                        Book Now
                    </a>
                </div>
            </div>
        </div>

        <!-- My Bookings -->
        <div class="col-md-6 mb-3">
            <div class="card text-center shadow-sm h-100">
                <div class="card-body d-flex flex-column justify-content-center">
                    <h5>View My Bookings</h5>
                    <p class="text-muted">Manage your reservations.</p>

                    <a href="${pageContext.request.contextPath}/BookingServlet?action=myBookings"
                       class="btn btn-secondary">
                        My Bookings
                    </a>
                </div>
            </div>
        </div>

    </div>

</div>

</body>
</html>