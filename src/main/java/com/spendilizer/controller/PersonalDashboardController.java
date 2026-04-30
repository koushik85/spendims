package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.SplitGroup;
import com.spendilizer.entity.Subscription;
import com.spendilizer.entity.User;
import com.spendilizer.service.SplitGroupService;
import com.spendilizer.service.SubscriptionService;
import com.spendilizer.service.UserService;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.math.BigDecimal;
import java.util.List;

@Controller
@RequestMapping("/personal")
public class PersonalDashboardController {

    private final UserService userService;
    private final SplitGroupService splitGroupService;
    private final SubscriptionService subscriptionService;

    public PersonalDashboardController(UserService userService,
                                       SplitGroupService splitGroupService,
                                       SubscriptionService subscriptionService) {
        this.userService = userService;
        this.splitGroupService = splitGroupService;
        this.subscriptionService = subscriptionService;
    }

    @GetMapping("/dashboard")
    public String dashboard(@AuthenticationPrincipal CustomUserDetails principal,
                            HttpSession session, Model model) {
        User user = userService.getUserByUserEmail(principal.getUsername());
        session.setAttribute("currentModule", "PERSONAL");

        List<SplitGroup> groups = splitGroupService.getAllGroups(user);
        long activeGroups = groups.stream()
                .filter(g -> g.getStatus().name().equals("ACTIVE")).count();

        List<Subscription> upcomingRenewals = subscriptionService.getDueWithin(user, 7);
        BigDecimal monthlyCost = subscriptionService.totalMonthlyCost(user);
        long activeSubCount = subscriptionService.getActive(user).size();

        model.addAttribute("activeGroupCount", activeGroups);
        model.addAttribute("recentGroups", groups.stream().limit(5).toList());
        model.addAttribute("upcomingRenewals", upcomingRenewals);
        model.addAttribute("monthlyCost", monthlyCost);
        model.addAttribute("activeSubCount", activeSubCount);

        return "personal/dashboard";
    }
}
