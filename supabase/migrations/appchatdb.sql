-- ChatApp Database Schema
-- MySQL Database Creation Script
-- Date: June 24, 2025, 07:50 PM +07

-- Create database
CREATE DATABASE IF NOT EXISTS chatappdb 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE chatappdb;

-- Drop triggers if they exist to avoid conflicts
DROP TRIGGER IF EXISTS message_validate_destination;
DROP TRIGGER IF EXISTS message_validate_destination_update;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    profile_picture VARCHAR(255),
    status ENUM('ONLINE', 'OFFLINE', 'AWAY', 'BUSY') DEFAULT 'OFFLINE',
    last_seen TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- Create groups table
CREATE TABLE IF NOT EXISTS groups (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    group_picture VARCHAR(255),
    created_by BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_created_by (created_by),
    INDEX idx_name (name)
) ENGINE=InnoDB;

-- Create group_members table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS group_members (
    group_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (group_id, user_id),
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_group_id (group_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB;

-- Create files table
CREATE TABLE IF NOT EXISTS files (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    original_name VARCHAR(255) NOT NULL,
    stored_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT,
    mime_type VARCHAR(100),
    uploaded_by BIGINT NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_uploaded_by (uploaded_by),
    INDEX idx_mime_type (mime_type)
) ENGINE=InnoDB;

-- Create messages table
CREATE TABLE IF NOT EXISTS messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    content TEXT,
    type ENUM('TEXT', 'IMAGE', 'FILE', 'STICKER', 'EMOJI', 'VOICE', 'VIDEO') DEFAULT 'TEXT',
    sender_id BIGINT NOT NULL,
    receiver_id BIGINT NULL,
    group_id BIGINT NULL,
    file_id BIGINT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    is_read BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE,
    FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE SET NULL,
    INDEX idx_sender_id (sender_id),
    INDEX idx_receiver_id (receiver_id),
    INDEX idx_group_id (group_id),
    INDEX idx_sent_at (sent_at),
    INDEX idx_type (type)
) ENGINE=InnoDB;

-- Create timeline table for status sharing
CREATE TABLE IF NOT EXISTS timeline (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    content TEXT,
    user_id BIGINT NOT NULL,
    file_id BIGINT NULL,
    type ENUM('TEXT', 'IMAGE', 'VIDEO') DEFAULT 'TEXT',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at),
    INDEX idx_expires_at (expires_at),
    INDEX idx_type (type)
) ENGINE=InnoDB;

-- Create trigger to ensure messages have either a receiver_id or group_id, not both
DELIMITER //
CREATE TRIGGER message_validate_destination
BEFORE INSERT ON messages
FOR EACH ROW
BEGIN
    IF (NEW.receiver_id IS NOT NULL AND NEW.group_id IS NOT NULL) OR 
       (NEW.receiver_id IS NULL AND NEW.group_id IS NULL) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'A message must have either a receiver_id or a group_id, not both or neither';
    END IF;
END//

CREATE TRIGGER message_validate_destination_update
BEFORE UPDATE ON messages
FOR EACH ROW
BEGIN
    IF (NEW.receiver_id IS NOT NULL AND NEW.group_id IS NOT NULL) OR 
       (NEW.receiver_id IS NULL AND NEW.group_id IS NULL) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'A message must have either a receiver_id or a group_id, not both or neither';
    END IF;
END//
DELIMITER ;

-- Insert sample data
INSERT INTO users (username, password, full_name, email, status) VALUES
('demo', 'demo123', 'Demo User', 'demo@chatapp.com', 'ONLINE'),
('alice', 'alice123', 'Alice Johnson', 'alice@chatapp.com', 'ONLINE'),
('bob', 'bob123', 'Bob Smith', 'bob@chatapp.com', 'AWAY'),
('charlie', 'charlie123', 'Charlie Brown', 'charlie@chatapp.com', 'OFFLINE'),
('diana', 'diana123', 'Diana Prince', 'diana@chatapp.com', 'ONLINE');

-- Insert sample groups
INSERT INTO groups (name, description, created_by) VALUES
('General Discussion', 'Main chat room for general topics', 1),
('Project Team', 'Team collaboration space', 2),
('Random Chat', 'Casual conversations and fun', 1);

-- Insert group members
INSERT INTO group_members (group_id, user_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
(2, 1), (2, 2), (2, 3),
(3, 1), (3, 4), (3, 5);

-- Insert sample messages
INSERT INTO messages (content, type, sender_id, receiver_id, sent_at) VALUES
('Hello Alice! How are you doing?', 'TEXT', 1, 2, '2025-06-24 19:45:00'),
('Hi Demo! I am doing great, thanks for asking!', 'TEXT', 2, 1, '2025-06-24 19:46:00'),
('Would you like to grab coffee sometime?', 'TEXT', 1, 2, '2025-06-24 19:47:00');

INSERT INTO messages (content, type, sender_id, group_id, sent_at) VALUES
('Welcome everyone to our general discussion group!', 'TEXT', 1, 1, '2025-06-24 19:30:00'),
('Thanks for creating this group!', 'TEXT', 2, 1, '2025-06-24 19:31:00'),
('Looking forward to great conversations 😊', 'TEXT', 3, 1, '2025-06-24 19:32:00'),
('This will be very useful for our team collaboration', 'TEXT', 2, 2, '2025-06-24 19:35:00');

-- Insert sample timeline posts
INSERT INTO timeline (content, user_id, type, expires_at) VALUES
('Having a great day at work! 🌟', 1, 'TEXT', DATE_ADD(NOW(), INTERVAL 24 HOUR)),
('Just finished an amazing project 🎉', 2, 'TEXT', DATE_ADD(NOW(), INTERVAL 24 HOUR)),
('Weekend vibes! Time to relax 😎', 3, 'TEXT', DATE_ADD(NOW(), INTERVAL 24 HOUR));

-- Create indexes for better performance
CREATE INDEX idx_messages_conversation ON messages(sender_id, receiver_id, sent_at);
CREATE INDEX idx_messages_group_chat ON messages(group_id, sent_at);
CREATE INDEX idx_timeline_active ON timeline(expires_at, created_at);

-- Drop existing views if they exist
DROP VIEW IF EXISTS active_timeline;
DROP VIEW IF EXISTS recent_messages;

-- Create a view for active timeline posts
CREATE OR REPLACE VIEW active_timeline AS
SELECT t.*, u.full_name, u.username
FROM timeline t
JOIN users u ON t.user_id = u.id
WHERE t.expires_at > NOW()
ORDER BY t.created_at DESC;

-- Create a view for recent messages
CREATE OR REPLACE VIEW recent_messages AS
SELECT 
    m.*,
    s.full_name as sender_name,
    s.username as sender_username,
    r.full_name as receiver_name,
    r.username as receiver_username,
    g.name as group_name
FROM messages m
JOIN users s ON m.sender_id = s.id
LEFT JOIN users r ON m.receiver_id = r.id
LEFT JOIN groups g ON m.group_id = g.id
ORDER BY m.sent_at DESC;

-- Set MySQL to commit after each statement for compatibility with XAMPP
SET autocommit = 1;

-- Display success message
SELECT 'ChatApp database schema created successfully!' as Status;
SELECT 'Database: chatappdb' as Database_Name;
SELECT 'Tables created: users, groups, group_members, files, messages, timeline' as Tables;
SELECT 'Sample data inserted for testing' as Sample_Data;
SELECT 'Views created: active_timeline, recent_messages' as Views;
SELECT 'Ready for deployment with Apache Tomcat' as Deployment_Status;