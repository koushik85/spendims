package com.spendilizer.repository;

import com.spendilizer.entity.NotificationState;
import com.spendilizer.entity.Subscription;
import com.spendilizer.entity.SubscriptionNotification;
import com.spendilizer.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface SubscriptionNotificationRepository extends JpaRepository<SubscriptionNotification, Long> {

    List<SubscriptionNotification> findAllByUserAndStateInOrderByDaysUntilDueAsc(
            User user, List<NotificationState> states);

    List<SubscriptionNotification> findAllByUserAndState(User user, NotificationState state);

    long countByUserAndState(User user, NotificationState state);

    boolean existsBySubscriptionAndNotifiedDate(Subscription subscription, LocalDate notifiedDate);

    Optional<SubscriptionNotification> findByIdAndUser(Long id, User user);
}
