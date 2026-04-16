package com.spendilizer.repository;

import com.spendilizer.entity.User;
import com.spendilizer.entity.UserRolesMapping;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserRolesMappingRepository extends JpaRepository<UserRolesMapping,Integer> {
    List<UserRolesMapping> findByUser(User user);
}
