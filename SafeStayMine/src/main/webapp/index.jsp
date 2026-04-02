<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SafeStay | Home</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;800&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }

        body {
            height: 100vh;
            width: 100%;
            /* 1. මුලින්ම Project එක ඇතුළේ තියෙන පින්තූරය බලනවා.
               2. ඒක නැත්නම් Internet එකෙන් ගන්නවා. */
            background-image: url('images/hotel_v_04.jpg'),
            url('https://img.freepik.com/premium-vector/woman-with-suitcases-standing-hotel-room-apartment-bedroom-interior-with-bed-bedding_424648059.jpg');
            background-repeat: no-repeat;
            background-size: cover;
            background-position: center;
            background-color: #fceabb;
            display: flex;
            align-items: center;
            justify-content: flex-start;
            padding-left: 8%;
            overflow: hidden;
        }

        /* SafeStay අකුරු තියෙන පෙට්ටිය */
        .hero-card {
            background: rgba(255, 255, 255, 0.9); /* පසුබිම පේන විදිහට ලස්සනට හදමු */
            padding: 50px 40px;
            border-radius: 20px;
            max-width: 450px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.15);
            text-align: left;
            border-left: 10px solid #e67e22; /* පින්තූරයේ තැඹිලි පාටට ගැලපෙන්න */
            animation: fadeIn 1.2s ease-in-out;
        }

        h1 {
            font-size: 4rem;
            color: #2c3e50;
            font-weight: 800;
            margin-bottom: 10px;
            line-height: 1;
        }

        p {
            font-size: 1.2rem;
            color: #555;
            margin-bottom: 35px;
            line-height: 1.5;
        }

        .btn-start {
            display: inline-block;
            padding: 16px 45px;
            background-color: #e67e22;
            color: white;
            text-decoration: none;
            font-weight: 700;
            border-radius: 12px;
            transition: all 0.3s ease;
            box-shadow: 0 8px 20px rgba(230, 126, 34, 0.3);
            text-transform: uppercase;
        }

        .btn-start:hover {
            background-color: #d35400;
            transform: scale(1.05);
            box-shadow: 0 12px 25px rgba(230, 126, 34, 0.5);
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateX(-50px); }
            to { opacity: 1; transform: translateX(0); }
        }

        /* Mobile Layout */
        @media (max-width: 768px) {
            body { justify-content: center; padding-left: 0; }
            .hero-card { text-align: center; margin: 20px; }
        }
    </style>
</head>
<body>

<div class="hero-card">
    <h1>SafeStay</h1>
    <p>Your Secure and Smart Hostel Management Companion.</p>
    <a href="login.jsp" class="btn-start">Get Started</a>
</div>

</body>
</html>