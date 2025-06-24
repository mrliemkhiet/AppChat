package com.chatapp.servlet;

import com.chatapp.entity.FileEntity;
import com.chatapp.entity.Message;
import com.chatapp.entity.User;
import com.chatapp.entity.Group;
import com.chatapp.util.HibernateUtil;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.hibernate.Session;
import org.hibernate.Transaction;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/upload")
public class FileUploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger(FileUploadServlet.class.getName());
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
    private static final String UPLOAD_DIRECTORY = "uploads";
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession httpSession = request.getSession();
        User currentUser = (User) httpSession.getAttribute("user");
        
        if (currentUser == null) {
            sendJsonError(response, "User not authenticated", HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        // Check if request is multipart
        if (!ServletFileUpload.isMultipartContent(request)) {
            sendJsonError(response, "Request must be multipart/form-data", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        // Configure file upload
        DiskFileItemFactory factory = new DiskFileItemFactory();
        factory.setSizeThreshold(1024 * 1024); // 1MB threshold
        factory.setRepository(new File(System.getProperty("java.io.tmpdir")));
        
        ServletFileUpload upload = new ServletFileUpload(factory);
        upload.setFileSizeMax(MAX_FILE_SIZE);
        upload.setSizeMax(MAX_FILE_SIZE * 2);
        
        Session session = null;
        Transaction tx = null;
        
        try {
            // Get upload directory path
            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIRECTORY;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                if (!created) {
                    logger.warning("Failed to create upload directory: " + uploadPath);
                }
            }
            
            List<FileItem> items = upload.parseRequest(request);
            String groupId = null;
            String receiverId = null;
            FileItem fileItem = null;
            
            // Process form fields
            for (FileItem item : items) {
                if (item.isFormField()) {
                    String fieldName = item.getFieldName();
                    String fieldValue = item.getString("UTF-8");
                    
                    if ("groupId".equals(fieldName)) {
                        groupId = fieldValue;
                    } else if ("receiverId".equals(fieldName)) {
                        receiverId = fieldValue;
                    }
                } else {
                    fileItem = item;
                }
            }
            
            if (fileItem == null || fileItem.getSize() == 0) {
                sendJsonError(response, "No file selected or file is empty", HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            
            // Validate file size
            if (fileItem.getSize() > MAX_FILE_SIZE) {
                sendJsonError(response, "File size exceeds maximum limit of 10MB", HttpServletResponse.SC_REQUEST_ENTITY_TOO_LARGE);
                return;
            }
            
            // Validate destination
            if ((groupId == null || groupId.isEmpty()) && (receiverId == null || receiverId.isEmpty())) {
                sendJsonError(response, "Either groupId or receiverId is required", HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            
            // Generate unique filename
            String originalFileName = fileItem.getName();
            if (originalFileName == null || originalFileName.isEmpty()) {
                originalFileName = "unnamed_file";
            }
            
            String fileExtension = "";
            int lastDotIndex = originalFileName.lastIndexOf('.');
            if (lastDotIndex > 0 && lastDotIndex < originalFileName.length() - 1) {
                fileExtension = originalFileName.substring(lastDotIndex);
            }
            
            String storedFileName = UUID.randomUUID().toString() + fileExtension;
            String filePath = uploadPath + File.separator + storedFileName;
            
            // Save file to disk
            File storeFile = new File(filePath);
            fileItem.write(storeFile);
            
            logger.info("File saved to: " + filePath + ", Size: " + fileItem.getSize() + " bytes");
            
            // Save file info to database
            session = HibernateUtil.getSessionFactory().getCurrentSession();
            tx = session.beginTransaction();
            
            FileEntity fileEntity = new FileEntity(
                originalFileName,
                storedFileName,
                UPLOAD_DIRECTORY + "/" + storedFileName,
                fileItem.getSize(),
                fileItem.getContentType(),
                currentUser
            );
            
            session.save(fileEntity);
            
            // Create message with file attachment
            Message message = new Message();
            message.setSender(currentUser);
            message.setContent("📎 " + originalFileName);
            message.setType(getMessageTypeFromMimeType(fileItem.getContentType()));
            message.setFile(fileEntity);
            message.setSentAt(LocalDateTime.now());
            
            if (groupId != null && !groupId.isEmpty()) {
                Group group = session.get(Group.class, Long.parseLong(groupId));
                if (group != null) {
                    message.setGroup(group);
                    logger.info("File message sent to group: " + group.getName());
                } else {
                    sendJsonError(response, "Group not found", HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
            } else if (receiverId != null && !receiverId.isEmpty()) {
                User receiver = session.get(User.class, Long.parseLong(receiverId));
                if (receiver != null) {
                    message.setReceiver(receiver);
                    logger.info("File message sent to user: " + receiver.getUsername());
                } else {
                    sendJsonError(response, "Receiver not found", HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
            }
            
            session.save(message);
            tx.commit();
            
            // Return success response
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("fileId", fileEntity.getId());
            result.put("fileName", originalFileName);
            result.put("fileSize", fileEntity.getFileSize());
            result.put("messageId", message.getId());
            result.put("timestamp", message.getSentAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            result.put("downloadUrl", request.getContextPath() + "/download?fileId=" + fileEntity.getId());
            
            sendJsonResponse(response, result);
            logger.info("File upload completed successfully: " + originalFileName);
            
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            logger.log(Level.SEVERE, "Error uploading file", e);
            sendJsonError(response, "File upload failed: " + e.getMessage(), HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private Message.MessageType getMessageTypeFromMimeType(String mimeType) {
        if (mimeType == null) {
            return Message.MessageType.FILE;
        }
        
        String lowerMimeType = mimeType.toLowerCase();
        if (lowerMimeType.startsWith("image/")) {
            return Message.MessageType.IMAGE;
        } else if (lowerMimeType.startsWith("video/")) {
            return Message.MessageType.VIDEO;
        } else if (lowerMimeType.startsWith("audio/")) {
            return Message.MessageType.VOICE;
        } else {
            return Message.MessageType.FILE;
        }
    }
    
    private void sendJsonResponse(HttpServletResponse response, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try (PrintWriter out = response.getWriter()) {
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            out.print(mapper.writeValueAsString(data));
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