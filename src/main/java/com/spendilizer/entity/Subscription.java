package com.spendilizer.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "subscription")
public class Subscription {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(length = 100)
    private String provider;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    @Column(name = "billing_cycle", nullable = false)
    private BillingCycle billingCycle = BillingCycle.MONTHLY;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "next_billing_date", nullable = false)
    private LocalDate nextBillingDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SubscriptionCategory category = SubscriptionCategory.OTHER;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SubscriptionStatus status = SubscriptionStatus.ACTIVE;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by", nullable = false)
    private User createdBy;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public Subscription() {}

    /** Monthly equivalent cost for budgeting display. */
    public BigDecimal getMonthlyEquivalent() {
        if (amount == null) return BigDecimal.ZERO;
        return switch (billingCycle) {
            case WEEKLY    -> amount.multiply(BigDecimal.valueOf(52)).divide(BigDecimal.valueOf(12), 2, RoundingMode.HALF_UP);
            case MONTHLY   -> amount;
            case QUARTERLY -> amount.divide(BigDecimal.valueOf(3), 2, RoundingMode.HALF_UP);
            case YEARLY    -> amount.divide(BigDecimal.valueOf(12), 2, RoundingMode.HALF_UP);
        };
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getProvider() { return provider; }
    public void setProvider(String provider) { this.provider = provider; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public BillingCycle getBillingCycle() { return billingCycle; }
    public void setBillingCycle(BillingCycle billingCycle) { this.billingCycle = billingCycle; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getNextBillingDate() { return nextBillingDate; }
    public void setNextBillingDate(LocalDate nextBillingDate) { this.nextBillingDate = nextBillingDate; }

    public SubscriptionCategory getCategory() { return category; }
    public void setCategory(SubscriptionCategory category) { this.category = category; }

    public SubscriptionStatus getStatus() { return status; }
    public void setStatus(SubscriptionStatus status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public User getCreatedBy() { return createdBy; }
    public void setCreatedBy(User createdBy) { this.createdBy = createdBy; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
