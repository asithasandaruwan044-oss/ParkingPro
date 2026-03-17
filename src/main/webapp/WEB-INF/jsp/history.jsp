<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.parking.system.HistoryEntity" %>

<!DOCTYPE html>
<html>
<head>
    <title>Parking History - Admin</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(rgba(0,0,0,0.8), rgba(0,0,0,0.8)), url('https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&q=80&w=2070');
            background-size: cover; background-attachment: fixed; color: white;
            display: flex; justify-content: center; padding: 50px 20px;
        }
        .container { width: 100%; max-width: 1100px; background: rgba(255,255,255,0.1); backdrop-filter: blur(10px); padding: 30px; border-radius: 20px; border: 1px solid rgba(255,255,255,0.2); }

        .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255,255,255,0.2); padding-bottom: 15px; margin-bottom: 25px; }
        .earning-card { background: #ff9f43; color: black; padding: 10px 20px; border-radius: 10px; font-weight: bold; font-size: 18px; }

        .summary-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .summary-box { background: rgba(255, 255, 255, 0.05); padding: 20px; border-radius: 15px; border: 1px solid rgba(255, 255, 255, 0.1); max-height: 250px; overflow-y: auto; }
        .summary-box h4 { margin: 0 0 15px 0; color: #ff9f43; border-bottom: 1px solid rgba(255,159,67,0.3); padding-bottom: 8px; display: flex; align-items: center; gap: 8px; }
        .stat-row { display: flex; justify-content: space-between; font-size: 14px; padding: 8px 0; border-bottom: 1px solid rgba(255,255,255,0.05); }

        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.1); font-size: 14px; }
        th { background: rgba(255,255,255,0.2); text-transform: uppercase; letter-spacing: 1px; }

        .more-btn { background: #ff9f43; color: black; border: none; padding: 6px 12px; border-radius: 5px; cursor: pointer; font-weight: bold; transition: 0.3s; }
        .more-btn:hover { background: #e68a00; transform: scale(1.05); }

        .delete-btn { background: rgba(255, 71, 87, 0.2); color: #ff4757; padding: 6px 12px; border-radius: 5px; text-decoration: none; font-weight: bold; font-size: 13px; transition: 0.3s; }
        .delete-btn:hover { background: #ff4757; color: white; }

        .modal { display: none; position: fixed; z-index: 2000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.9); backdrop-filter: blur(5px); }
        .modal-content { background: #1e1e1e; margin: 5% auto; padding: 20px; border-radius: 15px; width: 400px; text-align: center; border: 1px solid #ff9f43; box-shadow: 0 0 20px rgba(255, 159, 67, 0.4); }
        .modal-content img { width: 100%; height: 250px; border-radius: 10px; border: 2px solid #ff9f43; margin-bottom: 15px; object-fit: cover; }
        .close-btn { float: right; font-size: 28px; cursor: pointer; color: white; }

        .back-btn { display: inline-block; margin-top: 30px; text-decoration: none; color: #2ecc71; font-weight: bold; }
        #historySearch { padding: 10px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.2); background: rgba(255,255,255,0.1); color: white; width: 250px; outline: none; }
        .page-btn { background: rgba(255, 255, 255, 0.1); border: 1px solid rgba(255, 255, 255, 0.2); color: white; padding: 5px 15px; border-radius: 5px; cursor: pointer; }
    </style>
</head>
<body>

<div id="detailsModal" class="modal">
    <div class="modal-content">
        <span class="close-btn" onclick="closeModal()">&times;</span>
        <h3 style="color: #ff9f43; margin-bottom: 20px;">📜 Entry Evidence</h3>
        <%-- Modal එකේ පින්තූරය පෙන්වන තැන --%>
        <img id="modalImg" src="" alt="Vehicle Image" onclick="window.open(this.src)">
        <div style="text-align: left; background: rgba(255,255,255,0.05); padding: 15px; border-radius: 10px;">
            <p>🚗 <b>Plate:</b> <span id="mPlate"></span></p>
            <p>👤 <b>Owner:</b> <span id="mOwner"></span></p>
            <p>💰 <b>Paid:</b> Rs. <span id="mFee"></span>.00</p>
            <p>🕒 <b>Entry Time:</b> <span id="mEntry"></span></p>
            <p>🕒 <b>Exit Time:</b> <span id="mExit"></span></p>
            <p>👮 <b>Staff:</b> <span id="mStaff"></span></p>
        </div>
    </div>
</div>

<div class="container">
    <div class="header">
        <h2 style="margin:0;">📜 Parking History</h2>
        <div style="display: flex; gap: 15px;">
            <div class="earning-card" style="background: #2ecc71;">Today's: Rs. ${todayEarnings != null ? todayEarnings : 0}.00</div>
            <div class="earning-card">Grand Total: Rs. ${totalEarnings != null ? totalEarnings : 0}.00</div>
        </div>
    </div>

    <div class="summary-grid">
        <div class="summary-box">
            <h4>📅 Daily Revenue</h4>
            <%
                java.util.Map<String, Long> daily = (java.util.Map<String, Long>) request.getAttribute("dailyEarnings");
                if(daily != null) {
                    for(String date : daily.keySet()) {
            %>
            <div class="stat-row"><span><%= date %></span><span style="color: #2ecc71;">Rs. <%= daily.get(date) %>.00</span></div>
            <% } } %>
        </div>
        <div class="summary-box">
            <h4>📊 Monthly Revenue</h4>
            <%
                java.util.Map<String, Long> monthly = (java.util.Map<String, Long>) request.getAttribute("monthlyEarnings");
                if(monthly != null) {
                    for(String month : monthly.keySet()) {
            %>
            <div class="stat-row"><span><%= month %></span><span style="color: #ff9f43;">Rs. <%= monthly.get(month) %>.00</span></div>
            <% } } %>
        </div>
    </div>

    <div class="table-wrapper">
        <div style="margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
            <h3 style="color: rgba(255,255,255,0.7); font-size: 16px; margin: 0;">Detailed Logs</h3>
            <input type="text" id="historySearch" onkeyup="searchHistory()" placeholder="🔎 Search Plate or Owner...">
        </div>

        <table>
            <thead>
            <tr>
                <th>Photo</th><th>Vehicle No</th><th>Owner</th><th>Fee Paid</th><th>Exit Time</th><th>Action</th>
            </tr>
            </thead>
            <tbody id="historyTableBody">
            <%
                List<HistoryEntity> historyList = (List<HistoryEntity>) request.getAttribute("historyLogs");
                if (historyList != null && !historyList.isEmpty()) {
                    for (HistoryEntity h : historyList) {
            %>
            <tr class="history-row">
                <td>
                    <img src="<%= h.getImageName() %>"
                         style="width: 45px; height: 45px; border-radius: 5px; object-fit: cover; border: 1px solid rgba(255,255,255,0.1);">
                </td>
                <td><b><%= h.getVehicleNumber() %></b></td>
                <td><%= h.getOwnerName() %></td>
                <td style="color:#2ecc71; font-weight:bold;">Rs. <%= h.getFee().intValue() %>.00</td>
                <td style="font-size: 12px; opacity: 0.8;"><%= h.getExitTime() %></td>
                <td style="display: flex; gap: 8px;">
                    <button class="more-btn"
                            onclick="showDetails('<%= h.getVehicleNumber() %>', '<%= h.getOwnerName() %>', '<%= h.getFee().intValue() %>', '<%= h.getExitTime() %>', '<%= h.getImageName() %>', '<%= h.getEntryTime() %>', '<%= h.getHandledBy() %>')">
                        More
                    </button>
                    <a href="/deleteLog?id=<%= h.getId() %>" class="delete-btn"
                       onclick="return confirm('Do you want to delete this?')">🗑️</a>
                </td>
            </tr>
            <% } } %>
            </tbody>
        </table>

        <div id="paginationControls" style="margin-top: 20px; display: flex; justify-content: center; gap: 10px;">
            <button onclick="prevPage()" id="btn_prev" class="page-btn">Previous</button>
            <span id="page_num" style="align-self: center; font-weight: bold; color: #ff9f43;"></span>
            <button onclick="nextPage()" id="btn_next" class="page-btn">Next</button>
        </div>
    </div>

    <a href="/dashboard" class="back-btn">← Back to Dashboard</a>
</div>

<script>
    function showDetails(vNo, owner, fee, exit, imgUrl, entry, staff) {
        document.getElementById("mPlate").innerText = vNo;
        document.getElementById("mOwner").innerText = owner;
        document.getElementById("mFee").innerText = fee;
        document.getElementById("mExit").innerText = exit;
        document.getElementById("mEntry").innerText = entry;
        document.getElementById("mStaff").innerText = staff;

        // --- මෙන්න මෙතනයි වෙනස් කළේ ---
        // දැන්imgUrl එකේ කෙලින්ම Cloudinary URL එක තියෙන නිසා path එක ඕන වෙන්නේ නැහැ
        document.getElementById("modalImg").src = imgUrl;
        document.getElementById("detailsModal").style.display = "block";
    }

    function closeModal() {
        document.getElementById("detailsModal").style.display = "none";
    }

    function searchHistory() {
        let input = document.getElementById("historySearch").value.toUpperCase();
        let rows = document.querySelectorAll(".history-row");
        rows.forEach(row => {
            let text = row.innerText.toUpperCase();
            row.style.display = text.includes(input) ? "" : "none";
        });
    }

    let currentPage = 1;
    let recordsPerPage = 10;

    function changePage(page) {
        let tableRows = Array.from(document.querySelectorAll(".history-row"));
        let totalP = Math.ceil(tableRows.length / recordsPerPage) || 1;
        if (page < 1) page = 1;
        if (page > totalP) page = totalP;

        tableRows.forEach(row => row.style.display = "none");
        for (let i = (page - 1) * recordsPerPage; i < (page * recordsPerPage) && i < tableRows.length; i++) {
            tableRows[i].style.display = "";
        }
        document.getElementById("page_num").innerHTML = "Page: " + page + " of " + totalP;
        document.getElementById("btn_prev").disabled = (page === 1);
        document.getElementById("btn_next").disabled = (page === totalP || tableRows.length === 0);
    }

    function prevPage() { currentPage--; changePage(currentPage); }
    function nextPage() { currentPage++; changePage(currentPage); }

    window.onload = function() { changePage(1); };
    window.onclick = function(event) {
        if (event.target == document.getElementById("detailsModal")) closeModal();
    }
</script>

</body>
</html>