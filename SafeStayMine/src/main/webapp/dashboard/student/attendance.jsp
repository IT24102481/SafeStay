<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.*, java.util.*, java.text.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"Student".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String fullName = user.getFullName() != null ? user.getFullName() : "Student";
    String studentId = user.getUserId();
    SimpleDateFormat sdf = new SimpleDateFormat("EEEE, MMMM d, yyyy");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>24/7 Attendance System - SafeStay</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://unpkg.com/html5-qrcode/minified/html5-qrcode.min.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { background: #f8fafc; min-height: 100vh; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; }

        .header {
            background: white; border-radius: 20px; padding: 25px 30px;
            margin-bottom: 25px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            display: flex; justify-content: space-between; align-items: center;
        }
        .header h1 { font-size: 28px; color: #0f172a; display: flex; align-items: center; gap: 12px; }
        .header h1 i { color: #4f46e5; }
        .back-btn {
            background: #f1f5f9; color: #0f172a; border: none; padding: 12px 25px;
            border-radius: 12px; font-weight: 600; display: flex; align-items: center;
            gap: 10px; cursor: pointer; text-decoration: none;
        }
        .back-btn:hover { background: #e2e8f0; transform: translateX(-5px); }

        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 25px; }

        .qr-card {
            background: white; border-radius: 20px; padding: 30px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
        }
        .qr-card h2 { font-size: 22px; color: #0f172a; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
        #qr-reader { width: 100%; border-radius: 15px; border: 2px dashed #e2e8f0; margin-bottom: 20px; }

        .scan-btn {
            background: #4f46e5; color: white; border: none; padding: 15px 30px;
            border-radius: 12px; font-size: 16px; font-weight: 600; cursor: pointer;
            width: 100%; display: flex; align-items: center; justify-content: center; gap: 10px;
            margin-bottom: 15px; transition: all 0.3s;
        }
        .scan-btn.stop { background: #ef4444; }

        .today-card {
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 15px; padding: 25px; color: white; margin-top: 20px;
        }
        .status-row {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 20px;
        }
        .status-badge {
            padding: 8px 25px; border-radius: 50px; font-weight: 600; font-size: 14px;
            background: rgba(255,255,255,0.2);
        }
        .time-display {
            display: flex; gap: 30px; margin: 20px 0;
        }
        .time-box {
            flex: 1; text-align: center; padding: 15px;
            background: rgba(255,255,255,0.1); border-radius: 12px;
        }
        .time-label { font-size: 12px; opacity: 0.9; margin-bottom: 5px; }
        .time-value { font-size: 20px; font-weight: 700; }

        .action-buttons {
            display: flex; gap: 15px; margin-top: 20px;
        }
        .btn {
            flex: 1; padding: 15px; border: none; border-radius: 10px;
            font-weight: 600; cursor: pointer; display: flex;
            align-items: center; justify-content: center; gap: 8px;
            transition: all 0.3s;
        }
        .btn-checkin { background: #10b981; color: white; }
        .btn-checkout { background: #f59e0b; color: white; }
        .btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .btn:hover:not(:disabled) { transform: translateY(-2px); }

        .stats-card {
            background: linear-gradient(135deg, #4f46e5, #6366f1);
            border-radius: 20px; padding: 30px; color: white; margin-bottom: 25px;
        }
        .percentage { font-size: 48px; font-weight: 700; margin-bottom: 10px; }
        .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; margin-top: 15px; }
        .stat-item { text-align: center; padding: 15px; background: rgba(255,255,255,0.1); border-radius: 12px; }
        .stat-value { font-size: 24px; font-weight: 700; }
        .stat-label { font-size: 12px; opacity: 0.9; }

        .history-card {
            background: white; border-radius: 20px; padding: 30px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
        }
        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; padding: 15px 10px; color: #64748b; font-weight: 600; border-bottom: 2px solid #f1f5f9; }
        td { padding: 15px 10px; border-bottom: 1px solid #f1f5f9; }
        .badge {
            padding: 5px 12px; border-radius: 50px; font-size: 12px; font-weight: 600; display: inline-block;
        }
        .badge-present { background: #d4edda; color: #155724; }
        .badge-late { background: #fff3cd; color: #856404; }
        .badge-absent { background: #f8d7da; color: #721c24; }

        .loading { text-align: center; padding: 50px; color: #64748b; }
        .loading i { font-size: 40px; animation: spin 1s linear infinite; }
        @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }

        @media (max-width: 768px) {
            .grid { grid-template-columns: 1fr; }
            .header { flex-direction: column; gap: 15px; text-align: center; }
            .time-display { flex-direction: column; gap: 10px; }
        }
    </style>
</head>
<body>
<div class="container">
    <!-- Header -->
    <div class="header">
        <h1><i class="fas fa-qrcode"></i> 24/7 Attendance System</h1>
        <a href="<%= request.getContextPath() %>/dashboard/student/" class="back-btn">
            <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>
    </div>

    <!-- Main Grid -->
    <div class="grid">
        <!-- Left Column - QR Scanner & Actions -->
        <div>
            <div class="qr-card">
                <h2><i class="fas fa-camera"></i> Scan QR Code</h2>
                <div id="qr-reader"></div>

                <button class="scan-btn" onclick="startScanner()" id="scanBtn">
                    <i class="fas fa-camera"></i> Start Scanner
                </button>

                <!-- Today's Status Card -->
                <div class="today-card" id="todayCard">
                    <div class="status-row">
                        <span>Today's Status</span>
                        <span class="status-badge" id="statusBadge">Loading...</span>
                    </div>
                    <div class="time-display" id="timeDisplay">
                        <div class="time-box">
                            <div class="time-label">Check In</div>
                            <div class="time-value" id="checkInDisplay">--:--</div>
                        </div>
                        <div class="time-box">
                            <div class="time-label">Check Out</div>
                            <div class="time-value" id="checkOutDisplay">--:--</div>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="action-buttons">
                        <button class="btn btn-checkin" onclick="manualCheckIn()" id="checkInBtn">
                            <i class="fas fa-sign-in-alt"></i> Check In
                        </button>
                        <button class="btn btn-checkout" onclick="manualCheckOut()" id="checkOutBtn">
                            <i class="fas fa-sign-out-alt"></i> Check Out
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Column - Stats & History -->
        <div>
            <!-- Stats Card -->
            <div class="stats-card" id="statsCard">
                <div class="loading"><i class="fas fa-spinner"></i><p>Loading statistics...</p></div>
            </div>

            <!-- History Card -->
            <div class="history-card">
                <h2 style="margin-bottom: 20px;"><i class="fas fa-history"></i> Last 30 Days Attendance</h2>
                <div id="historyTable">
                    <div class="loading"><i class="fas fa-spinner"></i><p>Loading history...</p></div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    let html5QrCode = null;
    let scannerActive = false;

    window.onload = function() {
        loadData();
    };

    function loadData() {
        fetch('<%= request.getContextPath() %>/attendance/history?studentId=<%= studentId %>')
            .then(response => response.json())
            .then(data => {
                updateUI(data);
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }

    function updateUI(data) {
        // Update stats
        const stats = data.stats;
        document.getElementById('statsCard').innerHTML = `
                <div class="percentage">${stats.percentage}%</div>
                <div style="font-size: 14px; opacity: 0.9;">Last 30 days</div>
                <div class="stats-grid">
                    <div class="stat-item">
                        <div class="stat-value">${stats.presentDays}</div>
                        <div class="stat-label">Present</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value">${stats.lateDays}</div>
                        <div class="stat-label">Late</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value">${stats.absentDays}</div>
                        <div class="stat-label">Absent</div>
                    </div>
                </div>
                <div style="margin-top: 15px; font-size: 13px;">Total Days: ${stats.totalDays}</div>
            `;

        // Update today's status
        document.getElementById('statusBadge').textContent =
            data.checkedIn ? (data.checkedOut ? 'Completed' : 'Checked In') : 'Not Checked In';
        document.getElementById('checkInDisplay').textContent = data.checkInTime || '--:--';
        document.getElementById('checkOutDisplay').textContent = data.checkOutTime || '--:--';

        // Update buttons
        document.getElementById('checkInBtn').disabled = data.checkedIn;
        document.getElementById('checkOutBtn').disabled = !data.checkedIn || data.checkedOut;

        // Update history table
        let historyHtml = '<table><tr><th>Date</th><th>Check In</th><th>Check Out</th><th>Status</th></tr>';

        if (data.history.length === 0) {
            historyHtml += '<tr><td colspan="4" style="text-align: center; padding: 30px;">No attendance records found</td></tr>';
        } else {
            data.history.forEach(record => {
                historyHtml += `
                        <tr>
                            <td>${record.date}</td>
                            <td>${record.checkIn}</td>
                            <td>${record.checkOut}</td>
                            <td><span class="badge badge-${record.status.toLowerCase()}">${record.status}</span></td>
                        </tr>
                    `;
            });
        }
        historyHtml += '</table>';
        document.getElementById('historyTable').innerHTML = historyHtml;
    }

    function startScanner() {
        const scanBtn = document.getElementById('scanBtn');

        if (scannerActive) {
            stopScanner();
            return;
        }

        html5QrCode = new Html5Qrcode("qr-reader");

        html5QrCode.start(
            { facingMode: "environment" },
            { fps: 10, qrbox: { width: 250, height: 250 } },
            (decodedText) => {
                stopScanner();
                processQR(decodedText);
            },
            (error) => {}
        ).then(() => {
            scannerActive = true;
            scanBtn.innerHTML = '<i class="fas fa-stop"></i> Stop Scanner';
            scanBtn.classList.add('stop');
        }).catch((err) => {
            alert('Camera error: ' + err);
        });
    }

    function stopScanner() {
        if (html5QrCode && scannerActive) {
            html5QrCode.stop().then(() => {
                html5QrCode.clear();
                scannerActive = false;
                document.getElementById('scanBtn').innerHTML = '<i class="fas fa-camera"></i> Start Scanner';
                document.getElementById('scanBtn').classList.remove('stop');
            });
        }
    }

    function processQR(qrCode) {
        if (confirm('Check in using QR code?')) {
            checkIn('Present', 'Scanned via QR');
        }
    }

    function manualCheckIn() {
        const status = prompt('Select status (Present, Late, Absent):', 'Present');
        if (status && ['Present', 'Late', 'Absent'].includes(status)) {
            checkIn(status, 'Manual check-in');
        } else if (status) {
            alert('Invalid status. Please enter Present, Late, or Absent');
        }
    }

    function checkIn(status, remarks) {
        const formData = new URLSearchParams();
        formData.append('studentId', '<%= studentId %>');
        formData.append('status', status);
        formData.append('remarks', remarks);

        fetch('<%= request.getContextPath() %>/attendance/checkin', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData.toString()
        })
            .then(response => response.json())
            .then(data => {
                alert(data.message);
                if (data.success) loadData();
            });
    }

    function manualCheckOut() {
        if (!confirm('Check out now?')) return;

        const formData = new URLSearchParams();
        formData.append('studentId', '<%= studentId %>');

        fetch('<%= request.getContextPath() %>/attendance/checkout', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData.toString()
        })
            .then(response => response.json())
            .then(data => {
                alert(data.message);
                if (data.success) loadData();
            });
    }

    window.addEventListener('beforeunload', function() {
        stopScanner();
    });
</script>
</body>
</html>