package com.spendilizer.repository;

import com.spendilizer.entity.Product;
import com.spendilizer.entity.Status;
import com.spendilizer.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findAllByRowStatusAndCreatedByIn(Status status, List<User> users);
    List<Product> findAllByCreatedByIn(List<User> users);
    Optional<Product> findByIdAndCreatedByIn(Long id, List<User> users);
    boolean existsBySkuIgnoreCase(String sku);

    @Query("SELECT p.sku FROM Product p WHERE p.sku LIKE :prefix% AND p.createdBy IN :users ORDER BY p.sku DESC")
    List<String> findSkusByPrefix(@Param("prefix") String prefix, @Param("users") List<User> users);

    @Query("SELECT p FROM Product p WHERE p.rowStatus = com.spendilizer.entity.Status.ACTIVE AND p.createdBy IN :users AND (LOWER(p.name) LIKE LOWER(CONCAT('%',:q,'%')) OR LOWER(p.sku) LIKE LOWER(CONCAT('%',:q,'%')))")
    List<Product> searchActiveByNameOrSku(@Param("q") String q, @Param("users") List<User> users);
}
