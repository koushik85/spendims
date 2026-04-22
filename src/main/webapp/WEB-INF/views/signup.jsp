<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Spendilizer — Sign Up</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/spendilizer/css/ims-login.css">
    <style>
        /* ── Account-type selector ── */
        .type-selector {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
            margin-bottom: 28px;
        }
        .type-card {
            border: 2px solid var(--color-border);
            border-radius: 10px;
            padding: 14px 12px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: border-color 0.18s, background 0.18s;
            user-select: none;
        }
        .type-card:hover { border-color: #9dd8d4; background: #f0fdf9; }
        .type-card.active {
            border-color: var(--color-primary);
            background: #f0fdf9;
        }
        .type-icon {
            width: 34px; height: 34px;
            border-radius: 8px;
            background: var(--color-border);
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
            color: var(--color-text-muted);
            transition: background 0.18s, color 0.18s;
        }
        .type-card.active .type-icon {
            background: var(--color-primary);
            color: #fff;
        }
        .type-label { font-size: 0.86rem; font-weight: 600; color: var(--color-text); }
        .type-sublabel { font-size: 0.75rem; color: var(--color-text-muted); margin-top: 1px; }

        /* ── Signup-specific overrides ── */
        .signup-heading { font-size: 1.45rem; font-weight: 700; color: var(--color-text); margin-bottom: 6px; letter-spacing: -0.2px; }
        .signup-sub { font-size: 0.83rem; color: var(--color-text-muted); margin-bottom: 28px; }

        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }

        .signup-footer-note {
            text-align: center;
            margin-top: 20px;
            font-size: 0.82rem;
            color: var(--color-text-muted);
        }
        .signup-footer-note a { color: var(--color-primary); text-decoration: none; font-weight: 600; }
        .signup-footer-note a:hover { text-decoration: underline; }

        .login-footer { margin-top: 18px; }

        /* ── flash-success for registered redirect ── */
        .flash-success {
            background: #dcfce7;
            border: 1px solid #bbf7d0;
            border-radius: 10px;
            padding: 12px 16px;
            font-size: 0.82rem;
            color: #16a34a;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 24px;
        }
    </style>
</head>
<body>

<!-- ── Left brand panel (identical to login) ────────────────── -->
<div class="left-panel">
    <div class="brand-logo">
        <svg width="26" height="26" fill="none" viewBox="0 0 24 24" stroke="#fff" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10"/>
        </svg>
    </div>
    <div class="brand-name">Spendilizer</div>
    <div class="brand-tagline">Personal finance tools and inventory management — in one place.</div>

    <div class="brand-features">
        <div class="brand-feature">
            <div class="brand-feature-dot">
                <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="#fff" stroke-width="2.2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
                </svg>
            </div>
            Individual &amp; team accounts
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
            Low-stock alerts &amp; reporting
        </div>
    </div>
</div>

<!-- ── Right signup panel ────────────────────────────────────── -->
<div class="right-panel">
    <div class="login-box">

        <div class="signup-heading">Create your account</div>
        <div class="signup-sub">Choose your account type to get started</div>

        <%-- Error alert --%>
        <c:if test="${not empty error}">
            <div class="flash-error">
                <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
                ${error}
            </div>
        </c:if>

        <%-- Account-type selector --%>
        <div class="type-selector">
            <div class="type-card ${empty activeTab || activeTab == 'INDIVIDUAL' ? 'active' : ''}"
                 id="card-individual" onclick="selectType('INDIVIDUAL')">
                <div class="type-icon">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                    </svg>
                </div>
                <div>
                    <div class="type-label">Individual</div>
                    <div class="type-sublabel">Splits &amp; subscriptions</div>
                </div>
            </div>
            <div class="type-card ${activeTab == 'ENTERPRISE' ? 'active' : ''}"
                 id="card-enterprise" onclick="selectType('ENTERPRISE')">
                <div class="type-icon">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
                    </svg>
                </div>
                <div>
                    <div class="type-label">Enterprise</div>
                    <div class="type-sublabel">Inventory &amp; team</div>
                </div>
            </div>
        </div>

        <div id="type-hint" style="font-size:0.76rem;color:var(--color-text-muted);margin:-18px 0 20px;line-height:1.5;">
            <span id="hint-individual">Track shared expenses, manage subscriptions, and stay on top of personal finances.</span>
            <span id="hint-enterprise" style="display:none;">Full inventory system — products, stock, orders, invoices — plus personal finance tools.</span>
        </div>

        <form action="/spendilizer/signup" method="post" id="signupForm">
            <input type="hidden" name="accountType" id="accountTypeInput"
                   value="${empty activeTab || activeTab == 'INDIVIDUAL' ? 'INDIVIDUAL' : 'ENTERPRISE'}">

            <%-- Enterprise-only: company name --%>
            <div class="form-group" id="field-company"
                 style="${activeTab == 'ENTERPRISE' ? '' : 'display:none;'}">
                <label for="enterpriseName">Company name</label>
                <div class="input-wrap">
                    <svg class="input-icon" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
                    </svg>
                    <input type="text" id="enterpriseName" name="enterpriseName"
                           placeholder="Acme Corporation">
                </div>
            </div>

            <%-- Name row --%>
            <div class="form-row">
                <div class="form-group">
                    <label for="firstName">First name</label>
                    <div class="input-wrap">
                        <svg class="input-icon" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                        </svg>
                        <input type="text" id="firstName" name="firstName"
                               placeholder="John" required>
                    </div>
                </div>
                <div class="form-group">
                    <label for="lastName">Last name</label>
                    <div class="input-wrap">
                        <svg class="input-icon" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                        </svg>
                        <input type="text" id="lastName" name="lastName"
                               placeholder="Doe" required>
                    </div>
                </div>
            </div>

            <%-- Email --%>
            <div class="form-group">
                <label for="email">Email address</label>
                <div class="input-wrap">
                    <svg class="input-icon" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                    </svg>
                    <input type="email" id="email" name="email"
                           placeholder="you@example.com" required>
                </div>
            </div>

            <%-- Password --%>
            <div class="form-group">
                <label for="password">Password</label>
                <div class="input-wrap">
                    <svg class="input-icon" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
                    </svg>
                    <input type="password" id="password" name="password"
                           placeholder="Min. 8 characters" required minlength="8">
                    <button type="button" class="toggle-pw" onclick="togglePw('password','eyeIcon1')" title="Show / hide">
                        <svg id="eyeIcon1" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                            <path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                        </svg>
                    </button>
                </div>
            </div>

            <%-- Confirm password --%>
            <div class="form-group">
                <label for="confirmPassword">Confirm password</label>
                <div class="input-wrap">
                    <svg class="input-icon" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
                    </svg>
                    <input type="password" id="confirmPassword" name="confirmPassword"
                           placeholder="Re-enter password" required>
                    <button type="button" class="toggle-pw" onclick="togglePw('confirmPassword','eyeIcon2')" title="Show / hide">
                        <svg id="eyeIcon2" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                            <path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                        </svg>
                    </button>
                </div>
            </div>

            <%-- PAN Number --%>
            <div class="form-group">
                <label for="pan">PAN Number <span style="font-size:0.75rem;color:var(--color-text-muted);font-weight:400;">(optional)</span></label>
                <div class="input-wrap">
                    <svg class="input-icon" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M10 6H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V8a2 2 0 00-2-2h-5m-4 0V5a2 2 0 114 0v1m-4 0a2 2 0 104 0m-5 8a2 2 0 100-4 2 2 0 000 4zm0 0c1.306 0 2.417.835 2.83 2M9 14a3.001 3.001 0 00-2.83 2"/>
                    </svg>
                    <input type="text" id="pan" name="pan"
                           placeholder="e.g. ABCDE1234F"
                           maxlength="10"
                           style="text-transform:uppercase;"
                           oninput="validatePan(this)">
                </div>
                <div id="panError" style="display:none;color:#dc2626;font-size:0.76rem;margin-top:4px;">
                    Invalid PAN. Format: 5 letters · 4 digits · 1 letter (e.g. ABCDE1234F)
                </div>
            </div>

            <button type="submit" class="btn-login">
                <svg width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"/>
                </svg>
                Create account
            </button>
        </form>

        <div class="signup-footer-note">
            Already have an account? <a href="/spendilizer/login">Sign in</a>
        </div>

        <div class="login-footer">
            © 2025 Spendilizer · Inventory Management System
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="/spendilizer/js/ims-shared.js"></script>
<script src="/spendilizer/js/ims-signup.js"></script>
</body>
</html>
