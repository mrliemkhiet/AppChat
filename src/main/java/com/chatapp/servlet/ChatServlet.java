package com.chatapp.servlet;

import com.chatapp.entity.Group;
import com.chatapp.entity.Message;
import com.chatapp.entity.User;
import com.chatapp.util.HibernateUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/chat")
public class ChatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger(ChatServlet.class.getName());
    private ObjectMapper objectMapper;
    
    @Override
    public void init() throws ServletException {
        super.init();
        // Configure ObjectMapper with Java 8 Date/Time support
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new com.fasterxml.jackson.datatype.jsr310.JavaTimeModule());
        objectMapper.disable(com.fasterxml.jackson.databind.SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        logger.info("ChatServlet initialized successfully");
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession httpSession = request.getSession();
        User currentUser = (User) httpSession.getAttribute("user");
        
        if (currentUser == null) {
            // Create or get demo user
            currentUser = getOrCreateDemoUser();
            httpSession.setAttribute("user", currentUser);
            logger.info("Demo user created/retrieved: " + currentUser.getUsername());
        }
        
        String action = request.getParameter("action");
        logger.info("GET request - Action: " + action + ", User: " + currentUser.getUsername());
        
        if ("getMessages".equals(action)) {
            handleGetMessages(request, response, currentUser);
        } else if ("getGroups".equals(action)) {
            handleGetGroups(request, response, currentUser);
        } else if ("getUsers".equals(action)) {
            handleGetUsers(request, response, currentUser);
        } else {
            // Forward to chat JSP page
            request.setAttribute("currentUser", currentUser);
            request.getRequestDispatcher("/WEB-INF/views/chat.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession httpSession = request.getSession();
        User currentUser = (User) httpSession.getAttribute("user");
        
        if (currentUser == null) {
            sendJsonError(response, "User not authenticated", HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        String action = request.getParameter("action");
        logger.info("POST request - Action: " + action + ", User: " + currentUser.getUsername());
        
        if ("sendMessage".equals(action)) {
            handleSendMessage(request, response, currentUser);
        } else if ("createGroup".equals(action)) {
            handleCreateGroup(request, response, currentUser);
        } else if ("login".equals(action)) {
            handleLogin(request, response);
        } else {
            sendJsonError(response, "Invalid action", HttpServletResponse.SC_BAD_REQUEST);
        }
    }
    
    private void handleGetMessages(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws IOException {
        
        String groupIdStr = request.getParameter("groupId");
        String receiverIdStr = request.getParameter("receiverId");
        
        Session session = null;
        Transaction tx = null;
        
        try {
            session = HibernateUtil.getSessionFactory().getCurrentSession();
            tx = session.beginTransaction();
            
            List<Message> messages;
            
            if (groupIdStr != null && !groupIdStr.isEmpty()) {
                // Get group messages
                Long groupId = Long.parseLong(groupIdStr);
                Query<Message> query = session.createQuery(
                    "SELECT m FROM Message m " +
                    "LEFT JOIN FETCH m.sender " +
                    "LEFT JOIN FETCH m.group " +
                    "LEFT JOIN FETCH m.file " +
                    "WHERE m.group.id = :groupId " +
                    "ORDER BY m.sentAt ASC", Message.class);
                query.setParameter("groupId", groupId);
                messages = query.getResultList();
                logger.info("Retrieved " + messages.size() + " group messages for group " + groupId);
            } else if (receiverIdStr != null && !receiverIdStr.isEmpty()) {
                // Get private messages
                Long receiverId = Long.parseLong(receiverIdStr);
                Query<Message> query = session.createQuery(
                    "SELECT m FROM Message m " +
                    "LEFT JOIN FETCH m.sender " +
                    "LEFT JOIN FETCH m.receiver " +
                    "LEFT JOIN FETCH m.file " +
                    "WHERE (m.sender.id = :senderId AND m.receiver.id = :receiverId) " +
                    "OR (m.sender.id = :receiverId AND m.receiver.id = :senderId) " +
                    "ORDER BY m.sentAt ASC", Message.class);
                query.setParameter("senderId", currentUser.getId());
                query.setParameter("receiverId", receiverId);
                messages = query.getResultList();
                logger.info("Retrieved " + messages.size() + " private messages between " + currentUser.getId() + " and " + receiverId);
            } else {
                messages = List.of();
                logger.warning("No groupId or receiverId provided for getMessages");
            }
            
            tx.commit();
            
            // Convert messages to JSON-friendly format
            List<Map<String, Object>> messageList = new java.util.ArrayList<>();
            for (Message message : messages) {
                Map<String, Object> messageMap = new HashMap<>();
                messageMap.put("id", message.getId());
                messageMap.put("content", message.getContent());
                messageMap.put("type", message.getType().toString());
                messageMap.put("senderId", message.getSender().getId());
                messageMap.put("senderName", message.getSender().getFullName() != null ? 
                    message.getSender().getFullName() : message.getSender().getUsername());
                messageMap.put("sentAt", message.getSentAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
                messageMap.put("isRead", message.isRead());
                
                if (message.getReceiver() != null) {
                    messageMap.put("receiverId", message.getReceiver().getId());
                    messageMap.put("receiverName", message.getReceiver().getFullName() != null ? 
                        message.getReceiver().getFullName() : message.getReceiver().getUsername());
                }
                
                if (message.getGroup() != null) {
                    messageMap.put("groupId", message.getGroup().getId());
                    messageMap.put("groupName", message.getGroup().getName());
                }
                
                if (message.getFile() != null) {
                    messageMap.put("fileId", message.getFile().getId());
                    messageMap.put("fileName", message.getFile().getOriginalName());
                }
                
                messageList.add(messageMap);
            }
            
            sendJsonResponse(response, messageList);
            
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            logger.log(Level.SEVERE, "Error getting messages", e);
            sendJsonError(response, "Error loading messages: " + e.getMessage(), HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private void handleSendMessage(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws IOException {
        
        String content = request.getParameter("content");
        String groupIdStr = request.getParameter("groupId");
        String receiverIdStr = request.getParameter("receiverId");
        String messageType = request.getParameter("type");
        
        if (content == null || content.trim().isEmpty()) {
            sendJsonError(response, "Message content is required", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        Session session = null;
        Transaction tx = null;
        
        try {
            session = HibernateUtil.getSessionFactory().getCurrentSession();
            tx = session.beginTransaction();
            
            Message message = new Message();
            message.setContent(content.trim());
            message.setSender(currentUser);
            message.setSentAt(LocalDateTime.now());
            
            // Set message type
            if (messageType != null) {
                try {
                    message.setType(Message.MessageType.valueOf(messageType.toUpperCase()));
                } catch (IllegalArgumentException e) {
                    message.setType(Message.MessageType.TEXT);
                }
            } else {
                message.setType(Message.MessageType.TEXT);
            }
            
            // Set destination (group or private)
            if (groupIdStr != null && !groupIdStr.isEmpty()) {
                Long groupId = Long.parseLong(groupIdStr);
                Group group = session.get(Group.class, groupId);
                if (group != null) {
                    message.setGroup(group);
                    logger.info("Sending message to group: " + group.getName());
                } else {
                    sendJsonError(response, "Group not found", HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
            } else if (receiverIdStr != null && !receiverIdStr.isEmpty()) {
                Long receiverId = Long.parseLong(receiverIdStr);
                User receiver = session.get(User.class, receiverId);
                if (receiver != null) {
                    message.setReceiver(receiver);
                    logger.info("Sending private message to: " + receiver.getUsername());
                } else {
                    sendJsonError(response, "Receiver not found", HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
            } else {
                sendJsonError(response, "Either groupId or receiverId is required", HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            
            session.save(message);
            tx.commit();
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("messageId", message.getId());
            result.put("timestamp", message.getSentAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            
            sendJsonResponse(response, result);
            logger.info("Message sent successfully: " + message.getId());
            
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            logger.log(Level.SEVERE, "Error sending message", e);
            sendJsonError(response, "Error sending message: " + e.getMessage(), HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private void handleGetGroups(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws IOException {
        
        Session session = null;
        Transaction tx = null;
        
        try {
            session = HibernateUtil.getSessionFactory().getCurrentSession();
            tx = session.beginTransaction();
            
            // Get user's groups with member count
            Query<Object[]> query = session.createQuery(
                "SELECT g, SIZE(g.members) FROM Group g " +
                "JOIN g.members m " +
                "WHERE m.id = :userId " +
                "ORDER BY g.name", Object[].class);
            query.setParameter("userId", currentUser.getId());
            List<Object[]> results = query.getResultList();
            
            List<Map<String, Object>> groupsList = new java.util.ArrayList<>();
            for (Object[] result : results) {
                Group group = (Group) result[0];
                Long memberCount = (Long) result[1];
                
                Map<String, Object> groupMap = new HashMap<>();
                groupMap.put("id", group.getId());
                groupMap.put("name", group.getName());
                groupMap.put("description", group.getDescription());
                groupMap.put("memberCount", memberCount.intValue());
                groupMap.put("createdBy", group.getCreatedBy().getUsername());
                groupMap.put("createdAt", group.getCreatedAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                groupsList.add(groupMap);
            }
            
            tx.commit();
            
            sendJsonResponse(response, groupsList);
            logger.info("Retrieved " + groupsList.size() + " groups for user " + currentUser.getUsername());
            
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            logger.log(Level.SEVERE, "Error loading groups", e);
            sendJsonError(response, "Error loading groups: " + e.getMessage(), HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private void handleGetUsers(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws IOException {
        
        Session session = null;
        Transaction tx = null;
        
        try {
            session = HibernateUtil.getSessionFactory().getCurrentSession();
            tx = session.beginTransaction();
            
            // Get all users except current user
            Query<User> query = session.createQuery(
                "FROM User u WHERE u.id != :currentUserId ORDER BY u.fullName, u.username", User.class);
            query.setParameter("currentUserId", currentUser.getId());
            List<User> users = query.getResultList();
            
            List<Map<String, Object>> usersList = new java.util.ArrayList<>();
            for (User user : users) {
                Map<String, Object> userMap = new HashMap<>();
                userMap.put("id", user.getId());
                userMap.put("username", user.getUsername());
                userMap.put("fullName", user.getFullName());
                userMap.put("status", user.getStatus().toString());
                userMap.put("lastSeen", user.getLastSeen() != null ? 
                    user.getLastSeen().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) : null);
                usersList.add(userMap);
            }
            
            tx.commit();
            
            sendJsonResponse(response, usersList);
            logger.info("Retrieved " + usersList.size() + " users for " + currentUser.getUsername());
            
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            logger.log(Level.SEVERE, "Error loading users", e);
            sendJsonError(response, "Error loading users: " + e.getMessage(), HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private void handleCreateGroup(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws IOException {
        
        String groupName = request.getParameter("groupName");
        String description = request.getParameter("description");
        
        if (groupName == null || groupName.trim().isEmpty()) {
            sendJsonError(response, "Group name is required", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        Session session = null;
        Transaction tx = null;
        
        try {
            session = HibernateUtil.getSessionFactory().getCurrentSession();
            tx = session.beginTransaction();
            
            // Create new group
            Group group = new Group();
            group.setName(groupName.trim());
            group.setDescription(description != null ? description.trim() : null);
            group.setCreatedBy(currentUser);
            group.setCreatedAt(LocalDateTime.now());
            group.setUpdatedAt(LocalDateTime.now());
            
            // Add current user as a member
            group.getMembers().add(currentUser);
            
            session.save(group);
            tx.commit();
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("groupId", group.getId());
            result.put("groupName", group.getName());
            
            sendJsonResponse(response, result);
            logger.info("Group created successfully: " + group.getName() + " by " + currentUser.getUsername());
            
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            logger.log(Level.SEVERE, "Error creating group", e);
            sendJsonError(response, "Error creating group: " + e.getMessage(), HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private void handleLogin(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        if (username == null || username.isEmpty() || password == null || password.isEmpty()) {
            sendJsonError(response, "Username and password are required", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        Session session = null;
        Transaction tx = null;
        
        try {
            session = HibernateUtil.getSessionFactory().getCurrentSession();
            tx = session.beginTransaction();
            
            Query<User> query = session.createQuery(
                "FROM User u WHERE u.username = :username AND u.password = :password", User.class);
            query.setParameter("username", username);
            query.setParameter("password", password); // Note: In production, use proper password hashing
            User user = query.uniqueResult();
            
            if (user == null) {
                tx.rollback();
                sendJsonError(response, "Invalid username or password", HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }
            
            // Update user status
            user.setStatus(User.UserStatus.ONLINE);
            user.setLastSeen(LocalDateTime.now());
            user.setUpdatedAt(LocalDateTime.now());
            session.update(user);
            tx.commit();
            
            // Set session
            HttpSession httpSession = request.getSession();
            httpSession.setAttribute("user", user);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("userId", user.getId());
            result.put("username", user.getUsername());
            result.put("fullName", user.getFullName());
            
            sendJsonResponse(response, result);
            logger.info("User logged in successfully: " + user.getUsername());
            
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            logger.log(Level.SEVERE, "Error during login", e);
            sendJsonError(response, "Error during login: " + e.getMessage(), HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private User getOrCreateDemoUser() {
        Session session = null;
        Transaction tx = null;
        
        try {
            session = HibernateUtil.getSessionFactory().getCurrentSession();
            tx = session.beginTransaction();
            
            // Check if demo user exists
            Query<User> query = session.createQuery(
                "FROM User u WHERE u.username = :username", User.class);
            query.setParameter("username", "demo");
            User demoUser = query.uniqueResult();
            
            if (demoUser == null) {
                // Create demo user and sample data
                demoUser = createSampleData(session);
                logger.info("Created demo user and sample data");
            } else {
                // Update existing demo user status
                demoUser.setStatus(User.UserStatus.ONLINE);
                demoUser.setLastSeen(LocalDateTime.now());
                demoUser.setUpdatedAt(LocalDateTime.now());
                session.update(demoUser);
                logger.info("Updated existing demo user status");
            }
            
            tx.commit();
            return demoUser;
            
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            logger.log(Level.SEVERE, "Error creating/getting demo user", e);
            
            // Create a basic fallback user object
            User fallbackUser = new User();
            fallbackUser.setId(1L);
            fallbackUser.setUsername("demo");
            fallbackUser.setFullName("Demo User");
            fallbackUser.setEmail("demo@zola.com");
            fallbackUser.setStatus(User.UserStatus.ONLINE);
            return fallbackUser;
        }
    }
    
    private User createSampleData(Session session) {
        // Create demo user
        User demoUser = new User("demo", "demo123", "demo@zola.com", "Demo User");
        demoUser.setStatus(User.UserStatus.ONLINE);
        demoUser.setLastSeen(LocalDateTime.now());
        session.save(demoUser);
        
        // Create additional sample users
        User alice = new User("alice", "alice123", "alice@zola.com", "Alice Johnson");
        alice.setStatus(User.UserStatus.ONLINE);
        alice.setLastSeen(LocalDateTime.now().minusMinutes(5));
        session.save(alice);
        
        User bob = new User("bob", "bob123", "bob@zola.com", "Bob Smith");
        bob.setStatus(User.UserStatus.AWAY);
        bob.setLastSeen(LocalDateTime.now().minusMinutes(15));
        session.save(bob);
        
        User carol = new User("carol", "carol123", "carol@zola.com", "Carol Williams");
        carol.setStatus(User.UserStatus.ONLINE);
        carol.setLastSeen(LocalDateTime.now().minusMinutes(2));
        session.save(carol);
        
        User david = new User("david", "david123", "david@zola.com", "David Brown");
        david.setStatus(User.UserStatus.BUSY);
        david.setLastSeen(LocalDateTime.now().minusMinutes(30));
        session.save(david);
        
        // Create sample groups
        Group generalGroup = new Group();
        generalGroup.setName("General Chat");
        generalGroup.setDescription("Welcome to the general discussion group!");
        generalGroup.setCreatedBy(demoUser);
        generalGroup.setCreatedAt(LocalDateTime.now().minusDays(1));
        generalGroup.setUpdatedAt(LocalDateTime.now().minusDays(1));
        generalGroup.getMembers().add(demoUser);
        generalGroup.getMembers().add(alice);
        generalGroup.getMembers().add(bob);
        generalGroup.getMembers().add(carol);
        session.save(generalGroup);
        
        Group projectGroup = new Group();
        projectGroup.setName("Project Team");
        projectGroup.setDescription("Team collaboration and project updates");
        projectGroup.setCreatedBy(alice);
        projectGroup.setCreatedAt(LocalDateTime.now().minusHours(12));
        projectGroup.setUpdatedAt(LocalDateTime.now().minusHours(12));
        projectGroup.getMembers().add(demoUser);
        projectGroup.getMembers().add(alice);
        projectGroup.getMembers().add(david);
        session.save(projectGroup);
        
        Group friendsGroup = new Group();
        friendsGroup.setName("Friends Circle");
        friendsGroup.setDescription("Casual chats and fun conversations");
        friendsGroup.setCreatedBy(carol);
        friendsGroup.setCreatedAt(LocalDateTime.now().minusHours(6));
        friendsGroup.setUpdatedAt(LocalDateTime.now().minusHours(6));
        friendsGroup.getMembers().add(demoUser);
        friendsGroup.getMembers().add(carol);
        friendsGroup.getMembers().add(bob);
        session.save(friendsGroup);
        
        // Create sample messages
        createSampleMessages(session, demoUser, alice, bob, carol, david, generalGroup, projectGroup, friendsGroup);
        
        return demoUser;
    }
    
    private void createSampleMessages(Session session, User demo, User alice, User bob, User carol, User david,
                                    Group generalGroup, Group projectGroup, Group friendsGroup) {
        
        // Group messages for General Chat
        Message msg1 = new Message();
        msg1.setSender(alice);
        msg1.setGroup(generalGroup);
        msg1.setContent("Hello everyone! Welcome to our general chat group! 👋");
        msg1.setType(Message.MessageType.TEXT);
        msg1.setSentAt(LocalDateTime.now().minusHours(2));
        session.save(msg1);
        
        Message msg2 = new Message();
        msg2.setSender(bob);
        msg2.setGroup(generalGroup);
        msg2.setContent("Thanks Alice! Great to be here 😊");
        msg2.setType(Message.MessageType.TEXT);
        msg2.setSentAt(LocalDateTime.now().minusHours(2).plusMinutes(5));
        session.save(msg2);
        
        Message msg3 = new Message();
        msg3.setSender(carol);
        msg3.setGroup(generalGroup);
        msg3.setContent("This is going to be fun! Looking forward to chatting with everyone 🎉");
        msg3.setType(Message.MessageType.TEXT);
        msg3.setSentAt(LocalDateTime.now().minusHours(2).plusMinutes(10));
        session.save(msg3);
        
        Message msg4 = new Message();
        msg4.setSender(demo);
        msg4.setGroup(generalGroup);
        msg4.setContent("Welcome to Zola! Feel free to share anything here 💬");
        msg4.setType(Message.MessageType.TEXT);
        msg4.setSentAt(LocalDateTime.now().minusHours(1).plusMinutes(30));
        session.save(msg4);
        
        // Project group messages
        Message msg5 = new Message();
        msg5.setSender(alice);
        msg5.setGroup(projectGroup);
        msg5.setContent("Let's discuss our project timeline. What do you think about the current milestones?");
        msg5.setType(Message.MessageType.TEXT);
        msg5.setSentAt(LocalDateTime.now().minusHours(1));
        session.save(msg5);
        
        Message msg6 = new Message();
        msg6.setSender(david);
        msg6.setGroup(projectGroup);
        msg6.setContent("I think we're on track. The design phase is almost complete 📊");
        msg6.setType(Message.MessageType.TEXT);
        msg6.setSentAt(LocalDateTime.now().minusMinutes(45));
        session.save(msg6);
        
        // Friends group messages
        Message msg7 = new Message();
        msg7.setSender(carol);
        msg7.setGroup(friendsGroup);
        msg7.setContent("Anyone up for a movie night this weekend? 🍿🎬");
        msg7.setType(Message.MessageType.TEXT);
        msg7.setSentAt(LocalDateTime.now().minusMinutes(30));
        session.save(msg7);
        
        Message msg8 = new Message();
        msg8.setSender(bob);
        msg8.setGroup(friendsGroup);
        msg8.setContent("Count me in! What movie are we watching?");
        msg8.setType(Message.MessageType.TEXT);
        msg8.setSentAt(LocalDateTime.now().minusMinutes(25));
        session.save(msg8);
        
        // Private messages between demo and alice
        Message msg9 = new Message();
        msg9.setSender(alice);
        msg9.setReceiver(demo);
        msg9.setContent("Hey Demo! How are you liking the new chat app?");
        msg9.setType(Message.MessageType.TEXT);
        msg9.setSentAt(LocalDateTime.now().minusMinutes(20));
        session.save(msg9);
        
        Message msg10 = new Message();
        msg10.setSender(demo);
        msg10.setReceiver(alice);
        msg10.setContent("It's amazing! The interface is so clean and user-friendly 👍");
        msg10.setType(Message.MessageType.TEXT);
        msg10.setSentAt(LocalDateTime.now().minusMinutes(18));
        session.save(msg10);
        
        Message msg11 = new Message();
        msg11.setSender(alice);
        msg11.setReceiver(demo);
        msg11.setContent("I'm glad you like it! Let me know if you need any help with the features");
        msg11.setType(Message.MessageType.TEXT);
        msg11.setSentAt(LocalDateTime.now().minusMinutes(15));
        session.save(msg11);
        
        // Private messages between demo and carol
        Message msg12 = new Message();
        msg12.setSender(carol);
        msg12.setReceiver(demo);
        msg12.setContent("Hi there! Welcome to our chat community! 🌟");
        msg12.setType(Message.MessageType.TEXT);
        msg12.setSentAt(LocalDateTime.now().minusMinutes(10));
        session.save(msg12);
        
        Message msg13 = new Message();
        msg13.setSender(demo);
        msg13.setReceiver(carol);
        msg13.setContent("Thank you Carol! Everyone here seems so friendly 😊");
        msg13.setType(Message.MessageType.TEXT);
        msg13.setSentAt(LocalDateTime.now().minusMinutes(8));
        session.save(msg13);
    }
    
    private void sendJsonResponse(HttpServletResponse response, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try (PrintWriter out = response.getWriter()) {
            out.print(objectMapper.writeValueAsString(data));
            out.flush();
        }
    }
    
    private void sendJsonError(HttpServletResponse response, String message, int statusCode) throws IOException {
        response.setStatus(statusCode);
        
        Map<String, Object> error = new HashMap<>();
        error.put("success", false);
        error.put("error", message);
        
        sendJsonResponse(response, error);
    }
}