package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.*;
import com.spendilizer.service.SubscriptionService;
import com.spendilizer.service.UserService;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/personal/subscriptions")
public class SubscriptionController {

    private final SubscriptionService subscriptionService;
    private final UserService userService;

    public SubscriptionController(SubscriptionService subscriptionService, UserService userService) {
        this.subscriptionService = subscriptionService;
        this.userService = userService;
    }

    @GetMapping
    public String list(@AuthenticationPrincipal CustomUserDetails principal,
                       HttpSession session, Model model) {
        User user = userService.getUserByEmail(principal.getUsername());
        session.setAttribute("currentModule", "PERSONAL");
        model.addAttribute("subscriptions", subscriptionService.getAll(user));
        model.addAttribute("monthlyCost", subscriptionService.totalMonthlyCost(user));
        model.addAttribute("activeCount", subscriptionService.getActive(user).size());
        model.addAttribute("notifications", subscriptionService.getActiveNotifications(user));
        model.addAttribute("cycles", BillingCycle.values());
        model.addAttribute("categories", SubscriptionCategory.values());
        return "personal/subscriptions/list";
    }

    @GetMapping("/new")
    public String newForm(HttpSession session, Model model) {
        session.setAttribute("currentModule", "PERSONAL");
        model.addAttribute("subscription", new Subscription());
        model.addAttribute("cycles", BillingCycle.values());
        model.addAttribute("categories", SubscriptionCategory.values());
        model.addAttribute("editMode", false);
        return "personal/subscriptions/form";
    }

    @PostMapping("/new")
    public String create(@ModelAttribute Subscription subscription,
                         @AuthenticationPrincipal CustomUserDetails principal,
                         RedirectAttributes ra) {
        User user = userService.getUserByEmail(principal.getUsername());
        subscriptionService.save(subscription, user);
        ra.addFlashAttribute("success", "Subscription \"" + subscription.getName() + "\" added.");
        return "redirect:/personal/subscriptions";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id,
                           @AuthenticationPrincipal CustomUserDetails principal,
                           HttpSession session, Model model) {
        User user = userService.getUserByEmail(principal.getUsername());
        session.setAttribute("currentModule", "PERSONAL");
        Subscription sub = subscriptionService.getById(id, user)
                .orElseThrow(() -> new RuntimeException("Subscription not found"));
        model.addAttribute("subscription", sub);
        model.addAttribute("cycles", BillingCycle.values());
        model.addAttribute("categories", SubscriptionCategory.values());
        model.addAttribute("statuses", SubscriptionStatus.values());
        model.addAttribute("editMode", true);
        return "personal/subscriptions/form";
    }

    @PostMapping("/{id}/edit")
    public String update(@PathVariable Long id,
                         @ModelAttribute Subscription subscription,
                         @AuthenticationPrincipal CustomUserDetails principal,
                         RedirectAttributes ra) {
        User user = userService.getUserByEmail(principal.getUsername());
        subscriptionService.update(id, subscription, user);
        ra.addFlashAttribute("success", "Subscription updated.");
        return "redirect:/personal/subscriptions";
    }

    @PostMapping("/{id}/status")
    public String setStatus(@PathVariable Long id,
                            @RequestParam SubscriptionStatus status,
                            @AuthenticationPrincipal CustomUserDetails principal,
                            RedirectAttributes ra) {
        User user = userService.getUserByEmail(principal.getUsername());
        subscriptionService.setStatus(id, status, user);
        ra.addFlashAttribute("success", "Status updated.");
        return "redirect:/personal/subscriptions";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id,
                         @AuthenticationPrincipal CustomUserDetails principal,
                         RedirectAttributes ra) {
        User user = userService.getUserByEmail(principal.getUsername());
        subscriptionService.delete(id, user);
        ra.addFlashAttribute("success", "Subscription deleted.");
        return "redirect:/personal/subscriptions";
    }

    // ── Notification endpoints ────────────────────────────────────────

    @PostMapping("/notifications/{notifId}/remove")
    public String removeNotification(@PathVariable Long notifId,
                                     @AuthenticationPrincipal CustomUserDetails principal) {
        User user = userService.getUserByEmail(principal.getUsername());
        subscriptionService.removeNotification(notifId, user);
        return "redirect:/personal/subscriptions";
    }

    @PostMapping("/notifications/dismiss-all")
    public String dismissAll(@AuthenticationPrincipal CustomUserDetails principal) {
        User user = userService.getUserByEmail(principal.getUsername());
        subscriptionService.removeAllNotifications(user);
        return "redirect:/personal/subscriptions";
    }
}
