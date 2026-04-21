package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.Product;
import com.spendilizer.entity.Status;
import com.spendilizer.entity.User;
import com.spendilizer.service.CategoryService;
import com.spendilizer.service.MasterProductService;
import com.spendilizer.service.ProductService;
import com.spendilizer.service.SupplierService;
import com.spendilizer.service.UserService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/product")
public class ProductController {

    private final ProductService productService;
    private final CategoryService categoryService;
    private final SupplierService supplierService;
    private final MasterProductService masterProductService;
    private final UserService userService;

    public ProductController(ProductService productService,
                             CategoryService categoryService,
                             SupplierService supplierService,
                             MasterProductService masterProductService,
                             UserService userService) {
        this.productService = productService;
        this.categoryService = categoryService;
        this.supplierService = supplierService;
        this.masterProductService = masterProductService;
        this.userService = userService;
    }

    @GetMapping
    public String listProducts(@AuthenticationPrincipal CustomUserDetails principal, Model model) {
        model.addAttribute("products", productService.getAllActiveProducts(resolveUser(principal)));
        return "ims/product/list";
    }

    @GetMapping("/new")
    public String showCreateForm(@AuthenticationPrincipal CustomUserDetails principal, Model model) {
        User user = resolveUser(principal);
        model.addAttribute("product", new Product());
        model.addAttribute("categories", categoryService.getActiveCategories(user));
        model.addAttribute("suppliers", supplierService.getAllActiveSuppliers(user));
        model.addAttribute("masterProducts", masterProductService.getAllActiveMasterProducts());
        return "ims/product/form";
    }

    @PostMapping("/new")
    public String createProduct(@AuthenticationPrincipal CustomUserDetails principal,
                                @ModelAttribute Product product,
                    @RequestParam(value = "masterProductId", required = false) Long masterProductId,
                                RedirectAttributes redirectAttributes) {
        User user = resolveUser(principal);
        Product saved = masterProductId != null
            ? productService.createProductFromMaster(masterProductId, product, user)
            : productService.createProduct(product, user);
        redirectAttributes.addFlashAttribute("successMessage",
            "Product \"" + saved.getName() + "\" created successfully.");
        return "redirect:/product";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@AuthenticationPrincipal CustomUserDetails principal,
                               @PathVariable Long id, Model model) {
        User user = resolveUser(principal);
        Product product = productService.getProductById(id, user)
                .orElseThrow(() -> new RuntimeException("Product not found: " + id));
        model.addAttribute("product", product);
        model.addAttribute("categories", categoryService.getActiveCategories(user));
        model.addAttribute("suppliers", supplierService.getAllActiveSuppliers(user));
        model.addAttribute("statuses", Status.values());
        return "ims/product/form";
    }

    @PostMapping("/edit/{id}")
    public String updateProduct(@AuthenticationPrincipal CustomUserDetails principal,
                                @PathVariable Long id,
                                @ModelAttribute Product product,
                                RedirectAttributes redirectAttributes) {
        productService.updateProduct(id, product, resolveUser(principal));
        redirectAttributes.addFlashAttribute("successMessage",
                "Product \"" + product.getName() + "\" updated successfully.");
        return "redirect:/product";
    }

    @PostMapping("/delete/{id}")
    public String deactivateProduct(@AuthenticationPrincipal CustomUserDetails principal,
                                    @PathVariable Long id,
                                    RedirectAttributes redirectAttributes) {
        User user = resolveUser(principal);
        Product product = productService.getProductById(id, user)
                .orElseThrow(() -> new RuntimeException("Product not found: " + id));
        productService.softDeleteProduct(id, user);
        redirectAttributes.addFlashAttribute("successMessage",
                "Product \"" + product.getName() + "\" has been deactivated.");
        return "redirect:/product";
    }

    @GetMapping("/generate-sku")
    @ResponseBody
    public String generateSku(@AuthenticationPrincipal CustomUserDetails principal,
                              @RequestParam String categoryName,
                              @RequestParam String productName) {
        return productService.generateSku(categoryName, productName, resolveUser(principal));
    }

    private User resolveUser(CustomUserDetails principal) {
        return userService.getUserByEmail(principal.getUsername());
    }
}
