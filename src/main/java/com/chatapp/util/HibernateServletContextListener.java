package com.chatapp.util;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Servlet context listener that initializes Hibernate when the application starts
 * and shuts it down when the application stops.
 */
@WebListener
public class HibernateServletContextListener implements ServletContextListener {
    private static final Logger logger = Logger.getLogger(HibernateServletContextListener.class.getName());
    
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        logger.info("Zola Chat Application starting up...");
        try {
            // Force initialization of the SessionFactory
            HibernateUtil.getSessionFactory();
            logger.info("Hibernate SessionFactory initialized successfully");
            
            // Log application startup
            logger.info("Zola Chat Application started successfully");
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Failed to initialize Zola Chat Application", e);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        logger.info("Zola Chat Application shutting down...");
        try {
            HibernateUtil.shutdown();
            logger.info("Zola Chat Application shutdown completed");
        } catch (Exception e) {
            logger.log(Level.WARNING, "Error during application shutdown", e);
        }
    }
}