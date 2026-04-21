package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.dto.MemberBalanceDto;
import com.spendilizer.dto.SettlementDto;
import com.spendilizer.entity.*;
import com.spendilizer.repository.GroupMemberRepository;
import com.spendilizer.service.SplitGroupService;
import com.spendilizer.service.UserService;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/personal/splits")
public class SplitGroupController {

    private final SplitGroupService splitGroupService;
    private final GroupMemberRepository groupMemberRepository;
    private final UserService userService;

    public SplitGroupController(SplitGroupService splitGroupService,
                                GroupMemberRepository groupMemberRepository,
                                UserService userService) {
        this.splitGroupService = splitGroupService;
        this.groupMemberRepository = groupMemberRepository;
        this.userService = userService;
    }

    @GetMapping
    public String list(@AuthenticationPrincipal CustomUserDetails principal,
                       HttpSession session, Model model) {
        User user = userService.getUserByEmail(principal.getUsername());
        session.setAttribute("currentModule", "PERSONAL");
        model.addAttribute("groups", splitGroupService.getAllGroups(user));
        return "personal/splits/list";
    }

    @GetMapping("/new")
    public String newForm(HttpSession session) {
        session.setAttribute("currentModule", "PERSONAL");
        return "personal/splits/form";
    }

    @PostMapping("/new")
    public String create(@RequestParam String name,
                         @RequestParam(required = false) String description,
                         @RequestParam(required = false) String eventDate,
                         @RequestParam List<String> memberName,
                         @RequestParam(required = false) List<String> memberEmail,
                         @AuthenticationPrincipal CustomUserDetails principal,
                         RedirectAttributes ra) {
        User user = userService.getUserByEmail(principal.getUsername());
        LocalDate date = (eventDate != null && !eventDate.isBlank())
                ? LocalDate.parse(eventDate) : null;
        SplitGroup group = splitGroupService.createGroup(name, description, date,
                memberName, memberEmail, user);
        ra.addFlashAttribute("success", "Group \"" + group.getName() + "\" created.");
        return "redirect:/personal/splits/" + group.getId();
    }

    @GetMapping("/{id}")
    public String view(@PathVariable Long id,
                       @AuthenticationPrincipal CustomUserDetails principal,
                       HttpSession session, Model model) {
        User user = userService.getUserByEmail(principal.getUsername());
        session.setAttribute("currentModule", "PERSONAL");
        SplitGroup group = splitGroupService.getGroupById(id, user)
                .orElseThrow(() -> new RuntimeException("Group not found"));

        List<GroupMember> members = groupMemberRepository.findBySplitGroup(group);
        List<MemberBalanceDto> balances = splitGroupService.computeBalances(group);
        List<SettlementDto> settlements = splitGroupService.computeSettlements(balances);

        // Find the current user's member record (null if not linked)
        Optional<GroupMember> myMember = splitGroupService.getMemberForUser(group, user);
        boolean isCreator = group.getCreatedBy().getUserId() == user.getUserId();

        model.addAttribute("group", group);
        model.addAttribute("members", members);
        model.addAttribute("expenses", group.getExpenses());
        model.addAttribute("balances", balances);
        model.addAttribute("settlements", settlements);
        model.addAttribute("myMember", myMember.orElse(null));
        model.addAttribute("isCreator", isCreator);
        return "personal/splits/view";
    }

    @PostMapping("/{id}/add-member")
    public String addMember(@PathVariable Long id,
                            @RequestParam String name,
                            @RequestParam(required = false) String email,
                            @AuthenticationPrincipal CustomUserDetails principal,
                            RedirectAttributes ra) {
        User user = userService.getUserByEmail(principal.getUsername());
        try {
            splitGroupService.addMember(id, name, email, user);
            ra.addFlashAttribute("success", "Member \"" + name + "\" added.");
        } catch (IllegalStateException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/personal/splits/" + id;
    }

    @PostMapping("/{id}/add-expense")
    public String addExpense(@PathVariable Long id,
                             @RequestParam String description,
                             @RequestParam BigDecimal amount,
                             @RequestParam SplitType splitType,
                             @RequestParam(required = false) String expenseDate,
                             @RequestParam Map<String, String> allParams,
                             @AuthenticationPrincipal CustomUserDetails principal,
                             RedirectAttributes ra) {
        User user = userService.getUserByEmail(principal.getUsername());
        LocalDate date = (expenseDate != null && !expenseDate.isBlank())
                ? LocalDate.parse(expenseDate) : LocalDate.now();

        Map<Long, BigDecimal> customShares = new HashMap<>();
        if (splitType == SplitType.CUSTOM) {
            for (Map.Entry<String, String> e : allParams.entrySet()) {
                if (e.getKey().startsWith("share_")) {
                    try {
                        Long memberId = Long.parseLong(e.getKey().substring(6));
                        BigDecimal share = new BigDecimal(e.getValue());
                        customShares.put(memberId, share);
                    } catch (NumberFormatException ignored) {}
                }
            }
        }

        try {
            splitGroupService.addExpense(id, description, amount, splitType, date, customShares, user);
            ra.addFlashAttribute("success", "Expense added.");
        } catch (IllegalStateException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/personal/splits/" + id;
    }

    @PostMapping("/{groupId}/expense/{expenseId}/delete")
    public String deleteExpense(@PathVariable Long groupId,
                                @PathVariable Long expenseId,
                                @AuthenticationPrincipal CustomUserDetails principal,
                                RedirectAttributes ra) {
        User user = userService.getUserByEmail(principal.getUsername());
        try {
            splitGroupService.deleteExpense(expenseId, groupId, user);
            ra.addFlashAttribute("success", "Expense removed.");
        } catch (IllegalStateException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/personal/splits/" + groupId;
    }

    @PostMapping("/{id}/close")
    public String closeGroup(@PathVariable Long id,
                             @AuthenticationPrincipal CustomUserDetails principal,
                             RedirectAttributes ra) {
        User user = userService.getUserByEmail(principal.getUsername());
        try {
            splitGroupService.closeGroup(id, user);
            ra.addFlashAttribute("success", "Group closed.");
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/personal/splits/" + id;
    }

    @PostMapping("/{id}/delete")
    public String deleteGroup(@PathVariable Long id,
                              @AuthenticationPrincipal CustomUserDetails principal,
                              RedirectAttributes ra) {
        User user = userService.getUserByEmail(principal.getUsername());
        try {
            splitGroupService.deleteGroup(id, user);
            ra.addFlashAttribute("success", "Group deleted.");
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", "Only the group creator can delete this group.");
        }
        return "redirect:/personal/splits";
    }
}
