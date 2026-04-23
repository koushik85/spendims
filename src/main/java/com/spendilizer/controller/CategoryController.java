package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.Category;
import com.spendilizer.entity.User;
import com.spendilizer.service.CategoryService;
import com.spendilizer.service.UserService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/category")
public class CategoryController {

    private final CategoryService categoryService;
    private final UserService userService;

    public CategoryController(CategoryService categoryService, UserService userService) {
        this.categoryService = categoryService;
        this.userService = userService;
    }

    @GetMapping
    public String listCategories(@AuthenticationPrincipal CustomUserDetails principal, Model model) {
        User user = resolveUser(principal);
        model.addAttribute("categories", categoryService.getAllActiveCategory(user));
        return "ims/category/list";
    }

    @GetMapping("/new")
    public String showAddForm(Model model) {
        model.addAttribute("category", new Category());
        return "ims/category/form";
    }

    @PostMapping("/new")
    public String addCategory(@AuthenticationPrincipal CustomUserDetails principal,
                              @ModelAttribute Category category,
                              Model model,
                              RedirectAttributes redirectAttributes) {
        try {
            categoryService.createCategory(category, resolveUser(principal));
            redirectAttributes.addFlashAttribute("successMessage", "Category created successfully.");
            return "redirect:/category";
        } catch (IllegalArgumentException e) {
            model.addAttribute("errorMessage", e.getMessage());
            return "ims/category/form";
        }
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@AuthenticationPrincipal CustomUserDetails principal,
                               @PathVariable Long id, Model model) {
        User user = resolveUser(principal);
        Category category = categoryService.getCategoryById(id, user)
                .orElseThrow(() -> new RuntimeException("Category not found: " + id));
        model.addAttribute("category", category);
        return "ims/category/form";
    }

    @PostMapping("/edit/{id}")
    public String updateCategory(@AuthenticationPrincipal CustomUserDetails principal,
                                 @PathVariable Long id,
                                 @ModelAttribute Category category,
                                 Model model,
                                 RedirectAttributes redirectAttributes) {
        try {
            categoryService.updateCategory(id, category, resolveUser(principal));
            redirectAttributes.addFlashAttribute("successMessage", "Category updated successfully.");
            return "redirect:/category";
        } catch (IllegalArgumentException e) {
            model.addAttribute("errorMessage", e.getMessage());
                return "ims/category/form";
        }
    }

    @PostMapping("/delete/{id}")
    public String softDeleteCategory(@AuthenticationPrincipal CustomUserDetails principal,
                                     @PathVariable Long id,
                                     RedirectAttributes redirectAttributes) {
        categoryService.softDeleteCategory(id, resolveUser(principal));
        redirectAttributes.addFlashAttribute("successMessage", "Category deactivated successfully.");
        return "redirect:/category";
    }

    private User resolveUser(CustomUserDetails principal) {
        return userService.getUserByEmail(principal.getUsername());
    }
}
