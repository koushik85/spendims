package com.spendilizer.repository;

import com.spendilizer.entity.Status;
import com.spendilizer.entity.StockMovement;
import com.spendilizer.entity.StockMovementType;
import com.spendilizer.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface StockMovementRepository extends JpaRepository<StockMovement, Long> {
    List<StockMovement> findByProductIdAndProduct_CreatedByIn(Long productId, List<User> users);
    List<StockMovement> findByTypeAndProduct_CreatedByIn(StockMovementType type, List<User> users);
    List<StockMovement> findByProductIdAndTypeAndProduct_CreatedByIn(Long productId, StockMovementType type, List<User> users);
    List<StockMovement> findAllByProduct_CreatedByIn(List<User> users);
    List<StockMovement> findAllByProduct_CreatedByInAndRowStatus(List<User> users, Status rowStatus);
}
