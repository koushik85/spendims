package com.spendilizer.repository;

import com.spendilizer.entity.Customer;
import com.spendilizer.entity.Invoice;
import com.spendilizer.entity.InvoiceStatus;
import com.spendilizer.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

public interface InvoiceRepository extends JpaRepository<Invoice, Long> {

    List<Invoice> findAllByCreatedByInOrderByCreatedAtDesc(List<User> createdBy);

    List<Invoice> findAllByStatusAndCreatedByIn(InvoiceStatus status, List<User> createdBy);

    List<Invoice> findAllByCustomerAndCreatedByIn(Customer customer, List<User> createdBy);

    Optional<Invoice> findByIdAndCreatedByIn(Long id, List<User> createdBy);

    long countByCreatedByIn(List<User> createdBy);

    long countByStatusAndCreatedByIn(InvoiceStatus status, List<User> createdBy);

    @Query("SELECT COALESCE(SUM(i.totalAmount), 0) FROM Invoice i WHERE i.status = :status AND i.createdBy IN :users")
    BigDecimal sumTotalAmountByStatusAndCreatedByIn(@Param("status") InvoiceStatus status, @Param("users") List<User> users);

    @Query("SELECT i.invoiceNumber FROM Invoice i WHERE i.invoiceNumber LIKE :prefix AND i.createdBy IN :users")
    List<String> findInvoiceNumbersByPrefix(@Param("prefix") String prefix, @Param("users") List<User> users);

    Optional<Invoice> findBySalesOrderIdAndCreatedByIn(Long salesOrderId, List<User> createdBy);

    @Query("SELECT i FROM Invoice i WHERE i.createdBy IN :users AND (LOWER(i.invoiceNumber) LIKE LOWER(CONCAT('%',:q,'%')) OR LOWER(i.customer.firstName) LIKE LOWER(CONCAT('%',:q,'%')) OR LOWER(i.customer.companyName) LIKE LOWER(CONCAT('%',:q,'%')))")
    List<Invoice> searchByNumberOrCustomer(@Param("q") String q, @Param("users") List<User> users);
}
