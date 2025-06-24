package com.chatapp.servlet;

import com.chatapp.entity.FileEntity;
import com.chatapp.util.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/download")
public class FileDownloadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger(FileDownloadServlet.class.getName());
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String fileIdStr = request.getParameter("fileId");
        
        if (fileIdStr == null || fileIdStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "File ID is required");
            return;
        }
        
        Session session = null;
        Transaction tx = null;
        
        try {
            Long fileId = Long.parseLong(fileIdStr);
            
            session = HibernateUtil.getSessionFactory().getCurrentSession();
            tx = session.beginTransaction();
            
            FileEntity fileEntity = session.get(FileEntity.class, fileId);
            tx.commit();
            
            if (fileEntity == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found");
                return;
            }
            
            // Construct file path
            String filePath = getServletContext().getRealPath("") + File.separator + fileEntity.getFilePath();
            File file = new File(filePath);
            
            if (!file.exists()) {
                logger.warning("File not found on disk: " + filePath);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found on server");
                return;
            }
            
            // Validate file is within upload directory (security check)
            String uploadDir = getServletContext().getRealPath("") + File.separator + "uploads";
            if (!file.getCanonicalPath().startsWith(new File(uploadDir).getCanonicalPath())) {
                logger.warning("Attempted access to file outside upload directory: " + filePath);
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                return;
            }
            
            // Set response headers
            String mimeType = fileEntity.getMimeType();
            if (mimeType == null || mimeType.isEmpty()) {
                mimeType = getServletContext().getMimeType(fileEntity.getOriginalName());
                if (mimeType == null) {
                    mimeType = "application/octet-stream";
                }
            }
            
            response.setContentType(mimeType);
            response.setContentLengthLong(fileEntity.getFileSize());
            
            // Encode filename for proper handling of special characters
            String encodedFilename = URLEncoder.encode(fileEntity.getOriginalName(), StandardCharsets.UTF_8.toString())
                    .replaceAll("\\+", "%20");
            
            response.setHeader("Content-Disposition", 
                "attachment; filename=\"" + fileEntity.getOriginalName() + "\"; filename*=UTF-8''" + encodedFilename);
            
            // Add cache control headers
            response.setHeader("Cache-Control", "private, max-age=3600");
            response.setDateHeader("Expires", System.currentTimeMillis() + 3600000); // 1 hour
            
            // Stream file to response
            try (FileInputStream fileInputStream = new FileInputStream(file);
                 OutputStream outputStream = response.getOutputStream()) {
                
                byte[] buffer = new byte[8192]; // 8KB buffer
                int bytesRead;
                long totalBytesRead = 0;
                
                while ((bytesRead = fileInputStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, bytesRead);
                    totalBytesRead += bytesRead;
                }
                
                outputStream.flush();
                logger.info("File downloaded successfully: " + fileEntity.getOriginalName() + 
                           " (" + totalBytesRead + " bytes)");
            }
            
        } catch (NumberFormatException e) {
            logger.log(Level.WARNING, "Invalid file ID format: " + fileIdStr, e);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid file ID format");
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            logger.log(Level.SEVERE, "Error downloading file", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error downloading file");
        }
    }
}