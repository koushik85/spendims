package com.spendilizer.repository;

import com.spendilizer.entity.MasterProduct;
import com.spendilizer.entity.Status;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MasterProductRepository extends JpaRepository<MasterProduct, Long> {
    List<MasterProduct> findAllByRowStatusOrderByNameAsc(Status rowStatus);
    Optional<MasterProduct> findByIdAndRowStatus(Long id, Status rowStatus);
}
