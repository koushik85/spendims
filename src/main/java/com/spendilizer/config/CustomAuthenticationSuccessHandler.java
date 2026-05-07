package com.spendilizer.config;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Collection;

@Component
public class CustomAuthenticationSuccessHandler implements AuthenticationSuccessHandler {

    private static final Logger logger = LoggerFactory.getLogger(CustomAuthenticationSuccessHandler.class);

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) throws IOException, ServletException {

        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Collection<? extends GrantedAuthority> authorities = userDetails.getAuthorities();

        logger.info("AUTH_SUCCESS email={} roles={} ip={}", userDetails.getUsername(),
                authorities.stream().map(GrantedAuthority::getAuthority).toList(), resolveClientIp(request));

        String contextPath = request.getContextPath();

        if (hasRole(authorities, "ROLE_SUPER_ADMIN")) {
            request.getSession().setAttribute("currentModule", "ADMIN");
            response.sendRedirect(contextPath + "/admin/dashboard");
        } else if (hasRole(authorities, "ROLE_PREMIUM_USER")) {
            request.getSession().setAttribute("currentModule", "IMS");
            response.sendRedirect(contextPath + "/dashboard");
        } else {
            request.getSession().setAttribute("currentModule", "PERSONAL");
            response.sendRedirect(contextPath + "/personal/dashboard");
        }
    }

    private boolean hasRole(Collection<? extends GrantedAuthority> authorities, String role) {
        return authorities.stream().anyMatch(a -> a.getAuthority().equals(role));
    }

    private String resolveClientIp(HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null && !forwardedFor.isBlank()) {
            return forwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
