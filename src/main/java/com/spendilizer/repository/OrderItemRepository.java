package com.spendilizer.repository;

import com.spendilizer.entity.OrderItem;
import com.spendilizer.entity.SalesOrder;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {
    List<OrderItem> findBySalesOrder(SalesOrder salesOrder);
    void deleteBySalesOrder(SalesOrder salesOrder);
}
