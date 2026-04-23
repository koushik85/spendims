package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.Customer;
import com.spendilizer.entity.User;
import com.spendilizer.service.CustomerService;
import com.spendilizer.service.UserService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/customer")
public class CustomerController {

    private final CustomerService customerService;
    private final UserService userService;

    public CustomerController(CustomerService customerService, UserService userService) {
        this.customerService = customerService;
        this.userService = userService;
    }

    @GetMapping
    public String list(@AuthenticationPrincipal CustomUserDetails principal, Model model) {
        model.addAttribute("customers", customerService.getAllActive(resolveUser(principal)));
        return "ims/customer/list";
    }

    @GetMapping("/new")
    public String showNewForm(Model model) {
        model.addAttribute("customer", new Customer());
        return "ims/customer/form";
    }

    @PostMapping("/new")
    public String create(@AuthenticationPrincipal CustomUserDetails principal,
                         @ModelAttribute Customer customer,
                         RedirectAttributes ra) {
        try {
            customerService.createCustomer(customer, resolveUser(principal));
            ra.addFlashAttribute("successMessage", "Customer \"" + customer.getDisplayName() + "\" created.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/customer/new";
        }
        return "redirect:/customer";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@AuthenticationPrincipal CustomUserDetails principal,
                               @PathVariable Long id, Model model) {
        Customer customer = customerService.getById(id, resolveUser(principal))
                .orElseThrow(() -> new RuntimeException("Customer not found: " + id));
        model.addAttribute("customer", customer);
        return "ims/customer/form";
    }

    @PostMapping("/edit/{id}")
    public String update(@AuthenticationPrincipal CustomUserDetails principal,
                         @PathVariable Long id,
                         @ModelAttribute Customer customer,
                         RedirectAttributes ra) {
        try {
            customerService.updateCustomer(id, customer, resolveUser(principal));
            ra.addFlashAttribute("successMessage", "Customer updated successfully.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/customer";
    }

    @PostMapping("/delete/{id}")
    public String delete(@AuthenticationPrincipal CustomUserDetails principal,
                         @PathVariable Long id,
                         RedirectAttributes ra) {
        User user = resolveUser(principal);
        Customer c = customerService.getById(id, user)
                .orElseThrow(() -> new RuntimeException("Customer not found: " + id));
        customerService.softDeleteCustomer(id, user);
        ra.addFlashAttribute("successMessage", "Customer \"" + c.getDisplayName() + "\" deleted.");
        return "redirect:/customer";
    }

    private User resolveUser(CustomUserDetails principal) {
        return userService.getUserByEmail(principal.getUsername());
    }
}
