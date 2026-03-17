<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <title>Admin Settings - ParkingPro</title>
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      background: linear-gradient(rgba(0,0,0,0.8), rgba(0,0,0,0.8)), url('https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&q=80&w=2070');
      background-size: cover; background-attachment: fixed; color: white;
      display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0;
    }
    .settings-card {
      background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(15px);
      padding: 30px; border-radius: 20px; border: 1px solid rgba(255, 255, 255, 0.2);
      width: 400px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.5);
    }
    .form-group {
      text-align: left; margin-bottom: 20px;
    }
    label { font-size: 14px; color: #ff9f43; font-weight: bold; margin-left: 5px; }

    input[type="number"] {
      width: 100%; padding: 12px; margin-top: 8px; border-radius: 10px; border: none;
      font-size: 18px; text-align: center; background: rgba(255,255,255,0.9); box-sizing: border-box;
    }

    .update-btn {
      background: #ff9f43; color: black; border: none; padding: 15px;
      border-radius: 10px; cursor: pointer; font-weight: bold; width: 100%;
      transition: 0.3s; font-size: 16px; margin-top: 10px;
    }
    .update-btn:hover { background: #f39c12; transform: scale(1.02); }

    .back-link { display: block; margin-top: 25px; color: #2ecc71; text-decoration: none; font-size: 15px; font-weight: 500; }
    .back-link:hover { text-decoration: underline; }

    .msg { color: #2ecc71; margin-bottom: 15px; font-weight: bold; }
  </style>
</head>
<body>
<div class="settings-card">
  <h2 style="color: #ff9f43; margin-bottom: 5px;">⚙️ System Settings</h2>
  <p style="opacity: 0.8; font-size: 13px; margin-bottom: 25px;">Adjust parking capacity and pricing</p>

  <% if(request.getAttribute("msg") != null) { %>
  <div class="msg">${msg}</div>
  <% } %>

  <form action="/updateSettings" method="post">
    <div class="form-group">
      <label>Total Parking Slots</label>
      <input type="number" name="newLimit" value="${totalSlots}" min="1" max="500" required placeholder="e.g. 50">
    </div>

    <div class="form-group">
      <label>Rate Per Minute (LKR)</label>
      <input type="number" name="newRate" value="${currentRate}" min="1" max="1000" required placeholder="e.g. 2">
    </div>

    <button type="submit" class="update-btn">Save All Changes</button>
  </form>

  <a href="/dashboard" class="back-link">← Back to Dashboard</a>
</div>
</body>
</html>