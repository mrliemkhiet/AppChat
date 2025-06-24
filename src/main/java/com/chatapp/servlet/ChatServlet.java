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

@WebServlet("/chat")
public class ChatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ObjectMapper objectMapper;
    
    @Override
    public void init() throws ServletException {
        super.init();
        // Configure ObjectMapper with Java 8 Date/Time support
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new com.fasterxml.jackson.datatype.jsr310.JavaTimeModule());
        objectMapper.disable(com.fasterxml.jackson.databind.SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession httpSession = request.getSession();
        User currentUser = (User) httpSession.getAttribute("user");
        
        if (currentUser == null) {
            // Redirect to login page or create a demo user
            currentUser = createDemoUser();
            httpSession.setAttribute("user", currentUser);
        }
        
        String action = request.getParameter("action");
        
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
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("sendMessage".equals(action)) {
            handleSendMessage(request, response, currentUser);
        } else if ("createGroup".equals(action)) {
            handleCreateGroup(request, response, currentUser);
        } else if ("login".equals(action)) {
            handleLogin(request, response);
        }
    }
    
    private void handleGetMessages(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws IOException {
        
        String groupIdStr = request.getParameter("groupId");
        String receiverIdStr = request.getParameter("receiverId");
        
        Session session = HibernateUtil.getSessionFactory().getCurrentSession();
        Transaction tx = session.beginTransaction();
        
        try {
            List<Message> messages;
            
            if (groupIdStr != null && !groupIdStr.isEmpty()) {
                // Get group messages
                Long groupId = Long.parseLong(groupIdStr);
                Query<Message> query = session.createQuery(
                    "FROM com.chatapp.entity.Message m WHERE m.group.id = :groupId ORDER BY m.sentAt ASC", Message.class);
                query.setParameter("groupId", groupId);
                messages = query.getResultList();
            } else if (receiverIdStr != null && !receiverIdStr.isEmpty()) {
                // Get private messages
                Long receiverId = Long.parseLong(receiverIdStr);
                Query<Message> query = session.createQuery(
                    "FROM com.chatapp.entity.Message m WHERE (m.sender.id = :senderId AND m.receiver.id = :receiverId) " +
                    "OR (m.sender.id = :receiverId AND m.receiver.id = :senderId) ORDER BY m.sentAt ASC", Message.class);
                query.setParameter("senderId", currentUser.getId());
                query.setParameter("receiverId", receiverId);
                messages = query.getResultList();
            } else {
                messages = List.of();
            }
            
            tx.commit();
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            PrintWriter out = response.getWriter();
            out.print(convertMessagesToJson(messages));
            out.flush();
            
        } catch (Exception e) {
            tx.rollback();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            e.printStackTrace();
        }
    }
    
    private void handleSendMessage(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws IOException {
        
        String content = request.getParameter("content");
        String groupIdStr = request.getParameter("groupId");
        String receiverIdStr = request.getParameter("receiverId");
        String messageType = request.getParameter("type");
        
        if (content == null || content.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        Session session = HibernateUtil.getSessionFactory().getCurrentSession();
        Transaction tx = session.beginTransaction();
        
        try {
            Message message = new Message();
            message.setContent(content.trim());
            message.setSender(currentUser);
            message.setSentAt(LocalDateTime.now());
            
            if (messageType != null) {
                try {
                    message.setType(Message.MessageType.valueOf(messageType.toUpperCase()));
                } catch (IllegalArgumentException e) {
                    message.setType(Message.MessageType.TEXT);
                }
            }
            
            if (groupIdStr != null && !groupIdStr.isEmpty()) {
                // Group message
                Long groupId = Long.parseLong(groupIdStr);
                Group group = session.get(Group.class, groupId);
                if (group != null) {
                    message.setGroup(group);
                }
            } else if (receiverIdStr != null && !receiverIdStr.isEmpty()) {
                // Private message
                Long receiverId = Long.parseLong(receiverIdStr);
                User receiver = session.get(User.class, receiverId);
                if (receiver != null) {
                    message.setReceiver(receiver);
                }
            }
            
            session.save(message);
            tx.commit();
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("messageId", message.getId());
            result.put("timestamp", message.getSentAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            
            PrintWriter out = response.getWriter();
            out.print(objectMapper.writeValueAsString(result));
            out.flush();
            
        } catch (Exception e) {
            tx.rollback();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            e.printStackTrace();
        }
    }
    
    private void handleGetGroups(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws IOException {
        
        Session session = HibernateUtil.getSessionFactory().getCurrentSession();
        Transaction tx = session.beginTransaction();
        
        try {
            // Get user's groups
            Query<Group> query = session.createQuery(
                "FROM com.chatapp.entity.Group g JOIN g.members m WHERE m.id = :userId ORDER BY g.name", Group.class);
            query.setParameter("userId", currentUser.getId());
            List<Group> groups = query.getResultList();
            
            // Convert to simpler format for JSON response
            List<Map<String, Object>> groupsList = new java.util.ArrayList<>();
            for (Group group : groups) {
                Map<String, Object> groupMap = new HashMap<>();
                groupMap.put("id", group.getId());
                groupMap.put("name", group.getName());
                groupMap.put("description", group.getDescription());
                groupMap.put("memberCount", group.getMembers().size());
                groupMap.put("createdBy", group.getCreatedBy().getUsername());
                groupMap.put("createdAt", group.getCreatedAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                groupsList.add(groupMap);
            }
            
            tx.commit();
            
            // Send JSON response
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            out.print(objectMapper.writeValueAsString(groupsList));
            out.flush();
            
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading groups");
        }
    }
    
    private void handleGetUsers(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws IOException {
        
        Session session = HibernateUtil.getSessionFactory().getCurrentSession();
        Transaction tx = session.beginTransaction();
        
        try {
            // Get all users
            Query<User> query = session.createQuery("FROM User ORDER BY username", User.class);
            List<User> users = query.getResultList();
            
            // Convert to simpler format for JSON response
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
            
            // Send JSON response
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            out.print(objectMapper.writeValueAsString(usersList));
            out.flush();
            
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading users");
        }
    }
    
    private void handleCreateGroup(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws IOException {
        
        String groupName = request.getParameter("groupName");
        String description = request.getParameter("description");
        
        if (groupName == null || groupName.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        Session session = HibernateUtil.getSessionFactory().getCurrentSession();
        Transaction tx = session.beginTransaction();
        
        try {
            // Create new group
            Group group = new Group();
            group.setName(groupName);
            group.setDescription(description);
            group.setCreatedBy(currentUser);
            group.setCreatedAt(LocalDateTime.now());
            
            // Add current user as a member
            group.getMembers().add(currentUser);
            
            session.save(group);
            tx.commit();
            
            // Send success response
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("groupId", group.getId());
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            out.print(objectMapper.writeValueAsString(result));
            out.flush();
            
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            e.printStackTrace();
            sendJsonError(response, "Error creating group: " + e.getMessage());
        }
    }
    
    private void handleLogin(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        if (username == null || username.isEmpty() || password == null || password.isEmpty()) {
            sendJsonError(response, "Username and password are required");
            return;
        }
        
        Session session = HibernateUtil.getSessionFactory().getCurrentSession();
        Transaction tx = session.beginTransaction();
        
        try {
            Query<User> query = session.createQuery(
                "FROM com.chatapp.entity.User u WHERE u.username = :username AND u.password = :password", User.class);
            query.setParameter("username", username);
            query.setParameter("password", password); // Note: In production, use proper password hashing
            User user = query.uniqueResult();
            
            if (user == null) {
                tx.rollback();
                sendJsonError(response, "Invalid username or password");
                return;
            }
            
            // Update user status
            user.setStatus(User.UserStatus.ONLINE);
            user.setLastSeen(LocalDateTime.now());
            session.update(user);
            tx.commit();
            
            // Set session
            HttpSession httpSession = request.getSession();
            httpSession.setAttribute("user", user);
            
            // Send success response
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("userId", user.getId());
            result.put("username", user.getUsername());
            result.put("fullName", user.getFullName());
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            out.print(objectMapper.writeValueAsString(result));
            out.flush();
            
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            e.printStackTrace();
            sendJsonError(response, "Error during login: " + e.getMessage());
        }
    }
    
    private void sendJsonError(HttpServletResponse response, String message) throws IOException {
        Map<String, Object> result = new HashMap<>();
        result.put("success", false);
        result.put("error", message);
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print(objectMapper.writeValueAsString(result));
        out.flush();
    }
    
    private User createDemoUser() {
        Session session = HibernateUtil.getSessionFactory().getCurrentSession();
        Transaction tx = session.beginTransaction();
        
        try {
            // Check if demo user exists
            Query<User> query = session.createQuery(
                "FROM com.chatapp.entity.User u WHERE u.username = :username", User.class);
            query.setParameter("username", "demo");
            User demoUser = query.uniqueResult();
            
            if (demoUser == null) {
                // Create demo user
                demoUser = new User("demo", "demo", "demo@example.com", "Demo User");
                demoUser.setStatus(User.UserStatus.ONLINE);
                demoUser.setLastSeen(LocalDateTime.now());
                session.save(demoUser);
                
                // Create some additional demo users for testing
                User alice = new User("alice", "pass123", "alice@example.com", "Alice Smith");
                alice.setStatus(User.UserStatus.ONLINE);
                session.save(alice);
                
                User bob = new User("bob", "pass123", "bob@example.com", "Bob Johnson");
                bob.setStatus(User.UserStatus.AWAY);
                session.save(bob);
                
                User carol = new User("carol", "pass123", "carol@example.com", "Carol Williams");
                carol.setStatus(User.UserStatus.ONLINE);
                session.save(carol);
                
                // Create a demo group
                Group group = new Group();
                group.setName("General Chat");
                group.setDescription("A group for general discussions");
                group.setCreatedBy(demoUser);
                group.getMembers().add(demoUser);
                group.getMembers().add(alice);
                group.getMembers().add(bob);
                session.save(group);
                
                // Add some initial messages
                Message message1 = new Message();
                message1.setSender(alice);
                message1.setGroup(group);
                message1.setContent("Hello everyone! Welcome to the chat!");
                message1.setType(Message.MessageType.TEXT);
                message1.setSentAt(LocalDateTime.now().minusMinutes(30));
                session.save(message1);
                
                Message message2 = new Message();
                message2.setSender(bob);
                message2.setGroup(group);
                message2.setContent("Hi Alice! Thanks for setting this up.");
                message2.setType(Message.MessageType.TEXT);
                message2.setSentAt(LocalDateTime.now().minusMinutes(25));
                session.save(message2);
                
                // Direct message between Alice and Demo
                Message message3 = new Message();
                message3.setSender(alice);
                message3.setReceiver(demoUser);
                message3.setContent("Hey Demo! How are you doing?");
                message3.setType(Message.MessageType.TEXT);
                message3.setSentAt(LocalDateTime.now().minusMinutes(20));
                session.save(message3);
            } else {
                // Update existing demo user
                demoUser.setStatus(User.UserStatus.ONLINE);
                demoUser.setLastSeen(LocalDateTime.now());
                session.update(demoUser);
            }
            
            tx.commit();
            return demoUser;
            
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            e.printStackTrace();
            // Create a basic user object if database operation fails
            User fallbackUser = new User();
            fallbackUser.setId(1L);
            fallbackUser.setUsername("demo");
            fallbackUser.setFullName("Demo User");
            fallbackUser.setStatus(User.UserStatus.ONLINE);
            return fallbackUser;
        }
    }
    
    private String convertMessagesToJson(List<Message> messages) {
        try {
            return objectMapper.writeValueAsString(messages.stream().map(this::messageToMap).toArray());
        } catch (Exception e) {
            e.printStackTrace();
            return "[]";
        }
    }
    
    // Helper methods for converting entity objects to maps moved to direct implementation in handler methods
    
    private Map<String, Object> messageToMap(Message message) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", message.getId());
        map.put("content", message.getContent());
        map.put("type", message.getType().toString());
        map.put("senderName", message.getSender().getFullName());
        map.put("senderId", message.getSender().getId());
        map.put("sentAt", message.getSentAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        map.put("isRead", message.isRead());
        
        if (message.getReceiver() != null) {
            map.put("receiverId", message.getReceiver().getId());
            map.put("receiverName", message.getReceiver().getFullName());
        }
        
        if (message.getGroup() != null) {
            map.put("groupId", message.getGroup().getId());
            map.put("groupName", message.getGroup().getName());
        }
        
        return map;
    }
    
    // Helper methods removed as they are not used in the current implementation
    // Entity to map conversions are done directly in the respective handler methods
}