package com.spendilizer.repository;

import com.spendilizer.entity.Category;
import com.spendilizer.entity.Status;
import com.spendilizer.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CategoryRepository extends JpaRepository<Category, Long> {
    List<Category> findAllByRowStatusAndCreatedByIn(Status rowStatus, List<User> users);
    List<Category> findAllByCreatedByIn(List<User> users);
    Optional<Category> findByIdAndCreatedByIn(Long id, List<User> users);

    // Duplicate-name checks scoped to the user's enterprise / individual scope
    boolean existsByNameIgnoreCaseAndCreatedByInAndRowStatus(
            String name, List<User> createdBy, Status rowStatus);

    boolean existsByNameIgnoreCaseAndCreatedByInAndRowStatusAndIdNot(
            String name, List<User> createdBy, Status rowStatus, Long id);

    Optional<Category> findFirstByNameIgnoreCaseAndCreatedByInAndRowStatus(
            String name, List<User> users, Status rowStatus);
}
