package com.spendilizer.service;

import com.spendilizer.entity.*;
import com.spendilizer.repository.SubscriptionNotificationRepository;
import com.spendilizer.repository.SubscriptionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
public class SubscriptionService {

    private final SubscriptionRepository subscriptionRepository;
    private final SubscriptionNotificationRepository notificationRepository;

    public SubscriptionService(SubscriptionRepository subscriptionRepository,
                               SubscriptionNotificationRepository notificationRepository) {
        this.subscriptionRepository = subscriptionRepository;
        this.notificationRepository = notificationRepository;
    }

    public List<Subscription> getAll(User user) {
        return subscriptionRepository.findAllByCreatedByOrderByNextBillingDateAsc(user);
    }

    public List<Subscription> getActive(User user) {
        return subscriptionRepository.findAllByCreatedByAndStatusOrderByNextBillingDateAsc(
                user, SubscriptionStatus.ACTIVE);
    }

    public List<Subscription> getDueWithin(User user, int days) {
        LocalDate from = LocalDate.now();
        LocalDate to   = from.plusDays(days);
        return subscriptionRepository.findAllByCreatedByAndStatusAndNextBillingDateBetween(
                user, SubscriptionStatus.ACTIVE, from, to);
    }

    public Optional<Subscription> getById(Long id, User user) {
        return subscriptionRepository.findByIdAndCreatedBy(id, user);
    }

    @Transactional
    public Subscription save(Subscription sub, User user) {
        sub.setCreatedBy(user);
        sub.setNextBillingDate(computeNextBillingDate(sub.getStartDate(), sub.getBillingCycle()));
        return subscriptionRepository.save(sub);
    }

    @Transactional
    public Subscription update(Long id, Subscription updated, User user) {
        Subscription existing = getById(id, user)
                .orElseThrow(() -> new RuntimeException("Subscription not found"));
        existing.setName(updated.getName());
        existing.setProvider(updated.getProvider());
        existing.setAmount(updated.getAmount());
        existing.setBillingCycle(updated.getBillingCycle());
        existing.setStartDate(updated.getStartDate());
        existing.setNextBillingDate(computeNextBillingDate(updated.getStartDate(), updated.getBillingCycle()));
        existing.setCategory(updated.getCategory());
        existing.setStatus(updated.getStatus());
        existing.setNotes(updated.getNotes());
        return subscriptionRepository.save(existing);
    }

    @Transactional
    public void delete(Long id, User user) {
        Subscription sub = getById(id, user)
                .orElseThrow(() -> new RuntimeException("Subscription not found"));
        subscriptionRepository.delete(sub);
    }

    @Transactional
    public void setStatus(Long id, SubscriptionStatus status, User user) {
        Subscription sub = getById(id, user)
                .orElseThrow(() -> new RuntimeException("Subscription not found"));
        sub.setStatus(status);
        subscriptionRepository.save(sub);
    }

    public BigDecimal totalMonthlyCost(User user) {
        return getActive(user).stream()
                .map(Subscription::getMonthlyEquivalent)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    // ── Notifications ─────────────────────────────────────────────────

    /** NEW + SEEN — visible in the bell dropdown. */
    public List<SubscriptionNotification> getActiveNotifications(User user) {
        return notificationRepository.findAllByUserAndStateInOrderByDaysUntilDueAsc(
                user, List.of(NotificationState.NEW, NotificationState.SEEN));
    }

    /** Count of unread (NEW) notifications — drives the badge. */
    public long getNewNotificationCount(User user) {
        return notificationRepository.countByUserAndState(user, NotificationState.NEW);
    }

    /** Mark all NEW → SEEN (called when bell dropdown is opened). */
    @Transactional
    public void markAllNotificationsSeen(User user) {
        List<SubscriptionNotification> newOnes =
                notificationRepository.findAllByUserAndState(user, NotificationState.NEW);
        newOnes.forEach(n -> n.setState(NotificationState.SEEN));
        notificationRepository.saveAll(newOnes);
    }

    /** Mark a single notification as REMOVED (dismissed by user). */
    @Transactional
    public void removeNotification(Long id, User user) {
        notificationRepository.findByIdAndUser(id, user).ifPresent(n -> {
            n.setState(NotificationState.REMOVED);
            notificationRepository.save(n);
        });
    }

    /** Mark all active notifications as REMOVED. */
    @Transactional
    public void removeAllNotifications(User user) {
        List<SubscriptionNotification> active = getActiveNotifications(user);
        active.forEach(n -> n.setState(NotificationState.REMOVED));
        notificationRepository.saveAll(active);
    }

    // ── Date helpers ──────────────────────────────────────────────────

    public static LocalDate computeNextBillingDate(LocalDate startDate, BillingCycle cycle) {
        LocalDate today = LocalDate.now();
        LocalDate next = startDate;
        while (!next.isAfter(today)) {
            next = advanceByOneCycle(next, cycle);
        }
        return next;
    }

    public static LocalDate advanceByOneCycle(LocalDate date, BillingCycle cycle) {
        return switch (cycle) {
            case WEEKLY    -> date.plusWeeks(1);
            case MONTHLY   -> date.plusMonths(1);
            case QUARTERLY -> date.plusMonths(3);
            case YEARLY    -> date.plusYears(1);
        };
    }
}
