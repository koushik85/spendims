package com.spendilizer.service;

import com.spendilizer.entity.*;
import com.spendilizer.repository.InvoiceRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class InvoiceService {

    private final InvoiceRepository invoiceRepository;
    private final UserService userService;

    public InvoiceService(InvoiceRepository invoiceRepository, UserService userService) {
        this.invoiceRepository = invoiceRepository;
        this.userService = userService;
    }

    @Transactional
    public Invoice createInvoice(Invoice invoice, List<InvoiceItem> items, User user) {
        List<User> scope = userService.getScopeUsers(user);
        invoice.setInvoiceNumber(generateInvoiceNumber(scope));
        invoice.setCreatedBy(user);
        invoice.setStatus(InvoiceStatus.DRAFT);
        if (invoice.getPaymentMode() == null) {
            if (invoice.getSalesOrder() != null && invoice.getSalesOrder().getPaymentMode() != null) {
                invoice.setPaymentMode(invoice.getSalesOrder().getPaymentMode());
            } else {
                invoice.setPaymentMode(OrderPaymentMode.CASH);
            }
        }
        if (invoice.getInvoiceDate() == null) invoice.setInvoiceDate(LocalDate.now());
        if (invoice.getCustomer() != null && (invoice.getCustomerGstin() == null || invoice.getCustomerGstin().isBlank())) {
            invoice.setCustomerGstin(invoice.getCustomer().getGstin());
        }
        invoice.getItems().clear();
        for (InvoiceItem item : items) {
            recalculateItem(item);
            item.setInvoice(invoice);
            invoice.getItems().add(item);
        }
        recalculateTotals(invoice);
        return invoiceRepository.save(invoice);
    }

    @Transactional
    public Invoice updateInvoice(Long id, Invoice updated, List<InvoiceItem> items, User user) {
        Invoice existing = getById(id, user)
                .orElseThrow(() -> new RuntimeException("Invoice not found: " + id));
        if (existing.getStatus() != InvoiceStatus.DRAFT) {
            throw new IllegalStateException("Only DRAFT invoices can be edited.");
        }
        existing.setCustomer(updated.getCustomer());
        existing.setInvoiceDate(updated.getInvoiceDate());
        existing.setDueDate(updated.getDueDate());
        existing.setPaymentMode(updated.getPaymentMode() != null ? updated.getPaymentMode() : OrderPaymentMode.CASH);
        existing.setBillingAddress(updated.getBillingAddress());
        existing.setShippingAddress(updated.getShippingAddress());
        existing.setCustomerGstin(updated.getCustomerGstin());
        existing.setNotes(updated.getNotes());
        existing.setTermsAndConditions(updated.getTermsAndConditions());
        existing.getItems().clear();
        for (InvoiceItem item : items) {
            recalculateItem(item);
            item.setInvoice(existing);
            existing.getItems().add(item);
        }
        recalculateTotals(existing);
        return invoiceRepository.save(existing);
    }

    @Transactional
    public Invoice markSent(Long id, User user) {
        Invoice invoice = getById(id, user)
                .orElseThrow(() -> new RuntimeException("Invoice not found: " + id));
        if (invoice.getStatus() != InvoiceStatus.DRAFT) {
            throw new IllegalStateException("Only DRAFT invoices can be marked as SENT.");
        }
        invoice.setStatus(InvoiceStatus.SENT);
        return invoiceRepository.save(invoice);
    }

    @Transactional
    public Invoice markPaid(Long id, User user) {
        Invoice invoice = getById(id, user)
                .orElseThrow(() -> new RuntimeException("Invoice not found: " + id));
        if (invoice.getStatus() != InvoiceStatus.SENT && invoice.getStatus() != InvoiceStatus.OVERDUE) {
            throw new IllegalStateException("Only SENT or OVERDUE invoices can be marked as PAID.");
        }
        invoice.setStatus(InvoiceStatus.PAID);
        return invoiceRepository.save(invoice);
    }

    @Transactional
    public Invoice markCancelled(Long id, User user) {
        Invoice invoice = getById(id, user)
                .orElseThrow(() -> new RuntimeException("Invoice not found: " + id));
        if (invoice.getStatus() == InvoiceStatus.PAID || invoice.getStatus() == InvoiceStatus.CANCELLED) {
            throw new IllegalStateException("Cannot cancel a " + invoice.getStatus() + " invoice.");
        }
        invoice.setStatus(InvoiceStatus.CANCELLED);
        return invoiceRepository.save(invoice);
    }

    public List<Invoice> getAll(User user) {
        return invoiceRepository.findAllByCreatedByInOrderByCreatedAtDesc(userService.getScopeUsers(user));
    }

    public Optional<Invoice> getById(Long id, User user) {
        return invoiceRepository.findByIdAndCreatedByIn(id, userService.getScopeUsers(user));
    }

    public Optional<Invoice> findByOrderId(Long orderId, User user) {
        return invoiceRepository.findBySalesOrderIdAndCreatedByIn(orderId, userService.getScopeUsers(user));
    }

    @Transactional
    public Invoice autoCreateFromOrder(SalesOrder order, User user) {
        Invoice invoice = new Invoice();
        invoice.setSalesOrder(order);
        invoice.setCustomer(order.getCustomer());
        invoice.setBillingAddress(order.getBillingAddress());
        invoice.setShippingAddress(order.getShippingAddress());
        invoice.setPaymentMode(order.getPaymentMode() != null ? order.getPaymentMode() : OrderPaymentMode.CASH);
        if (order.getCustomer() != null) {
            invoice.setCustomerGstin(order.getCustomer().getGstin());
        }
        invoice.setDueDate(LocalDate.now().plusDays(30));
        List<InvoiceItem> items = new ArrayList<>();
        for (OrderItem oi : order.getItems()) {
            InvoiceItem item = new InvoiceItem();
            item.setProduct(oi.getProduct());
            String desc = (oi.getDescription() != null && !oi.getDescription().isBlank())
                    ? oi.getDescription()
                    : (oi.getProduct() != null ? oi.getProduct().getName() : "");
            item.setDescription(desc);
            if (oi.getProduct() != null && oi.getProduct().getHsn() != null) {
                item.setHsnCode(oi.getProduct().getHsn().getHsnCode());
            }
            item.setQuantity(oi.getQuantity());
            item.setUnitPrice(oi.getUnitPrice());
            item.setDiscountPercent(oi.getDiscountPercent());
            item.setTaxPercent(oi.getTaxPercent());
            items.add(item);
        }
        return createInvoice(invoice, items, user);
    }

    public long countAll(User user) {
        return invoiceRepository.countByCreatedByIn(userService.getScopeUsers(user));
    }

    public long countByStatus(InvoiceStatus status, User user) {
        return invoiceRepository.countByStatusAndCreatedByIn(status, userService.getScopeUsers(user));
    }

    public BigDecimal sumByStatus(InvoiceStatus status, User user) {
        return invoiceRepository.sumTotalAmountByStatusAndCreatedByIn(status, userService.getScopeUsers(user));
    }

    private void recalculateItem(InvoiceItem item) {
        BigDecimal qty = BigDecimal.valueOf(item.getQuantity());
        BigDecimal price = item.getUnitPrice() != null ? item.getUnitPrice() : BigDecimal.ZERO;
        BigDecimal discPct = item.getDiscountPercent() != null ? item.getDiscountPercent() : BigDecimal.ZERO;
        BigDecimal discountFactor = BigDecimal.ONE.subtract(
                discPct.divide(BigDecimal.valueOf(100), 10, RoundingMode.HALF_UP));
        item.setAmount(qty.multiply(price).multiply(discountFactor).setScale(2, RoundingMode.HALF_UP));
    }

    private void recalculateTotals(Invoice invoice) {
        BigDecimal subtotal = BigDecimal.ZERO;
        BigDecimal totalDiscount = BigDecimal.ZERO;
        BigDecimal totalTax = BigDecimal.ZERO;
        for (InvoiceItem item : invoice.getItems()) {
            BigDecimal qty = BigDecimal.valueOf(item.getQuantity());
            BigDecimal price = item.getUnitPrice() != null ? item.getUnitPrice() : BigDecimal.ZERO;
            BigDecimal gross = qty.multiply(price).setScale(2, RoundingMode.HALF_UP);
            BigDecimal discPct = item.getDiscountPercent() != null ? item.getDiscountPercent() : BigDecimal.ZERO;
            BigDecimal discAmt = gross.multiply(discPct).divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
            BigDecimal taxable = gross.subtract(discAmt);
            BigDecimal taxPct = item.getTaxPercent() != null ? item.getTaxPercent() : BigDecimal.ZERO;
            BigDecimal taxAmt = taxable.multiply(taxPct).divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
            subtotal = subtotal.add(gross);
            totalDiscount = totalDiscount.add(discAmt);
            totalTax = totalTax.add(taxAmt);
        }
        invoice.setSubtotal(subtotal);
        invoice.setTotalDiscount(totalDiscount);
        invoice.setTotalTax(totalTax);
        invoice.setTotalAmount(subtotal.subtract(totalDiscount).add(totalTax));
    }

    private String generateInvoiceNumber(List<User> scopeUsers) {
        String year = String.valueOf(LocalDate.now().getYear());
        String prefix = "INV-" + year + "-";
        List<String> existing = invoiceRepository.findInvoiceNumbersByPrefix(prefix + "%", scopeUsers);
        int max = 0;
        for (String num : existing) {
            try {
                int seq = Integer.parseInt(num.substring(prefix.length()));
                if (seq > max) max = seq;
            } catch (NumberFormatException ignored) {}
        }
        return prefix + String.format("%04d", max + 1);
    }
}
