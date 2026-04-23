package com.spendilizer.entity;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "subscription_notification",
        uniqueConstraints = @UniqueConstraint(columnNames = {"subscription_id", "notified_date"}))
public class SubscriptionNotification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "subscription_id", nullable = false)
    private Subscription subscription;

    @Column(name = "days_until_due", nullable = false)
    private int daysUntilDue;

    @Column(name = "notified_date", nullable = false)
    private LocalDate notifiedDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10, columnDefinition = "VARCHAR(10) NOT NULL DEFAULT 'NEW'")
    private NotificationState state = NotificationState.NEW;

    public SubscriptionNotification() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public Subscription getSubscription() { return subscription; }
    public void setSubscription(Subscription subscription) { this.subscription = subscription; }

    public int getDaysUntilDue() { return daysUntilDue; }
    public void setDaysUntilDue(int daysUntilDue) { this.daysUntilDue = daysUntilDue; }

    public LocalDate getNotifiedDate() { return notifiedDate; }
    public void setNotifiedDate(LocalDate notifiedDate) { this.notifiedDate = notifiedDate; }

    public NotificationState getState() { return state; }
    public void setState(NotificationState state) { this.state = state; }
}
