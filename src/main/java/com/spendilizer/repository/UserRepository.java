package com.spendilizer.repository;

import com.spendilizer.entity.Enterprise;
import com.spendilizer.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserRepository extends JpaRepository<User,Integer> {
    User findByEmail(String email);
    List<User> findByEnterpriseAndAccountType(Enterprise enterprise, String accountType);
    List<User> findByEnterprise(Enterprise enterprise);
    boolean existsByCustomerId(String customerId);
}
