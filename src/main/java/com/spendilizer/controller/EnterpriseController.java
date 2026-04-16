package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.Enterprise;
import com.spendilizer.entity.User;
import com.spendilizer.service.UserService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/enterprise")
public class EnterpriseController {

    private final UserService userService;

    public EnterpriseController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/members")
    public String listMembers(@AuthenticationPrincipal CustomUserDetails principal, Model model) {
        User owner = userService.getUserByEmail(principal.getUsername());
        Enterprise enterprise = userService.getEnterpriseByOwner(owner);
        List<User> members = userService.getMembersByEnterprise(enterprise);
        model.addAttribute("enterprise", enterprise);
        model.addAttribute("members", members);
        return "enterprise/members";
    }

    @PostMapping("/members/add")
    public String addMember(@AuthenticationPrincipal CustomUserDetails principal,
                            @RequestParam("email") String email,
                            @RequestParam("firstName") String firstName,
                            @RequestParam("lastName") String lastName,
                            @RequestParam("password") String password,
                            RedirectAttributes redirectAttributes) {
        User owner = userService.getUserByEmail(principal.getUsername());
        Enterprise enterprise = userService.getEnterpriseByOwner(owner);

        if (userService.emailExists(email)) {
            redirectAttributes.addFlashAttribute("errorMessage", "An account with this email already exists");
            return "redirect:/enterprise/members";
        }

        userService.addEnterpriseMember(enterprise, email, firstName, lastName, password);
        redirectAttributes.addFlashAttribute("successMessage",
                firstName + " " + lastName + " was added to your team");
        return "redirect:/enterprise/members";
    }

    @PostMapping("/members/remove/{userId}")
    public String removeMember(@PathVariable int userId, RedirectAttributes redirectAttributes) {
        userService.removeEnterpriseMember(userId);
        redirectAttributes.addFlashAttribute("successMessage", "Team member removed");
        return "redirect:/enterprise/members";
    }
}
