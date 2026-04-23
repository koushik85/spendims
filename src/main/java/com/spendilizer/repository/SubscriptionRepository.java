package com.spendilizer.repository;

import com.spendilizer.entity.Subscription;
import com.spendilizer.entity.SubscriptionStatus;
import com.spendilizer.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface SubscriptionRepository extends JpaRepository<Subscription, Long> {
    List<Subscription> findAllByCreatedByOrderByNextBillingDateAsc(User createdBy);
    List<Subscription> findAllByCreatedByAndStatusOrderByNextBillingDateAsc(User createdBy, SubscriptionStatus status);
    List<Subscription> findAllByCreatedByAndStatusAndNextBillingDateBetween(User createdBy, SubscriptionStatus status, LocalDate from, LocalDate to);
    Optional<Subscription> findByIdAndCreatedBy(Long id, User createdBy);
    List<Subscription> findAllByStatus(SubscriptionStatus status);
}
