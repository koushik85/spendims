package com.spendilizer.controller;

import com.spendilizer.config.CustomUserDetails;
import com.spendilizer.entity.*;
import com.spendilizer.repository.*;
import com.spendilizer.service.UserService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/search")
public class SearchController {

    private final ProductRepository  productRepository;
    private final SupplierRepository supplierRepository;
    private final CustomerRepository customerRepository;
    private final SalesOrderRepository salesOrderRepository;
    private final InvoiceRepository  invoiceRepository;
    private final UserService        userService;

    public SearchController(ProductRepository productRepository,
                            SupplierRepository supplierRepository,
                            CustomerRepository customerRepository,
                            SalesOrderRepository salesOrderRepository,
                            InvoiceRepository invoiceRepository,
                            UserService userService) {
        this.productRepository   = productRepository;
        this.supplierRepository  = supplierRepository;
        this.customerRepository  = customerRepository;
        this.salesOrderRepository = salesOrderRepository;
        this.invoiceRepository   = invoiceRepository;
        this.userService         = userService;
    }

    @GetMapping
    public List<Map<String, String>> search(@RequestParam String q,
                                            @AuthenticationPrincipal CustomUserDetails principal) {
        String trimmed = q == null ? "" : q.trim();
        if (trimmed.length() < 2) return Collections.emptyList();

        User user = userService.getUserByEmail(principal.getUsername());
        List<User> scope = userService.getScopeUsers(user);
        List<Map<String, String>> results = new ArrayList<>();

        productRepository.searchActiveByNameOrSku(trimmed, scope).stream().limit(4).forEach(p ->
                results.add(result("Product", p.getName(),
                        p.getSku() != null ? p.getSku() : "",
                        "/spendilizer/product")));

        supplierRepository.searchActiveByName(trimmed, scope).stream().limit(3).forEach(s ->
                results.add(result("Supplier", s.getName(),
                        s.getEmail() != null ? s.getEmail() : "",
                        "/spendilizer/supplier")));

        customerRepository.searchActiveByNameOrEmail(trimmed, scope).stream().limit(3).forEach(c ->
                results.add(result("Customer", c.getDisplayName(),
                        c.getEmail(),
                        "/spendilizer/customer")));

        salesOrderRepository.searchByNumberOrCustomer(trimmed, scope).stream().limit(3).forEach(o ->
                results.add(result("Order", o.getOrderNumber(),
                        o.getCustomer() != null ? o.getCustomer().getDisplayName() : "",
                        "/spendilizer/order/" + o.getId())));

        invoiceRepository.searchByNumberOrCustomer(trimmed, scope).stream().limit(3).forEach(i ->
                results.add(result("Invoice", i.getInvoiceNumber(),
                        i.getCustomer() != null ? i.getCustomer().getDisplayName() : "",
                        "/spendilizer/invoice/" + i.getId())));

        return results;
    }

    private Map<String, String> result(String type, String label, String sub, String url) {
        Map<String, String> m = new LinkedHashMap<>();
        m.put("type",  type);
        m.put("label", label);
        m.put("sub",   sub);
        m.put("url",   url);
        return m;
    }
}
