package com.spendilizer.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long userId;

    @Column(name = "user_unique_id", unique = true, nullable = false)
    private String userUniqueId;

    @Column(name = "customer_id", unique = true, nullable = false)
    private Long customerId;

    @Column(name = "user_email")
    private String userEmail;

    @Column(name = "user_password")
    private String userPassword;

    @Column(name = "user_creation_date_time")
    private LocalDateTime userCreationDateTime;

    @Column(name = "user_modification_date_time")
    private LocalDateTime userModificationDateTime;

    @Column(name = "user_last_login")
    private LocalDateTime userLastLogin;

    @Enumerated(EnumType.STRING)
    @Column(name = "user_status")
    private UserStatusEnum userStatus;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    private UserBasicDetails userBasicDetails;

    public User() {}

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getUserUniqueId() { return userUniqueId; }
    public void setUserUniqueId(String userUniqueId) { this.userUniqueId = userUniqueId; }

    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getUserPassword() { return userPassword; }
    public void setUserPassword(String userPassword) { this.userPassword = userPassword; }

    public LocalDateTime getUserCreationDateTime() { return userCreationDateTime; }
    public void setUserCreationDateTime(LocalDateTime userCreationDateTime) { this.userCreationDateTime = userCreationDateTime; }

    public LocalDateTime getUserModificationDateTime() { return userModificationDateTime; }
    public void setUserModificationDateTime(LocalDateTime userModificationDateTime) { this.userModificationDateTime = userModificationDateTime; }

    public LocalDateTime getUserLastLogin() { return userLastLogin; }
    public void setUserLastLogin(LocalDateTime userLastLogin) { this.userLastLogin = userLastLogin; }

    public UserStatusEnum getUserStatus() { return userStatus; }
    public void setUserStatus(UserStatusEnum userStatus) { this.userStatus = userStatus; }

    public UserBasicDetails getUserBasicDetails() { return userBasicDetails; }
    public void setUserBasicDetails(UserBasicDetails userBasicDetails) { this.userBasicDetails = userBasicDetails; }

    @Override
    public String toString() {
        return "User{" +
                "userId=" + userId +
                ", userEmail='" + userEmail + '\'' +
                '}';
    }
}
