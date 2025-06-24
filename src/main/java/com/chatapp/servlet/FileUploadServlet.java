package com.chatapp.servlet;

import com.chatapp.entity.FileEntity;
import com.chatapp.entity.Message;
import com.chatapp.entity.User;
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

@WebServlet("/upload")
public class FileUploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
    private static final String UPLOAD_DIRECTORY = "uploads";
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession httpSession = request.getSession();
        User currentUser = (User) httpSession.getAttribute("user");
        
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        // Check if request is multipart
        if (!ServletFileUpload.isMultipartContent(request)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        // Configure file upload
        DiskFileItemFactory factory = new DiskFileItemFactory();
        factory.setSizeThreshold(1024 * 1024); // 1MB threshold
        factory.setRepository(new File(System.getProperty("java.io.tmpdir")));
        
        ServletFileUpload upload = new ServletFileUpload(factory);
        upload.setFileSizeMax(MAX_FILE_SIZE);
        upload.setSizeMax(MAX_FILE_SIZE * 2);
        
        try {
            // Get upload directory path
            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIRECTORY;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            List<FileItem> items = upload.parseRequest(request);
            String groupId = null;
            String receiverId = null;
            FileItem fileItem = null;
            
            // Process form fields
            for (FileItem item : items) {
                if (item.isFormField()) {
                    String fieldName = item.getFieldName();
                    String fieldValue = item.getString();
                    
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
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            
            // Validate file size
            if (fileItem.getSize() > MAX_FILE_SIZE) {
                response.setStatus(HttpServletResponse.SC_REQUEST_ENTITY_TOO_LARGE);
                return;
            }
            
            // Generate unique filename
            String originalFileName = fileItem.getName();
            String fileExtension = "";
            int lastDotIndex = originalFileName.lastIndexOf('.');
            if (lastDotIndex > 0) {
                fileExtension = originalFileName.substring(lastDotIndex);
            }
            
            String storedFileName = UUID.randomUUID().toString() + fileExtension;
            String filePath = uploadPath + File.separator + storedFileName;
            
            // Save file to disk
            File storeFile = new File(filePath);
            fileItem.write(storeFile);
            
            // Save file info to database
            Session session = HibernateUtil.getSessionFactory().getCurrentSession();
            Transaction tx = session.beginTransaction();
            
            try {
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
                    message.setGroup(session.get(com.chatapp.entity.Group.class, Long.parseLong(groupId)));
                } else if (receiverId != null && !receiverId.isEmpty()) {
                    message.setReceiver(session.get(User.class, Long.parseLong(receiverId)));
                }
                
                session.save(message);
                tx.commit();
                
                // Return success response
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("fileId", fileEntity.getId());
                result.put("fileName", originalFileName);
                result.put("fileSize", fileEntity.getFileSize());
                result.put("messageId", message.getId());
                result.put("timestamp", message.getSentAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
                result.put("downloadUrl", request.getContextPath() + "/download?fileId=" + fileEntity.getId());
                
                PrintWriter out = response.getWriter();
                out.print(new com.fasterxml.jackson.databind.ObjectMapper().writeValueAsString(result));
                out.flush();
                
            } catch (Exception e) {
                tx.rollback();
                throw e;
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "File upload failed: " + e.getMessage());
            
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print(new com.fasterxml.jackson.databind.ObjectMapper().writeValueAsString(error));
            out.flush();
        }
    }
    
    private Message.MessageType getMessageTypeFromMimeType(String mimeType) {
        if (mimeType == null) {
            return Message.MessageType.FILE;
        }
        
        if (mimeType.startsWith("image/")) {
            return Message.MessageType.IMAGE;
        } else if (mimeType.startsWith("video/")) {
            return Message.MessageType.VIDEO;
        } else if (mimeType.startsWith("audio/")) {
            return Message.MessageType.VOICE;
        } else {
            return Message.MessageType.FILE;
        }
    }
}