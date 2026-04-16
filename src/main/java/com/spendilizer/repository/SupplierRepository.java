package com.spendilizer.repository;

import com.spendilizer.entity.Status;
import com.spendilizer.entity.Supplier;
import com.spendilizer.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface SupplierRepository extends JpaRepository<Supplier, Long> {
    List<Supplier> findAllByRowStatusAndCreatedByIn(Status status, List<User> users);
    List<Supplier> findAllByCreatedByIn(List<User> users);
    Optional<Supplier> findByIdAndCreatedByIn(Long id, List<User> users);

    @Query("SELECT s FROM Supplier s WHERE s.rowStatus = com.spendilizer.entity.Status.ACTIVE AND s.createdBy IN :users AND LOWER(s.name) LIKE LOWER(CONCAT('%',:q,'%'))")
    List<Supplier> searchActiveByName(@Param("q") String q, @Param("users") List<User> users);

    Optional<Supplier> findFirstByNameIgnoreCaseAndCreatedByInAndRowStatus(
            String name, List<User> users, Status rowStatus);
}
