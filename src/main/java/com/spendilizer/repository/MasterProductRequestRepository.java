package com.spendilizer.repository;

import com.spendilizer.entity.ApprovalStatus;
import com.spendilizer.entity.MasterProductRequest;
import com.spendilizer.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MasterProductRequestRepository extends JpaRepository<MasterProductRequest, Long> {
    List<MasterProductRequest> findAllByRequestStatusOrderByRequestedAtDesc(ApprovalStatus status);
    List<MasterProductRequest> findAllByRequestedByOrderByRequestedAtDesc(User user);
    boolean existsByNameIgnoreCaseAndCategoryNameIgnoreCaseAndRequestStatus(String name,
                                                                            String categoryName,
                                                                            ApprovalStatus status);
}
