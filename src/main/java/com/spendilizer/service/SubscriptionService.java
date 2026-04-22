package com.spendilizer.service;

import com.spendilizer.entity.*;
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

    public SubscriptionService(SubscriptionRepository subscriptionRepository) {
        this.subscriptionRepository = subscriptionRepository;
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
        existing.setNextBillingDate(updated.getNextBillingDate());
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

    /** Total monthly equivalent cost across all ACTIVE subscriptions. */
    public BigDecimal totalMonthlyCost(User user) {
        return getActive(user).stream()
                .map(Subscription::getMonthlyEquivalent)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
