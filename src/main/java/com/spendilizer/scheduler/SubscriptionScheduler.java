package com.spendilizer.scheduler;

import com.spendilizer.entity.NotificationState;
import com.spendilizer.entity.Subscription;
import com.spendilizer.entity.SubscriptionNotification;
import com.spendilizer.entity.SubscriptionStatus;
import com.spendilizer.repository.SubscriptionNotificationRepository;
import com.spendilizer.repository.SubscriptionRepository;
import com.spendilizer.service.SubscriptionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Component
public class SubscriptionScheduler {

    private static final Logger log = LoggerFactory.getLogger(SubscriptionScheduler.class);
    private static final int NOTIFY_DAYS_BEFORE = 7;

    private final SubscriptionRepository subscriptionRepository;
    private final SubscriptionNotificationRepository notificationRepository;

    public SubscriptionScheduler(SubscriptionRepository subscriptionRepository,
                                 SubscriptionNotificationRepository notificationRepository) {
        this.subscriptionRepository = subscriptionRepository;
        this.notificationRepository = notificationRepository;
    }

    /**
     * Runs every day at 8:00 AM.
     * 1. Advances nextBillingDate for subscriptions whose billing date has passed.
     * 2. Creates renewal notification records for subscriptions due within 7 days.
     */
    @Scheduled(cron = "0 0 8 * * *")
    @Transactional
    public void dailySubscriptionMaintenance() {
        LocalDate today = LocalDate.now();
        log.info("SUBSCRIPTION_SCHEDULER running for date={}", today);

        List<Subscription> active = subscriptionRepository.findAllByStatus(SubscriptionStatus.ACTIVE);
        int advanced = 0;
        int notified = 0;

        for (Subscription sub : active) {
            LocalDate nextBilling = sub.getNextBillingDate();
            if (nextBilling == null) continue;

            // Advance past-due billing dates
            if (!nextBilling.isAfter(today)) {
                while (!nextBilling.isAfter(today)) {
                    nextBilling = SubscriptionService.advanceByOneCycle(nextBilling, sub.getBillingCycle());
                }
                sub.setNextBillingDate(nextBilling);
                subscriptionRepository.save(sub);
                advanced++;
            }

            // Create notification if billing is within NOTIFY_DAYS_BEFORE days
            long daysUntilDue = ChronoUnit.DAYS.between(today, nextBilling);
            if (daysUntilDue >= 0 && daysUntilDue <= NOTIFY_DAYS_BEFORE) {
                boolean alreadyNotified = notificationRepository.existsBySubscriptionAndNotifiedDate(sub, today);
                if (!alreadyNotified) {
                    SubscriptionNotification notification = new SubscriptionNotification();
                    notification.setUser(sub.getCreatedBy());
                    notification.setSubscription(sub);
                    notification.setDaysUntilDue((int) daysUntilDue);
                    notification.setNotifiedDate(today);
                    notification.setState(NotificationState.NEW);
                    notificationRepository.save(notification);
                    notified++;
                }
            }
        }

        log.info("SUBSCRIPTION_SCHEDULER done: advanced={} notified={}", advanced, notified);
    }
}
