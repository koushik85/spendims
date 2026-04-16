package com.spendilizer.repository;

import com.spendilizer.entity.Customer;
import com.spendilizer.entity.OrderStatus;
import com.spendilizer.entity.SalesOrder;
import com.spendilizer.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface SalesOrderRepository extends JpaRepository<SalesOrder, Long> {

    List<SalesOrder> findAllByCreatedByInOrderByCreatedAtDesc(List<User> createdBy);

    List<SalesOrder> findAllByStatusAndCreatedByIn(OrderStatus status, List<User> createdBy);

    List<SalesOrder> findAllByCustomerAndCreatedByIn(Customer customer, List<User> createdBy);

    Optional<SalesOrder> findByIdAndCreatedByIn(Long id, List<User> createdBy);

    long countByCreatedByIn(List<User> createdBy);

    long countByStatusAndCreatedByIn(OrderStatus status, List<User> createdBy);

    @Query("SELECT s.orderNumber FROM SalesOrder s WHERE s.orderNumber LIKE :prefix AND s.createdBy IN :users")
    List<String> findOrderNumbersByPrefix(@Param("prefix") String prefix, @Param("users") List<User> users);

    @Query("SELECT s FROM SalesOrder s WHERE s.createdBy IN :users AND (LOWER(s.orderNumber) LIKE LOWER(CONCAT('%',:q,'%')) OR LOWER(s.customer.firstName) LIKE LOWER(CONCAT('%',:q,'%')) OR LOWER(s.customer.companyName) LIKE LOWER(CONCAT('%',:q,'%')))")
    List<SalesOrder> searchByNumberOrCustomer(@Param("q") String q, @Param("users") List<User> users);
}
