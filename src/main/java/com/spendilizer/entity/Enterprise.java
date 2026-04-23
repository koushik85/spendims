package com.spendilizer.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "enterprise")
public class Enterprise {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "enterprise_id")
    private int enterpriseId;

    @Column(name = "enterprise_name", length = 100, nullable = false)
    private String enterpriseName;

    @OneToOne
    @JoinColumn(name = "owner_user_id")
    private User owner;

    @Enumerated(EnumType.STRING)
    @Column(name = "approval_status", nullable = false, length = 20)
    private ApprovalStatus approvalStatus = ApprovalStatus.PENDING;

    public Enterprise() {}

    public Enterprise(String enterpriseName, User owner) {
        this.enterpriseName = enterpriseName;
        this.owner = owner;
    }

    public int getEnterpriseId() { return enterpriseId; }
    public void setEnterpriseId(int enterpriseId) { this.enterpriseId = enterpriseId; }

    public String getEnterpriseName() { return enterpriseName; }
    public void setEnterpriseName(String enterpriseName) { this.enterpriseName = enterpriseName; }

    public User getOwner() { return owner; }
    public void setOwner(User owner) { this.owner = owner; }

    public ApprovalStatus getApprovalStatus() { return approvalStatus; }
    public void setApprovalStatus(ApprovalStatus approvalStatus) { this.approvalStatus = approvalStatus; }
}
