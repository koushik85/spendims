package com.spendilizer.repository;

import com.spendilizer.entity.Enterprise;
import com.spendilizer.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EnterpriseRepository extends JpaRepository<Enterprise, Integer> {
    Enterprise findByOwner(User owner);
}
