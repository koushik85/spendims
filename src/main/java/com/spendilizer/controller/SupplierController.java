package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.Supplier;
import com.spendilizer.entity.User;
import com.spendilizer.service.SupplierService;
import com.spendilizer.service.UserService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/supplier")
public class SupplierController {

    private final SupplierService supplierService;
    private final UserService userService;

    public SupplierController(SupplierService supplierService, UserService userService) {
        this.supplierService = supplierService;
        this.userService = userService;
    }

    @GetMapping
    public String listSuppliers(@AuthenticationPrincipal CustomUserDetails principal, Model model) {
        model.addAttribute("suppliers", supplierService.getAllActiveSuppliers(resolveUser(principal)));
        return "ims/supplier/list";
    }

    @GetMapping("/new")
    public String showNewForm(Model model) {
        model.addAttribute("supplier", new Supplier());
        return "ims/supplier/form";
    }

    @PostMapping("/new")
    public String createSupplier(@AuthenticationPrincipal CustomUserDetails principal,
                                 @ModelAttribute Supplier supplier,
                                 RedirectAttributes redirectAttributes) {
        supplierService.createSupplier(supplier, resolveUser(principal));
        redirectAttributes.addFlashAttribute("successMessage",
                "Supplier \"" + supplier.getName() + "\" created successfully.");
        return "redirect:/supplier";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@AuthenticationPrincipal CustomUserDetails principal,
                               @PathVariable Long id, Model model) {
        Supplier supplier = supplierService.getSupplierById(id, resolveUser(principal))
                .orElseThrow(() -> new RuntimeException("Supplier not found: " + id));
        model.addAttribute("supplier", supplier);
        return "ims/supplier/form";
    }

    @PostMapping("/edit/{id}")
    public String updateSupplier(@AuthenticationPrincipal CustomUserDetails principal,
                                 @PathVariable Long id,
                                 @ModelAttribute Supplier supplier,
                                 RedirectAttributes redirectAttributes) {
        supplierService.updateSupplier(id, supplier, resolveUser(principal));
        redirectAttributes.addFlashAttribute("successMessage",
                "Supplier \"" + supplier.getName() + "\" updated successfully.");
        return "redirect:/supplier";
    }

    @PostMapping("/delete/{id}")
    public String deleteSupplier(@AuthenticationPrincipal CustomUserDetails principal,
                                 @PathVariable Long id,
                                 RedirectAttributes redirectAttributes) {
        User user = resolveUser(principal);
        Supplier supplier = supplierService.getSupplierById(id, user)
                .orElseThrow(() -> new RuntimeException("Supplier not found: " + id));
        supplierService.softDeleteSupplier(id, user);
        redirectAttributes.addFlashAttribute("successMessage",
                "Supplier \"" + supplier.getName() + "\" has been deactivated.");
        return "redirect:/supplier";
    }

    private User resolveUser(CustomUserDetails principal) {
        return userService.getUserByEmail(principal.getUsername());
    }
}
