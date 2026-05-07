package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class ModuleSwitchController {

    @GetMapping("/switch-module")
    public String switchModule(@RequestParam String to,
                               @AuthenticationPrincipal CustomUserDetails principal,
                               HttpSession session) {
        if ("PERSONAL".equals(to)) {
            session.setAttribute("currentModule", "PERSONAL");
            return "redirect:/personal/dashboard";
        }

        boolean isPremium = principal.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_PREMIUM_USER"));

        if ("IMS".equals(to) && isPremium) {
            session.setAttribute("currentModule", "IMS");
            return "redirect:/dashboard";
        }

        return "redirect:/personal/dashboard";
    }
}
