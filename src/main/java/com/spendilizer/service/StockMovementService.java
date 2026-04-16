package com.spendilizer.service;

import com.spendilizer.entity.Status;
import com.spendilizer.entity.StockMovement;
import com.spendilizer.entity.StockMovementType;
import com.spendilizer.entity.User;
import com.spendilizer.repository.StockMovementRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class StockMovementService {

    private final StockMovementRepository stockMovementRepository;
    private final UserService userService;

    public StockMovementService(StockMovementRepository stockMovementRepository, UserService userService) {
        this.stockMovementRepository = stockMovementRepository;
        this.userService = userService;
    }

    public StockMovement createMovement(StockMovement stockMovement) {
        return stockMovementRepository.save(stockMovement);
    }

    public List<StockMovement> getAllMovements(User user) {
        return stockMovementRepository.findAllByProduct_CreatedByIn(userService.getScopeUsers(user));
    }

    public List<StockMovement> getAllActiveMovements(User user) {
        return stockMovementRepository.findAllByProduct_CreatedByInAndRowStatus(userService.getScopeUsers(user), Status.ACTIVE);
    }

    public Optional<StockMovement> getMovementById(Long id) {
        return stockMovementRepository.findById(id);
    }

    public List<StockMovement> getMovementsByProductId(Long productId, User user) {
        return stockMovementRepository.findByProductIdAndProduct_CreatedByIn(productId, userService.getScopeUsers(user));
    }

    public List<StockMovement> getMovementsByType(StockMovementType type, User user) {
        return stockMovementRepository.findByTypeAndProduct_CreatedByIn(type, userService.getScopeUsers(user));
    }

    public List<StockMovement> getMovementsByProductIdAndType(Long productId, StockMovementType type, User user) {
        return stockMovementRepository.findByProductIdAndTypeAndProduct_CreatedByIn(productId, type, userService.getScopeUsers(user));
    }

    public StockMovement updateNote(Long id, String note) {
        StockMovement existing = stockMovementRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("StockMovement not found: " + id));
        existing.setNote(note);
        return stockMovementRepository.save(existing);
    }

    public void softDeleteMovement(Long id) {
        StockMovement existing = stockMovementRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("StockMovement not found: " + id));
        existing.setRowStatus(Status.DELETED);
        stockMovementRepository.save(existing);
    }
}
