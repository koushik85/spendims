package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.Status;
import com.spendilizer.entity.StockMovement;
import com.spendilizer.entity.StockMovementType;
import com.spendilizer.entity.User;
import com.spendilizer.service.ProductService;
import com.spendilizer.service.StockMovementService;
import com.spendilizer.service.StockService;
import com.spendilizer.service.UserService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.util.List;

@Controller
@RequestMapping("/stock-movement")
public class StockMovementController {

    private final StockMovementService stockMovementService;
    private final ProductService       productService;
    private final StockService         stockService;
    private final UserService          userService;

    public StockMovementController(StockMovementService stockMovementService,
                                   ProductService productService,
                                   StockService stockService,
                                   UserService userService) {
        this.stockMovementService = stockMovementService;
        this.productService       = productService;
        this.stockService         = stockService;
        this.userService          = userService;
    }

    @GetMapping
    public String listMovements(@AuthenticationPrincipal CustomUserDetails principal,
                                @RequestParam(required = false) Long productId,
                                @RequestParam(required = false) StockMovementType type,
                                Model model) {
        User user = resolveUser(principal);
        List<StockMovement> movements;

        if (productId != null && type != null) {
            movements = stockMovementService.getMovementsByProductIdAndType(productId, type, user);
        } else if (productId != null) {
            movements = stockMovementService.getMovementsByProductId(productId, user);
        } else if (type != null) {
            movements = stockMovementService.getMovementsByType(type, user);
        } else {
            movements = stockMovementService.getAllActiveMovements(user);
        }

        long inCount  = movements.stream().filter(m -> m.getType() == StockMovementType.IN).count();
        long outCount = movements.stream().filter(m -> m.getType() == StockMovementType.OUT).count();

        model.addAttribute("movements",         movements);
        model.addAttribute("products",          productService.getAllProducts(user));
        model.addAttribute("types",             StockMovementType.values());
        model.addAttribute("inCount",           inCount);
        model.addAttribute("outCount",          outCount);
        model.addAttribute("filterProductId",   productId);
        model.addAttribute("filterType",        type);
        return "ims/stock-movement/list";
    }

    @GetMapping("/new")
    public String showAddForm(@AuthenticationPrincipal CustomUserDetails principal, Model model) {
        User user = resolveUser(principal);
        model.addAttribute("movement", new StockMovement());
        model.addAttribute("products", productService.getAllProducts(user));
        model.addAttribute("types",    StockMovementType.values());
        return "ims/stock-movement/form";
    }

    @PostMapping("/new")
    public String createMovement(@AuthenticationPrincipal CustomUserDetails principal,
                                 @ModelAttribute StockMovement movement,
                                 RedirectAttributes ra) {
        User user = resolveUser(principal);
        movement.setMovedAt(LocalDateTime.now());
        movement.setRowStatus(Status.ACTIVE);
        stockMovementService.createMovement(movement);

        try {
            stockService.getStockByProductId(movement.getProduct().getId())
                    .ifPresentOrElse(stock -> {
                        int delta = movement.getType() == StockMovementType.IN
                                ? movement.getQuantity()
                                : -movement.getQuantity();
                        stockService.adjustQuantity(stock.getId(), delta);
                    }, () -> {
                        int initialQty = movement.getType() == StockMovementType.IN
                                ? movement.getQuantity() : 0;
                        stockService.createStockBeforeMovement(movement.getProduct().getId(), initialQty, user);
                    });
        } catch (RuntimeException e) {
            ra.addFlashAttribute("errorMessage",
                    "Movement recorded but stock adjustment failed: " + e.getMessage());
            return "redirect:/stock-movement";
        }

        ra.addFlashAttribute("successMessage", "Stock movement recorded successfully.");
        return "redirect:/stock-movement";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model) {
        StockMovement movement = stockMovementService.getMovementById(id)
                .orElseThrow(() -> new RuntimeException("StockMovement not found: " + id));
        model.addAttribute("movement", movement);
        model.addAttribute("statuses", Status.values());
        return "ims/stock-movement/form";
    }

    @PostMapping("/edit/{id}")
    public String updateNote(@PathVariable Long id,
                             @RequestParam String note,
                             RedirectAttributes ra) {
        stockMovementService.updateNote(id, note);
        ra.addFlashAttribute("successMessage", "Movement note updated.");
        return "redirect:/stock-movement";
    }

    @PostMapping("/delete/{id}")
    public String softDelete(@PathVariable Long id, RedirectAttributes ra) {
        stockMovementService.softDeleteMovement(id);
        ra.addFlashAttribute("successMessage", "Movement record deactivated.");
        return "redirect:/stock-movement";
    }

    private User resolveUser(CustomUserDetails principal) {
        return userService.getUserByEmail(principal.getUsername());
    }
}
