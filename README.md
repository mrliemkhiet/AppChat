# ChatApp - Java Servlet Chat Application

A comprehensive chat application built with Java Servlets, Hibernate, and MySQL, designed for deployment on Apache Tomcat.

## Features

- **Instant Messaging**: Real-time private and group messaging
- **Group Chats**: Create and manage group conversations
- **File Sharing**: Upload and share files up to 10MB
- **Stickers/Emojis**: Rich emoji support for expressive messaging
- **Timeline**: Share status updates that expire after 24 hours
- **User Management**: User registration, authentication, and profile management
- **Responsive Design**: Modern, mobile-friendly interface

## Technology Stack

- **Backend**: Java 17+, Servlets, Hibernate 5.6
- **Database**: MySQL 8.0
- **Build Tool**: Maven 3.6+
- **Server**: Apache Tomcat 10+
- **Frontend**: JSP, HTML5, CSS3, JavaScript

## Project Structure

```
ChatApp/
├── src/main/java/com/chatapp/
│   ├── entity/          # Hibernate entity classes
│   │   ├── User.java
│   │   ├── Group.java
│   │   ├── Message.java
│   │   ├── FileEntity.java
│   │   └── Timeline.java
│   ├── servlet/         # Servlet controllers
│   │   ├── ChatServlet.java
│   │   ├── FileUploadServlet.java
│   │   └── FileDownloadServlet.java
│   └── util/           # Utility classes
│       ├── HibernateUtil.java
│       └── HibernateServletContextListener.java
├── src/main/resources/
│   └── hibernate.cfg.xml
├── src/main/webapp/
│   ├── WEB-INF/
│   │   ├── web.xml
│   │   └── views/
│   │       ├── chat.jsp
│   │       └── error.jsp
│   └── uploads/        # File upload directory
├── supabase/migrations/
│   └── 20250624125812_golden_harbor.sql   # Database schema
├── pom.xml
└── README.md
```

## Prerequisites

Before building and deploying the application, ensure you have:

1. **Java Development Kit (JDK) 17 or higher**
2. **Apache Maven 3.6 or higher**
3. **MySQL 8.0 or higher**
4. **Apache Tomcat 10.0 or higher**
5. **IDE** (IntelliJ IDEA, Eclipse, or VS Code with Java extensions)

## Setup and Installation

### Easy Setup (Windows)

1. **Install JDK 17+ and Maven** if not already installed

2. **Run the setup scripts** (as Administrator):
   ```powershell
   # Install and configure MySQL
   .\setup-mysql.ps1
   
   # Install and configure Tomcat
   .\setup-tomcat.ps1
   ```

3. **Build and deploy** the application:
   ```powershell
   .\build-and-deploy.ps1
   ```

4. **Access the application** at `http://localhost:8080/ChatApp/`

### Manual Setup

#### Database Setup

1. **Install MySQL** and ensure it's running on port 3306

2. **Create the database** by running the SQL script:
   ```bash
   mysql -u root -p < supabase/migrations/20250624125812_golden_harbor.sql
   ```

3. **Update database credentials** in `src/main/resources/hibernate.cfg.xml` if needed:
   ```xml
   <property name="hibernate.connection.username">root</property>
   <property name="hibernate.connection.password"></property>
   ```

## Building the Application

1. **Navigate to the project directory**:
   ```bash
   cd ChatApp
   ```

2. **Set JAVA_HOME** environment variable to point to JDK 17+:
   ```powershell
   # PowerShell (Windows)
   $env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
   
   # Or permanently set it via System Properties > Environment Variables
   ```

3. **Build the project** using Maven:
   ```bash
   mvn clean compile
   ```

4. **Package the application** into a WAR file:
   ```bash
   mvn clean package
   ```

   This will create `ChatApp.war` in the `target/` directory.

## Deployment to Apache Tomcat

1. **Stop Tomcat** if it's currently running

2. **Copy the WAR file** to Tomcat's webapps directory:
   ```bash
   cp target/ChatApp.war $TOMCAT_HOME/webapps/
   ```

3. **Start Tomcat**:
   ```bash
   $TOMCAT_HOME/bin/startup.sh    # Linux/Mac
   %TOMCAT_HOME%\bin\startup.bat  # Windows
   ```

4. **Access the application** at:
   ```
   http://localhost:8080/ChatApp/chat
   ```

## Troubleshooting

### Hibernate "User is not mapped" Error

If you encounter the "User is not mapped" error:

1. **Verify the database connection** in `hibernate.cfg.xml`
2. **Check that MySQL service is running**
3. **Ensure the `users` table exists** in the database
4. **Check hibernate.cfg.xml** has all entity mappings:
   ```xml
   <mapping class="com.chatapp.entity.User"/>
   <mapping class="com.chatapp.entity.Group"/>
   <mapping class="com.chatapp.entity.Message"/>
   <mapping class="com.chatapp.entity.FileEntity"/>
   <mapping class="com.chatapp.entity.Timeline"/>
   ```
5. **Verify HibernateUtil** has explicit class registration
6. **Ensure HibernateServletContextListener** is registered in `web.xml`

**hibernate.cfg.xml**:
```xml
<property name="hibernate.connection.url">jdbc:mysql://localhost:3306/chatappdb</property>
<property name="hibernate.connection.username">root</property>
<property name="hibernate.connection.password">your_password</property>
```

**web.xml** (context parameters):
```xml
<context-param>
    <param-name>hibernate.connection.url</param-name>
    <param-value>jdbc:mysql://localhost:3306/chatappdb</param-value>
</context-param>
```

### File Upload Configuration

- Maximum file size: 10MB (configurable in `FileUploadServlet.java`)
- Upload directory: `webapps/ChatApp/uploads/`
- Supported file types: All types (configurable)

## Default Users

The application comes with sample users for testing:

| Username | Password | Full Name |
|----------|----------|-----------|
| demo | demo123 | Demo User |
| alice | alice123 | Alice Johnson |
| bob | bob123 | Bob Smith |
| charlie | charlie123 | Charlie Brown |
| diana | diana123 | Diana Prince |

## API Endpoints

### Chat Servlet (`/chat`)

**GET Requests**:
- `?action=getMessages&groupId=1` - Get group messages
- `?action=getMessages&receiverId=2` - Get private messages
- `?action=getGroups` - Get user's groups
- `?action=getUsers` - Get all users

**POST Requests**:
- `action=sendMessage` - Send a message
- `action=createGroup` - Create a new group
- `action=login` - User authentication

### File Upload (`/upload`)

**POST**: Upload files with multipart/form-data

### File Download (`/download`)

**GET**: `?fileId=1` - Download file by ID

## Development

### Running in Development Mode

1. **Import the project** into your IDE
2. **Configure Tomcat** in your IDE
3. **Set up database connection**
4. **Run the application** directly from IDE

### Adding New Features

1. **Entity Classes**: Add new entities in `com.chatapp.entity`
2. **Servlets**: Create new servlets in `com.chatapp.servlet`
3. **Database**: Update schema and Hibernate configuration
4. **Frontend**: Modify JSP files and add JavaScript functionality

## Troubleshooting

### Common Issues

1. **Database Connection Failed**:
   - Check MySQL is running
   - Verify credentials in hibernate.cfg.xml
   - Ensure database exists

2. **File Upload Issues**:
   - Check upload directory permissions
   - Verify file size limits
   - Ensure temp directory is writable

3. **Tomcat Deployment Issues**:
   - Check Tomcat logs in `logs/catalina.out`
   - Verify WAR file is properly built
   - Ensure all dependencies are included

### Logs

- **Tomcat Logs**: `$TOMCAT_HOME/logs/`
- **Application Logs**: Console output (configurable with logging framework)
- **Hibernate SQL**: Enabled in hibernate.cfg.xml for debugging

## Security Considerations

- **Password Encryption**: Implement proper password hashing (currently plain text for demo)
- **SQL Injection**: Using Hibernate parameterized queries
- **File Upload Security**: Validate file types and sizes
- **Session Management**: Proper session handling implemented

## Performance Optimization

- **Database Indexing**: Optimized indexes for common queries
- **Connection Pooling**: Hibernate connection pool configured
- **Lazy Loading**: Hibernate lazy loading for related entities
- **Caching**: Consider adding second-level cache for production

## License

This project is created for educational and demonstration purposes.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review Tomcat and application logs
3. Verify database connectivity
4. Ensure all prerequisites are met

---

**Built with ❤️ using Java Servlets and Hibernate**

**Date**: June 24, 2025, 07:50 PM +07
**Version**: 1.0.0
**Target**: Apache Tomcat 9+ Deployment