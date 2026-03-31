%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Classroom Schedule - UniSpace</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    
    <style>
        :root {
            --primary-color: #4f46e5;
            --secondary-color: #06b6d4;
            --success-color: #10b981;
            --danger-color: #ef4444;
            --warning-color: #f59e0b;
        }

        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .navbar {
            background: rgba(255, 255, 255, 0.95) !important;
            backdrop-filter: blur(10px);
            box-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
        }

        .navbar-brand {
            font-weight: 700;
            font-size: 1.5rem;
            color: var(--primary-color) !important;
        }

        .main-container {
            margin-top: 2rem;
            margin-bottom: 2rem;
        }

        .card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.15);
        }

        .card-header {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
            border-radius: 15px 15px 0 0 !important;
            padding: 1.5rem;
            font-weight: 600;
            font-size: 1.2rem;
        }

        .filter-section {
            background: white;
            padding: 2rem;
            border-radius: 15px;
            margin-bottom: 2rem;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.08);
        }

        .btn-primary {
            background: var(--primary-color);
            border: none;
            padding: 0.6rem 1.5rem;
            border-radius: 8px;
            transition: all 0.3s ease;
        }

        .btn-primary:hover {
            background: #4338ca;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(79, 70, 229, 0.3);
        }

        .schedule-table {
            background: white;
            border-radius: 10px;
            overflow: hidden;
        }

        .schedule-table thead {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }

        .schedule-table th {
            font-weight: 600;
            padding: 1rem;
            border: none;
        }

        .schedule-table td {
            padding: 1rem;
            vertical-align: middle;
            border-bottom: 1px solid #f1f5f9;
        }

        .schedule-table tbody tr:hover {
            background: #f8fafc;
            transition: background 0.3s ease;
        }

        .badge-course {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            padding: 0.4rem 0.8rem;
            border-radius: 6px;
        }

        .badge-event {
            background: linear-gradient(135deg, #f59e0b, #d97706);
            padding: 0.4rem 0.8rem;
            border-radius: 6px;
        }

        .badge-club {
            background: linear-gradient(135deg, #10b981, #059669);
            padding: 0.4rem 0.8rem;
            border-radius: 6px;
        }

        .badge-periodic {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
            padding: 0.3rem 0.6rem;
            border-radius: 5px;
            font-size: 0.75rem;
        }

        .badge-single {
            background: linear-gradient(135deg, #ec4899, #db2777);
            padding: 0.3rem 0.6rem;
            border-radius: 5px;
            font-size: 0.75rem;
        }

        .time-badge {
            background: #f1f5f9;
            color: #475569;
            padding: 0.3rem 0.7rem;
            border-radius: 5px;
            font-weight: 600;
            font-size: 0.85rem;
        }

        .room-info {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .room-icon {
            width: 35px;
            height: 35px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }

        .action-buttons .btn {
            margin: 0 0.2rem;
            padding: 0.4rem 0.8rem;
            border-radius: 6px;
            font-size: 0.85rem;
        }

        .btn-view {
            background: linear-gradient(135deg, #06b6d4, #0891b2);
            color: white;
            border: none;
        }

        .btn-cancel {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
            border: none;
        }

        .empty-state {
            text-align: center;
            padding: 3rem;
            color: #64748b;
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: 1rem;
            color: #cbd5e1;
        }

        .stats-card {
            background: white;
            padding: 1.5rem;
            border-radius: 12px;
            text-align: center;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
            transition: transform 0.3s ease;
        }

        .stats-card:hover {
            transform: translateY(-5px);
        }

        .stats-number {
            font-size: 2.5rem;
            font-weight: 700;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .stats-label {
            color: #64748b;
            font-size: 0.9rem;
            margin-top: 0.5rem;
        }

        .loading-spinner {
            display: none;
            text-align: center;
            padding: 2rem;
        }

        @media (max-width: 768px) {
            .schedule-table {
                font-size: 0.85rem;
            }
            
            .action-buttons .btn {
                padding: 0.3rem 0.6rem;
                font-size: 0.75rem;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-light">
        <div class="container-fluid">
            <a class="navbar-brand" href="index.jsp">
                <i class="bi bi-calendar-check"></i> UniSpace
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="schedule.jsp">
                            <i class="bi bi-calendar3"></i> Schedule
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="BookingServlet?action=new">
                            <i class="bi bi-plus-circle"></i> New Booking
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="BookingServlet?action=myBookings">
                            <i class="bi bi-list-check"></i> My Bookings
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-danger" href="LogoutServlet">
                            <i class="bi bi-box-arrow-right"></i> Logout
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container main-container">
        <!-- Stats Cards -->
        <div class="row mb-4">
            <div class="col-md-3 col-6 mb-3">
                <div class="stats-card">
                    <div class="stats-number">${totalBookings != null ? totalBookings : 0}</div>
                    <div class="stats-label">Total Bookings</div>
                </div>
            </div>
            <div class="col-md-3 col-6 mb-3">
                <div class="stats-card">
                    <div class="stats-number">${courseBookings != null ? courseBookings : 0}</div>
                    <div class="stats-label">Course Bookings</div>
                </div>
            </div>
            <div class="col-md-3 col-6 mb-3">
                <div class="stats-card">
                    <div class="stats-number">${eventBookings != null ? eventBookings : 0}</div>
                    <div class="stats-label">Events</div>
                </div>
            </div>
            <div class="col-md-3 col-6 mb-3">
                <div class="stats-card">
                    <div class="stats-number">${clubBookings != null ? clubBookings : 0}</div>
                    <div class="stats-label">Club Activities</div>
                </div>
            </div>
        </div>

        <!-- Filters -->
        <div class="filter-section">
            <h5 class="mb-3"><i class="bi bi-funnel"></i> Filter Schedule</h5>
            <form action="ScheduleServlet" method="GET" class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Semester</label>
                    <select name="semester" class="form-select">
                        <option value="">All Semesters</option>
                        <option value="1" ${param.semester == '1' ? 'selected' : ''}>Semester 1</option>
                        <option value="2" ${param.semester == '2' ? 'selected' : ''}>Semester 2</option>
                        <option value="3" ${param.semester == '3' ? 'selected' : ''}>Semester 3</option>
                        <option value="4" ${param.semester == '4' ? 'selected' : ''}>Semester 4</option>
                        <option value="5" ${param.semester == '5' ? 'selected' : ''}>Semester 5</option>
                        <option value="6" ${param.semester == '6' ? 'selected' : ''}>Semester 6</option>
                        <option value="7" ${param.semester == '7' ? 'selected' : ''}>Semester 7</option>
                        <option value="8" ${param.semester == '8' ? 'selected' : ''}>Semester 8</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Year</label>
                    <select name="year" class="form-select">
                        <option value="">All Years</option>
                        <option value="2025" ${param.year == '2025' ? 'selected' : ''}>2025</option>
                        <option value="2026" ${param.year == '2026' ? 'selected' : ''}>2026</option>
                        <option value="2027" ${param.year == '2027' ? 'selected' : ''}>2027</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Day</label>
                    <select name="day" class="form-select">
                        <option value="">All Days</option>
                        <option value="M" ${param.day == 'M' ? 'selected' : ''}>Monday</option>
                        <option value="T" ${param.day == 'T' ? 'selected' : ''}>Tuesday</option>
                        <option value="W" ${param.day == 'W' ? 'selected' : ''}>Wednesday</option>
                        <option value="R" ${param.day == 'R' ? 'selected' : ''}>Thursday</option>
                        <option value="F" ${param.day == 'F' ? 'selected' : ''}>Friday</option>
                        <option value="S" ${param.day == 'S' ? 'selected' : ''}>Saturday</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Category</label>
                    <select name="category" class="form-select">
                        <option value="">All Categories</option>
                        <option value="COURSE" ${param.category == 'COURSE' ? 'selected' : ''}>Course</option>
                        <option value="EVENT" ${param.category == 'EVENT' ? 'selected' : ''}>Event</option>
                        <option value="CLUB" ${param.category == 'CLUB' ? 'selected' : ''}>Club</option>
                    </select>
                </div>
                <div class="col-12">
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-search"></i> Apply Filters
                    </button>
                    <a href="schedule.jsp" class="btn btn-outline-secondary">
                        <i class="bi bi-x-circle"></i> Clear
                    </a>
                </div>
            </form>
        </div>

        <!-- Schedule Table -->
        <div class="card">
            <div class="card-header">
                <i class="bi bi-calendar-week"></i> Classroom Schedule
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${not empty bookings}">
                        <div class="table-responsive">
                            <table class="table schedule-table mb-0">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Course/Event</th>
                                        <th>Instructor</th>
                                        <th>Room</th>
                                        <th>Day & Time</th>
                                        <th>Semester/Year</th>
                                        <th>Type</th>
                                        <th>Category</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="booking" items="${bookings}">
                                        <tr>
                                            <td><strong>#${booking.bookingId}</strong></td>
                                            <td>
                                                <strong>${booking.courseTitle}</strong>
                                            </td>
                                            <td>
                                                <i class="bi bi-person-circle"></i>
                                                ${booking.instructorName}
                                            </td>
                                            <td>
                                                <div class="room-info">
                                                    <div class="room-icon">
                                                        <i class="bi bi-door-closed"></i>
                                                    </div>
                                                    <div>
                                                        <strong>${booking.room}</strong><br>
                                                        <small class="text-muted">Cap: ${booking.capacity}</small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <span class="badge bg-secondary">
                                                    ${booking.day == 'M' ? 'Mon' :
                                                      booking.day == 'T' ? 'Tue' :
                                                      booking.day == 'W' ? 'Wed' :
                                                      booking.day == 'R' ? 'Thu' :
                                                      booking.day == 'F' ? 'Fri' :
                                                      booking.day == 'S' ? 'Sat' : 'Sun'}
                                                </span>
                                                <br>
                                                <span class="time-badge">
                                                    <fmt:formatDate value="${booking.startTime}" pattern="HH:mm"/> -
                                                    <fmt:formatDate value="${booking.endTime}" pattern="HH:mm"/>
                                                </span>
                                            </td>
                                            <td>
                                                <strong>Sem ${booking.semester}</strong><br>
                                                <small class="text-muted">${booking.year}</small>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${booking.bookingType == 'PERIODIC'}">
                                                        <span class="badge badge-periodic">
                                                            <i class="bi bi-arrow-repeat"></i> Periodic
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-single">
                                                            <i class="bi bi-calendar-event"></i> Single
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${booking.bookingCategory == 'COURSE'}">
                                                        <span class="badge badge-course">
                                                            <i class="bi bi-book"></i> Course
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${booking.bookingCategory == 'EVENT'}">
                                                        <span class="badge badge-event">
                                                            <i class="bi bi-calendar-event"></i> Event
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-club">
                                                            <i class="bi bi-people"></i> Club
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="action-buttons">
                                                    <button class="btn btn-view btn-sm" 
                                                            onclick="viewDetails(${booking.bookingId})">
                                                        <i class="bi bi-eye"></i> View
                                                    </button>
                                                    <c:if test="${sessionScope.userRole == 'ADMIN' || sessionScope.userId == booking.instId}">
                                                        <button class="btn btn-cancel btn-sm" 
                                                                onclick="cancelBooking(${booking.bookingId})">
                                                            <i class="bi bi-x-circle"></i> Cancel
                                                        </button>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state">
                            <i class="bi bi-calendar-x"></i>
                            <h4>No Bookings Found</h4>
                            <p>There are no bookings matching your criteria.</p>
                            <a href="BookingServlet?action=new" class="btn btn-primary mt-3">
                                <i class="bi bi-plus-circle"></i> Create New Booking
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Loading Spinner -->
        <div class="loading-spinner" id="loadingSpinner">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        function viewDetails(bookingId) {
            window.location.href = 'BookingServlet?action=view&id=' + bookingId;
        }

        function cancelBooking(bookingId) {
            if (confirm('Are you sure you want to cancel this booking?')) {
                document.getElementById('loadingSpinner').style.display = 'block';
                window.location.href = 'CancelBookingServlet?bookingId=' + bookingId;
            }
        }

        // Show loading spinner on form submit
        document.querySelector('form').addEventListener('submit', function() {
            document.getElementById('loadingSpinner').style.display = 'block';
        });

        // Display alert messages if present
        <c:if test="${not empty successMessage}">
            alert('Success: ${successMessage}');
        </c:if>

        <c:if test="${not empty errorMessage}">
            alert('Error: ${errorMessage}');
        </c:if>
    </script>
</body>
</html>