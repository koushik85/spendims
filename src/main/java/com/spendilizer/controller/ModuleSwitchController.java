package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.User;
import com.spendilizer.service.UserService;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class ModuleSwitchController {

    private final UserService userService;

    public ModuleSwitchController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/switch-module")
    public String switchModule(@RequestParam String to,
                               @AuthenticationPrincipal CustomUserDetails principal,
                               HttpSession session) {
        User user = userService.getUserByEmail(principal.getUsername());

        if ("PERSONAL".equals(to)) {
            session.setAttribute("currentModule", "PERSONAL");
            return "redirect:/personal/dashboard";
        }

        // Only enterprise users can switch to IMS
        if ("IMS".equals(to) && (
                "ENTERPRISE_OWNER".equals(user.getAccountType()) ||
                "ENTERPRISE_MEMBER".equals(user.getAccountType()))) {
            session.setAttribute("currentModule", "IMS");
            return "redirect:/dashboard";
        }

        // Fallback
        return "redirect:/personal/dashboard";
    }
}
