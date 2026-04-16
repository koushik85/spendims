package com.spendilizer.repository;

import com.spendilizer.entity.Roles;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RolesRepository extends JpaRepository<Roles,Integer> {
    Roles findByRoleName(String roleName);
}
