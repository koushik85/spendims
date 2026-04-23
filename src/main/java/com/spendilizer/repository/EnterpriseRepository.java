package com.spendilizer.repository;

import com.spendilizer.entity.ApprovalStatus;
import com.spendilizer.entity.Enterprise;
import com.spendilizer.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface EnterpriseRepository extends JpaRepository<Enterprise, Integer> {
    Enterprise findByOwner(User owner);
    List<Enterprise> findAllByApprovalStatus(ApprovalStatus approvalStatus);
}
