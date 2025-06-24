# Zola - Modern Chat Application

A comprehensive, production-ready chat application built with Java Servlets, Hibernate, and MySQL, designed for deployment on Apache Tomcat. Zola provides a modern, Zalo-like messaging experience with real-time communication, file sharing, and group management.

## 🚀 Features

- **💬 Real-time Messaging**: Instant private and group messaging with auto-refresh
- **👥 Group Management**: Create and manage group conversations with multiple members
- **📎 File Sharing**: Upload and share files up to 10MB with secure download links
- **😊 Rich Messaging**: Emoji support and message type indicators
- **📱 Responsive Design**: Modern, mobile-friendly interface optimized for all devices
- **🔐 User Authentication**: Secure user registration and session management
- **⚡ Performance Optimized**: Connection pooling, lazy loading, and efficient queries
- **🎨 Modern UI**: Clean, intuitive interface inspired by popular messaging apps

## 🛠 Technology Stack

- **Backend**: Java 17+, Jakarta Servlets 5.0, Hibernate 5.6
- **Database**: MySQL 8.0+ with optimized schema
- **Build Tool**: Maven 3.6+
- **Server**: Apache Tomcat 10+
- **Frontend**: JSP, HTML5, CSS3, Vanilla JavaScript
- **Libraries**: Jackson (JSON), Apache Commons (File Upload), SLF4J (Logging)

## 📁 Project Structure

```
Zola/
├── src/main/java/com/chatapp/
│   ├── entity/              # Hibernate entity classes
│   │   ├── User.java        # User entity with status management
│   │   ├── Group.java       # Group entity with member management
│   │   ├── Message.java     # Message entity with type support
│   │   ├── FileEntity.java  # File metadata entity
│   │   └── Timeline.java    # Timeline/status entity
│   ├── servlet/             # Servlet controllers
│   │   ├── ChatServlet.java        # Main chat operations
│   │   ├── FileUploadServlet.java  # File upload handling
│   │   └── FileDownloadServlet.java # Secure file downloads
│   └── util/               # Utility classes
│       ├── HibernateUtil.java              # Hibernate configuration
│       └── HibernateServletContextListener.java # Lifecycle management
├── src/main/resources/
│   └── hibernate.cfg.xml   # Hibernate configuration
├── src/main/webapp/
│   ├── WEB-INF/
│   │   ├── web.xml         # Web application configuration
│   │   └── views/
│   │       ├── chat.jsp    # Main chat interface
│   │       └── error.jsp   # Error handling page
│   └── uploads/            # File upload directory (auto-created)
├── supabase/migrations/
│   └── appchatdb.sql      # Complete database schema
├── pom.xml                # Maven dependencies and build config
└── README.md              # This file
```

## 🔧 Prerequisites

Before deploying Zola, ensure you have:

1. **Java Development Kit (JDK) 17 or higher**
2. **Apache Maven 3.6 or higher**
3. **MySQL 8.0 or higher**
4. **Apache Tomcat 10.0 or higher**
5. **XAMPP** (recommended for easy MySQL setup)

## 🚀 Quick Deployment Guide

### Step 1: Database Setup

1. **Start MySQL** (via XAMPP or standalone installation)
2. **Import the database schema**:
   ```bash
   mysql -u root -p < supabase/migrations/appchatdb.sql
   ```
   Or use phpMyAdmin to import the SQL file.

3. **Verify database creation**:
   - Database name: `chatappdb`
   - Default MySQL user: `root` (no password)
   - Port: `3306`

### Step 2: Build the Application

1. **Navigate to project directory**:
   ```bash
   cd /path/to/zola-project
   ```

2. **Build with Maven**:
   ```bash
   mvn clean package
   ```

3. **Verify WAR file creation**:
   - File location: `target/ChatApp.war`
   - File size: ~15-20MB

### Step 3: Deploy to Tomcat

1. **Copy WAR file to XAMPP Tomcat**:
   ```bash
   copy target\ChatApp.war F:\xampp\tomcat\webapps\
   ```

2. **Start Tomcat** (via XAMPP Control Panel)

3. **Access the application**:
   ```
   http://localhost:8080/ChatApp/
   ```

## 🎯 Default Demo Users

Zola comes with pre-configured demo users for immediate testing:

| Username | Password | Full Name | Status |
|----------|----------|-----------|---------|
| demo | demo123 | Demo User | Online |
| alice | alice123 | Alice Johnson | Online |
| bob | bob123 | Bob Smith | Away |
| carol | carol123 | Carol Williams | Online |
| david | david123 | David Brown | Busy |

## 📡 API Endpoints

### Chat Operations (`/chat`)

**GET Requests:**
- `?action=getMessages&groupId=1` - Retrieve group messages
- `?action=getMessages&receiverId=2` - Retrieve private messages
- `?action=getGroups` - Get user's groups with member counts
- `?action=getUsers` - Get all users with status information

**POST Requests:**
- `action=sendMessage` - Send text/emoji messages
- `action=createGroup` - Create new group with description
- `action=login` - User authentication (demo purposes)

### File Operations

**Upload (`/upload`):**
- POST with multipart/form-data
- Max file size: 10MB
- Supports all file types
- Auto-generates secure filenames

**Download (`/download`):**
- GET with `?fileId=<id>` parameter
- Secure path validation
- Proper MIME type handling
- Browser-friendly file names

## 🔧 Configuration

### Database Configuration

Update `src/main/resources/hibernate.cfg.xml` if needed:

```xml
<property name="hibernate.connection.url">jdbc:mysql://localhost:3306/chatappdb</property>
<property name="hibernate.connection.username">root</property>
<property name="hibernate.connection.password"></property>
```

### File Upload Configuration

Modify `FileUploadServlet.java` for custom settings:

```java
private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
private static final String UPLOAD_DIRECTORY = "uploads";
```

### Session Configuration

Adjust in `web.xml`:

```xml
<session-config>
    <session-timeout>60</session-timeout> <!-- 60 minutes -->
</session-config>
```

## 🐛 Troubleshooting

### Common Issues and Solutions

1. **Database Connection Failed**
   ```
   Error: Could not connect to database
   Solution: 
   - Verify MySQL is running (XAMPP Control Panel)
   - Check database credentials in hibernate.cfg.xml
   - Ensure chatappdb database exists
   ```

2. **File Upload Issues**
   ```
   Error: File upload failed
   Solution:
   - Check uploads directory permissions
   - Verify file size under 10MB limit
   - Ensure sufficient disk space
   ```

3. **Tomcat Deployment Issues**
   ```
   Error: Application not starting
   Solution:
   - Check Tomcat logs: F:\xampp\tomcat\logs\catalina.out
   - Verify Java version compatibility (JDK 17+)
   - Ensure all dependencies are included in WAR
   ```

4. **Hibernate Mapping Errors**
   ```
   Error: Entity not mapped
   Solution:
   - Verify all entities are registered in HibernateUtil.java
   - Check hibernate.cfg.xml entity mappings
   - Ensure database schema matches entity definitions
   ```

### Log Files

- **Tomcat Logs**: `F:\xampp\tomcat\logs\catalina.out`
- **Application Logs**: Console output (configurable)
- **Access Logs**: `F:\xampp\tomcat\logs\localhost_access_log.txt`

## 🔒 Security Features

- **SQL Injection Prevention**: Parameterized queries via Hibernate
- **File Upload Security**: Path validation and type checking
- **Session Management**: Secure session handling with timeout
- **XSS Protection**: Input sanitization and output encoding
- **CSRF Protection**: Form token validation (can be enhanced)

## 🚀 Performance Optimizations

- **Connection Pooling**: C3P0 connection pool (5-20 connections)
- **Lazy Loading**: Hibernate lazy loading for related entities
- **Query Optimization**: Indexed database columns for common queries
- **Caching**: Browser caching for static resources
- **Compression**: Gzip compression for responses (configurable)

## 📱 Mobile Responsiveness

Zola is fully responsive and optimized for:
- **Desktop**: Full-featured interface with sidebar
- **Tablet**: Adaptive layout with collapsible sidebar
- **Mobile**: Touch-optimized interface with slide-out navigation

## 🔄 Auto-Refresh System

- **Message Polling**: Every 3 seconds when chat is active
- **Smart Updates**: Only refreshes when new messages detected
- **Performance**: Minimal server load with efficient queries
- **Real-time Feel**: Near-instant message delivery

## 🎨 UI/UX Features

- **Modern Design**: Clean, minimalist interface
- **Smooth Animations**: CSS transitions and micro-interactions
- **Emoji Support**: Rich emoji picker with common expressions
- **File Previews**: Type-specific icons for different file types
- **Status Indicators**: Online/offline/away/busy status display
- **Message Timestamps**: Relative and absolute time display

## 🔧 Development Setup

For development and customization:

1. **Import into IDE** (IntelliJ IDEA, Eclipse, VS Code)
2. **Configure Tomcat** in your IDE
3. **Set up hot reload** for rapid development
4. **Enable debug logging** in hibernate.cfg.xml
5. **Use Maven for dependency management**

## 📈 Scalability Considerations

- **Database Indexing**: Optimized for common query patterns
- **Connection Pooling**: Configurable pool sizes
- **Stateless Design**: Easy horizontal scaling
- **File Storage**: Can be moved to external storage (S3, etc.)
- **Caching Layer**: Ready for Redis/Memcached integration

## 🤝 Contributing

To contribute to Zola:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is created for educational and demonstration purposes. Feel free to use and modify for your own projects.

## 🆘 Support

For issues and questions:

1. Check the troubleshooting section above
2. Review Tomcat and application logs
3. Verify database connectivity
4. Ensure all prerequisites are met
5. Check file permissions for uploads directory

## 🎯 Production Deployment Notes

For production deployment:

1. **Enable HTTPS** with SSL certificates
2. **Use strong passwords** and implement password hashing
3. **Configure proper logging** with log rotation
4. **Set up monitoring** and health checks
5. **Implement backup strategies** for database and files
6. **Configure firewall rules** and security policies
7. **Use environment-specific configurations**

---

**Built with ❤️ using Java Servlets and Hibernate**

**Version**: 1.0.0  
**Last Updated**: December 2024  
**Target Platform**: Apache Tomcat 10+ with MySQL 8+

**Zola** - Connecting people through modern messaging technology.