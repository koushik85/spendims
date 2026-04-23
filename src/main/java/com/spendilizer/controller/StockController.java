package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.Status;
import com.spendilizer.entity.Stock;
import com.spendilizer.entity.User;
import com.spendilizer.service.ProductService;
import com.spendilizer.service.StockService;
import com.spendilizer.service.UserService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/stock")
public class StockController {

    private final StockService stockService;
    private final ProductService productService;
    private final UserService userService;

    public StockController(StockService stockService, ProductService productService, UserService userService) {
        this.stockService = stockService;
        this.productService = productService;
        this.userService = userService;
    }

    @GetMapping
    public String listStocks(@AuthenticationPrincipal CustomUserDetails principal, Model model) {
        User user = resolveUser(principal);
        List<Stock> stocks    = stockService.getAllActiveStocks(user);
        List<Stock> lowStocks = stockService.getLowStockItems(user);
        model.addAttribute("stocks",        stocks);
        model.addAttribute("lowStockCount", lowStocks.size());
        model.addAttribute("totalCount",    stocks.size());
        return "ims/stock/list";
    }

    @GetMapping("/new")
    public String showAddForm(@AuthenticationPrincipal CustomUserDetails principal, Model model) {
        model.addAttribute("stock",    new Stock());
        model.addAttribute("products", productService.getAllActiveProducts(resolveUser(principal)));
        return "ims/stock/form";
    }

    @PostMapping("/new")
    public String createStock(@ModelAttribute Stock stock, RedirectAttributes ra) {
        stock.setRowStatus(Status.ACTIVE);
        stockService.createStock(stock);
        ra.addFlashAttribute("successMessage", "Stock entry created successfully.");
        return "redirect:/stock";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@AuthenticationPrincipal CustomUserDetails principal,
                               @PathVariable Long id, Model model) {
        Stock stock = stockService.getStockById(id)
                .orElseThrow(() -> new RuntimeException("Stock not found: " + id));
        model.addAttribute("stock",    stock);
        model.addAttribute("products", productService.getAllActiveProducts(resolveUser(principal)));
        return "ims/stock/form";
    }

    @PostMapping("/edit/{id}")
    public String updateStock(@PathVariable Long id,
                              @ModelAttribute Stock updatedStock,
                              RedirectAttributes ra) {
        stockService.updateStock(id, updatedStock);
        ra.addFlashAttribute("successMessage", "Stock entry updated successfully.");
        return "redirect:/stock";
    }

    @PostMapping("/adjust/{id}")
    public String adjustQuantity(@PathVariable Long id,
                                 @RequestParam int delta,
                                 @RequestParam(required = false) String note,
                                 RedirectAttributes ra) {
        try {
            stockService.adjustQuantityWithMovement(id, delta, note);
            ra.addFlashAttribute("successMessage",
                    "Quantity " + (delta >= 0 ? "increased" : "decreased") + " by " + Math.abs(delta) + ".");
        } catch (RuntimeException e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/stock";
    }

    @PostMapping("/delete/{id}")
    public String softDelete(@PathVariable Long id, RedirectAttributes ra) {
        stockService.softDeleteStock(id);
        ra.addFlashAttribute("successMessage", "Stock entry deactivated.");
        return "redirect:/stock";
    }

    private User resolveUser(CustomUserDetails principal) {
        return userService.getUserByEmail(principal.getUsername());
    }
}
