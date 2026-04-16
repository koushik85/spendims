package com.spendilizer.config;

import com.spendilizer.entity.User;
import com.spendilizer.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import java.util.Collection;

@ControllerAdvice
public class GlobalModelAttribute {

    private final UserService userService;

    public GlobalModelAttribute(UserService userService) {
        this.userService = userService;
    }

    @ModelAttribute("user")
    public User getAuthenticatedUser(Model model) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || auth.getPrincipal().equals("anonymousUser")) {
            return null;
        }
        String email = auth.getName();
        if (email != null) {
            User user = userService.getUserByEmail(email);
            return user;
        }
        return null;
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
}

