package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.User;
import com.spendilizer.service.SubscriptionService;
import com.spendilizer.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
public class NotificationApiController {

    private final SubscriptionService subscriptionService;
    private final UserService userService;

    public NotificationApiController(SubscriptionService subscriptionService, UserService userService) {
        this.subscriptionService = subscriptionService;
        this.userService = userService;
    }

    /** Called when the bell dropdown opens — transitions NEW → SEEN. */
    @PostMapping("/mark-seen")
    public ResponseEntity<Map<String, Object>> markSeen(
            @AuthenticationPrincipal CustomUserDetails principal) {
        User user = userService.getUserByEmail(principal.getUsername());
        subscriptionService.markAllNotificationsSeen(user);
        return ResponseEntity.ok(Map.of(
                "newCount", 0L,
                "totalActive", subscriptionService.getActiveNotifications(user).size()
        ));
    }

    /** Called when user clicks ✕ on a single notification — transitions to REMOVED. */
    @PostMapping("/{id}/remove")
    public ResponseEntity<Map<String, Object>> remove(
            @PathVariable Long id,
            @AuthenticationPrincipal CustomUserDetails principal) {
        User user = userService.getUserByEmail(principal.getUsername());
        subscriptionService.removeNotification(id, user);
        return ResponseEntity.ok(Map.of(
                "newCount", subscriptionService.getNewNotificationCount(user),
                "totalActive", subscriptionService.getActiveNotifications(user).size()
        ));
    }
}
