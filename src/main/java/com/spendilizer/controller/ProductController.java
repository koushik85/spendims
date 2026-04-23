package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.MasterProduct;
import com.spendilizer.entity.MasterProductRequest;
import com.spendilizer.entity.Product;
import com.spendilizer.entity.User;
import com.spendilizer.service.CategoryService;
import com.spendilizer.service.MasterProductService;
import com.spendilizer.service.ProductService;
import com.spendilizer.service.SupplierService;
import com.spendilizer.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/product")
public class ProductController {

    private static final Logger log = LoggerFactory.getLogger(ProductController.class);

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
        List<MasterProduct> masterProducts = masterProductService.getAllActiveMasterProducts();
        model.addAttribute("product", new Product());
        model.addAttribute("categories", categoryService.getActiveCategories(user));
        model.addAttribute("suppliers", supplierService.getAllActiveSuppliers(user));
        model.addAttribute("masterProducts", masterProducts);
        return "ims/product/form";
    }

    @PostMapping("/new")
    public String createProduct(@AuthenticationPrincipal CustomUserDetails principal,
                                @ModelAttribute Product product,
                    @RequestParam(value = "masterProductId", required = false) Long masterProductId,
                                RedirectAttributes redirectAttributes) {
        User user = resolveUser(principal);
        if (masterProductId == null || masterProductId <= 0) {
            redirectAttributes.addFlashAttribute("errorMessage",
                    "Please choose a product from the master list. If it is missing, submit a request to add it.");
            return "redirect:/product/new";
        }

        Product saved;
        try {
            saved = productService.createProductFromMaster(masterProductId, product, user);
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/product/new";
        } catch (RuntimeException e) {
            log.error("Failed to create product from master list. masterProductId={}, userId={}",
                    masterProductId, user.getUserId(), e);
            String message = (e.getMessage() != null && !e.getMessage().isBlank())
                    ? e.getMessage()
                    : "Unable to create product from master list. Please reselect and try again.";
            redirectAttributes.addFlashAttribute("errorMessage", message);
            return "redirect:/product/new";
        }

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

    @GetMapping("/request-master")
    public String showRequestForm(Model model) {
        model.addAttribute("request", new MasterProductRequest());
        return "ims/product/request-master";
    }

    @PostMapping("/request-master")
    public String submitRequest(@AuthenticationPrincipal CustomUserDetails principal,
                                @ModelAttribute MasterProductRequest request,
                                Model model,
                                RedirectAttributes redirectAttributes) {
        try {
            masterProductService.submitRequest(request, resolveUser(principal));
            redirectAttributes.addFlashAttribute("successMessage",
                    "Request submitted. A Super Admin will review it shortly.");
            return "redirect:/product";
        } catch (IllegalArgumentException e) {
            model.addAttribute("errorMessage", e.getMessage());
            model.addAttribute("request", request);
            return "ims/product/request-master";
        }
    }

    @GetMapping("/my-requests")
    public String myRequests(@AuthenticationPrincipal CustomUserDetails principal, Model model) {
        model.addAttribute("requests", masterProductService.getRequestsByUser(resolveUser(principal)));
        return "ims/product/my-requests";
    }

    private User resolveUser(CustomUserDetails principal) {
        return userService.getUserByEmail(principal.getUsername());
    }
}
