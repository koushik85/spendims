package com.spendilizer.config;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class CustomAuthenticationFailureHandler implements AuthenticationFailureHandler {

    private static final Logger logger = LoggerFactory.getLogger(CustomAuthenticationFailureHandler.class);

    @Override
    public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response,
                                        AuthenticationException exception) throws IOException, ServletException {
        String attemptedEmail = request.getParameter("username");

        logger.warn("AUTH_FAILURE email={} ip={} reason={}",
                maskEmail(attemptedEmail),
                resolveClientIp(request),
                exception.getClass().getSimpleName());

        response.sendRedirect(request.getContextPath() + "/login?error=true");
    }

    private String resolveClientIp(HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null && !forwardedFor.isBlank()) {
            return forwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    private String maskEmail(String email) {
        if (email == null || email.isBlank() || !email.contains("@")) {
            return "unknown";
        }
        String[] parts = email.split("@", 2);
        String user = parts[0];
        String domain = parts[1];
        if (user.length() <= 2) {
            return "**@" + domain;
        }
        return user.substring(0, 2) + "***@" + domain;
    }
}
