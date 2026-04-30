package com.spendilizer.config;

import com.spendilizer.entity.User;
import com.spendilizer.entity.UserRolesMapping;
import com.spendilizer.repository.UserRepository;
import com.spendilizer.repository.UserRolesMappingRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private static final Logger logger = LoggerFactory.getLogger(CustomUserDetailsService.class);

    private final UserRepository userRepository;
    private final UserRolesMappingRepository userRolesMappingRepository;

    public CustomUserDetailsService(UserRepository userRepository,
                                    UserRolesMappingRepository userRolesMappingRepository) {
        this.userRepository = userRepository;
        this.userRolesMappingRepository = userRolesMappingRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userRepository.findByUserEmail(email);

        if (user == null) {
            logger.warn("AUTH_FAILURE_UNKNOWN_USER email={}", email);
            throw new UsernameNotFoundException("User not found with email: " + email);
        }

        List<UserRolesMapping> roleMappings = userRolesMappingRepository.findByUser(user);

        List<GrantedAuthority> authorities = roleMappings.stream()
                .map(mapping -> new SimpleGrantedAuthority("ROLE_" + mapping.getRole().getRoleName()))
                .collect(Collectors.toList());

        return new CustomUserDetails(user, authorities);
    }
}
