package com.spendilizer.repository;

import com.spendilizer.entity.Status;
import com.spendilizer.entity.Stock;
import com.spendilizer.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface StockRepository extends JpaRepository<Stock, Long> {
    Optional<Stock> findByProductId(Long productId);
    List<Stock> findAllByProduct_CreatedByIn(List<User> users);
    List<Stock> findAllByProduct_CreatedByInAndRowStatus(List<User> users, Status rowStatus);
}
