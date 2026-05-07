package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.User;
import com.spendilizer.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/profile")
public class ProfileController {

    private static final Logger logger = LoggerFactory.getLogger(ProfileController.class);

    private final UserService userService;

    public ProfileController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/edit")
    public String showEditForm(@AuthenticationPrincipal CustomUserDetails principal, Model model) {
        model.addAttribute("profileUser", resolveUser(principal));
        return "ims/profile/edit";
    }

    @PostMapping("/edit")
    public String saveEdit(@AuthenticationPrincipal CustomUserDetails principal,
                           @RequestParam String firstName,
                           @RequestParam String lastName,
                           @RequestParam(required = false) String pan,
                           RedirectAttributes ra) {
        User currentUser = resolveUser(principal);
        try {
            userService.updateProfile(currentUser.getUserId(), firstName, lastName, pan);
            logger.info("PROFILE_UPDATE_SUCCESS userId={} email={}", currentUser.getUserId(), currentUser.getUserEmail());
            ra.addFlashAttribute("successMessage", "Profile updated successfully.");
        } catch (Exception e) {
            logger.warn("PROFILE_UPDATE_FAILED userId={} email={} reason={}",
                    currentUser.getUserId(),
                    currentUser.getUserEmail(),
                    e.getClass().getSimpleName());
            ra.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/profile/edit";
    }

    @GetMapping("/reset-password")
    public String showResetForm() {
        return "ims/profile/reset-password";
    }

    @PostMapping("/reset-password")
    public String resetPassword(@AuthenticationPrincipal CustomUserDetails principal,
                                @RequestParam String currentPassword,
                                @RequestParam String newPassword,
                                @RequestParam String confirmPassword,
                                RedirectAttributes ra) {
        User currentUser = resolveUser(principal);
        if (!newPassword.equals(confirmPassword)) {
            logger.warn("PASSWORD_CHANGE_REJECTED reason=mismatch userId={} email={}",
                    currentUser.getUserId(),
                    currentUser.getUserEmail());
            ra.addFlashAttribute("errorMessage", "New passwords do not match.");
            return "redirect:/profile/reset-password";
        }
        if (newPassword.length() < 8) {
            logger.warn("PASSWORD_CHANGE_REJECTED reason=weak_password userId={} email={}",
                    currentUser.getUserId(),
                    currentUser.getUserEmail());
            ra.addFlashAttribute("errorMessage", "New password must be at least 8 characters.");
            return "redirect:/profile/reset-password";
        }
        try {
            userService.changePassword(currentUser.getUserId(), currentPassword, newPassword);
            logger.info("PASSWORD_CHANGE_SUCCESS userId={} email={}", currentUser.getUserId(), currentUser.getUserEmail());
            ra.addFlashAttribute("successMessage", "Password changed successfully.");
        } catch (IllegalArgumentException e) {
            logger.warn("PASSWORD_CHANGE_FAILED userId={} email={} reason={}",
                    currentUser.getUserId(),
                    currentUser.getUserEmail(),
                    e.getClass().getSimpleName());
            ra.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/profile/reset-password";
    }

    private User resolveUser(CustomUserDetails principal) {
        return userService.getUserByUserEmail(principal.getUsername());
    }
}
