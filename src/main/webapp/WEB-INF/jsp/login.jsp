<!DOCTYPE html>
<html>
<head>
    <title>Vehicle Parking System - Login</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background: linear-gradient(rgba(0, 0, 0, 0.6), rgba(0, 0, 0, 0.6)),
            url('https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&q=80&w=2070');
            background-size: cover;
            background-position: center;
        }

        .login-container {
            background: rgba(255, 255, 255, 0.15); /* Glass effect */
            backdrop-filter: blur(10px);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
            border: 1px solid rgba(255, 255, 255, 0.18);
            width: 350px;
            text-align: center;
            color: white;
        }

        h2 { margin-bottom: 30px; font-weight: 300; letter-spacing: 2px; }

        .input-group { margin-bottom: 20px; text-align: left; }

        .input-group label { display: block; margin-bottom: 5px; font-size: 14px; }

        .input-group input {
            width: 100%;
            padding: 12px;
            border-radius: 5px;
            border: none;
            outline: none;
            background: rgba(255, 255, 255, 0.9);
            box-sizing: border-box; /* padding නිසා width එක වෙනස් වීම වළක්වයි */
        }

        .login-btn {
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 5px;
            background-color: #4CAF50;
            color: white;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.3s;
            margin-top: 10px;
        }

        .login-btn:hover { background-color: #45a049; transform: scale(1.02); }

        .error-msg {
            color: #ff6b6b;
            background: rgba(0, 0, 0, 0.2);
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
            font-size: 14px;
        }
    </style>
</head>
<body>

<div class="login-container">
    <h2> ParkingPro</h2>

    <% if (request.getAttribute("error") != null) { %>
    <div class="error-msg">
        <%= request.getAttribute("error") %>
    </div>
    <% } %>

    <form action="/login" method="post">
        <div class="input-group">
            <label>Username</label>
            <input type="text" name="username" placeholder="Enter your username" required>
        </div>

        <div class="input-group">
            <label>Password</label>
            <input type="password" name="password" placeholder="Enter your password" required>
        </div>

        <button type="submit" class="login-btn">LOGIN</button>
    </form>

    <p style="margin-top: 20px; font-size: 12px; opacity: 0.7;">
        &copy; 2026 Vehicle Parking System
    </p>
</div>

</body>
</html>