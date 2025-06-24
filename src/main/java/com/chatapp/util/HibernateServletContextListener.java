package com.chatapp.util;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Servlet context listener that initializes Hibernate when the application starts
 * and shuts it down when the application stops.
 */
public class HibernateServletContextListener implements ServletContextListener {
    private static final Logger logger = LoggerFactory.getLogger(HibernateServletContextListener.class);    @Override
    public void contextInitialized(ServletContextEvent sce) {
        logger.info("Initializing Hibernate SessionFactory...");
        try {
            // Force initialization of the SessionFactory
            HibernateUtil.getSessionFactory();
            
            // Test database connection
            org.hibernate.Session session = HibernateUtil.getSessionFactory().openSession();
            try {
                // Run a simple query to validate connection
                session.createNativeQuery("SELECT 1").uniqueResult();
                logger.info("Database connection test successful");
            } catch (Exception dbEx) {
                logger.error("Database connection test failed", dbEx);
            } finally {
                if (session != null && session.isOpen()) {
                    session.close();
                }
            }
            
            logger.info("Hibernate SessionFactory initialized successfully.");
        } catch (Exception e) {
            logger.error("Failed to initialize Hibernate SessionFactory", e);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        logger.info("Shutting down Hibernate SessionFactory...");
        HibernateUtil.shutdown();
    }
}
