<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Zola - Modern Messaging</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="icon" type="image/x-icon" href="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzIiIGhlaWdodD0iMzIiIHZpZXdCb3g9IjAgMCAzMiAzMiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPGNpcmNsZSBjeD0iMTYiIGN5PSIxNiIgcj0iMTYiIGZpbGw9IiMwMDg0ZmYiLz4KPHN2ZyB4PSI4IiB5PSI4IiB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSI+CjxwYXRoIGQ9Ik04IDJMMTQgOEw4IDE0TDIgOEw4IDJaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4KPC9zdmc+">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        :root {
            --primary-color: #0084ff;
            --primary-dark: #0066cc;
            --secondary-color: #f0f2f5;
            --text-primary: #1c1e21;
            --text-secondary: #65676b;
            --border-color: #e4e6ea;
            --success-color: #42b883;
            --error-color: #e74c3c;
            --warning-color: #f39c12;
            --online-color: #44c767;
            --away-color: #ffa500;
            --busy-color: #ff6b6b;
            --offline-color: #95a5a6;
            --shadow: 0 2px 12px rgba(0, 0, 0, 0.15);
            --shadow-light: 0 1px 3px rgba(0, 0, 0, 0.1);
            --border-radius: 8px;
            --border-radius-large: 12px;
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            height: 100vh;
            overflow: hidden;
            display: flex;
            justify-content: center;
            align-items: center;
            color: var(--text-primary);
        }
        
        .chat-container {
            display: flex;
            height: 95vh;
            width: 95vw;
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            box-shadow: var(--shadow);
            border-radius: var(--border-radius-large);
            overflow: hidden;
            backdrop-filter: blur(10px);
        }
        
        .sidebar {
            width: 350px;
            background: var(--secondary-color);
            border-right: 1px solid var(--border-color);
            display: flex;
            flex-direction: column;
            position: relative;
        }
        
        .sidebar-header {
            padding: 20px;
            background: var(--primary-color);
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: var(--shadow-light);
        }
        
        .logo-section {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .logo {
            width: 40px;
            height: 40px;
            background: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-color);
            font-weight: bold;
            font-size: 18px;
        }
        
        .app-name {
            font-size: 24px;
            font-weight: 700;
            letter-spacing: -0.5px;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 16px;
            border: 2px solid rgba(255, 255, 255, 0.3);
        }
        
        .user-details h3 {
            font-size: 16px;
            margin-bottom: 2px;
            font-weight: 600;
        }
        
        .user-status {
            font-size: 12px;
            color: rgba(255, 255, 255, 0.8);
            display: flex;
            align-items: center;
            gap: 4px;
        }
        
        .status-indicator {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--online-color);
        }
        
        .header-actions {
            display: flex;
            gap: 8px;
        }
        
        .header-btn {
            width: 36px;
            height: 36px;
            border: none;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: var(--transition);
        }
        
        .header-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: scale(1.05);
        }
        
        .sidebar-tabs {
            display: flex;
            background: white;
            border-bottom: 1px solid var(--border-color);
        }
        
        .tab-button {
            flex: 1;
            padding: 16px;
            border: none;
            background: transparent;
            cursor: pointer;
            font-weight: 600;
            font-size: 14px;
            color: var(--text-secondary);
            transition: var(--transition);
            position: relative;
        }
        
        .tab-button.active {
            color: var(--primary-color);
        }
        
        .tab-button.active::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: var(--primary-color);
            border-radius: 3px 3px 0 0;
        }
        
        .tab-button:hover:not(.active) {
            background: var(--secondary-color);
            color: var(--text-primary);
        }
        
        .search-container {
            padding: 16px;
            background: white;
            border-bottom: 1px solid var(--border-color);
        }
        
        .search-input {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid var(--border-color);
            border-radius: 20px;
            font-size: 14px;
            background: var(--secondary-color);
            transition: var(--transition);
        }
        
        .search-input:focus {
            outline: none;
            border-color: var(--primary-color);
            background: white;
            box-shadow: 0 0 0 3px rgba(0, 132, 255, 0.1);
        }
        
        .contacts-list {
            flex: 1;
            overflow-y: auto;
            background: white;
        }
        
        .contact-item {
            padding: 16px 20px;
            cursor: pointer;
            transition: var(--transition);
            border-left: 3px solid transparent;
            display: flex;
            align-items: center;
            gap: 12px;
            position: relative;
        }
        
        .contact-item:hover {
            background: var(--secondary-color);
        }
        
        .contact-item.active {
            background: rgba(0, 132, 255, 0.1);
            border-left-color: var(--primary-color);
        }
        
        .contact-avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 18px;
            position: relative;
            flex-shrink: 0;
        }
        
        .contact-status-dot {
            position: absolute;
            bottom: 2px;
            right: 2px;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            border: 2px solid white;
            background: var(--offline-color);
        }
        
        .contact-status-dot.online { background: var(--online-color); }
        .contact-status-dot.away { background: var(--away-color); }
        .contact-status-dot.busy { background: var(--busy-color); }
        
        .contact-info {
            flex: 1;
            min-width: 0;
        }
        
        .contact-info h4 {
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 4px;
            color: var(--text-primary);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .contact-last-message {
            font-size: 13px;
            color: var(--text-secondary);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .contact-meta {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 4px;
        }
        
        .contact-time {
            font-size: 12px;
            color: var(--text-secondary);
        }
        
        .unread-badge {
            background: var(--primary-color);
            color: white;
            border-radius: 10px;
            padding: 2px 6px;
            font-size: 11px;
            font-weight: 600;
            min-width: 18px;
            text-align: center;
        }
        
        .loading, .error, .no-items, .no-messages {
            padding: 40px 20px;
            text-align: center;
            color: var(--text-secondary);
            font-size: 14px;
        }
        
        .loading {
            color: var(--primary-color);
        }
        
        .loading::after {
            content: '';
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 2px solid var(--primary-color);
            border-radius: 50%;
            border-top-color: transparent;
            animation: spin 1s linear infinite;
            margin-left: 8px;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        
        .error {
            color: var(--error-color);
        }
        
        .main-chat {
            flex: 1;
            display: flex;
            flex-direction: column;
            background: white;
            position: relative;
        }
        
        .chat-header {
            padding: 20px;
            background: white;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: var(--shadow-light);
            z-index: 10;
        }
        
        .chat-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .chat-avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 18px;
            position: relative;
        }
        
        .chat-status-dot {
            position: absolute;
            bottom: 2px;
            right: 2px;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            border: 2px solid white;
            background: var(--offline-color);
        }
        
        .chat-status-dot.online { background: var(--online-color); }
        .chat-status-dot.away { background: var(--away-color); }
        .chat-status-dot.busy { background: var(--busy-color); }
        
        .chat-details h3 {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 2px;
            color: var(--text-primary);
        }
        
        .chat-status {
            font-size: 13px;
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            gap: 4px;
        }
        
        .chat-actions {
            display: flex;
            gap: 8px;
        }
        
        .action-btn {
            width: 40px;
            height: 40px;
            border: none;
            border-radius: 50%;
            background: var(--secondary-color);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: var(--transition);
            color: var(--text-secondary);
        }
        
        .action-btn:hover {
            background: var(--primary-color);
            color: white;
            transform: scale(1.05);
        }
        
        .messages-container {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            background: var(--secondary-color);
            scroll-behavior: smooth;
        }
        
        .message-date {
            text-align: center;
            padding: 8px 16px;
            font-size: 12px;
            color: var(--text-secondary);
            background: white;
            border-radius: 16px;
            margin: 20px auto;
            width: fit-content;
            box-shadow: var(--shadow-light);
            font-weight: 500;
        }
        
        .message {
            margin-bottom: 16px;
            display: flex;
            align-items: flex-end;
            gap: 8px;
            animation: messageSlideIn 0.3s ease-out;
        }
        
        @keyframes messageSlideIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .message.sent {
            flex-direction: row-reverse;
        }
        
        .message-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 12px;
            font-weight: bold;
            flex-shrink: 0;
        }
        
        .message-content {
            max-width: 70%;
            background: white;
            padding: 12px 16px;
            border-radius: 18px;
            box-shadow: var(--shadow-light);
            position: relative;
            word-wrap: break-word;
        }
        
        .message.sent .message-content {
            background: var(--primary-color);
            color: white;
        }
        
        .message-sender {
            font-size: 12px;
            font-weight: 600;
            color: var(--primary-color);
            margin-bottom: 4px;
        }
        
        .message.sent .message-sender {
            color: rgba(255, 255, 255, 0.8);
        }
        
        .message-text {
            margin-bottom: 4px;
            line-height: 1.4;
            font-size: 14px;
        }
        
        .message-time {
            font-size: 11px;
            color: var(--text-secondary);
            text-align: right;
            opacity: 0.7;
        }
        
        .message.sent .message-time {
            color: rgba(255, 255, 255, 0.7);
        }
        
        .file-message {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            background: rgba(0, 132, 255, 0.1);
            border-radius: 8px;
            text-decoration: none;
            color: var(--primary-color);
            font-weight: 500;
            transition: var(--transition);
        }
        
        .file-message:hover {
            background: rgba(0, 132, 255, 0.2);
        }
        
        .message.sent .file-message {
            background: rgba(255, 255, 255, 0.2);
            color: white;
        }
        
        .message.sent .file-message:hover {
            background: rgba(255, 255, 255, 0.3);
        }
        
        .welcome-message {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            text-align: center;
            color: var(--text-secondary);
            padding: 40px;
        }
        
        .welcome-icon {
            font-size: 64px;
            color: var(--primary-color);
            margin-bottom: 20px;
            opacity: 0.5;
        }
        
        .welcome-message h2 {
            color: var(--text-primary);
            margin-bottom: 12px;
            font-size: 24px;
            font-weight: 600;
        }
        
        .welcome-message p {
            font-size: 16px;
            line-height: 1.5;
        }
        
        .message-input-container {
            padding: 20px;
            background: white;
            border-top: 1px solid var(--border-color);
        }
        
        .message-input-wrapper {
            display: flex;
            align-items: center;
            gap: 12px;
            background: var(--secondary-color);
            border-radius: 24px;
            padding: 8px 16px;
            transition: var(--transition);
        }
        
        .message-input-wrapper:focus-within {
            background: white;
            box-shadow: 0 0 0 2px var(--primary-color);
        }
        
        .input-btn {
            width: 36px;
            height: 36px;
            border: none;
            background: transparent;
            cursor: pointer;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: var(--transition);
            color: var(--text-secondary);
        }
        
        .input-btn:hover {
            background: rgba(0, 132, 255, 0.1);
            color: var(--primary-color);
        }
        
        .message-input {
            flex: 1;
            border: none;
            background: transparent;
            padding: 12px 0;
            font-size: 14px;
            outline: none;
            color: var(--text-primary);
        }
        
        .message-input::placeholder {
            color: var(--text-secondary);
        }
        
        .send-btn {
            width: 36px;
            height: 36px;
            border: none;
            background: var(--primary-color);
            color: white;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: var(--transition);
        }
        
        .send-btn:hover:not(:disabled) {
            background: var(--primary-dark);
            transform: scale(1.05);
        }
        
        .send-btn:disabled {
            background: var(--text-secondary);
            cursor: not-allowed;
            transform: none;
        }
        
        .emoji-picker {
            position: absolute;
            bottom: 80px;
            left: 20px;
            background: white;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            padding: 16px;
            box-shadow: var(--shadow);
            display: none;
            z-index: 1000;
            max-width: 300px;
        }
        
        .emoji-picker.show {
            display: block;
            animation: fadeInUp 0.3s ease-out;
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .emoji-grid {
            display: grid;
            grid-template-columns: repeat(8, 1fr);
            gap: 4px;
        }
        
        .emoji-item {
            width: 32px;
            height: 32px;
            border: none;
            background: transparent;
            cursor: pointer;
            border-radius: 4px;
            font-size: 18px;
            transition: var(--transition);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .emoji-item:hover {
            background: var(--secondary-color);
            transform: scale(1.2);
        }
        
        .file-upload {
            display: none;
        }
        
        .typing-indicator {
            padding: 12px 20px;
            font-style: italic;
            color: var(--text-secondary);
            font-size: 13px;
            background: white;
            border-top: 1px solid var(--border-color);
        }
        
        .new-group-form {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: white;
            z-index: 100;
            display: none;
            flex-direction: column;
        }
        
        .new-group-form.show {
            display: flex;
        }
        
        .form-header {
            padding: 20px;
            background: var(--primary-color);
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .form-header h3 {
            font-size: 18px;
            font-weight: 600;
        }
        
        .close-btn {
            width: 32px;
            height: 32px;
            border: none;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: var(--transition);
        }
        
        .close-btn:hover {
            background: rgba(255, 255, 255, 0.3);
        }
        
        .form-content {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--text-primary);
            font-size: 14px;
        }
        
        .form-group input, .form-group textarea {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            font-size: 14px;
            transition: var(--transition);
            font-family: inherit;
        }
        
        .form-group input:focus, .form-group textarea:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(0, 132, 255, 0.1);
        }
        
        .form-group textarea {
            resize: vertical;
            height: 80px;
        }
        
        .form-buttons {
            padding: 20px;
            background: var(--secondary-color);
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            border-top: 1px solid var(--border-color);
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: var(--border-radius);
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: var(--transition);
            min-width: 100px;
        }
        
        .btn-primary {
            background: var(--primary-color);
            color: white;
        }
        
        .btn-primary:hover {
            background: var(--primary-dark);
            transform: translateY(-1px);
        }
        
        .btn-secondary {
            background: var(--text-secondary);
            color: white;
        }
        
        .btn-secondary:hover {
            background: #5a6c7d;
            transform: translateY(-1px);
        }
        
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 16px 20px;
            border-radius: var(--border-radius);
            color: white;
            font-weight: 500;
            z-index: 10000;
            animation: slideInRight 0.3s ease-out;
            max-width: 300px;
        }
        
        @keyframes slideInRight {
            from {
                opacity: 0;
                transform: translateX(100%);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }
        
        .notification.success {
            background: var(--success-color);
        }
        
        .notification.error {
            background: var(--error-color);
        }
        
        .notification.warning {
            background: var(--warning-color);
        }
        
        /* Mobile Responsive */
        @media (max-width: 768px) {
            .chat-container {
                height: 100vh;
                width: 100vw;
                border-radius: 0;
            }
            
            .sidebar {
                width: 100%;
                position: absolute;
                z-index: 1000;
                transform: translateX(-100%);
                transition: transform 0.3s ease;
                height: 100%;
            }
            
            .sidebar.show {
                transform: translateX(0);
            }
            
            .main-chat {
                width: 100%;
            }
            
            .chat-header {
                padding: 16px;
            }
            
            .messages-container {
                padding: 16px;
            }
            
            .message-input-container {
                padding: 16px;
            }
            
            .contact-item {
                padding: 12px 16px;
            }
            
            .sidebar-header {
                padding: 16px;
            }
        }
        
        /* Scrollbar Styling */
        .contacts-list::-webkit-scrollbar,
        .messages-container::-webkit-scrollbar {
            width: 6px;
        }
        
        .contacts-list::-webkit-scrollbar-track,
        .messages-container::-webkit-scrollbar-track {
            background: var(--secondary-color);
        }
        
        .contacts-list::-webkit-scrollbar-thumb,
        .messages-container::-webkit-scrollbar-thumb {
            background: var(--border-color);
            border-radius: 3px;
        }
        
        .contacts-list::-webkit-scrollbar-thumb:hover,
        .messages-container::-webkit-scrollbar-thumb:hover {
            background: var(--text-secondary);
        }
        
        /* Loading Animation */
        .message-loading {
            display: flex;
            align-items: center;
            gap: 4px;
            padding: 8px 0;
        }
        
        .loading-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--text-secondary);
            animation: loadingDots 1.4s infinite ease-in-out;
        }
        
        .loading-dot:nth-child(1) { animation-delay: -0.32s; }
        .loading-dot:nth-child(2) { animation-delay: -0.16s; }
        
        @keyframes loadingDots {
            0%, 80%, 100% {
                transform: scale(0);
                opacity: 0.5;
            }
            40% {
                transform: scale(1);
                opacity: 1;
            }
        }
    </style>
</head>
<body>
    <div class="chat-container">
        <!-- Sidebar -->
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <div class="logo-section">
                    <div class="logo">Z</div>
                    <div class="app-name">Zola</div>
                </div>
                <div class="user-info">
                    <div class="user-avatar">
                        ${currentUser.username.substring(0,1).toUpperCase()}
                    </div>
                    <div class="user-details">
                        <h3>${currentUser.fullName != null ? currentUser.fullName : currentUser.username}</h3>
                        <div class="user-status">
                            <div class="status-indicator"></div>
                            Online
                        </div>
                    </div>
                </div>
                <div class="header-actions">
                    <button class="header-btn" onclick="toggleNewGroupForm()" title="New Group">
                        <i class="fas fa-plus"></i>
                    </button>
                    <button class="header-btn" onclick="toggleSidebar()" title="Menu">
                        <i class="fas fa-bars"></i>
                    </button>
                </div>
            </div>
            
            <div class="sidebar-tabs">
                <button id="chatsTabButton" class="tab-button active" onclick="switchTab('chats')">
                    <i class="fas fa-comments"></i> Chats
                </button>
                <button id="groupsTabButton" class="tab-button" onclick="switchTab('groups')">
                    <i class="fas fa-users"></i> Groups
                </button>
            </div>
            
            <div class="search-container">
                <input type="text" class="search-input" placeholder="Search conversations..." id="searchInput" oninput="filterContacts()">
            </div>
            
            <div id="chats-container" class="contacts-list">
                <div class="loading">
                    <i class="fas fa-spinner fa-spin"></i> Loading contacts...
                </div>
            </div>
            
            <div id="groups-container" class="contacts-list" style="display: none;">
                <div class="loading">
                    <i class="fas fa-spinner fa-spin"></i> Loading groups...
                </div>
            </div>
            
            <!-- New Group Form -->
            <div id="newGroupForm" class="new-group-form">
                <div class="form-header">
                    <h3><i class="fas fa-users"></i> Create New Group</h3>
                    <button class="close-btn" onclick="toggleNewGroupForm()">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                <div class="form-content">
                    <div class="form-group">
                        <label for="groupName"><i class="fas fa-tag"></i> Group Name</label>
                        <input type="text" id="groupName" placeholder="Enter group name" maxlength="50">
                    </div>
                    <div class="form-group">
                        <label for="groupDescription"><i class="fas fa-info-circle"></i> Description</label>
                        <textarea id="groupDescription" placeholder="Enter group description (optional)" maxlength="200"></textarea>
                    </div>
                </div>
                <div class="form-buttons">
                    <button class="btn btn-secondary" onclick="toggleNewGroupForm()">Cancel</button>
                    <button class="btn btn-primary" onclick="createGroup()">
                        <i class="fas fa-plus"></i> Create Group
                    </button>
                </div>
            </div>
        </div>
        
        <!-- Main Chat Area -->
        <div class="main-chat">
            <div class="chat-header">
                <div class="chat-info">
                    <div class="chat-avatar">
                        <i class="fas fa-comment-dots"></i>
                        <div class="chat-status-dot"></div>
                    </div>
                    <div class="chat-details">
                        <h3>Select a chat</h3>
                        <div class="chat-status">Choose a conversation to start messaging</div>
                    </div>
                </div>
                <div class="chat-actions">
                    <button class="action-btn" title="Voice Call">
                        <i class="fas fa-phone"></i>
                    </button>
                    <button class="action-btn" title="Video Call">
                        <i class="fas fa-video"></i>
                    </button>
                    <button class="action-btn" title="Chat Info">
                        <i class="fas fa-info-circle"></i>
                    </button>
                </div>
            </div>
            
            <div class="messages-container" id="messagesContainer">
                <div class="welcome-message">
                    <div class="welcome-icon">
                        <i class="fas fa-comments"></i>
                    </div>
                    <h2>Welcome to Zola</h2>
                    <p>Select a contact or group from the sidebar to start chatting.<br>
                    Connect with friends and family instantly!</p>
                </div>
            </div>
            
            <div class="message-input-container">
                <div class="message-input-wrapper">
                    <button class="input-btn" onclick="toggleEmojiPicker()" title="Emoji">
                        <i class="far fa-smile"></i>
                    </button>
                    <input type="text" id="messageInput" class="message-input" placeholder="Type a message..." onkeypress="handleKeyPress(event)" maxlength="1000">
                    <label for="fileUpload" class="input-btn" title="Attach File">
                        <i class="fas fa-paperclip"></i>
                    </label>
                    <input type="file" id="fileUpload" class="file-upload" onchange="handleFileUpload()" accept="*/*">
                    <button class="send-btn" onclick="sendMessage()" title="Send Message">
                        <i class="fas fa-paper-plane"></i>
                    </button>
                </div>
                
                <!-- Emoji Picker -->
                <div id="emojiPicker" class="emoji-picker">
                    <div class="emoji-grid">
                        <button class="emoji-item" onclick="insertEmoji('😀')">😀</button>
                        <button class="emoji-item" onclick="insertEmoji('😁')">😁</button>
                        <button class="emoji-item" onclick="insertEmoji('😂')">😂</button>
                        <button class="emoji-item" onclick="insertEmoji('🤣')">🤣</button>
                        <button class="emoji-item" onclick="insertEmoji('😃')">😃</button>
                        <button class="emoji-item" onclick="insertEmoji('😄')">😄</button>
                        <button class="emoji-item" onclick="insertEmoji('😅')">😅</button>
                        <button class="emoji-item" onclick="insertEmoji('😆')">😆</button>
                        <button class="emoji-item" onclick="insertEmoji('😉')">😉</button>
                        <button class="emoji-item" onclick="insertEmoji('😊')">😊</button>
                        <button class="emoji-item" onclick="insertEmoji('😋')">😋</button>
                        <button class="emoji-item" onclick="insertEmoji('😎')">😎</button>
                        <button class="emoji-item" onclick="insertEmoji('😍')">😍</button>
                        <button class="emoji-item" onclick="insertEmoji('😘')">😘</button>
                        <button class="emoji-item" onclick="insertEmoji('🥰')">🥰</button>
                        <button class="emoji-item" onclick="insertEmoji('😗')">😗</button>
                        <button class="emoji-item" onclick="insertEmoji('🤔')">🤔</button>
                        <button class="emoji-item" onclick="insertEmoji('🤗')">🤗</button>
                        <button class="emoji-item" onclick="insertEmoji('😌')">😌</button>
                        <button class="emoji-item" onclick="insertEmoji('😔')">😔</button>
                        <button class="emoji-item" onclick="insertEmoji('😢')">😢</button>
                        <button class="emoji-item" onclick="insertEmoji('😭')">😭</button>
                        <button class="emoji-item" onclick="insertEmoji('😤')">😤</button>
                        <button class="emoji-item" onclick="insertEmoji('😠')">😠</button>
                        <button class="emoji-item" onclick="insertEmoji('👍')">👍</button>
                        <button class="emoji-item" onclick="insertEmoji('👎')">👎</button>
                        <button class="emoji-item" onclick="insertEmoji('👏')">👏</button>
                        <button class="emoji-item" onclick="insertEmoji('🙏')">🙏</button>
                        <button class="emoji-item" onclick="insertEmoji('❤️')">❤️</button>
                        <button class="emoji-item" onclick="insertEmoji('💕')">💕</button>
                        <button class="emoji-item" onclick="insertEmoji('💖')">💖</button>
                        <button class="emoji-item" onclick="insertEmoji('🔥')">🔥</button>
                    </div>
                </div>
            </div>
            
            <div class="typing-indicator" id="typingIndicator" style="display: none;">
                <div class="message-loading">
                    <span>Someone is typing</span>
                    <div class="loading-dot"></div>
                    <div class="loading-dot"></div>
                    <div class="loading-dot"></div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Global variables
        let currentUser;
        let currentChat = null;
        let currentTab = 'chats';
        let contacts = [];
        let groups = [];
        let messages = [];
        let lastMessageCount = 0;
        let refreshInterval;
        
        // Initialize current user from JSP
        function initCurrentUser() {
            currentUser = {
                id: Number('${currentUser != null ? currentUser.id : 0}'),
                username: '${currentUser != null ? currentUser.username : "Guest"}',
                fullName: '${currentUser != null ? currentUser.fullName : "Guest User"}'
            };
        }
        
        // Initialize the application
        document.addEventListener('DOMContentLoaded', function() {
            initCurrentUser();
            console.log('Zola Chat initialized for user:', currentUser);
            
            // Set up UI
            document.getElementById('chats-container').style.display = 'block';
            document.getElementById('groups-container').style.display = 'none';
            document.getElementById('chatsTabButton').classList.add('active');
            
            // Load initial data
            loadContacts();
            
            // Start auto-refresh for messages
            startMessageRefresh();
            
            // Set up event listeners
            setupEventListeners();
        });
        
        // Set up event listeners
        function setupEventListeners() {
            // Close emoji picker when clicking outside
            document.addEventListener('click', function(event) {
                const emojiPicker = document.getElementById('emojiPicker');
                const emojiBtn = document.querySelector('.input-btn');
                
                if (!emojiPicker.contains(event.target) && !event.target.closest('.input-btn')) {
                    emojiPicker.classList.remove('show');
                }
            });
            
            // Handle window resize
            window.addEventListener('resize', function() {
                if (window.innerWidth > 768) {
                    document.getElementById('sidebar').classList.remove('show');
                }
            });
        }
        
        // Tab switching
        function switchTab(tab) {
            currentTab = tab;
            
            // Update tab buttons
            document.querySelectorAll('.tab-button').forEach(btn => btn.classList.remove('active'));
            document.getElementById(tab + 'TabButton').classList.add('active');
            
            // Show/hide containers
            if (tab === 'chats') {
                document.getElementById('chats-container').style.display = 'block';
                document.getElementById('groups-container').style.display = 'none';
                loadContacts();
            } else if (tab === 'groups') {
                document.getElementById('chats-container').style.display = 'none';
                document.getElementById('groups-container').style.display = 'block';
                loadGroups();
            }
            
            // Clear search
            document.getElementById('searchInput').value = '';
        }
        
        // Load contacts
        function loadContacts() {
            const container = document.getElementById('chats-container');
            container.innerHTML = '<div class="loading"><i class="fas fa-spinner fa-spin"></i> Loading contacts...</div>';
            
            fetch('chat?action=getUsers')
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }
                return response.json();
            })
            .then(data => {
                contacts = Array.isArray(data) ? data : [];
                renderContacts();
            })
            .catch(error => {
                console.error('Error loading contacts:', error);
                container.innerHTML = `<div class="error"><i class="fas fa-exclamation-triangle"></i> Failed to load contacts<br><small>${error.message}</small></div>`;
            });
        }
        
        // Load groups
        function loadGroups() {
            const container = document.getElementById('groups-container');
            container.innerHTML = '<div class="loading"><i class="fas fa-spinner fa-spin"></i> Loading groups...</div>';
            
            fetch('chat?action=getGroups')
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }
                return response.json();
            })
            .then(data => {
                groups = Array.isArray(data) ? data : [];
                renderGroups();
            })
            .catch(error => {
                console.error('Error loading groups:', error);
                container.innerHTML = `<div class="error"><i class="fas fa-exclamation-triangle"></i> Failed to load groups<br><small>${error.message}</small></div>`;
            });
        }
        
        // Render contacts
        function renderContacts() {
            const container = document.getElementById('chats-container');
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            
            if (!Array.isArray(contacts) || contacts.length === 0) {
                container.innerHTML = '<div class="no-items"><i class="fas fa-user-friends"></i><br>No contacts available</div>';
                return;
            }
            
            // Filter contacts (exclude current user and apply search)
            const filteredContacts = contacts.filter(contact => {
                if (contact.id === currentUser.id) return false;
                if (searchTerm) {
                    const name = (contact.fullName || contact.username || '').toLowerCase();
                    return name.includes(searchTerm);
                }
                return true;
            });
            
            if (filteredContacts.length === 0) {
                container.innerHTML = '<div class="no-items"><i class="fas fa-search"></i><br>No contacts found</div>';
                return;
            }
            
            let html = '';
            filteredContacts.forEach(contact => {
                const displayName = contact.fullName || contact.username || 'Unknown';
                const status = (contact.status || 'offline').toLowerCase();
                const firstLetter = displayName.charAt(0).toUpperCase();
                const isActive = currentChat && currentChat.type === 'user' && currentChat.id === contact.id;
                
                html += `
                    <div class="contact-item ${isActive ? 'active' : ''}" 
                         onclick="selectChat('user', ${contact.id}, '${escapeHtml(displayName)}', '${status}')">
                        <div class="contact-avatar">
                            ${firstLetter}
                            <div class="contact-status-dot ${status}"></div>
                        </div>
                        <div class="contact-info">
                            <h4>${escapeHtml(displayName)}</h4>
                            <div class="contact-last-message">Click to start chatting</div>
                        </div>
                        <div class="contact-meta">
                            <div class="contact-time"></div>
                        </div>
                    </div>
                `;
            });
            
            container.innerHTML = html;
        }
        
        // Render groups
        function renderGroups() {
            const container = document.getElementById('groups-container');
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            
            if (!Array.isArray(groups) || groups.length === 0) {
                container.innerHTML = '<div class="no-items"><i class="fas fa-users"></i><br>No groups available<br><small>Create a new group to get started</small></div>';
                return;
            }
            
            // Filter groups by search term
            const filteredGroups = groups.filter(group => {
                if (searchTerm) {
                    const name = (group.name || '').toLowerCase();
                    return name.includes(searchTerm);
                }
                return true;
            });
            
            if (filteredGroups.length === 0) {
                container.innerHTML = '<div class="no-items"><i class="fas fa-search"></i><br>No groups found</div>';
                return;
            }
            
            let html = '';
            filteredGroups.forEach(group => {
                const isActive = currentChat && currentChat.type === 'group' && currentChat.id === group.id;
                const memberCount = group.memberCount || 0;
                
                html += `
                    <div class="contact-item ${isActive ? 'active' : ''}" 
                         onclick="selectChat('group', ${group.id}, '${escapeHtml(group.name)}', 'group')">
                        <div class="contact-avatar">
                            ${group.name.charAt(0).toUpperCase()}
                        </div>
                        <div class="contact-info">
                            <h4>${escapeHtml(group.name)}</h4>
                            <div class="contact-last-message">${memberCount} member${memberCount !== 1 ? 's' : ''}</div>
                        </div>
                        <div class="contact-meta">
                            <div class="contact-time"></div>
                        </div>
                    </div>
                `;
            });
            
            container.innerHTML = html;
        }
        
        // Filter contacts/groups based on search
        function filterContacts() {
            if (currentTab === 'chats') {
                renderContacts();
            } else {
                renderGroups();
            }
        }
        
        // Select chat
        function selectChat(type, id, name, status) {
            currentChat = {
                type: type,
                id: id,
                name: name,
                status: status || 'offline'
            };
            
            // Update active state in sidebar
            if (type === 'user') {
                renderContacts();
            } else {
                renderGroups();
            }
            
            // Update chat header
            updateChatHeader();
            
            // Load messages
            loadMessages();
            
            // Hide sidebar on mobile
            if (window.innerWidth <= 768) {
                document.getElementById('sidebar').classList.remove('show');
            }
        }
        
        // Update chat header
        function updateChatHeader() {
            if (!currentChat) return;
            
            const chatAvatar = document.querySelector('.chat-avatar');
            const chatTitle = document.querySelector('.chat-details h3');
            const chatStatus = document.querySelector('.chat-status');
            const statusDot = document.querySelector('.chat-status-dot');
            
            chatAvatar.innerHTML = currentChat.name.charAt(0).toUpperCase();
            chatTitle.textContent = currentChat.name;
            
            if (currentChat.type === 'user') {
                chatStatus.innerHTML = `<i class="fas fa-circle"></i> ${currentChat.status}`;
                statusDot.className = `chat-status-dot ${currentChat.status}`;
            } else {
                chatStatus.innerHTML = `<i class="fas fa-users"></i> Group chat`;
                statusDot.className = 'chat-status-dot';
            }
        }
        
        // Load messages
        function loadMessages() {
            if (!currentChat) return;
            
            const container = document.getElementById('messagesContainer');
            container.innerHTML = '<div class="loading"><i class="fas fa-spinner fa-spin"></i> Loading messages...</div>';
            
            const params = currentChat.type === 'user' ? 
                `receiverId=${currentChat.id}` : `groupId=${currentChat.id}`;
            
            fetch(`chat?action=getMessages&${params}`)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }
                return response.json();
            })
            .then(data => {
                messages = Array.isArray(data) ? data : [];
                lastMessageCount = messages.length;
                renderMessages();
                scrollToBottom();
            })
            .catch(error => {
                console.error('Error loading messages:', error);
                container.innerHTML = `<div class="error"><i class="fas fa-exclamation-triangle"></i> Failed to load messages<br><small>${error.message}</small></div>`;
            });
        }
        
        // Render messages
        function renderMessages() {
            const container = document.getElementById('messagesContainer');
            
            if (!Array.isArray(messages) || messages.length === 0) {
                container.innerHTML = `
                    <div class="welcome-message">
                        <div class="welcome-icon">
                            <i class="fas fa-comment-dots"></i>
                        </div>
                        <h2>Start the conversation</h2>
                        <p>Send a message to ${currentChat.name} to begin chatting!</p>
                    </div>
                `;
                return;
            }
            
            let html = '';
            let lastDate = null;
            
            messages.forEach((message, index) => {
                if (!message || typeof message !== 'object') return;
                
                const isCurrentUser = message.senderId === currentUser.id;
                const messageTime = message.sentAt ? new Date(message.sentAt) : new Date();
                const messageDate = messageTime.toLocaleDateString();
                const messageTimeStr = messageTime.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                
                // Add date separator
                if (lastDate !== messageDate) {
                    html += `<div class="message-date">${messageDate}</div>`;
                    lastDate = messageDate;
                }
                
                const senderInitial = message.senderName ? message.senderName.charAt(0).toUpperCase() : '?';
                const messageContent = message.content || '';
                
                html += `
                    <div class="message ${isCurrentUser ? 'sent' : 'received'}">
                        ${!isCurrentUser ? `<div class="message-avatar">${senderInitial}</div>` : ''}
                        <div class="message-content">
                            ${!isCurrentUser && currentChat.type === 'group' ? 
                              `<div class="message-sender">${escapeHtml(message.senderName || 'Unknown')}</div>` : ''}
                            ${renderMessageContent(message)}
                            <div class="message-time">${messageTimeStr}</div>
                        </div>
                        ${isCurrentUser ? `<div class="message-avatar">${currentUser.username.charAt(0).toUpperCase()}</div>` : ''}
                    </div>
                `;
            });
            
            container.innerHTML = html;
        }
        
        // Render message content based on type
        function renderMessageContent(message) {
            const content = escapeHtml(message.content || '');
            
            switch (message.type) {
                case 'FILE':
                case 'IMAGE':
                case 'VIDEO':
                case 'VOICE':
                    return `
                        <a href="download?fileId=${message.fileId || ''}" target="_blank" class="file-message">
                            <i class="fas fa-${getFileIcon(message.type)}"></i>
                            ${content}
                        </a>
                    `;
                default:
                    return `<div class="message-text">${content}</div>`;
            }
        }
        
        // Get file icon based on message type
        function getFileIcon(type) {
            switch (type) {
                case 'IMAGE': return 'image';
                case 'VIDEO': return 'video';
                case 'VOICE': return 'microphone';
                default: return 'file';
            }
        }
        
        // Send message
        function sendMessage() {
            if (!currentChat) {
                showNotification('Please select a chat first', 'warning');
                return;
            }
            
            const input = document.getElementById('messageInput');
            const message = input.value.trim();
            
            if (!message) return;
            
            // Disable send button temporarily
            const sendBtn = document.querySelector('.send-btn');
            sendBtn.disabled = true;
            
            const formData = new FormData();
            formData.append('action', 'sendMessage');
            formData.append('content', message);
            
            if (currentChat.type === 'user') {
                formData.append('receiverId', currentChat.id);
            } else {
                formData.append('groupId', currentChat.id);
            }
            
            fetch('chat', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    input.value = '';
                    loadMessages(); // Refresh messages
                } else {
                    showNotification('Failed to send message', 'error');
                }
            })
            .catch(error => {
                console.error('Error sending message:', error);
                showNotification('Failed to send message', 'error');
            })
            .finally(() => {
                sendBtn.disabled = false;
            });
        }
        
        // Handle key press in message input
        function handleKeyPress(event) {
            if (event.key === 'Enter' && !event.shiftKey) {
                event.preventDefault();
                sendMessage();
            }
        }
        
        // Toggle emoji picker
        function toggleEmojiPicker() {
            const picker = document.getElementById('emojiPicker');
            picker.classList.toggle('show');
        }
        
        // Insert emoji
        function insertEmoji(emoji) {
            const input = document.getElementById('messageInput');
            const cursorPos = input.selectionStart;
            const textBefore = input.value.substring(0, cursorPos);
            const textAfter = input.value.substring(cursorPos);
            
            input.value = textBefore + emoji + textAfter;
            input.focus();
            input.setSelectionRange(cursorPos + emoji.length, cursorPos + emoji.length);
            
            // Hide emoji picker
            document.getElementById('emojiPicker').classList.remove('show');
        }
        
        // Handle file upload
        function handleFileUpload() {
            if (!currentChat) {
                showNotification('Please select a chat first', 'warning');
                return;
            }
            
            const fileInput = document.getElementById('fileUpload');
            if (!fileInput.files || fileInput.files.length === 0) return;
            
            const file = fileInput.files[0];
            const maxSize = 10 * 1024 * 1024; // 10MB
            
            if (file.size > maxSize) {
                showNotification('File size must be less than 10MB', 'error');
                fileInput.value = '';
                return;
            }
            
            const formData = new FormData();
            formData.append('file', file);
            
            if (currentChat.type === 'user') {
                formData.append('receiverId', currentChat.id);
            } else {
                formData.append('groupId', currentChat.id);
            }
            
            // Show upload progress
            showNotification('Uploading file...', 'info');
            
            fetch('upload', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showNotification('File uploaded successfully', 'success');
                    loadMessages(); // Refresh messages
                } else {
                    showNotification(data.error || 'Failed to upload file', 'error');
                }
            })
            .catch(error => {
                console.error('Error uploading file:', error);
                showNotification('Failed to upload file', 'error');
            })
            .finally(() => {
                fileInput.value = '';
            });
        }
        
        // Toggle new group form
        function toggleNewGroupForm() {
            const form = document.getElementById('newGroupForm');
            form.classList.toggle('show');
            
            if (form.classList.contains('show')) {
                document.getElementById('groupName').focus();
            } else {
                // Clear form
                document.getElementById('groupName').value = '';
                document.getElementById('groupDescription').value = '';
            }
        }
        
        // Create group
        function createGroup() {
            const groupName = document.getElementById('groupName').value.trim();
            const description = document.getElementById('groupDescription').value.trim();
            
            if (!groupName) {
                showNotification('Please enter a group name', 'warning');
                document.getElementById('groupName').focus();
                return;
            }
            
            const formData = new FormData();
            formData.append('action', 'createGroup');
            formData.append('groupName', groupName);
            formData.append('description', description);
            
            fetch('chat', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showNotification('Group created successfully', 'success');
                    toggleNewGroupForm();
                    switchTab('groups'); // Switch to groups tab and reload
                } else {
                    showNotification(data.error || 'Failed to create group', 'error');
                }
            })
            .catch(error => {
                console.error('Error creating group:', error);
                showNotification('Failed to create group', 'error');
            });
        }
        
        // Toggle sidebar (mobile)
        function toggleSidebar() {
            document.getElementById('sidebar').classList.toggle('show');
        }
        
        // Start message refresh
        function startMessageRefresh() {
            // Clear existing interval
            if (refreshInterval) {
                clearInterval(refreshInterval);
            }
            
            // Refresh messages every 3 seconds if chat is active
            refreshInterval = setInterval(() => {
                if (currentChat) {
                    refreshMessages();
                }
            }, 3000);
        }
        
        // Refresh messages (silent update)
        function refreshMessages() {
            if (!currentChat) return;
            
            const params = currentChat.type === 'user' ? 
                `receiverId=${currentChat.id}` : `groupId=${currentChat.id}`;
            
            fetch(`chat?action=getMessages&${params}`)
            .then(response => response.json())
            .then(data => {
                const newMessages = Array.isArray(data) ? data : [];
                
                // Only update if there are new messages
                if (newMessages.length > lastMessageCount) {
                    messages = newMessages;
                    lastMessageCount = messages.length;
                    renderMessages();
                    scrollToBottom();
                }
            })
            .catch(error => {
                console.error('Error refreshing messages:', error);
            });
        }
        
        // Scroll to bottom of messages
        function scrollToBottom() {
            const container = document.getElementById('messagesContainer');
            setTimeout(() => {
                container.scrollTop = container.scrollHeight;
            }, 100);
        }
        
        // Show notification
        function showNotification(message, type = 'info') {
            // Remove existing notifications
            const existingNotifications = document.querySelectorAll('.notification');
            existingNotifications.forEach(notification => notification.remove());
            
            const notification = document.createElement('div');
            notification.className = `notification ${type}`;
            notification.textContent = message;
            
            document.body.appendChild(notification);
            
            // Auto remove after 3 seconds
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.remove();
                }
            }, 3000);
        }
        
        // Utility function to escape HTML
        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
        
        // Format time
        function formatTime(timestamp) {
            const date = new Date(timestamp);
            return date.toLocaleTimeString('en-US', { 
                hour: '2-digit', 
                minute: '2-digit',
                hour12: true 
            });
        }
        
        // Clean up on page unload
        window.addEventListener('beforeunload', function() {
            if (refreshInterval) {
                clearInterval(refreshInterval);
            }
        });
    </script>
</body>
</html>