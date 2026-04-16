package com.spendilizer.service;

import com.spendilizer.entity.*;
import com.spendilizer.repository.StockRepository;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class StockService {

    private final StockRepository stockRepository;
    private final ProductService productService;
    private final UserService userService;
    private final StockMovementService stockMovementService;

    public StockService(StockRepository stockRepository,
                        ProductService productService,
                        UserService userService,
                        @Lazy StockMovementService stockMovementService) {
        this.stockRepository = stockRepository;
        this.productService  = productService;
        this.userService     = userService;
        this.stockMovementService = stockMovementService;
    }

    public Stock createStock(Stock stock) {
        Stock saved = stockRepository.save(stock);
        if (saved.getQuantity() != null && saved.getQuantity() > 0) {
            autoMovement(saved.getProduct(), saved.getQuantity(), StockMovementType.IN, "Initial stock entry");
        }
        return saved;
    }

    public List<Stock> getAllStocks(User user) {
        return stockRepository.findAllByProduct_CreatedByIn(userService.getScopeUsers(user));
    }

    public List<Stock> getAllActiveStocks(User user) {
        return stockRepository.findAllByProduct_CreatedByInAndRowStatus(userService.getScopeUsers(user), Status.ACTIVE);
    }

    public Optional<Stock> getStockById(Long id) {
        return stockRepository.findById(id);
    }

    public Optional<Stock> getStockByProductId(Long productId) {
        return stockRepository.findByProductId(productId);
    }

    public Stock updateStock(Long id, Stock updatedStock) {
        Stock existing = stockRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Stock not found: " + id));
        int oldQty = existing.getQuantity() != null ? existing.getQuantity() : 0;
        int newQty = updatedStock.getQuantity() != null ? updatedStock.getQuantity() : 0;
        existing.setQuantity(newQty);
        existing.setMinThreshold(updatedStock.getMinThreshold());
        existing.setProduct(updatedStock.getProduct());
        existing.setRowStatus(updatedStock.getRowStatus());
        Stock saved = stockRepository.save(existing);
        int delta = newQty - oldQty;
        if (delta != 0) {
            StockMovementType type = delta > 0 ? StockMovementType.IN : StockMovementType.OUT;
            autoMovement(saved.getProduct(), Math.abs(delta), type, "Manual stock adjustment");
        }
        return saved;
    }

    /**
     * Adjusts quantity only — no movement created. Use when the caller already
     * persists a StockMovement (e.g. StockMovementController, SalesOrderService).
     */
    public Stock adjustQuantity(Long id, int delta) {
        Stock existing = stockRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Stock not found: " + id));
        int newQuantity = existing.getQuantity() + delta;
        if (newQuantity < 0) {
            throw new RuntimeException("Insufficient stock for product id: " + existing.getProduct().getId());
        }
        existing.setQuantity(newQuantity);
        return stockRepository.save(existing);
    }

    /**
     * Adjusts quantity AND auto-creates a stock movement. Use from controllers
     * that do not separately persist a StockMovement (e.g. StockController quick-adjust).
     */
    public Stock adjustQuantityWithMovement(Long id, int delta, String note) {
        Stock saved = adjustQuantity(id, delta);
        StockMovementType type = delta > 0 ? StockMovementType.IN : StockMovementType.OUT;
        autoMovement(saved.getProduct(), Math.abs(delta), type,
                note != null && !note.isBlank() ? note : "Quick stock adjustment");
        return saved;
    }

    public List<Stock> getLowStockItems(User user) {
        return stockRepository.findAllByProduct_CreatedByIn(userService.getScopeUsers(user)).stream()
                .filter(s -> s.getQuantity() <= s.getMinThreshold())
                .toList();
    }

    public void softDeleteStock(Long id) {
        Stock existing = stockRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Stock not found: " + id));
        existing.setRowStatus(Status.DELETED);
        stockRepository.save(existing);
    }

    public void createStockBeforeMovement(Long productId, int initialQty, User user) {
        Product product = productService.getProductById(productId, user)
                .orElseThrow(() -> new RuntimeException("No product with id " + productId));
        Stock stock = new Stock();
        stock.setProduct(product);
        stock.setQuantity(initialQty);
        stock.setMinThreshold(10);
        stock.setRowStatus(Status.ACTIVE);
        stockRepository.save(stock);
        // Note: movement is created by caller (StockMovementController), not here
    }

    private void autoMovement(Product product, int qty, StockMovementType type, String note) {
        StockMovement movement = new StockMovement();
        movement.setProduct(product);
        movement.setType(type);
        movement.setQuantity(qty);
        movement.setNote(note);
        movement.setRowStatus(Status.ACTIVE);
        stockMovementService.createMovement(movement);
    }
}
