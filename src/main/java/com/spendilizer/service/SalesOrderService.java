package com.spendilizer.service;

import com.spendilizer.entity.*;
import com.spendilizer.repository.SalesOrderRepository;
import com.spendilizer.repository.StockRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
public class SalesOrderService {

    private final SalesOrderRepository salesOrderRepository;
    private final StockRepository stockRepository;
    private final StockMovementService stockMovementService;
    private final UserService userService;

    public SalesOrderService(SalesOrderRepository salesOrderRepository,
                             StockRepository stockRepository,
                             StockMovementService stockMovementService,
                             UserService userService) {
        this.salesOrderRepository = salesOrderRepository;
        this.stockRepository = stockRepository;
        this.stockMovementService = stockMovementService;
        this.userService = userService;
    }

    @Transactional
    public SalesOrder createOrder(SalesOrder order, List<OrderItem> items, User user) {
        List<User> scope = userService.getScopeUsers(user);
        order.setOrderNumber(generateOrderNumber(scope));
        order.setCreatedBy(user);
        order.setStatus(OrderStatus.DRAFT);
        order.setOrderDate(order.getOrderDate() != null ? order.getOrderDate() : LocalDate.now());
        order.setPaymentMode(order.getPaymentMode() != null ? order.getPaymentMode() : OrderPaymentMode.CASH);
        order.getItems().clear();
        for (OrderItem item : items) {
            recalculateItem(item);
            item.setSalesOrder(order);
            order.getItems().add(item);
        }
        recalculateTotals(order);
        return salesOrderRepository.save(order);
    }

    @Transactional
    public SalesOrder confirmOrder(Long id, User user) {
        SalesOrder order = getById(id, user)
                .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        if (order.getStatus() != OrderStatus.DRAFT) {
            throw new IllegalStateException("Only DRAFT orders can be confirmed.");
        }
        for (OrderItem item : order.getItems()) {
            Stock stock = stockRepository.findByProductId(item.getProduct().getId())
                    .orElseThrow(() -> new RuntimeException(
                            "No stock record for product: " + item.getProduct().getName()));
            if (stock.getQuantity() < item.getQuantity()) {
                throw new IllegalStateException(
                        "Insufficient stock for \"" + item.getProduct().getName()
                        + "\". Available: " + stock.getQuantity()
                        + ", Required: " + item.getQuantity());
            }
        }
        for (OrderItem item : order.getItems()) {
            Stock stock = stockRepository.findByProductId(item.getProduct().getId()).get();
            stock.setQuantity(stock.getQuantity() - item.getQuantity());
            stockRepository.save(stock);

            StockMovement movement = new StockMovement();
            movement.setProduct(item.getProduct());
            movement.setType(StockMovementType.OUT);
            movement.setQuantity(item.getQuantity());
            movement.setNote("Order confirmed: " + order.getOrderNumber());
            movement.setRowStatus(Status.ACTIVE);
            stockMovementService.createMovement(movement);
        }
        order.setStatus(OrderStatus.CONFIRMED);
        return salesOrderRepository.save(order);
    }

    @Transactional
    public SalesOrder shipOrder(Long id, User user) {
        SalesOrder order = getById(id, user)
                .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        if (order.getStatus() != OrderStatus.CONFIRMED) {
            throw new IllegalStateException("Only CONFIRMED orders can be shipped.");
        }
        order.setStatus(OrderStatus.SHIPPED);
        return salesOrderRepository.save(order);
    }

    @Transactional
    public SalesOrder deliverOrder(Long id, User user) {
        SalesOrder order = getById(id, user)
                .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        if (order.getStatus() != OrderStatus.SHIPPED) {
            throw new IllegalStateException("Only SHIPPED orders can be marked delivered.");
        }
        order.setStatus(OrderStatus.DELIVERED);
        return salesOrderRepository.save(order);
    }

    @Transactional
    public SalesOrder cancelOrder(Long id, User user) {
        SalesOrder order = getById(id, user)
                .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        if (order.getStatus() == OrderStatus.CANCELLED || order.getStatus() == OrderStatus.DELIVERED) {
            throw new IllegalStateException("Cannot cancel a " + order.getStatus() + " order.");
        }
        boolean stockWasDeducted = order.getStatus() == OrderStatus.CONFIRMED
                || order.getStatus() == OrderStatus.SHIPPED;
        if (stockWasDeducted) {
            for (OrderItem item : order.getItems()) {
                Stock stock = stockRepository.findByProductId(item.getProduct().getId())
                        .orElse(null);
                if (stock != null) {
                    stock.setQuantity(stock.getQuantity() + item.getQuantity());
                    stockRepository.save(stock);

                    StockMovement reversal = new StockMovement();
                    reversal.setProduct(item.getProduct());
                    reversal.setType(StockMovementType.IN);
                    reversal.setQuantity(item.getQuantity());
                    reversal.setNote("Order cancelled: " + order.getOrderNumber());
                    reversal.setRowStatus(Status.ACTIVE);
                    stockMovementService.createMovement(reversal);
                }
            }
        }
        order.setStatus(OrderStatus.CANCELLED);
        return salesOrderRepository.save(order);
    }

    @Transactional
    public SalesOrder updateOrder(Long id, SalesOrder updated, List<OrderItem> items, User user) {
        SalesOrder existing = getById(id, user)
                .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        if (existing.getStatus() != OrderStatus.DRAFT) {
            throw new IllegalStateException("Only DRAFT orders can be edited.");
        }
        existing.setCustomer(updated.getCustomer());
        existing.setOrderDate(updated.getOrderDate());
        existing.setExpectedDeliveryDate(updated.getExpectedDeliveryDate());
        existing.setPaymentMode(updated.getPaymentMode() != null ? updated.getPaymentMode() : OrderPaymentMode.CASH);
        existing.setBillingAddress(updated.getBillingAddress());
        existing.setShippingAddress(updated.getShippingAddress());
        existing.setNotes(updated.getNotes());
        existing.getItems().clear();
        for (OrderItem item : items) {
            recalculateItem(item);
            item.setSalesOrder(existing);
            existing.getItems().add(item);
        }
        recalculateTotals(existing);
        return salesOrderRepository.save(existing);
    }

    public List<SalesOrder> getAll(User user) {
        return salesOrderRepository.findAllByCreatedByInOrderByCreatedAtDesc(
                userService.getScopeUsers(user));
    }

    public List<SalesOrder> getAllByStatus(OrderStatus status, User user) {
        return salesOrderRepository.findAllByStatusAndCreatedByIn(
                status, userService.getScopeUsers(user));
    }

    public Optional<SalesOrder> getById(Long id, User user) {
        return salesOrderRepository.findByIdAndCreatedByIn(id, userService.getScopeUsers(user));
    }

    public long countAll(User user) {
        return salesOrderRepository.countByCreatedByIn(userService.getScopeUsers(user));
    }

    public long countByStatus(OrderStatus status, User user) {
        return salesOrderRepository.countByStatusAndCreatedByIn(status, userService.getScopeUsers(user));
    }


    private void recalculateItem(OrderItem item) {
        BigDecimal qty = BigDecimal.valueOf(item.getQuantity());
        BigDecimal price = item.getUnitPrice();
        BigDecimal discPct = item.getDiscountPercent() != null ? item.getDiscountPercent() : BigDecimal.ZERO;
        BigDecimal discountFactor = BigDecimal.ONE.subtract(discPct.divide(BigDecimal.valueOf(100), 10, RoundingMode.HALF_UP));
        BigDecimal taxableAmt = qty.multiply(price).multiply(discountFactor).setScale(2, RoundingMode.HALF_UP);
        item.setAmount(taxableAmt);
    }

    private void recalculateTotals(SalesOrder order) {
        BigDecimal subtotal = BigDecimal.ZERO;
        BigDecimal totalDiscount = BigDecimal.ZERO;
        BigDecimal totalTax = BigDecimal.ZERO;

        for (OrderItem item : order.getItems()) {
            BigDecimal qty = BigDecimal.valueOf(item.getQuantity());
            BigDecimal price = item.getUnitPrice();
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

        order.setSubtotal(subtotal);
        order.setTotalDiscount(totalDiscount);
        order.setTotalTax(totalTax);
        order.setTotalAmount(subtotal.subtract(totalDiscount).add(totalTax));
    }

    private String generateOrderNumber(List<User> scopeUsers) {
        String year = String.valueOf(LocalDate.now().getYear());
        String prefix = "ORD-" + year + "-";
        List<String> existing = salesOrderRepository.findOrderNumbersByPrefix(prefix + "%", scopeUsers);
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
