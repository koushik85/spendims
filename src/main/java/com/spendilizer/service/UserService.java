package com.spendilizer.service;

import com.spendilizer.entity.*;
import com.spendilizer.repository.*;


import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final UserBasicDetailsRepository userBasicDetailsRepository;
    private final EnterpriseRepository enterpriseRepository;
    private final RolesRepository rolesRepository;
    private final UserRolesMappingRepository userRolesMappingRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository,
                       UserBasicDetailsRepository userBasicDetailsRepository,
                       EnterpriseRepository enterpriseRepository,
                       RolesRepository rolesRepository,
                       UserRolesMappingRepository userRolesMappingRepository,
                       GroupMemberRepository groupMemberRepository,
                       PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.userBasicDetailsRepository = userBasicDetailsRepository;
        this.enterpriseRepository = enterpriseRepository;
        this.rolesRepository = rolesRepository;
        this.userRolesMappingRepository = userRolesMappingRepository;
        this.groupMemberRepository = groupMemberRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public User getUserByUserEmail(String email) {
        return userRepository.findByUserEmail(email);
    }

    public boolean emailExists(String email) {
        return userRepository.findByUserEmail(email) != null;
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    /** Returns the set of users whose data the given user may access. */
    public List<User> getScopeUsers(User user) {
        return List.of(user);
    }

    // ── Enterprise admin methods ─────────────────────────────────────────────

    public List<Enterprise> getPendingEnterprises() {
        return enterpriseRepository.findAllByApprovalStatus(ApprovalStatus.PENDING);
    }

    public List<Enterprise> getAllEnterprises() {
        return enterpriseRepository.findAll();
    }

    @Transactional
    public void approveEnterprise(int enterpriseId) {
        enterpriseRepository.findById(enterpriseId).ifPresent(e -> {
            e.setApprovalStatus(ApprovalStatus.APPROVED);
            enterpriseRepository.save(e);
        });
    }

    @Transactional
    public void rejectEnterprise(int enterpriseId) {
        enterpriseRepository.findById(enterpriseId).ifPresent(e -> {
            e.setApprovalStatus(ApprovalStatus.REJECTED);
            enterpriseRepository.save(e);
        });
    }

    public Enterprise getEnterpriseByOwner(User owner) {
        return enterpriseRepository.findByOwner(owner);
    }

    /** Enterprise member management — to be rearchitected with the new User model. */
    public List<User> getMembersByEnterprise(Enterprise enterprise) {
        return Collections.emptyList();
    }

    @Transactional
    public void addEnterpriseMember(Enterprise enterprise, String email, String firstName,
                                    String lastName, String rawPassword) {
        User user = buildUser(email, rawPassword);
        User saved = userRepository.save(user);

        UserBasicDetails details = buildBasicDetails(saved, firstName, lastName, null);
        userBasicDetailsRepository.save(details);

        assignRole(saved, "PREMIUM_USER");
        linkPendingGroupMembers(saved);
    }

    @Transactional
    public void removeEnterpriseMember(Long userId) {
        userRepository.findById(userId).ifPresent(userRepository::delete);
    }

    @Transactional
    public void registerIndividualUser(String email, String firstName, String lastName,
                                       String rawPassword, String pan) {
        User user = buildUser(email, rawPassword);
        User saved = userRepository.save(user);

        UserBasicDetails details = buildBasicDetails(saved, firstName, lastName, pan);
        userBasicDetailsRepository.save(details);

        assignRole(saved, "USER");
        linkPendingGroupMembers(saved);
    }

    @Transactional
    public void registerPremiumUser(String email, String firstName, String lastName,
                                    String rawPassword, String pan, String enterpriseName) {
        User user = buildUser(email, rawPassword);
        User saved = userRepository.save(user);

        UserBasicDetails details = buildBasicDetails(saved, firstName, lastName, pan);
        userBasicDetailsRepository.save(details);

        assignRole(saved, "PREMIUM_USER");
        linkPendingGroupMembers(saved);

        Enterprise enterprise = new Enterprise(enterpriseName, saved);
        enterprise.setApprovalStatus(ApprovalStatus.PENDING);
        enterpriseRepository.save(enterprise);
    }

    /**
     * Links any unlinked GroupMember slots whose email matches this user's email.
     */
    private void linkPendingGroupMembers(User user) {
        if (user.getUserEmail() == null) return;
        List<GroupMember> pending = groupMemberRepository
                .findByEmailAndLinkedUserIsNull(user.getUserEmail());
        for (GroupMember member : pending) {
            member.setLinkedUser(user);
            groupMemberRepository.save(member);
        }
    }

    @Transactional
    public void updateProfile(Long userId, String firstName, String lastName, String pan) {
        userRepository.findById(userId).ifPresent(user -> {
            user.setUserModificationDateTime(LocalDateTime.now());
            userRepository.save(user);

            UserBasicDetails details = userBasicDetailsRepository.findByUser_UserId(userId);
            if (details == null) {
                details = new UserBasicDetails();
                details.setUser(user);
            }
            details.setUserFirstName(firstName);
            details.setUserLastName(lastName);
            details.setPan(pan != null && !pan.isBlank() ? pan.toUpperCase() : null);
            userBasicDetailsRepository.save(details);
        });
    }

    @Transactional
    public void changePassword(Long userId, String currentRaw, String newRaw) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        if (!passwordEncoder.matches(currentRaw, user.getUserPassword())) {
            throw new IllegalArgumentException("Current password is incorrect.");
        }
        user.setUserPassword(passwordEncoder.encode(newRaw));
        user.setUserModificationDateTime(LocalDateTime.now());
        userRepository.save(user);
    }

    private User buildUser(String email, String rawPassword) {
        User user = new User();
        user.setUserEmail(email);
        user.setUserPassword(passwordEncoder.encode(rawPassword));
        user.setUserStatus(UserStatusEnum.ACTIVE);
        user.setUserUniqueId(UUID.randomUUID().toString());
        user.setCustomerId(freshCustomerId());
        user.setUserCreationDateTime(LocalDateTime.now());
        return user;
    }

    private UserBasicDetails buildBasicDetails(User saved, String firstName, String lastName, String pan) {
        UserBasicDetails details = new UserBasicDetails();
        details.setUser(saved);
        details.setUserFirstName(firstName);
        details.setUserLastName(lastName);
        if (pan != null && !pan.isBlank()) {
            details.setPan(pan.toUpperCase());
        }
        return details;
    }

    private Long freshCustomerId() {
        Long id;
        do {
            id = ThreadLocalRandom.current().nextLong(100_000_000L, 1_000_000_000L);
        } while (userRepository.existsByCustomerId(id));
        return id;
    }

    private void assignRole(User user, String roleName) {
        Roles role = rolesRepository.findByRoleName(roleName);
        if (role == null) {
            role = rolesRepository.save(new Roles(roleName));
        }
        userRolesMappingRepository.save(new UserRolesMapping(user, role));
    }
}
