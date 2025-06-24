<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ChatApp - Modern Messaging</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            height: 100vh;
            overflow: hidden;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        .chat-container {
            display: flex;
            height: 95vh;
            width: 95vw;
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            box-shadow: 0 0 30px rgba(0,0,0,0.1);
            border-radius: 10px;
            overflow: hidden;
        }
        
        .sidebar {
            width: 320px;
            background: #f8f9fa;
            border-right: 1px solid #e9ecef;
            display: flex;
            flex-direction: column;
        }
        
        .sidebar-header {
            padding: 20px;
            background: #343a40;
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
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
            background: #007bff;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
        }
        
        .user-details h3 {
            font-size: 16px;
            margin-bottom: 2px;
        }
        
        .user-status {
            font-size: 12px;
            color: #28a745;
        }
        
        .sidebar-tabs {
            display: flex;
            background: #e9ecef;
        }
        
        .tab-button {
            flex: 1;
            padding: 12px;
            border: none;
            background: transparent;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .tab-button.active {
            background: white;
            color: #007bff;
        }
        
        .tab-button:hover {
            background: #dee2e6;
        }
        
        .contacts-list {
            flex: 1;
            overflow-y: auto;
            padding: 10px 0;
        }
        
        .contact-item {
            padding: 15px 20px;
            cursor: pointer;
            transition: all 0.3s ease;
            border-left: 3px solid transparent;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .contact-item:hover {
            background: #e9ecef;
        }
        
        .contact-item.active {
            background: #e3f2fd;
            border-left-color: #007bff;
        }
        
        .contact-avatar {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: #6c757d;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
        }
        
        .contact-info h4 {
            font-size: 14px;
            margin-bottom: 4px;
            color: #343a40;
        }
        
        .contact-status {
            font-size: 12px;
            color: #6c757d;
        }
        
        .loading, .error, .no-items, .no-messages {
            padding: 20px;
            text-align: center;
            color: #6c757d;
            font-size: 14px;
        }
        
        .loading {
            color: #007bff;
        }
        
        .error {
            color: #dc3545;
        }
        
        .message-date {
            text-align: center;
            padding: 10px;
            font-size: 12px;
            color: #6c757d;
            background: #f8f9fa;
            border-radius: 15px;
            margin: 15px auto;
            width: fit-content;
        }
        
        .welcome-message {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            text-align: center;
            color: #6c757d;
        }
        
        .welcome-message h2 {
            color: #343a40;
            margin-bottom: 10px;
        }
        
        .main-chat {
            flex: 1;
            display: flex;
            flex-direction: column;
            background: white;
        }
        
        .chat-header {
            padding: 20px;
            background: #f8f9fa;
            border-bottom: 1px solid #e9ecef;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .chat-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .chat-avatar {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: #007bff;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
        }
        
        .chat-details h3 {
            font-size: 16px;
            margin-bottom: 2px;
            color: #343a40;
        }
        
        .chat-status {
            font-size: 12px;
            color: #28a745;
        }
        
        .chat-actions {
            display: flex;
            gap: 10px;
        }
        
        .action-btn {
            width: 40px;
            height: 40px;
            border: none;
            border-radius: 50%;
            background: #e9ecef;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }
        
        .action-btn:hover {
            background: #007bff;
            color: white;
        }
        
        .messages-container {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            background: #f8f9fa;
        }
        
        .message {
            margin-bottom: 15px;
            display: flex;
            align-items: flex-end;
            gap: 10px;
        }
        
        .message.sent {
            flex-direction: row-reverse;
        }
        
        .message-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #6c757d;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 12px;
            font-weight: bold;
        }
        
        .message-content {
            max-width: 70%;
            background: white;
            padding: 12px 16px;
            border-radius: 18px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.1);
            position: relative;
        }
        
        .message.sent .message-content {
            background: #007bff;
            color: white;
        }
        
        .message-text {
            margin-bottom: 4px;
            line-height: 1.4;
        }
        
        .message-time {
            font-size: 11px;
            color: #6c757d;
            text-align: right;
        }
        
        .message.sent .message-time {
            color: rgba(255,255,255,0.8);
        }
        
        .message-input-container {
            padding: 20px;
            background: white;
            border-top: 1px solid #e9ecef;
        }
        
        .message-input-wrapper {
            display: flex;
            align-items: center;
            gap: 10px;
            background: #f8f9fa;
            border-radius: 25px;
            padding: 8px 15px;
        }
        
        .emoji-btn, .file-btn {
            width: 35px;
            height: 35px;
            border: none;
            background: transparent;
            cursor: pointer;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }
        
        .emoji-btn:hover, .file-btn:hover {
            background: #e9ecef;
        }
        
        .message-input {
            flex: 1;
            border: none;
            background: transparent;
            padding: 8px 0;
            font-size: 14px;
            outline: none;
        }
        
        .send-btn {
            width: 35px;
            height: 35px;
            border: none;
            background: #007bff;
            color: white;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }
        
        .send-btn:hover {
            background: #0056b3;
            transform: scale(1.05);
        }
        
        .send-btn:disabled {
            background: #6c757d;
            cursor: not-allowed;
            transform: none;
        }
        
        .emoji-picker {
            position: absolute;
            bottom: 70px;
            left: 20px;
            background: white;
            border: 1px solid #e9ecef;
            border-radius: 10px;
            padding: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            display: none;
            z-index: 1000;
        }
        
        .emoji-picker.show {
            display: block;
        }
        
        .emoji-grid {
            display: grid;
            grid-template-columns: repeat(8, 1fr);
            gap: 5px;
        }
        
        .emoji-item {
            width: 30px;
            height: 30px;
            border: none;
            background: transparent;
            cursor: pointer;
            border-radius: 5px;
            font-size: 18px;
            transition: all 0.3s ease;
        }
        
        .emoji-item:hover {
            background: #f8f9fa;
            transform: scale(1.2);
        }
        
        .file-upload {
            display: none;
        }
        
        .typing-indicator {
            padding: 10px 20px;
            font-style: italic;
            color: #6c757d;
            font-size: 12px;
        }
        
        .new-group-form {
            padding: 20px;
            background: white;
            border-top: 1px solid #e9ecef;
            display: none;
        }
        
        .new-group-form.show {
            display: block;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            color: #343a40;
        }
        
        .form-group input, .form-group textarea {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #ced4da;
            border-radius: 5px;
            font-size: 14px;
        }
        
        .form-group textarea {
            resize: vertical;
            height: 60px;
        }
        
        .form-buttons {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s ease;
        }
        
        .btn-primary {
            background: #007bff;
            color: white;
        }
        
        .btn-primary:hover {
            background: #0056b3;
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #545b62;
        }
        
        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                position: absolute;
                z-index: 1000;
                transform: translateX(-100%);
                transition: transform 0.3s ease;
            }
            
            .sidebar.show {
                transform: translateX(0);
            }
            
            .main-chat {
                width: 100%;
            }
        }
        
        .loading {
            text-align: center;
            padding: 20px;
            color: #6c757d;
        }
        
        .error {
            background: #f8d7da;
            color: #721c24;
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
        }
        
        .success {
            background: #d4edda;
            color: #155724;
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="chat-container">
        <!-- Sidebar -->
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <div class="user-info">
                    <div class="user-avatar">
                        ${currentUser.username.charAt(0)}
                    </div>
                    <div class="user-details">
                        <h3>${currentUser.username}</h3>
                        <div class="user-status">Online</div>
                    </div>
                </div>
                <button class="action-btn" onclick="toggleNewGroupForm()">
                    <i class="fas fa-plus"></i>
                </button>
            </div>
            
            <div class="sidebar-tabs">
                <button id="chatsTabButton" class="tab-button active" onclick="switchTab('chats')">Chats</button>
                <button id="groupsTabButton" class="tab-button" onclick="switchTab('groups')">Groups</button>
            </div>
            
            <div id="chats-container" class="contacts-list">
                <!-- Contacts will be loaded here -->
                <div class="loading">Loading contacts...</div>
            </div>
            
            <div id="groups-container" class="contacts-list" style="display: none;">
                <!-- Groups will be loaded here -->
                <div class="loading">Loading groups...</div>
            </div>
            
            <div id="newGroupForm" class="new-group-form">
                <div class="form-group">
                    <label for="groupName">Group Name</label>
                    <input type="text" id="groupName" placeholder="Enter group name">
                </div>
                <div class="form-group">
                    <label for="groupDescription">Description</label>
                    <textarea id="groupDescription" placeholder="Enter group description"></textarea>
                </div>
                <div class="form-buttons">
                    <button class="btn btn-secondary" onclick="toggleNewGroupForm()">Cancel</button>
                    <button class="btn btn-primary" onclick="createGroup()">Create Group</button>
                </div>
            </div>
        </div>
        
        <!-- Main Chat Area -->
        <div class="main-chat">
            <div class="chat-header">
                <div class="chat-info">
                    <div class="chat-avatar">?</div>
                    <div class="chat-details">
                        <h3>Select a chat</h3>
                        <div class="chat-status">No chat selected</div>
                    </div>
                </div>
                <div class="chat-actions">
                    <button class="action-btn">
                        <i class="fas fa-phone"></i>
                    </button>
                    <button class="action-btn">
                        <i class="fas fa-video"></i>
                    </button>
                    <button class="action-btn">
                        <i class="fas fa-info-circle"></i>
                    </button>
                </div>
            </div>
            
            <div class="messages-container" id="messagesContainer">
                <div class="welcome-message">
                    <h2>Welcome to ChatApp</h2>
                    <p>Select a contact or group to start chatting</p>
                </div>
            </div>
            
            <div class="message-input-container">
                <div class="message-input-wrapper">
                    <button class="emoji-btn" onclick="toggleEmojiPicker()">
                        <i class="far fa-smile"></i>
                    </button>
                    <input type="text" id="messageInput" class="message-input" placeholder="Type a message..." onkeypress="handleKeyPress(event)">
                    <label for="fileUpload" class="file-btn">
                        <i class="fas fa-paperclip"></i>
                    </label>
                    <input type="file" id="fileUpload" class="file-upload" onchange="handleFileUpload()">
                    <button class="send-btn" onclick="sendMessage()">
                        <i class="fas fa-paper-plane"></i>
                    </button>
                </div>
                <div id="emojiPicker" class="emoji-picker">
                    <div class="emoji-grid">
                        <span class="emoji-item" onclick="insertEmoji('😀')">😀</span>
                        <span class="emoji-item" onclick="insertEmoji('😁')">😁</span>
                        <span class="emoji-item" onclick="insertEmoji('😂')">😂</span>
                        <span class="emoji-item" onclick="insertEmoji('🤣')">🤣</span>
                        <span class="emoji-item" onclick="insertEmoji('😃')">😃</span>
                        <span class="emoji-item" onclick="insertEmoji('😄')">😄</span>
                        <span class="emoji-item" onclick="insertEmoji('😅')">😅</span>
                        <span class="emoji-item" onclick="insertEmoji('😆')">😆</span>
                        <span class="emoji-item" onclick="insertEmoji('😉')">😉</span>
                        <span class="emoji-item" onclick="insertEmoji('😊')">😊</span>
                        <span class="emoji-item" onclick="insertEmoji('😋')">😋</span>
                        <span class="emoji-item" onclick="insertEmoji('😎')">😎</span>
                        <span class="emoji-item" onclick="insertEmoji('😍')">😍</span>
                        <span class="emoji-item" onclick="insertEmoji('😘')">😘</span>
                        <span class="emoji-item" onclick="insertEmoji('❤️')">❤️</span>
                        <span class="emoji-item" onclick="insertEmoji('👍')">👍</span>
                    </div>
                </div>
            </div>
            
            <div class="typing-indicator" id="typingIndicator"></div>
        </div>
    </div>

    <script>
        // Global variables
        /* 
         * The currentUser object is initialized with data from the server
         * JSP expressions are used to populate these values
         */
        let currentUser;
        
        // Using a function to initialize to avoid linting errors with JSP expressions
        function initCurrentUser() {
            currentUser = {
                id: Number('${currentUser != null ? currentUser.id : 0}'),
                username: '${currentUser != null ? currentUser.username : "Guest"}',
                fullName: '${currentUser != null ? currentUser.fullName : "Guest User"}'
            };
        }
        
        // Initialize the user immediately
        initCurrentUser();
        
        let currentChat = null;
        let currentTab = 'chats';
        let contacts = [];
        let groups = [];
        let messages = [];
        
        // Initialize the application
        document.addEventListener('DOMContentLoaded', function() {
            // Make sure UI elements are visible
            document.getElementById('chats-container').style.display = 'block';
            document.getElementById('groups-container').style.display = 'none';
            
            // Set active tab
            document.getElementById('chatsTabButton').classList.add('active');
            
            // Log current user for debugging
            console.log('Current user initialized:', currentUser);
            
            // Load data
            loadContacts();
            
            // Start refresh timer for messages
            setInterval(refreshMessages, 3000); // Refresh messages every 3 seconds
        });
        
        // Tab switching
        function switchTab(tab) {
            currentTab = tab;
            document.querySelectorAll('.tab-button').forEach(btn => btn.classList.remove('active'));
            document.getElementById(tab + 'TabButton').classList.add('active');
            
            if (tab === 'chats') {
                loadContacts();
                document.getElementById('chats-container').style.display = 'block';
                document.getElementById('groups-container').style.display = 'none';
            } else if (tab === 'groups') {
                loadGroups();
                document.getElementById('chats-container').style.display = 'none';
                document.getElementById('groups-container').style.display = 'block';
            }
        }
        
        // Load contacts
        function loadContacts() {
            document.getElementById('chats-container').innerHTML = '<div class="loading">Loading contacts...</div>';
            
            fetch('chat?action=getUsers')
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.statusText);
                }
                return response.json();
            })
            .then(data => {
                contacts = data;
                renderContacts();
            })
            .catch(error => {
                console.error('Error loading contacts:', error);
                document.getElementById('chats-container').innerHTML = '<div class="error">Failed to load contacts: ' + error.message + '</div>';
            });
        }
        
        // Load groups
        function loadGroups() {
            fetch('chat?action=getGroups')
            .then(response => response.json())
            .then(data => {
                groups = data;
                renderGroups();
            })
            .catch(error => {
                console.error('Error loading groups:', error);
                document.getElementById('groups-container').innerHTML = '<div class="error">Failed to load groups</div>';
            });
        }
        
        // Render contacts
        function renderContacts() {
            const container = document.getElementById('chats-container');
            
            // Check if contacts is undefined or not an array
            if (!Array.isArray(contacts) || contacts.length === 0) {
                container.innerHTML = '<div class="no-items">No contacts available</div>';
                return;
            }
            
            let html = '';
            contacts.forEach(contact => {
                if (contact.id === currentUser.id) return; // Skip current user
                
                const displayName = contact.fullName || contact.username || 'Unknown';
                const status = contact.status ? contact.status.toLowerCase() : 'offline';
                const firstLetter = (displayName.charAt(0) || '?').toUpperCase();
                
                html += `
                    <div class="contact-item ${currentChat && currentChat.type === 'user' && currentChat.id === contact.id ? 'active' : ''}" 
                         onclick="selectChat('user', ${contact.id}, '${contact.username}')">
                        <div class="contact-avatar">${firstLetter}</div>
                        <div class="contact-info">
                            <h4>${displayName}</h4>
                            <div class="contact-status">${status}</div>
                        </div>
                    </div>
                `;
            });
            
            container.innerHTML = html || '<div class="no-items">No contacts available</div>';
        }
        
        // Render groups
        function renderGroups() {
            const container = document.getElementById('groups-container');
            if (groups.length === 0) {
                container.innerHTML = '<div class="no-items">No groups available</div>';
                return;
            }
            
            let html = '';
            groups.forEach(group => {
                html += `
                    <div class="contact-item ${currentChat && currentChat.type === 'group' && currentChat.id === group.id ? 'active' : ''}" 
                         onclick="selectChat('group', ${group.id}, '${group.name}')">
                        <div class="contact-avatar">${group.name.charAt(0).toUpperCase()}</div>
                        <div class="contact-info">
                            <h4>${group.name}</h4>
                            <div class="contact-status">${group.members ? group.members.length : 0} members</div>
                        </div>
                    </div>
                `;
            });
            
            container.innerHTML = html;
        }
        
        // Select chat
        function selectChat(type, id, name) {
            currentChat = {
                type: type,
                id: id,
                name: name
            };
            
            // Update UI to show active chat
            if (type === 'user') {
                renderContacts();
            } else {
                renderGroups();
            }
            
            // Update chat header
            const chatHeader = document.querySelector('.chat-header');
            chatHeader.querySelector('.chat-avatar').textContent = name.charAt(0).toUpperCase();
            chatHeader.querySelector('.chat-details h3').textContent = name;
            chatHeader.querySelector('.chat-status').textContent = type === 'user' ? 'Online' : 'Group';
            
            // Clear welcome message and show the chat area
            document.getElementById('messagesContainer').innerHTML = '<div class="loading">Loading messages...</div>';
            
            // Load messages
            loadMessages();
        }
        
        // Load messages
        function loadMessages() {
            if (!currentChat) return;
            
            const params = currentChat.type === 'user' ? 
                `receiverId=${currentChat.id}` : `groupId=${currentChat.id}`;
            
            fetch(`chat?action=getMessages&${params}`)
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.statusText);
                }
                return response.json();
            })
            .then(data => {
                messages = Array.isArray(data) ? data : [];
                renderMessages();
                
                // Scroll to the bottom of messages
                const container = document.getElementById('messagesContainer');
                container.scrollTop = container.scrollHeight;
            })
            .catch(error => {
                console.error('Error loading messages:', error);
                document.getElementById('messagesContainer').innerHTML = '<div class="error">Failed to load messages: ' + error.message + '</div>';
            });
        }
        
        // Render messages
        function renderMessages() {
            const container = document.getElementById('messagesContainer');
            
            if (!Array.isArray(messages) || messages.length === 0) {
                container.innerHTML = '<div class="no-messages">No messages yet. Say hi!</div>';
                return;
            }
            
            let html = '';
            let lastDate = null;
            
            messages.forEach(message => {
                if (!message || typeof message !== 'object') return;
                
                const isCurrentUser = message.senderId === currentUser.id;
                const messageTime = message.sentAt ? new Date(message.sentAt) : new Date();
                const messageDate = messageTime.toLocaleDateString();
                const messageTimeStr = messageTime.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                
                // Add date separator if this is a new date
                if (lastDate !== messageDate) {
                    html += `<div class="message-date">${messageDate}</div>`;
                    lastDate = messageDate;
                }
                
                const senderInitial = message.senderName ? message.senderName.charAt(0).toUpperCase() : '?';
                const messageContent = message.content || '';
                const isSafe = (str) => String(str || '').replace(/</g, '&lt;').replace(/>/g, '&gt;');
                
                html += `
                    <div class="message ${isCurrentUser ? 'sent' : 'received'}">
                        <div class="message-avatar">${senderInitial}</div>
                        <div class="message-content">
                            ${!isCurrentUser && currentChat.type === 'group' ? 
                              `<div class="message-sender">${isSafe(message.senderName)}</div>` : ''}
                            ${message.type === 'FILE' ? 
                              `<a href="file-download?id=${message.fileId}" target="_blank" class="file-message">
                                <i class="fas fa-file"></i> ${isSafe(messageContent)}
                               </a>` 
                              : `<div class="message-text">${isSafe(messageContent)}</div>`}
                            <div class="message-time">${messageTimeStr}</div>
                        </div>
                    </div>
                `;
            });
            
            container.innerHTML = html;
            container.scrollTop = container.scrollHeight;
        }
        
        // Send message
        function sendMessage() {
            if (!currentChat) return;
            
            const input = document.getElementById('messageInput');
            const message = input.value.trim();
            
            if (!message) return;
            
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
                    loadMessages(); // Refresh messages to show the sent one
                } else {
                    alert('Failed to send message');
                }
            })
            .catch(error => {
                console.error('Error sending message:', error);
                alert('Failed to send message');
            });
        }
        
        // Handle key press
        function handleKeyPress(event) {
            if (event.keyCode === 13) { // Enter key
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
            input.value += emoji;
            input.focus();
            // Hide emoji picker after selection
            document.getElementById('emojiPicker').classList.remove('show');
        }
        
        // Handle file upload
        function handleFileUpload() {
            if (!currentChat) {
                alert('Please select a chat first');
                return;
            }
            
            const fileInput = document.getElementById('fileUpload');
            if (!fileInput.files || fileInput.files.length === 0) return;
            
            const file = fileInput.files[0];
            const formData = new FormData();
            formData.append('file', file);
            
            if (currentChat.type === 'user') {
                formData.append('receiverId', currentChat.id);
            } else {
                formData.append('groupId', currentChat.id);
            }
            
            fetch('file-upload', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    loadMessages(); // Refresh messages to show the sent file
                } else {
                    alert('Failed to upload file');
                }
            })
            .catch(error => {
                console.error('Error uploading file:', error);
                alert('Failed to upload file');
            });
            
            // Reset file input
            fileInput.value = '';
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
                alert('Please enter a group name');
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
                    toggleNewGroupForm();
                    switchTab('groups'); // Switch to groups tab and reload
                } else {
                    alert('Failed to create group');
                }
            })
            .catch(error => {
                console.error('Error creating group:', error);
                alert('Failed to create group');
            });
        }
        
        // Refresh messages periodically
        function refreshMessages() {
            if (currentChat) {
                loadMessages();
            }
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
        
        // Close emoji picker when clicking outside
        document.addEventListener('click', function(event) {
            const emojiPicker = document.getElementById('emojiPicker');
            const emojiBtn = document.querySelector('.emoji-btn');
            
            if (!emojiPicker.contains(event.target) && !emojiBtn.contains(event.target)) {
                emojiPicker.classList.remove('show');
            }
        });
    </script>
</body>
</html>