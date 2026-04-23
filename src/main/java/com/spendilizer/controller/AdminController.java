package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.Category;
import com.spendilizer.entity.MasterProduct;
import com.spendilizer.entity.Status;
import com.spendilizer.entity.User;
import com.spendilizer.service.CategoryService;
import com.spendilizer.service.MasterProductService;
import com.spendilizer.service.UserService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin")
public class AdminController {

    private final UserService userService;
    private final CategoryService categoryService;
    private final MasterProductService masterProductService;

    public AdminController(UserService userService,
                           CategoryService categoryService,
                           MasterProductService masterProductService) {
        this.userService = userService;
        this.categoryService = categoryService;
        this.masterProductService = masterProductService;
    }

    // ── Dashboard ────────────────────────────────────────────────────

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        model.addAttribute("allUsers", userService.getAllUsers());
        model.addAttribute("pendingEnterprises", userService.getPendingEnterprises());
        model.addAttribute("pendingProductRequests", masterProductService.getPendingRequests());
        return "admin/dashboard";
    }

    // ── Enterprise approvals ─────────────────────────────────────────

    @GetMapping("/enterprises")
    public String listEnterprises(Model model) {
        model.addAttribute("enterprises", userService.getAllEnterprises());
        return "admin/enterprises";
    }

    @PostMapping("/enterprises/{id}/approve")
    public String approveEnterprise(@PathVariable int id, RedirectAttributes ra) {
        userService.approveEnterprise(id);
        ra.addFlashAttribute("successMessage", "Enterprise approved.");
        return "redirect:/admin/enterprises";
    }

    @PostMapping("/enterprises/{id}/reject")
    public String rejectEnterprise(@PathVariable int id, RedirectAttributes ra) {
        userService.rejectEnterprise(id);
        ra.addFlashAttribute("successMessage", "Enterprise rejected.");
        return "redirect:/admin/enterprises";
    }

    // ── Category management ──────────────────────────────────────────

    @GetMapping("/categories")
    public String listCategories(Model model) {
        model.addAttribute("categories", categoryService.getAllActiveCategory());
        return "admin/categories/list";
    }

    @GetMapping("/categories/new")
    public String newCategoryForm(Model model) {
        model.addAttribute("category", new Category());
        return "admin/categories/form";
    }

    @PostMapping("/categories/new")
    public String createCategory(@AuthenticationPrincipal CustomUserDetails principal,
                                 @ModelAttribute Category category,
                                 Model model,
                                 RedirectAttributes ra) {
        try {
            User admin = userService.getUserByEmail(principal.getUsername());
            categoryService.adminCreateCategory(category, admin);
            ra.addFlashAttribute("successMessage", "Category created.");
            return "redirect:/admin/categories";
        } catch (IllegalArgumentException e) {
            model.addAttribute("errorMessage", e.getMessage());
            return "admin/categories/form";
        }
    }

    @GetMapping("/categories/edit/{id}")
    public String editCategoryForm(@PathVariable Long id, Model model) {
        Category category = categoryService.getCategoryById(id)
                .orElseThrow(() -> new RuntimeException("Category not found: " + id));
        model.addAttribute("category", category);
        return "admin/categories/form";
    }

    @PostMapping("/categories/edit/{id}")
    public String updateCategory(@PathVariable Long id,
                                 @ModelAttribute Category category,
                                 Model model,
                                 RedirectAttributes ra) {
        try {
            categoryService.adminUpdateCategory(id, category);
            ra.addFlashAttribute("successMessage", "Category updated.");
            return "redirect:/admin/categories";
        } catch (IllegalArgumentException e) {
            model.addAttribute("errorMessage", e.getMessage());
            return "admin/categories/form";
        }
    }

    @PostMapping("/categories/delete/{id}")
    public String deleteCategory(@PathVariable Long id, RedirectAttributes ra) {
        categoryService.adminSoftDeleteCategory(id);
        ra.addFlashAttribute("successMessage", "Category deactivated.");
        return "redirect:/admin/categories";
    }

    // ── Master product management ────────────────────────────────────

    @GetMapping("/master-products")
    public String listMasterProducts(Model model) {
        model.addAttribute("masterProducts", masterProductService.getAllMasterProducts());
        return "admin/master-products/list";
    }

    @GetMapping("/master-products/new")
    public String newMasterProductForm(Model model) {
        model.addAttribute("masterProduct", new MasterProduct());
        return "admin/master-products/form";
    }

    @PostMapping("/master-products/new")
    public String createMasterProduct(@ModelAttribute MasterProduct masterProduct, RedirectAttributes ra) {
        masterProduct.setRowStatus(Status.ACTIVE);
        masterProductService.save(masterProduct);
        ra.addFlashAttribute("successMessage", "Master product added.");
        return "redirect:/admin/master-products";
    }

    @GetMapping("/master-products/edit/{id}")
    public String editMasterProductForm(@PathVariable Long id, Model model) {
        model.addAttribute("masterProduct", masterProductService.getById(id));
        return "admin/master-products/form";
    }

    @PostMapping("/master-products/edit/{id}")
    public String updateMasterProduct(@PathVariable Long id,
                                      @ModelAttribute MasterProduct masterProduct,
                                      RedirectAttributes ra) {
        MasterProduct existing = masterProductService.getById(id);
        existing.setName(masterProduct.getName());
        existing.setCategoryName(masterProduct.getCategoryName());
        existing.setHsnCode(masterProduct.getHsnCode());
        existing.setDescription(masterProduct.getDescription());
        existing.setRowStatus(masterProduct.getRowStatus());
        masterProductService.save(existing);
        ra.addFlashAttribute("successMessage", "Master product updated.");
        return "redirect:/admin/master-products";
    }

    @PostMapping("/master-products/delete/{id}")
    public String deleteMasterProduct(@PathVariable Long id, RedirectAttributes ra) {
        masterProductService.softDelete(id);
        ra.addFlashAttribute("successMessage", "Master product deactivated.");
        return "redirect:/admin/master-products";
    }

    // ── Master product requests ──────────────────────────────────────

    @GetMapping("/master-products/requests")
    public String listRequests(Model model) {
        model.addAttribute("requests", masterProductService.getAllRequests());
        return "admin/master-products/requests";
    }

    @PostMapping("/master-products/requests/{id}/approve")
    public String approveRequest(@PathVariable Long id, RedirectAttributes ra) {
        masterProductService.approveRequest(id);
        ra.addFlashAttribute("successMessage", "Request approved and product added to master list.");
        return "redirect:/admin/master-products/requests";
    }

    @PostMapping("/master-products/requests/{id}/reject")
    public String rejectRequest(@PathVariable Long id,
                                @RequestParam(value = "reviewNote", defaultValue = "") String reviewNote,
                                RedirectAttributes ra) {
        masterProductService.rejectRequest(id, reviewNote);
        ra.addFlashAttribute("successMessage", "Request rejected.");
        return "redirect:/admin/master-products/requests";
    }
}
