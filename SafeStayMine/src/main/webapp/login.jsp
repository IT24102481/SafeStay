<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - SafeStay Hostel Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #4e73df;
            --secondary-color: #858796;
            --reg-red: #e74a3b; /* Variable එක මෙතන හරියට define කළා */
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }

        body {
            height: 100vh;
            width: 100%;
            background: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)),
            url('images/1737.jpg') no-repeat center center;
            background-size: cover;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .login-card {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.3);
            width: 100%;
            max-width: 400px;
            padding: 40px;
            text-align: center;
            animation: fadeIn 1s ease-in-out;
        }

        .login-card h2 { color: var(--primary-color); margin-bottom: 5px; font-weight: 700; font-size: 2rem; }
        .login-card p { color: #555; margin-bottom: 25px; font-size: 0.9rem; }

        .form-group { margin-bottom: 18px; text-align: left; }
        label { display: block; margin-bottom: 6px; font-weight: 600; font-size: 0.85rem; }

        input {
            width: 100%; padding: 12px; border: 1px solid #ddd;
            border-radius: 10px; outline: none; transition: 0.3s;
        }

        /* Login Button - Blue */
        .btn-login {
            background: linear-gradient(45deg, #4e73df, #224abe);
            color: white; border: none; padding: 14px; width: 100%;
            border-radius: 12px; font-size: 1rem; font-weight: bold;
            cursor: pointer; transition: 0.4s; margin-bottom: 15px;
            text-transform: uppercase;
        }

        .btn-login:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(78, 115, 223, 0.3); }

        /* Register Button - Beautiful Red */
        .btn-register {
            display: block;
            width: 100%;
            padding: 12px;
            text-decoration: none;
            color: var(--reg-red); /* var() භාවිතය නිවැරදි කළා */
            border: 2px solid var(--reg-red);
            border-radius: 12px;
            font-size: 0.95rem;
            font-weight: bold;
            transition: 0.3s;
            text-transform: uppercase;
        }

        .btn-register:hover {
            background: var(--reg-red);
            color: white;
            box-shadow: 0 5px 15px rgba(231, 74, 59, 0.3);
        }

        .divider {
            margin: 20px 0;
            display: flex;
            align-items: center;
            color: #999;
            font-size: 12px;
        }
        .divider::before, .divider::after { content: ""; flex: 1; height: 1px; background: #ddd; margin: 0 10px; }

        .error-msg {
            background-color: #fff3f3; color: #e74a3b; padding: 10px;
            border-radius: 10px; margin-bottom: 20px; font-size: 0.85rem; border: 1px solid #e74a3b;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>

<div class="login-card">
    <h2>SafeStay</h2>
    <p>Hostel Management System</p>

    <% if (request.getAttribute("errorMessage") != null) { %>
    <div class="error-msg"><%= request.getAttribute("errorMessage") %></div>
    <% } %>

    <form action="login" method="post">
        <div class="form-group">
            <label>User ID</label>
            <input type="text" name="userId" placeholder="Student/Staff ID" required>
        </div>
        <div class="form-group">
            <label>Password</label>
            <input type="password" name="password" placeholder="Password" required>
        </div>
        <button type="submit" class="btn-login">Login</button>
    </form>

    <div class="divider">OR</div>

    <a href="register.jsp" class="btn-register">Register Now</a>

    <div style="margin-top: 20px; font-size: 12px; color: #888;">
        Forgot password? <a href="#" style="color: var(--primary-color); text-decoration: none;">Contact Support</a>
    </div>
</div>

</body>
</html>