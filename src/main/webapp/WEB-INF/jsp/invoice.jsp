<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Payment Receipt - ParkingPro</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0; padding: 0;
            /* Dashboard එකේ පසුබිමම භාවිතා කරමු */
            background: linear-gradient(rgba(0, 0, 0, 0.7), rgba(0, 0, 0, 0.7)),
            url('https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&q=80&w=2070');
            background-size: cover; background-attachment: fixed; background-position: center;
            display: flex; justify-content: center; align-items: center;
            height: 100vh; color: white;
        }

        .invoice-card {
            /* වීදුරු වැනි පෙනුම (Glass effect) */
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);

            padding: 40px;
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.15);
            width: 400px;
            text-align: center;
            box-shadow: 0 15px 35px rgba(0,0,0,0.4);
            position: relative;
            overflow: hidden;
        }

        /* පින්තූරයේ තිබූ දොඩම් පාට තීරුව (Orange stripe) */
        .invoice-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 8px;
            background: #ff9f43;
        }

        .header h2 { margin: 10px 0 0; color: #ff9f43; font-size: 26px; }
        .header p { margin: 5px 0 25px; font-size: 13px; opacity: 0.7; letter-spacing: 1px; }

        .bill-details {
            text-align: left;
            margin-bottom: 30px;
            background: rgba(0, 0, 0, 0.2); /* දත්ත පැහැදිලිව පෙනීමට */
            padding: 20px;
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
            font-size: 15px;
            border-bottom: 1px solid rgba(255,255,255,0.05);
            padding-bottom: 8px;
        }

        .detail-row span:first-child { opacity: 0.8; }
        .detail-row strong { color: white; }

        .total-amount {
            font-size: 22px;
            font-weight: bold;
            color: #2ecc71; /* කොළ පාට TOTAL */
            margin-top: 20px;
            text-align: center;
            background: rgba(46, 204, 113, 0.1);
            padding: 10px;
            border-radius: 8px;
        }

        .btn-container { display: flex; gap: 15px; margin-top: 25px; }

        .btn {
            flex: 1; padding: 12px; border: none; border-radius: 8px;
            font-weight: bold; cursor: pointer; transition: 0.3s;
            text-decoration: none; text-align: center;
            font-size: 14px; display: flex; align-items: center; justify-content: center; gap: 8px;
        }

        /* පින්තූරයේ තිබූ කළු පාට Print බටන් එක */
        .btn-print { background: #1a1a1a; color: white; border: 1px solid #333; }
        .btn-print:hover { background: #333; }

        /* පින්තූරයේ තිබූ දොඩම් පාට Back බටන් එක */
        .btn-back { background: #ff9f43; color: black; }
        .btn-back:hover { background: #e68a2e; transform: scale(1.02); }

        /* මුද්‍රණය කරන විට (Printing) */
        @media print {
            .btn-container, background-image { display: none; }
            body { background: white; color: black; }
            .invoice-card {
                background: white; color: black; border: none;
                box-shadow: none; backdrop-filter: none; padding: 20px;
            }
            .header h2 { color: black; }
            .bill-details { background: white; border: 1px solid #ccc; color: black;}
            .detail-row strong { color: black; }
            .total-amount { color: black; border: 1px solid #ccc; background: #f9f9f9;}
        }
    </style>
</head>
<body>

<div class="invoice-card">
    <div class="header">
        <h2>🅿️ ParkingPro</h2>
        <p>OFFICIAL PAYMENT RECEIPT</p>
    </div>

    <div class="bill-details">
        <div class="detail-row">
            <span>Vehicle Number:</span>
            <strong>${vNumber}</strong>
        </div>
        <div class="detail-row">
            <span>Owner Name:</span>
            <strong>${owner}</strong>
        </div>
        <div class="detail-row">
            <span>Parked Duration:</span>
            <strong>${minutes} Minutes</strong>
        </div>
        <div class="total-amount">
            TOTAL: Rs. ${fee}.00
        </div>
    </div>

    <div style="font-size: 11px; opacity: 0.6; margin-bottom: 25px;">
        Thank you for using ParkingPro Services! <br>
        <%= new java.util.Date() %>
    </div>

    <div class="btn-container">
        <button class="btn btn-print" onclick="window.print()">🖨️ Print Receipt</button>
        <a href="/dashboard" class="btn btn-back">🏠 Back to Home</a>
    </div>
</div>

</body>
</html>