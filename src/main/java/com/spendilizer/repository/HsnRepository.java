package com.spendilizer.repository;

import com.spendilizer.entity.Hsn;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface HsnRepository extends JpaRepository<Hsn, Long> {

    @Query("SELECT h FROM Hsn h WHERE " +
            "LOWER(h.hsnCode) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(h.description) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Hsn> search(@Param("keyword") String keyword, Pageable pageable);

    Optional<Hsn> findFirstByHsnCodeIgnoreCase(String hsnCode);
}
