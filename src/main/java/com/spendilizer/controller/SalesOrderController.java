package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.*;
import com.spendilizer.service.CustomerService;
import com.spendilizer.service.InvoiceService;
import com.spendilizer.service.ProductService;
import com.spendilizer.service.SalesOrderService;
import com.spendilizer.service.UserService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/order")
public class SalesOrderController {

    private final SalesOrderService salesOrderService;
    private final CustomerService customerService;
    private final ProductService productService;
    private final UserService userService;
    private final InvoiceService invoiceService;

    public SalesOrderController(SalesOrderService salesOrderService,
                                CustomerService customerService,
                                ProductService productService,
                                UserService userService,
                                InvoiceService invoiceService) {
        this.salesOrderService = salesOrderService;
        this.customerService = customerService;
        this.productService = productService;
        this.userService = userService;
        this.invoiceService = invoiceService;
    }

    @GetMapping
    public String list(@AuthenticationPrincipal CustomUserDetails principal, Model model) {
        model.addAttribute("orders", salesOrderService.getAll(resolveUser(principal)));
        return "ims/order/list";
    }

    @GetMapping("/new")
    public String showNewForm(@AuthenticationPrincipal CustomUserDetails principal, Model model) {
        User user = resolveUser(principal);
        model.addAttribute("order", new SalesOrder());
        model.addAttribute("customers", customerService.getAllActive(user));
        model.addAttribute("products", productService.getAllActiveProducts(user));
        model.addAttribute("paymentModes", OrderPaymentMode.values());
        return "ims/order/form";
    }

    @PostMapping("/new")
    public String create(@AuthenticationPrincipal CustomUserDetails principal,
                         @ModelAttribute SalesOrder order,
                         @RequestParam(value = "itemProductId", required = false) Long[] productIds,
                         @RequestParam(value = "itemDescription", required = false) String[] descriptions,
                         @RequestParam(value = "itemQuantity", required = false) Integer[] quantities,
                         @RequestParam(value = "itemUnitPrice", required = false) BigDecimal[] unitPrices,
                         @RequestParam(value = "itemDiscountPercent", required = false) BigDecimal[] discounts,
                         @RequestParam(value = "itemTaxPercent", required = false) BigDecimal[] taxes,
                         RedirectAttributes ra) {
        User user = resolveUser(principal);
        List<OrderItem> items = buildOrderItems(productIds, descriptions, quantities, unitPrices, discounts, taxes, user);
        if (items.isEmpty()) {
            ra.addFlashAttribute("errorMessage", "Order must have at least one item.");
            return "redirect:/order/new";
        }
        try {
            SalesOrder saved = salesOrderService.createOrder(order, items, user);
            ra.addFlashAttribute("successMessage", "Order " + saved.getOrderNumber() + " created.");
            return "redirect:/order/" + saved.getId();
        } catch (Exception e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/order/new";
        }
    }

    @GetMapping("/{id}")
    public String view(@AuthenticationPrincipal CustomUserDetails principal,
                       @PathVariable Long id, Model model) {
        User user = resolveUser(principal);
        SalesOrder order = salesOrderService.getById(id, user)
                .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        model.addAttribute("order", order);
        invoiceService.findByOrderId(id, user).ifPresent(inv ->
                model.addAttribute("linkedInvoice", inv));
        return "ims/order/view";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@AuthenticationPrincipal CustomUserDetails principal,
                               @PathVariable Long id, Model model) {
        User user = resolveUser(principal);
        SalesOrder order = salesOrderService.getById(id, user)
                .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        if (order.getStatus() != OrderStatus.DRAFT) {
            return "redirect:/order/" + id;
        }
        model.addAttribute("order", order);
        model.addAttribute("customers", customerService.getAllActive(user));
        model.addAttribute("products", productService.getAllActiveProducts(user));
        model.addAttribute("paymentModes", OrderPaymentMode.values());
        return "ims/order/form";
    }

    @PostMapping("/edit/{id}")
    public String update(@AuthenticationPrincipal CustomUserDetails principal,
                         @PathVariable Long id,
                         @ModelAttribute SalesOrder order,
                         @RequestParam(value = "itemProductId", required = false) Long[] productIds,
                         @RequestParam(value = "itemDescription", required = false) String[] descriptions,
                         @RequestParam(value = "itemQuantity", required = false) Integer[] quantities,
                         @RequestParam(value = "itemUnitPrice", required = false) BigDecimal[] unitPrices,
                         @RequestParam(value = "itemDiscountPercent", required = false) BigDecimal[] discounts,
                         @RequestParam(value = "itemTaxPercent", required = false) BigDecimal[] taxes,
                         RedirectAttributes ra) {
        User user = resolveUser(principal);
        List<OrderItem> items = buildOrderItems(productIds, descriptions, quantities, unitPrices, discounts, taxes, user);
        if (items.isEmpty()) {
            ra.addFlashAttribute("errorMessage", "Order must have at least one item.");
            return "redirect:/order/edit/" + id;
        }
        try {
            salesOrderService.updateOrder(id, order, items, user);
            ra.addFlashAttribute("successMessage", "Order updated successfully.");
            return "redirect:/order/" + id;
        } catch (Exception e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/order/edit/" + id;
        }
    }

    @PostMapping("/{id}/confirm")
    public String confirm(@AuthenticationPrincipal CustomUserDetails principal,
                          @PathVariable Long id, RedirectAttributes ra) {
        User user = resolveUser(principal);
        try {
            SalesOrder order = salesOrderService.confirmOrder(id, user);
            Invoice invoice = invoiceService.autoCreateFromOrder(order, user);
            ra.addFlashAttribute("successMessage",
                    "Order confirmed. Draft invoice " + invoice.getInvoiceNumber() + " auto-generated.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/order/" + id;
    }

    @PostMapping("/{id}/ship")
    public String ship(@AuthenticationPrincipal CustomUserDetails principal,
                       @PathVariable Long id, RedirectAttributes ra) {
        try {
            salesOrderService.shipOrder(id, resolveUser(principal));
            ra.addFlashAttribute("successMessage", "Order marked as shipped.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/order/" + id;
    }

    @PostMapping("/{id}/deliver")
    public String deliver(@AuthenticationPrincipal CustomUserDetails principal,
                          @PathVariable Long id, RedirectAttributes ra) {
        try {
            salesOrderService.deliverOrder(id, resolveUser(principal));
            ra.addFlashAttribute("successMessage", "Order marked as delivered.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/order/" + id;
    }

    @PostMapping("/{id}/cancel")
    public String cancel(@AuthenticationPrincipal CustomUserDetails principal,
                         @PathVariable Long id, RedirectAttributes ra) {
        try {
            salesOrderService.cancelOrder(id, resolveUser(principal));
            ra.addFlashAttribute("successMessage", "Order cancelled.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/order/" + id;
    }

    private List<OrderItem> buildOrderItems(Long[] productIds, String[] descriptions,
                                            Integer[] quantities, BigDecimal[] unitPrices,
                                            BigDecimal[] discounts, BigDecimal[] taxes,
                                            User user) {
        List<OrderItem> items = new ArrayList<>();
        if (quantities == null) return items;
        int len = quantities.length;
        for (int i = 0; i < len; i++) {
            Integer qty = quantities[i];
            if (qty == null || qty <= 0) continue;
            OrderItem item = new OrderItem();
            if (productIds != null && i < productIds.length && productIds[i] != null) {
                final Long pid = productIds[i];
                Product product = productService.getAllActiveProducts(user).stream()
                        .filter(p -> p.getId().equals(pid))
                        .findFirst().orElse(null);
                item.setProduct(product);
            }
            item.setDescription(descriptions != null && i < descriptions.length ? descriptions[i] : "");
            item.setQuantity(qty);
            item.setUnitPrice(unitPrices != null && i < unitPrices.length && unitPrices[i] != null
                    ? unitPrices[i] : BigDecimal.ZERO);
            item.setDiscountPercent(discounts != null && i < discounts.length && discounts[i] != null
                    ? discounts[i] : BigDecimal.ZERO);
            item.setTaxPercent(taxes != null && i < taxes.length && taxes[i] != null
                    ? taxes[i] : BigDecimal.valueOf(18));
            items.add(item);
        }
        return items;
    }

    private User resolveUser(CustomUserDetails principal) {
        return userService.getUserByEmail(principal.getUsername());
    }
}
