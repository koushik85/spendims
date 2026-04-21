package com.spendilizer.repository;

import com.spendilizer.entity.SplitGroup;
import com.spendilizer.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SplitGroupRepository extends JpaRepository<SplitGroup, Long> {
    List<SplitGroup> findAllByCreatedByOrderByCreatedAtDesc(User createdBy);
    Optional<SplitGroup> findByIdAndCreatedBy(Long id, User createdBy);
}
