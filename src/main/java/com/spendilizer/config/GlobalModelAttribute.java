package com.spendilizer.config;

import com.spendilizer.entity.User;
import com.spendilizer.service.SubscriptionService;
import com.spendilizer.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import java.util.Collection;
import java.util.Collections;

@ControllerAdvice
public class GlobalModelAttribute {

    private final UserService userService;
    private final SubscriptionService subscriptionService;

    public GlobalModelAttribute(UserService userService, SubscriptionService subscriptionService) {
        this.userService = userService;
        this.subscriptionService = subscriptionService;
    }

    @ModelAttribute("user")
    public User getAuthenticatedUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || auth.getPrincipal().equals("anonymousUser")) {
            return null;
        }
        String email = auth.getName();
        return email != null ? userService.getUserByEmail(email) : null;
    }

    @ModelAttribute
    public void addCommonAttributes(HttpServletRequest request, Model model) {
        model.addAttribute("currentUri", request.getRequestURI());
    }

    @ModelAttribute
    @SuppressWarnings("unchecked")
    public void roles(HttpServletRequest request, Model model) {
        Collection<? extends GrantedAuthority> roles =
                (Collection<? extends GrantedAuthority>) request.getSession().getAttribute("AVAILABLE_ROLES");
        model.addAttribute("roles", roles);
    }

    @ModelAttribute
    public void addNavNotifications(Model model) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || auth.getPrincipal().equals("anonymousUser")) {
            model.addAttribute("navNotifications", Collections.emptyList());
            model.addAttribute("newNotificationCount", 0L);
            return;
        }
        try {
            User user = userService.getUserByEmail(auth.getName());
            if (user != null) {
                model.addAttribute("navNotifications", subscriptionService.getActiveNotifications(user));
                model.addAttribute("newNotificationCount", subscriptionService.getNewNotificationCount(user));
            } else {
                model.addAttribute("navNotifications", Collections.emptyList());
                model.addAttribute("newNotificationCount", 0L);
            }
        } catch (Exception e) {
            model.addAttribute("navNotifications", Collections.emptyList());
            model.addAttribute("newNotificationCount", 0L);
        }
    }
}
