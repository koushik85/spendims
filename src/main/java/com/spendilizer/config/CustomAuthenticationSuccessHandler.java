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
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication)
            throws IOException, ServletException {

        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Collection<? extends GrantedAuthority> roles = userDetails.getAuthorities();

        logger.info("AUTH_SUCCESS email={} roles={} ip={}",
            userDetails.getUsername(),
            roles.stream().map(GrantedAuthority::getAuthority).toList(),
            resolveClientIp(request));

//        if (roles.size() == 1) {
//            String role = roles.iterator().next().getAuthority();
//            HttpSession session = request.getSession();
//            session.setAttribute("currentRole", role);
//            redirectBasedOnRole(role, response);
//        } else {
//            request.getSession().setAttribute("AVAILABLE_ROLES", roles);
//            response.sendRedirect("/accredit/select-role");
//        }
        response.sendRedirect("/spendilizer/dashboard");
    }

    private String resolveClientIp(HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null && !forwardedFor.isBlank()) {
            return forwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

//    private void redirectBasedOnRole(String role, HttpServletResponse response) throws IOException {
//        if ("ROLE_ADMIN".equals(role)) {
//            response.sendRedirect("/accredit/admin/dashboard");
//        } else if ("ROLE_STUDENT".equals(role)) {
//            response.sendRedirect("/accredit/student/student-dashboard");
//
//        } else if ("ROLE_FACULTY".equals(role)) {
//            response.sendRedirect("/accredit/faculty/dashboard");
//        } else {
//            response.sendRedirect("/login?unauthorized=true");
//        }
//    }
}

