package com.spendilizer.service;

import com.spendilizer.entity.Enterprise;
import com.spendilizer.entity.GroupMember;
import com.spendilizer.entity.Roles;
import com.spendilizer.entity.User;
import com.spendilizer.entity.UserRolesMapping;
import com.spendilizer.repository.EnterpriseRepository;
import com.spendilizer.repository.GroupMemberRepository;
import com.spendilizer.repository.RolesRepository;
import com.spendilizer.repository.UserRepository;
import com.spendilizer.repository.UserRolesMappingRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final EnterpriseRepository enterpriseRepository;
    private final RolesRepository rolesRepository;
    private final UserRolesMappingRepository userRolesMappingRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository,
                       EnterpriseRepository enterpriseRepository,
                       RolesRepository rolesRepository,
                       UserRolesMappingRepository userRolesMappingRepository,
                       GroupMemberRepository groupMemberRepository,
                       PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.enterpriseRepository = enterpriseRepository;
        this.rolesRepository = rolesRepository;
        this.userRolesMappingRepository = userRolesMappingRepository;
        this.groupMemberRepository = groupMemberRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public boolean emailExists(String email) {
        return userRepository.findByEmail(email) != null;
    }

    /**
     * Returns all users whose data the given user is allowed to see.
     * - Individual  → just themselves
     * - Enterprise  → every user sharing the same enterprise (owner + all members)
     */
    public List<User> getScopeUsers(User user) {
        if (user.getEnterprise() == null) {
            return List.of(user);
        }
        return userRepository.findByEnterprise(user.getEnterprise());
    }

    @Transactional
    public void registerIndividualUser(String email, String firstName, String lastName,
                                       String rawPassword, String pan) {
        User user = new User(email, firstName, lastName, passwordEncoder.encode(rawPassword));
        user.setAccountType("INDIVIDUAL");
        if (pan != null && !pan.isBlank()) user.setPan(pan.toUpperCase());
        User saved = userRepository.save(user);
        assignRole(saved, "USER");
        linkPendingGroupMembers(saved);
    }

    @Transactional
    public void registerEnterpriseOwner(String email, String firstName, String lastName,
                                        String rawPassword, String enterpriseName, String pan) {
        User user = new User(email, firstName, lastName, passwordEncoder.encode(rawPassword));
        user.setAccountType("ENTERPRISE_OWNER");
        if (pan != null && !pan.isBlank()) user.setPan(pan.toUpperCase());
        User savedUser = userRepository.save(user);

        Enterprise enterprise = new Enterprise(enterpriseName, savedUser);
        Enterprise savedEnterprise = enterpriseRepository.save(enterprise);

        savedUser.setEnterprise(savedEnterprise);
        userRepository.save(savedUser);

        assignRole(savedUser, "ENTERPRISE_OWNER");
        linkPendingGroupMembers(savedUser);
    }

    @Transactional
    public void addEnterpriseMember(Enterprise enterprise, String email, String firstName,
                                    String lastName, String rawPassword) {
        User member = new User(email, firstName, lastName, passwordEncoder.encode(rawPassword));
        member.setAccountType("ENTERPRISE_MEMBER");
        member.setEnterprise(enterprise);
        User saved = userRepository.save(member);
        assignRole(saved, "ENTERPRISE_MEMBER");
        linkPendingGroupMembers(saved);
    }

    /**
     * Links any unlinked GroupMember slots whose email matches this user's email.
     * Called after every registration path so a user is immediately connected to
     * groups they were added to before they signed up.
     */
    private void linkPendingGroupMembers(User user) {
        if (user.getEmail() == null) return;
        List<GroupMember> pending = groupMemberRepository
                .findByEmailAndLinkedUserIsNull(user.getEmail());
        for (GroupMember member : pending) {
            member.setLinkedUser(user);
            groupMemberRepository.save(member);
        }
    }

    @Transactional
    public void removeEnterpriseMember(int userId) {
        userRepository.findById(userId).ifPresent(userRepository::delete);
    }

    public List<User> getMembersByEnterprise(Enterprise enterprise) {
        return userRepository.findByEnterpriseAndAccountType(enterprise, "ENTERPRISE_MEMBER");
    }

    public Enterprise getEnterpriseByOwner(User owner) {
        return enterpriseRepository.findByOwner(owner);
    }

    @Transactional
    public void updateProfile(int userId, String firstName, String lastName, String pan) {
        userRepository.findById(userId).ifPresent(user -> {
            user.setFirstName(firstName);
            user.setLastName(lastName);
            if (pan != null && !pan.isBlank()) user.setPan(pan.toUpperCase());
            else user.setPan(null);
            userRepository.save(user);
        });
    }

    @Transactional
    public void changePassword(int userId, String currentRaw, String newRaw) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        if (!passwordEncoder.matches(currentRaw, user.getPassword())) {
            throw new IllegalArgumentException("Current password is incorrect.");
        }
        user.setPassword(passwordEncoder.encode(newRaw));
        userRepository.save(user);
    }

    private void assignRole(User user, String roleName) {
        Roles role = rolesRepository.findByRoleName(roleName);
        if (role == null) {
            role = rolesRepository.save(new Roles(roleName));
        }
        userRolesMappingRepository.save(new UserRolesMapping(user, role));
    }
}
