package com.spendilizer.repository;

import com.spendilizer.entity.UserBasicDetails;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserBasicDetailsRepository extends JpaRepository<UserBasicDetails, Long> {
    UserBasicDetails findByUser_UserId(Long userId);
}
