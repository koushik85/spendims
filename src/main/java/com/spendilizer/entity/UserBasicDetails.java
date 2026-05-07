package com.spendilizer.entity;

import jakarta.persistence.*;
import org.springframework.format.annotation.DateTimeFormat;

import java.util.Date;

@Entity
@Table(name = "user_basic_details")
public class UserBasicDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_basic_id")
    private Long userBasicId;

    @Column(name = "customer_id", insertable = false, updatable = false)
    private Long customerId;

    @Column(name = "user_first_name")
    private String userFirstName;

    @Column(name = "user_last_name")
    private String userLastName;

    @Column(name = "user_phone_number")
    private String userPhoneNumber;

    @Column(name = "user_gender")
    private String userGender;

    @Column(name = "user_dob")
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date userDob;

    @Column(name = "user_image")
    private String userImage;

    @Column(name = "pan", length = 10)
    private String pan;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", referencedColumnName = "customer_id")
    private User user;

    @Transient
    private String userNameDisplay;

    @Transient
    private String userDobDisplay;

    @Transient
    private String userImageData;

    public UserBasicDetails() {}

    public Long getUserBasicId() { return userBasicId; }
    public void setUserBasicId(Long userBasicId) { this.userBasicId = userBasicId; }

    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }

    public String getUserFirstName() { return userFirstName; }
    public void setUserFirstName(String userFirstName) { this.userFirstName = userFirstName; }

    public String getUserLastName() { return userLastName; }
    public void setUserLastName(String userLastName) { this.userLastName = userLastName; }

    public String getUserPhoneNumber() { return userPhoneNumber; }
    public void setUserPhoneNumber(String userPhoneNumber) { this.userPhoneNumber = userPhoneNumber; }

    public String getUserGender() { return userGender; }
    public void setUserGender(String userGender) { this.userGender = userGender; }

    public Date getUserDob() { return userDob; }
    public void setUserDob(Date userDob) { this.userDob = userDob; }

    public String getUserImage() { return userImage; }
    public void setUserImage(String userImage) { this.userImage = userImage; }

    public String getPan() { return pan; }
    public void setPan(String pan) { this.pan = pan; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public String getUserNameDisplay() { return userNameDisplay; }
    public void setUserNameDisplay(String userNameDisplay) { this.userNameDisplay = userNameDisplay; }

    public String getUserDobDisplay() { return userDobDisplay; }
    public void setUserDobDisplay(String userDobDisplay) { this.userDobDisplay = userDobDisplay; }

    public String getUserImageData() { return userImageData; }
    public void setUserImageData(String userImageData) { this.userImageData = userImageData; }
}
