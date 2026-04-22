package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.*;
import com.spendilizer.service.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.math.BigDecimal;
import java.util.List;

@Controller
public class DashboardController {

    private final ProductService productService;
    private final CategoryService categoryService;
    private final SupplierService supplierService;
    private final StockService stockService;
    private final StockMovementService stockMovementService;
    private final CustomerService customerService;
    private final SalesOrderService salesOrderService;
    private final InvoiceService invoiceService;
    private final UserService userService;

    public DashboardController(ProductService productService,
                               CategoryService categoryService,
                               SupplierService supplierService,
                               StockService stockService,
                               StockMovementService stockMovementService,
                               CustomerService customerService,
                               SalesOrderService salesOrderService,
                               InvoiceService invoiceService,
                               UserService userService) {
        this.productService = productService;
        this.categoryService = categoryService;
        this.supplierService = supplierService;
        this.stockService = stockService;
        this.stockMovementService = stockMovementService;
        this.customerService = customerService;
        this.salesOrderService = salesOrderService;
        this.invoiceService = invoiceService;
        this.userService = userService;
    }

    @GetMapping("/dashboard")
    public String dashboard(@AuthenticationPrincipal CustomUserDetails principal, Model model) {
        User user = userService.getUserByEmail(principal.getUsername());

        long productCount = productService.getAllProducts(user).stream()
                .filter(p -> p.getRowStatus() != null && p.getRowStatus().name().equals("ACTIVE"))
                .count();

        long categoryCount = categoryService.getActiveCategories(user).size();
        long supplierCount = supplierService.getAllActiveSuppliers(user).size();

        long inStockCount = stockService.getAllStocks(user).stream()
                .filter(s -> s.getQuantity() > 0)
                .count();

        long lowStockCount = stockService.getLowStockItems(user).size();

        List<StockMovement> allMovements = stockMovementService.getAllMovements(user);
        long movementCount = allMovements.size();

        List<StockMovement> recentMovements = allMovements.stream()
                .sorted((a, b) -> {
                    if (a.getMovedAt() == null && b.getMovedAt() == null) return 0;
                    if (a.getMovedAt() == null) return 1;
                    if (b.getMovedAt() == null) return -1;
                    return b.getMovedAt().compareTo(a.getMovedAt());
                })
                .limit(10)
                .toList();

        long customerCount   = customerService.countActive(user);
        long pendingOrders   = salesOrderService.countByStatus(OrderStatus.CONFIRMED, user)
                             + salesOrderService.countByStatus(OrderStatus.SHIPPED, user);
        long totalOrders     = salesOrderService.countAll(user);
        BigDecimal paidRevenue = invoiceService.sumByStatus(InvoiceStatus.PAID, user);
        if (paidRevenue == null) paidRevenue = BigDecimal.ZERO;
        long unpaidInvoices  = invoiceService.countByStatus(InvoiceStatus.SENT, user)
                             + invoiceService.countByStatus(InvoiceStatus.OVERDUE, user);

        model.addAttribute("productCount",    productCount);
        model.addAttribute("categoryCount",   categoryCount);
        model.addAttribute("supplierCount",   supplierCount);
        model.addAttribute("inStockCount",    inStockCount);
        model.addAttribute("lowStockCount",   lowStockCount);
        model.addAttribute("movementCount",   movementCount);
        model.addAttribute("recentMovements", recentMovements);
        model.addAttribute("customerCount",   customerCount);
        model.addAttribute("pendingOrders",   pendingOrders);
        model.addAttribute("totalOrders",     totalOrders);
        model.addAttribute("paidRevenue",     paidRevenue);
        model.addAttribute("unpaidInvoices",  unpaidInvoices);

        return "ims/dashboard";
    }
}
