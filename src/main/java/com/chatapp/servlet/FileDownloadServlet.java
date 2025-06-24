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

@WebServlet("/download")
public class FileDownloadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String fileIdStr = request.getParameter("fileId");
        
        if (fileIdStr == null || fileIdStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        try {
            Long fileId = Long.parseLong(fileIdStr);
            
            Session session = HibernateUtil.getSessionFactory().getCurrentSession();
            Transaction tx = session.beginTransaction();
            
            try {
                FileEntity fileEntity = session.get(FileEntity.class, fileId);
                tx.commit();
                
                if (fileEntity == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                
                String filePath = getServletContext().getRealPath("") + File.separator + fileEntity.getFilePath();
                File file = new File(filePath);
                
                if (!file.exists()) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                
                // Set response headers
                response.setContentType(fileEntity.getMimeType());
                response.setContentLengthLong(fileEntity.getFileSize());
                response.setHeader("Content-Disposition", 
                    "attachment; filename=\"" + fileEntity.getOriginalName() + "\"");
                
                // Stream file to response
                try (FileInputStream fileInputStream = new FileInputStream(file);
                     OutputStream outputStream = response.getOutputStream()) {
                    
                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    
                    while ((bytesRead = fileInputStream.read(buffer)) != -1) {
                        outputStream.write(buffer, 0, bytesRead);
                    }
                    
                    outputStream.flush();
                }
                
            } catch (Exception e) {
                tx.rollback();
                throw e;
            }
            
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}