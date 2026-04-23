<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Spendilizer — Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/spendilizer/css/ims-login.css">
</head>
<body>

<!-- ── Left brand panel ─────────────────────────────────────────── -->
<div class="left-panel">
    <div class="brand-logo">
        <svg width="26" height="26" fill="none" viewBox="0 0 24 24" stroke="#fff" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10"/>
        </svg>
    </div>
    <div class="brand-name">Spendilizer</div>
    <div class="brand-tagline">A complete automation suite for smarter inventory management.</div>

    <div class="brand-features">
        <div class="brand-feature">
            <div class="brand-feature-dot">
                <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="#fff" stroke-width="2.2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/>
                </svg>
            </div>
            Category & product management
        </div>
        <div class="brand-feature">
            <div class="brand-feature-dot">
                <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="#fff" stroke-width="2.2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                </svg>
            </div>
            Real-time stock level tracking
        </div>
        <div class="brand-feature">
            <div class="brand-feature-dot">
                <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="#fff" stroke-width="2.2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6 6 0 10-12 0v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
                </svg>
            </div>
            Low-stock alerts & reporting
        </div>
    </div>
</div>

<!-- ── Right login panel ────────────────────────────────────────── -->
<div class="right-panel">
    <div class="login-box">

        <div class="login-heading">Welcome back</div>
        <div class="login-sub">Sign in to your Spendilizer account</div>

        <%-- Registered success flash --%>
        <c:if test="${param.registered != null}">
            <div class="flash-success">
                <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
                Account created! Sign in below.
            </div>
        </c:if>

        <%-- Error alert --%>
        <c:choose>
            <c:when test="${param.error == 'pending'}">
                <div class="flash-error" style="background:#fef9c3;border-color:#fde047;color:#854d0e;">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    Your business account is pending approval. You'll be notified once a Super Admin reviews it.
                </div>
            </c:when>
            <c:when test="${param.error == 'rejected'}">
                <div class="flash-error">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    Your business account registration was rejected. Please contact support.
                </div>
            </c:when>
            <c:when test="${param.error != null}">
                <div class="flash-error">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    Invalid email or password.
                </div>
            </c:when>
        </c:choose>

        <form action="/spendilizer/perform-login" method="post">

            <%-- Email --%>
            <div class="form-group">
                <label for="username">Email address</label>
                <div class="input-wrap">
                    <svg class="input-icon" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                    </svg>
                    <input type="email"
                           id="username"
                           name="username"
                           placeholder="you@example.com"
                           required
                           autofocus>
                </div>
            </div>

            <%-- Password --%>
            <div class="form-group">
                <label for="password">Password</label>
                <div class="input-wrap">
                    <svg class="input-icon" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
                    </svg>
                    <input type="password"
                           id="password"
                           name="password"
                           placeholder="Enter your password"
                           required>
                    <button type="button" class="toggle-pw" onclick="togglePw('password','eyeIcon')" title="Show / hide password">
                        <svg id="eyeIcon" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                            <path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                        </svg>
                    </button>
                </div>
            </div>

            <%-- Remember me --%>
            <div class="extras-row">
                <label class="remember-label">
                    <input type="checkbox" id="rememberMe" name="remember-me">
                    Remember me
                </label>
            </div>

            <button type="submit" class="btn-login">
                <svg width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"/>
                </svg>
                Sign in
            </button>

        </form>

        <div style="text-align:center;margin-top:18px;font-size:0.82rem;color:#64748b;">
            Don't have an account?
            <a href="/spendilizer/signup"
               style="color:#0f766e;text-decoration:none;font-weight:600;">Sign up</a>
        </div>

        <div class="login-footer">
            © 2025 Spendilizer · Inventory Management System
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="/spendilizer/js/ims-shared.js"></script>
</body>
</html>
