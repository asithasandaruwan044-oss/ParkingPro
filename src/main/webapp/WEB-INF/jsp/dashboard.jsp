<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.parking.system.VehicleEntity" %>

<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - Vehicle Parking System</title>
    <style>
        /* ඔයාගේ පරණ CSS ඔක්කොම මෙතන තියෙනවා කියලා හිතන්න */
        select {
            width: 100%; padding: 12px; margin-bottom: 18px; border-radius: 8px; border: none;
            background: rgba(255, 255, 255, 0.9); font-size: 14px; color: black;
        }
        .filtered-out { display: none !important; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0; padding: 0;
            background: linear-gradient(rgba(0, 0, 0, 0.7), rgba(0, 0, 0, 0.7)),
            url('https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&q=80&w=2070');
            background-size: cover; background-attachment: fixed; background-position: center;
            color: white; display: flex; flex-direction: column; align-items: center;
        }

        .navbar {
            width: 100%; padding: 15px 50px; background: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(10px); display: flex; justify-content: space-between;
            align-items: center; box-sizing: border-box; position: sticky; top: 0; z-index: 1000;
        }

        .nav-links { display: flex; gap: 15px; align-items: center; }
        .nav-links a {
            color: white; text-decoration: none; font-weight: 500; font-size: 14px;
            padding: 10px 18px; border-radius: 8px; transition: 0.3s; display: flex; align-items: center; gap: 8px;
        }
        .nav-links a:hover { background: rgba(255, 255, 255, 0.15); }
        .nav-links a.active { background: #ff9f43; color: black; font-weight: bold; }

        .logout-btn { background: #ff4757; color: white; padding: 10px 20px; border-radius: 8px; text-decoration: none; font-weight: bold; font-size: 14px; transition: 0.3s; }
        .logout-btn:hover { background: #ff6b81; transform: scale(1.05); }

        .container { width: 95%; max-width: 1200px; margin-top: 30px; padding: 20px; }
        .status-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }

        .card { background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(10px); padding: 20px; border-radius: 15px; border: 1px solid rgba(255, 255, 255, 0.2); text-align: center; transition: 0.3s; }
        .card:hover { transform: translateY(-5px); background: rgba(255, 255, 255, 0.2); border-color: #ff9f43; }
        .card h3 { margin: 0; font-size: 13px; opacity: 0.8; text-transform: uppercase; letter-spacing: 1px; }
        .card p { margin: 10px 0 0; font-size: 32px; font-weight: bold; }

        .main-content { display: flex; gap: 30px; flex-wrap: wrap; }
        .glass-box { background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(10px); padding: 25px; border-radius: 15px; border: 1px solid rgba(255, 255, 255, 0.2); height: fit-content; }
        .form-section { flex: 1; min-width: 320px; }
        .table-section { flex: 2; min-width: 500px; }

        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th { background: rgba(255, 255, 255, 0.15); padding: 12px; text-align: left; font-size: 14px; }
        td { padding: 12px; border-bottom: 1px solid rgba(255, 255, 255, 0.1); font-size: 14px; }

        input[type="text"], input[type="file"] { width: 100%; padding: 12px; margin: 8px 0 18px 0; border-radius: 8px; border: none; background: rgba(255, 255, 255, 0.9); box-sizing: border-box; font-size: 14px; color: black; }
        label { font-size: 13px; font-weight: bold; color: rgba(255, 255, 255, 0.9); }

        .save-btn { width: 100%; padding: 14px; border: none; border-radius: 8px; background: #2ecc71; color: white; font-weight: bold; cursor: pointer; font-size: 15px; transition: 0.3s; }
        .save-btn:hover { background: #27ae60; box-shadow: 0 5px 15px rgba(46, 204, 113, 0.3); }

        .delete-link { background: rgba(255, 71, 87, 0.2); color: #ff4757; padding: 5px 12px; border-radius: 5px; text-decoration: none; font-weight: bold; font-size: 12px; transition: 0.3s; }
        .delete-link:hover { background: #ff4757; color: white; }

        #paginationControls { display: flex; justify-content: center; align-items: center; gap: 15px; margin-top: 25px; padding: 10px; }
        #paginationControls button { background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(5px); color: white; border: 1px solid rgba(255, 255, 255, 0.2); padding: 8px 20px; border-radius: 8px; cursor: pointer; font-weight: 500; transition: 0.3s; font-size: 14px; }
        #paginationControls button:hover:not(:disabled) { background: rgba(255, 159, 67, 0.3); border-color: #ff9f43; }
        #paginationControls button:disabled { opacity: 0.3; cursor: not-allowed; }
    </style>
</head>
<body>

<%-- Messages Section --%>
<% if (request.getAttribute("error") != null || session.getAttribute("error") != null) {
    String msg = (request.getAttribute("error") != null) ? (String)request.getAttribute("error") : (String)session.getAttribute("error");
%>
<div id="errorAlert" style="width: 100%; background: #ff4757; color: white; padding: 10px; text-align: center; font-weight: bold; position: fixed; top: 0; z-index: 2000;">
    ⚠️ <%= msg %>
</div>
<script>setTimeout(function() { document.getElementById("errorAlert").style.display = 'none'; }, 5000);</script>
<% session.removeAttribute("error"); } %>

<%
    String role = (String) session.getAttribute("userRole");
    String userName = (String) session.getAttribute("userName");
    List<VehicleEntity> vList = (List<VehicleEntity>) request.getAttribute("vehicles");
    int totalSlots = (request.getAttribute("totalSlots") != null) ? (Integer) request.getAttribute("totalSlots") : 10;
%>

<div class="navbar">
    <h2 style="margin:0;">🅿️ ParkingPro</h2>
    <div class="nav-links">
        <a href="/dashboard" class="active">🏠 Dashboard</a>
        <% if ("ADMIN".equals(role)) { %>
        <a href="/userManagement">👥 Users</a>
        <a href="/history">📜 History</a>
        <a href="/adminSettings">⚙️ Settings</a>
        <% } %>
    </div>
    <div style="display: flex; align-items: center; gap: 20px;">
        <span>Welcome, <b><%= userName %></b></span>
        <a href="/logout" class="logout-btn">Logout</a>
    </div>
</div>

<div class="container">
    <div class="status-container">
        <div class="card" onclick="filterSlots('all')">
            <h3>Total Slots</h3>
            <p><%= totalSlots %></p>
        </div>
        <div class="card" onclick="filterSlots('occupied')" style="border-bottom: 4px solid #ff9f43;">
            <h3>Occupied</h3>
            <p><%= (vList != null) ? vList.size() : 0 %></p>
        </div>
        <div class="card" onclick="filterSlots('free')" style="border-bottom: 4px solid #2ecc71;">
            <h3>Free Slots</h3>
            <p><%= totalSlots - ((vList != null) ? vList.size() : 0) %></p>
        </div>
    </div>

    <div class="main-content">
        <div class="glass-box form-section">
            <h3 style="color: #ff9f43;">🚗 Register Vehicle</h3>
            <form action="/addVehicle" method="post" enctype="multipart/form-data">
                <label>Vehicle Number</label>
                <input type="text" name="vNumber" placeholder="Ex: CAS-1234" required>
                <label>Owner Name</label>
                <input type="text" name="owner" required>
                <label>Vehicle Model</label>
                <input type="text" name="model" required>
                <label>Customer Type</label>
                <select name="customerType">
                    <option value="GUEST">Guest</option>
                    <option value="MEMBER">Member</option>
                </select>
                <label>Vehicle Photo</label>
                <input type="file" name="vehicleImage" accept="image/*" required>
                <button type="submit" class="save-btn">CONFIRM & PARK</button>
            </form>
        </div>

        <div class="glass-box table-section">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                <h3 style="color: #ff9f43;">📊 Real-time Status</h3>
                <input type="text" id="searchInput" onkeyup="searchVehicle()" placeholder="🔎 Search..." style="width: 150px; padding: 8px; border-radius: 15px;">
            </div>

            <table>
                <thead>
                <tr>
                    <th>Photo</th> <th>Slot / Plate</th>
                    <th>Owner / Type</th> <th>Model</th>
                    <th>Entry Time</th> <th>Action</th>
                </tr>
                </thead>
                <tbody id="parkingTableBody">
                <%
                    for (int i = 1; i <= totalSlots; i++) {
                        String slotLabel = "Slot-" + String.format("%02d", i);
                        VehicleEntity found = null;
                        if (vList != null) {
                            for (VehicleEntity v : vList) {
                                if (v.getSlot() != null && v.getSlot().trim().equals(slotLabel)) { found = v; break; }
                            }
                        }

                        if (found != null) {
                %>
                <tr class="slot-row occupied-row">
                    <td>
                        <%-- Cloudinary පින්තූරය මෙතනින් නිවැරදිව පෙන්වනවා --%>
                        <img src="<%= found.getImageName() %>"
                             style="width: 50px; height: 50px; border-radius: 5px; object-fit: cover; cursor: pointer; border: 1px solid rgba(255,255,255,0.2);"
                             onclick="window.open(this.src)">
                    </td>
                    <td><b style="color: #ff9f43;"><%= found.getSlot() %></b><br><%= found.getVehicleNumber() %></td>
                    <td>
                        <%= found.getOwnerName() %><br>
                        <span style="font-size: 10px; padding: 2px 5px; border-radius: 4px; background: <%= "MEMBER".equals(found.getCustomerType()) ? "#2ecc71" : "#95a5a6" %>;">
                            <%= found.getCustomerType() %>
                        </span>
                    </td>
                    <td><%= found.getModel() %></td>
                    <td style="font-size: 11px; opacity: 0.8;"><%= found.getEntryTime() %></td>
                    <td>
                        <a href="/deleteVehicle?vNumber=<%= found.getVehicleNumber() %>" class="delete-link"
                           onclick="return confirm('Release vehicle?')">Exit</a>
                    </td>
                </tr>
                <% } else { %>
                <tr class="slot-row free-row">
                    <td><div style="width: 50px; height: 50px; background: rgba(255,255,255,0.05); border-radius: 5px; border: 1px dashed rgba(255,255,255,0.2);"></div></td>
                    <td><b><%= slotLabel %></b></td>
                    <td colspan="3" style="text-align:center; color: #2ecc71; opacity: 0.5;">Available</td>
                    <td><span style="color:#2ecc71; font-weight: bold;">Empty</span></td>
                </tr>
                <% } } %>
                </tbody>
            </table>

            <div id="paginationControls">
                <button onclick="prevPage()" id="btnPrev">←</button>
                <span id="pageInfo"></span>
                <button onclick="nextPage()" id="btnNext">→</button>
            </div>
        </div>
    </div>
</div>

<script>
    let currentFilter = 'all';
    let currentPage = 1;
    const recordsPerPage = 8;

    function filterSlots(type) {
        currentFilter = type;
        currentPage = 1;
        let rows = document.querySelectorAll(".slot-row");
        rows.forEach(row => {
            row.classList.remove('filtered-out');
            if (type === 'occupied' && !row.classList.contains('occupied-row')) row.classList.add('filtered-out');
            if (type === 'free' && !row.classList.contains('free-row')) row.classList.add('filtered-out');
        });
        displayTable();
    }

    function searchVehicle() {
        let input = document.getElementById("searchInput").value.toUpperCase();
        let rows = document.querySelectorAll(".slot-row");
        let pagination = document.getElementById("paginationControls");
        if (input === "") {
            pagination.style.display = "flex";
            displayTable();
        } else {
            pagination.style.display = "none";
            rows.forEach(row => {
                let text = row.innerText.toUpperCase();
                row.style.display = text.includes(input) ? "" : "none";
            });
        }
    }

    function displayTable() {
        let allRows = Array.from(document.querySelectorAll(".slot-row"));
        let visibleRows = allRows.filter(row => !row.classList.contains('filtered-out'));
        let totalPages = Math.ceil(visibleRows.length / recordsPerPage) || 1;
        if (currentPage > totalPages) currentPage = totalPages;
        allRows.forEach(row => row.style.display = "none");
        visibleRows.forEach((row, index) => {
            if (index >= (currentPage - 1) * recordsPerPage && index < currentPage * recordsPerPage) {
                row.style.display = "";
            }
        });
        document.getElementById("pageInfo").innerText = "Page " + currentPage + " of " + totalPages;
        document.getElementById("btnPrev").disabled = (currentPage === 1);
        document.getElementById("btnNext").disabled = (currentPage === totalPages || visibleRows.length === 0);
    }
    function prevPage() { if (currentPage > 1) { currentPage--; displayTable(); } }
    function nextPage() {
        let visibleRows = Array.from(document.querySelectorAll(".slot-row")).filter(row => !row.classList.contains('filtered-out'));
        if (currentPage < Math.ceil(visibleRows.length / recordsPerPage)) { currentPage++; displayTable(); }
    }
    window.onload = displayTable;
</script>
</body>
</html>