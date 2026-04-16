package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.*;
import com.spendilizer.service.CustomerService;
import com.spendilizer.service.InvoicePdfService;
import com.spendilizer.service.InvoiceService;
import com.spendilizer.service.ProductService;
import com.spendilizer.service.SalesOrderService;
import com.spendilizer.service.UserService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/invoice")
public class InvoiceController {

    private final InvoiceService invoiceService;
    private final InvoicePdfService invoicePdfService;
    private final CustomerService customerService;
    private final ProductService productService;
    private final SalesOrderService salesOrderService;
    private final UserService userService;

    public InvoiceController(InvoiceService invoiceService,
                             InvoicePdfService invoicePdfService,
                             CustomerService customerService,
                             ProductService productService,
                             SalesOrderService salesOrderService,
                             UserService userService) {
        this.invoiceService = invoiceService;
        this.invoicePdfService = invoicePdfService;
        this.customerService = customerService;
        this.productService = productService;
        this.salesOrderService = salesOrderService;
        this.userService = userService;
    }

    @GetMapping
    public String list(@AuthenticationPrincipal CustomUserDetails principal, Model model) {
        model.addAttribute("invoices", invoiceService.getAll(resolveUser(principal)));
        return "invoice/list";
    }

    @GetMapping("/new")
    public String showNewForm(@AuthenticationPrincipal CustomUserDetails principal,
                              @RequestParam(required = false) Long orderId,
                              Model model) {
        User user = resolveUser(principal);
        Invoice invoice = new Invoice();
        if (orderId != null) {
            salesOrderService.getById(orderId, user).ifPresent(order -> {
                invoice.setSalesOrder(order);
                invoice.setCustomer(order.getCustomer());
                invoice.setBillingAddress(order.getBillingAddress());
                invoice.setShippingAddress(order.getShippingAddress());
                invoice.setPaymentMode(order.getPaymentMode());
                model.addAttribute("prefillItems", order.getItems());
            });
        }
        model.addAttribute("invoice", invoice);
        model.addAttribute("paymentModes", OrderPaymentMode.values());
        model.addAttribute("customers", customerService.getAllActive(user));
        model.addAttribute("products", productService.getAllActiveProducts(user));
        model.addAttribute("orders", salesOrderService.getAll(user));
        return "invoice/form";
    }

    @PostMapping("/new")
    public String create(@AuthenticationPrincipal CustomUserDetails principal,
                         @ModelAttribute Invoice invoice,
                         @RequestParam(value = "itemProductId", required = false) Long[] productIds,
                         @RequestParam(value = "itemDescription", required = false) String[] descriptions,
                         @RequestParam(value = "itemHsnCode", required = false) String[] hsnCodes,
                         @RequestParam(value = "itemQuantity", required = false) Integer[] quantities,
                         @RequestParam(value = "itemUnitPrice", required = false) BigDecimal[] unitPrices,
                         @RequestParam(value = "itemDiscountPercent", required = false) BigDecimal[] discounts,
                         @RequestParam(value = "itemTaxPercent", required = false) BigDecimal[] taxes,
                         RedirectAttributes ra) {
        User user = resolveUser(principal);
        List<InvoiceItem> items = buildInvoiceItems(productIds, descriptions, hsnCodes,
                quantities, unitPrices, discounts, taxes, user);
        if (items.isEmpty()) {
            ra.addFlashAttribute("errorMessage", "Invoice must have at least one item.");
            return "redirect:/invoice/new";
        }
        try {
            Invoice saved = invoiceService.createInvoice(invoice, items, user);
            ra.addFlashAttribute("successMessage", "Invoice " + saved.getInvoiceNumber() + " created.");
            return "redirect:/invoice/" + saved.getId();
        } catch (Exception e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/invoice/new";
        }
    }

    @GetMapping("/{id}")
    public String view(@AuthenticationPrincipal CustomUserDetails principal,
                       @PathVariable Long id, Model model) {
        Invoice invoice = invoiceService.getById(id, resolveUser(principal))
                .orElseThrow(() -> new RuntimeException("Invoice not found: " + id));
        model.addAttribute("invoice", invoice);
        return "invoice/view";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@AuthenticationPrincipal CustomUserDetails principal,
                               @PathVariable Long id, Model model) {
        User user = resolveUser(principal);
        Invoice invoice = invoiceService.getById(id, user)
                .orElseThrow(() -> new RuntimeException("Invoice not found: " + id));
        if (invoice.getStatus() != InvoiceStatus.DRAFT) {
            return "redirect:/invoice/" + id;
        }
        model.addAttribute("invoice", invoice);
        model.addAttribute("paymentModes", OrderPaymentMode.values());
        model.addAttribute("customers", customerService.getAllActive(user));
        model.addAttribute("products", productService.getAllActiveProducts(user));
        model.addAttribute("orders", salesOrderService.getAll(user));
        return "invoice/form";
    }

        @GetMapping(value = "/{id}/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
        public ResponseEntity<byte[]> downloadPdf(@AuthenticationPrincipal CustomUserDetails principal,
                              @PathVariable Long id) {
        User user = resolveUser(principal);
        Invoice invoice = invoiceService.getById(id, user)
            .orElseThrow(() -> new RuntimeException("Invoice not found: " + id));
        byte[] pdf = invoicePdfService.generateInvoicePdf(id, user);
        String filename = (invoice.getInvoiceNumber() != null && !invoice.getInvoiceNumber().isBlank())
            ? invoice.getInvoiceNumber() + ".pdf"
            : "invoice-" + id + ".pdf";

        return ResponseEntity.ok()
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
            .contentType(MediaType.APPLICATION_PDF)
            .body(pdf);
        }

    @PostMapping("/edit/{id}")
    public String update(@AuthenticationPrincipal CustomUserDetails principal,
                         @PathVariable Long id,
                         @ModelAttribute Invoice invoice,
                         @RequestParam(value = "itemProductId", required = false) Long[] productIds,
                         @RequestParam(value = "itemDescription", required = false) String[] descriptions,
                         @RequestParam(value = "itemHsnCode", required = false) String[] hsnCodes,
                         @RequestParam(value = "itemQuantity", required = false) Integer[] quantities,
                         @RequestParam(value = "itemUnitPrice", required = false) BigDecimal[] unitPrices,
                         @RequestParam(value = "itemDiscountPercent", required = false) BigDecimal[] discounts,
                         @RequestParam(value = "itemTaxPercent", required = false) BigDecimal[] taxes,
                         RedirectAttributes ra) {
        User user = resolveUser(principal);
        List<InvoiceItem> items = buildInvoiceItems(productIds, descriptions, hsnCodes,
                quantities, unitPrices, discounts, taxes, user);
        if (items.isEmpty()) {
            ra.addFlashAttribute("errorMessage", "Invoice must have at least one item.");
            return "redirect:/invoice/edit/" + id;
        }
        try {
            invoiceService.updateInvoice(id, invoice, items, user);
            ra.addFlashAttribute("successMessage", "Invoice updated.");
            return "redirect:/invoice/" + id;
        } catch (Exception e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/invoice/edit/" + id;
        }
    }

    @PostMapping("/{id}/send")
    public String markSent(@AuthenticationPrincipal CustomUserDetails principal,
                           @PathVariable Long id, RedirectAttributes ra) {
        try {
            invoiceService.markSent(id, resolveUser(principal));
            ra.addFlashAttribute("successMessage", "Invoice marked as SENT.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/invoice/" + id;
    }

    @PostMapping("/{id}/pay")
    public String markPaid(@AuthenticationPrincipal CustomUserDetails principal,
                           @PathVariable Long id, RedirectAttributes ra) {
        try {
            invoiceService.markPaid(id, resolveUser(principal));
            ra.addFlashAttribute("successMessage", "Invoice marked as PAID.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/invoice/" + id;
    }

    @PostMapping("/{id}/cancel")
    public String cancel(@AuthenticationPrincipal CustomUserDetails principal,
                         @PathVariable Long id, RedirectAttributes ra) {
        try {
            invoiceService.markCancelled(id, resolveUser(principal));
            ra.addFlashAttribute("successMessage", "Invoice cancelled.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/invoice/" + id;
    }

    private List<InvoiceItem> buildInvoiceItems(Long[] productIds, String[] descriptions,
                                                String[] hsnCodes, Integer[] quantities,
                                                BigDecimal[] unitPrices, BigDecimal[] discounts,
                                                BigDecimal[] taxes, User user) {
        List<InvoiceItem> items = new ArrayList<>();
        if (quantities == null) return items;
        List<Product> allProducts = productService.getAllActiveProducts(user);
        for (int i = 0; i < quantities.length; i++) {
            Integer qty = quantities[i];
            if (qty == null || qty <= 0) continue;
            InvoiceItem item = new InvoiceItem();
            if (productIds != null && i < productIds.length && productIds[i] != null) {
                Long pid = productIds[i];
                allProducts.stream().filter(p -> p.getId().equals(pid)).findFirst()
                        .ifPresent(item::setProduct);
            }
            item.setDescription(descriptions != null && i < descriptions.length ? descriptions[i] : "");
            item.setHsnCode(hsnCodes != null && i < hsnCodes.length ? hsnCodes[i] : null);
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
