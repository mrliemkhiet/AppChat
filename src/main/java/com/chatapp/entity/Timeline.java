package com.chatapp.entity;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "timeline")
public class Timeline {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(columnDefinition = "TEXT")
    private String content;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "file_id")
    private FileEntity file;
    
    @Enumerated(EnumType.STRING)
    private TimelineType type = TimelineType.TEXT;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "expires_at")
    private LocalDateTime expiresAt;
    
    public enum TimelineType {
        TEXT, IMAGE, VIDEO
    }
    
    // Constructors
    public Timeline() {}
    
    public Timeline(String content, User user, TimelineType type) {
        this.content = content;
        this.user = user;
        this.type = type;
        this.createdAt = LocalDateTime.now();
        // Timeline posts expire after 24 hours
        this.expiresAt = LocalDateTime.now().plusHours(24);
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (expiresAt == null) {
            expiresAt = LocalDateTime.now().plusHours(24);
        }
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    
    public FileEntity getFile() { return file; }
    public void setFile(FileEntity file) { this.file = file; }
    
    public TimelineType getType() { return type; }
    public void setType(TimelineType type) { this.type = type; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }
}