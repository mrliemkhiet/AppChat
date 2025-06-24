package com.chatapp.util;

import org.hibernate.SessionFactory;
import org.hibernate.boot.registry.StandardServiceRegistryBuilder;
import org.hibernate.cfg.Configuration;
import org.hibernate.service.ServiceRegistry;
import java.util.logging.Logger;
import java.util.logging.Level;

public class HibernateUtil {
    private static final Logger logger = Logger.getLogger(HibernateUtil.class.getName());
    private static SessionFactory sessionFactory;
    
    static {
        try {
            logger.info("Initializing Hibernate SessionFactory...");
            
            // Create the SessionFactory from hibernate.cfg.xml
            Configuration configuration = new Configuration();
            configuration.configure("hibernate.cfg.xml");
            
            // Explicitly register entity classes to ensure they are loaded
            configuration.addAnnotatedClass(com.chatapp.entity.User.class);
            configuration.addAnnotatedClass(com.chatapp.entity.Group.class);
            configuration.addAnnotatedClass(com.chatapp.entity.Message.class);
            configuration.addAnnotatedClass(com.chatapp.entity.FileEntity.class);
            configuration.addAnnotatedClass(com.chatapp.entity.Timeline.class);
            
            logger.info("Entity classes registered successfully");
            
            ServiceRegistry serviceRegistry = new StandardServiceRegistryBuilder()
                    .applySettings(configuration.getProperties())
                    .build();
            
            sessionFactory = configuration.buildSessionFactory(serviceRegistry);
            logger.info("Hibernate SessionFactory created successfully");
            
            // Test database connection
            testDatabaseConnection();
            
        } catch (Exception ex) {
            logger.log(Level.SEVERE, "Initial SessionFactory creation failed", ex);
            throw new ExceptionInInitializerError(ex);
        }
    }
    
    private static void testDatabaseConnection() {
        try (org.hibernate.Session session = sessionFactory.openSession()) {
            // Test connection with a simple query
            session.createNativeQuery("SELECT 1").uniqueResult();
            logger.info("Database connection test successful");
        } catch (Exception e) {
            logger.log(Level.WARNING, "Database connection test failed", e);
        }
    }
    
    public static SessionFactory getSessionFactory() {
        if (sessionFactory == null) {
            throw new IllegalStateException("SessionFactory is not initialized");
        }
        return sessionFactory;
    }
    
    public static void shutdown() {
        if (sessionFactory != null) {
            try {
                sessionFactory.close();
                logger.info("Hibernate SessionFactory closed successfully");
            } catch (Exception e) {
                logger.log(Level.WARNING, "Error closing SessionFactory", e);
            }
        }
    }
}