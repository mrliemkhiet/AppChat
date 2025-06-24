<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - Zola</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            height: 100vh;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #333;
        }
        
        .error-container {
            background: white;
            padding: 60px 40px;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15);
            text-align: center;
            max-width: 500px;
            width: 90%;
            animation: slideUp 0.6s ease-out;
        }
        
        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .error-icon {
            font-size: 80px;
            color: #0084ff;
            margin-bottom: 30px;
            animation: bounce 2s infinite;
        }
        
        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% {
                transform: translateY(0);
            }
            40% {
                transform: translateY(-10px);
            }
            60% {
                transform: translateY(-5px);
            }
        }
        
        .error-title {
            font-size: 28px;
            color: #1c1e21;
            margin-bottom: 16px;
            font-weight: 600;
        }
        
        .error-message {
            color: #65676b;
            margin-bottom: 30px;
            line-height: 1.6;
            font-size: 16px;
        }
        
        .error-details {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            text-align: left;
            font-family: 'Courier New', monospace;
            font-size: 14px;
            color: #e74c3c;
            border-left: 4px solid #e74c3c;
            display: none;
        }
        
        .error-details.show {
            display: block;
        }
        
        .error-code {
            font-weight: bold;
            color: #0084ff;
            margin-bottom: 10px;
        }
        
        .back-btn {
            background: #0084ff;
            color: white;
            padding: 14px 28px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
            margin-right: 12px;
        }
        
        .back-btn:hover {
            background: #0066cc;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 132, 255, 0.3);
        }
        
        .details-btn {
            background: transparent;
            color: #65676b;
            padding: 14px 28px;
            border: 2px solid #e4e6ea;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }
        
        .details-btn:hover {
            border-color: #0084ff;
            color: #0084ff;
        }
        
        .logo {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            margin-bottom: 30px;
        }
        
        .logo-icon {
            width: 48px;
            height: 48px;
            background: #0084ff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 24px;
        }
        
        .logo-text {
            font-size: 32px;
            font-weight: 700;
            color: #1c1e21;
            letter-spacing: -1px;
        }
        
        @media (max-width: 480px) {
            .error-container {
                padding: 40px 20px;
                margin: 20px;
            }
            
            .error-title {
                font-size: 24px;
            }
            
            .error-icon {
                font-size: 60px;
            }
            
            .back-btn, .details-btn {
                padding: 12px 20px;
                font-size: 14px;
                width: 100%;
                margin-bottom: 12px;
                margin-right: 0;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="logo">
            <div class="logo-icon">Z</div>
            <div class="logo-text">Zola</div>
        </div>
        
        <div class="error-icon">
            <i class="fas fa-exclamation-triangle"></i>
        </div>
        
        <h1 class="error-title">Oops! Something went wrong</h1>
        
        <p class="error-message">
            We're sorry, but an error occurred while processing your request. 
            Don't worry, our team has been notified and we're working to fix this issue.
        </p>
        
        <div class="error-details" id="errorDetails">
            <div class="error-code">
                Error Code: <%= response.getStatus() %>
            </div>
            <% if (exception != null) { %>
                <strong>Exception:</strong> <%= exception.getClass().getSimpleName() %><br>
                <strong>Message:</strong> <%= exception.getMessage() != null ? exception.getMessage() : "No message available" %><br>
                <strong>Timestamp:</strong> <%= new java.util.Date() %>
            <% } else { %>
                <strong>HTTP Status:</strong> <%= response.getStatus() %><br>
                <strong>Request URI:</strong> <%= request.getRequestURI() %><br>
                <strong>Timestamp:</strong> <%= new java.util.Date() %>
            <% } %>
        </div>
        
        <div>
            <a href="${pageContext.request.contextPath}/chat" class="back-btn">
                <i class="fas fa-home"></i>
                Back to Chat
            </a>
            <button class="details-btn" onclick="toggleDetails()">
                <i class="fas fa-info-circle"></i>
                <span id="detailsText">Show Details</span>
            </button>
        </div>
    </div>
    
    <script>
        function toggleDetails() {
            const details = document.getElementById('errorDetails');
            const text = document.getElementById('detailsText');
            
            if (details.classList.contains('show')) {
                details.classList.remove('show');
                text.textContent = 'Show Details';
            } else {
                details.classList.add('show');
                text.textContent = 'Hide Details';
            }
        }
        
        // Auto-hide details after 10 seconds if shown
        setTimeout(() => {
            const details = document.getElementById('errorDetails');
            if (details.classList.contains('show')) {
                toggleDetails();
            }
        }, 10000);
    </script>
</body>
</html>