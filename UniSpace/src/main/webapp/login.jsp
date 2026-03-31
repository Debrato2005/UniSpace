<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login - UniSpace</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body style="background: linear-gradient(135deg,#667eea,#764ba2); height:100vh; display:flex; align-items:center; justify-content:center;">

<div class="card p-4" style="width:350px;">
    <h3 class="text-center mb-3">UniSpace</h3>

    <form action="LoginServlet" method="POST">
        <input type="text" name="instId" class="form-control mb-3" placeholder="Instructor ID" required>

        <button class="btn btn-primary w-100">Login</button>
    </form>

    <c:if test="${not empty error}">
        <p class="text-danger mt-2 text-center">${error}</p>
    </c:if>
</div>

</body>
</html>