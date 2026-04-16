package com.spendilizer.repository;

import com.spendilizer.entity.Customer;
import com.spendilizer.entity.Status;
import com.spendilizer.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CustomerRepository extends JpaRepository<Customer, Long> {

    List<Customer> findAllByRowStatusAndCreatedByIn(Status rowStatus, List<User> createdBy);

    List<Customer> findAllByCreatedByIn(List<User> createdBy);

    Optional<Customer> findByIdAndCreatedByIn(Long id, List<User> createdBy);

    boolean existsByEmailAndCreatedByInAndRowStatusAndIdNot(
            String email, List<User> createdBy, Status rowStatus, Long excludeId);

    boolean existsByEmailAndCreatedByInAndRowStatus(
            String email, List<User> createdBy, Status rowStatus);

    @org.springframework.data.jpa.repository.Query("SELECT c FROM Customer c WHERE c.rowStatus = com.spendilizer.entity.Status.ACTIVE AND c.createdBy IN :users AND (LOWER(c.firstName) LIKE LOWER(CONCAT('%',:q,'%')) OR LOWER(c.lastName) LIKE LOWER(CONCAT('%',:q,'%')) OR LOWER(c.companyName) LIKE LOWER(CONCAT('%',:q,'%')) OR LOWER(c.email) LIKE LOWER(CONCAT('%',:q,'%')))")
    List<Customer> searchActiveByNameOrEmail(@org.springframework.data.repository.query.Param("q") String q, @org.springframework.data.repository.query.Param("users") List<User> users);
}
