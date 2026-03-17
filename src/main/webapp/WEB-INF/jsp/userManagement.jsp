<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.parking.system.UserEntity" %> <%-- මේක අනිවාර්යයෙන්ම දාන්න --%>
<!DOCTYPE html>
<html>
<head>
    <title>User Management - ParkingPro</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0; padding: 0;
            background: linear-gradient(rgba(0, 0, 0, 0.8), rgba(0, 0, 0, 0.8)),
            url('https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&q=80&w=2070');
            background-size: cover; background-attachment: fixed; color: white;
            display: flex; flex-direction: column; align-items: center;
        }
        .navbar {
            width: 100%;
            padding: 15px 50px;
            background: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(10px);
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-sizing: border-box;
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        .nav-links { display: flex; gap: 20px; }
        .nav-links a { color: white; text-decoration: none; padding: 8px 15px; border-radius: 5px; transition: 0.3s; }
        .nav-links a:hover { background: rgba(255,255,255,0.1); }
        .active { background: rgba(255, 255, 255, 0.2); border-bottom: 2px solid #ff9f43; }

        .logout-btn { background: #ff4757; color: white; padding: 8px 20px; border-radius: 5px; text-decoration: none; font-weight: bold; }
        .container { width: 90%; max-width: 1000px; margin-top: 50px; margin-bottom: 50px; }

        .admin-card {
            background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(15px); padding: 30px;
            border-radius: 15px; border: 1px solid rgba(255, 159, 67, 0.4);
        }
        input[type="text"], select {
            width: 100%; padding: 12px; margin: 8px 0; border-radius: 8px; border: none;
            background: white; color: black; box-sizing: border-box;
        }
        .save-btn { background: #2ecc71; color: white; border: none; padding: 12px 25px; border-radius: 8px; cursor: pointer; font-weight: bold; width: 100%; }

        table { width: 100%; border-collapse: collapse; margin-top: 25px; }
        th, td { text-align: left; padding: 15px; border-bottom: 1px solid rgba(255,255,255,0.1); }
        th { background: rgba(255,159,67,0.2); color: #ff9f43; }
    </style>
</head>
<body>

<%
    String role = (String) session.getAttribute("userRole");
    String userName = (String) session.getAttribute("userName");
%>

<div class="navbar">
    <h2 style="margin:0; font-size: 22px;">🅿️ ParkingPro</h2>

    <div class="nav-links">
        <a href="/dashboard">🏠 Dashboard</a>
        <% if (role != null && role.equals("ADMIN")) { %>
        <a href="/userManagement" class="active">👥 User Management</a>
        <a href="/history">📜 History Logs</a>
        <a href="/adminSettings">⚙️ Admin Settings</a>
        <% } %>
    </div>

    <div style="display: flex; align-items: center; gap: 20px;">
        <span style="font-size: 13px; opacity: 0.8;">Welcome, <b><%= userName %></b></span>
        <a href="/logout" class="logout-btn">Logout</a>
    </div>
</div>

<div class="container">
    <div class="admin-card">
        <h3 style="margin-top:0; color: #ff9f43;">🛡️ User Account Management</h3>
        <p style="font-size: 13px; opacity: 0.7;">Administrator: <%= userName %></p>
        <hr style="border: 0.5px solid rgba(255,159,67,0.2); margin: 20px 0;">

        <h4 style="color: #2ecc71;">+ Create New Account</h4>
        <form action="/addUser" method="post" style="display: flex; gap: 15px; align-items: flex-end; flex-wrap: wrap;">
            <div style="flex: 1; min-width: 180px;">
                <label style="font-size: 12px;">Username</label>
                <input type="text" name="newUsername" placeholder="Username" required>
            </div>
            <div style="flex: 1; min-width: 180px;">
                <label style="font-size: 12px;">Password</label>
                <input type="text" name="newPassword" placeholder="Password" required>
            </div>
            <div style="width: 120px;">
                <label style="font-size: 12px;">Role</label>
                <select name="role">
                    <option value="STAFF">STAFF</option>
                    <option value="ADMIN">ADMIN</option>
                </select>
            </div>
            <button type="submit" class="save-btn" style="width: auto; margin-bottom: 8px;">Create</button>
        </form>

        <div style="margin-top: 40px;">
            <h4 style="color: #ff9f43;">System Users</h4>
            <table>
                <thead>
                <tr>
                    <th>Username</th>
                    <th>Password</th>
                    <th>Role</th>
                    <th>Action</th>
                </tr>
                </thead>
                <tbody>
                <%
                    // මෙතන තමයි වැදගත්ම වෙනස - දැන් අපි ගන්නේ UserEntity List එකක්
                    List<UserEntity> allUsers = (List<UserEntity>) request.getAttribute("allUsers");
                    if (allUsers != null) {
                        for (UserEntity u : allUsers) {
                %>
                <tr>
                    <td><%= u.getUsername() %></td>
                    <td style="font-family: monospace; color: #f1c40f;"><%= u.getPassword() %></td>
                    <td>
                        <span style="background: rgba(255,255,255,0.1); padding: 3px 10px; border-radius: 10px; font-size: 11px;">
                            <%= u.getRole() %>
                        </span>
                    </td>
                    <td>
                        <% if (!u.getUsername().equals(userName)) { %>
                        <a href="/deleteUser?username=<%= u.getUsername() %>"
                           style="color: #ff4757; text-decoration: none; font-weight: bold;"
                           onclick="return confirm('Delete user <%= u.getUsername() %>?')">❌ Remove</a>
                        <% } else { %>
                        <span style="opacity: 0.5;">(You)</span>
                        <% } %>
                    </td>
                </tr>
                <% } } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

</body>
</html>