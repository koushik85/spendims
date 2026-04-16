<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<link href="https://cdn.datatables.net/1.13.4/css/dataTables.bootstrap5.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/buttons/2.4.1/css/buttons.bootstrap5.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@400;500;600;700&display=swap" rel="stylesheet">

<link href="/spendilizer/css/navbar.css" rel="stylesheet">

<!-- ══════════════════════════════════════════════════
     TOP BAR
═══════════════════════════════════════════════════ -->
<header class="ims-topbar">

    <!-- Sidebar toggle -->
    <button class="sidebar-toggle-btn" id="sidebarToggle" onclick="toggleSidebar()" title="Toggle sidebar">
        <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"/>
        </svg>
    </button>

    <!-- Page context / breadcrumb -->
    <div class="topbar-context">
        <span class="topbar-page">Admin Portal</span>
        <span class="topbar-sep"></span>
        <span class="topbar-sub">Inventory Management System</span>
    </div>

    <!-- Search -->
    <div class="topbar-search" id="globalSearchWrap">
        <svg class="search-icon" width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
        </svg>
        <input type="text" id="globalSearchInput" placeholder="Search products, suppliers…"
               autocomplete="off" spellcheck="false">
        <div class="search-dropdown" id="searchDropdown"></div>
    </div>

    <!-- User / Enterprise context chip -->
    <c:if test="${not empty user}">
        <div class="topbar-user-chip">
            <c:choose>
                <c:when test="${user.accountType == 'ENTERPRISE_OWNER' or user.accountType == 'ENTERPRISE_MEMBER'}">
                    <div class="tuc-icon tuc-icon--enterprise">
                        <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
                        </svg>
                    </div>
                    <div class="tuc-text">
                        <div class="tuc-primary">${user.enterprise.enterpriseName}</div>
                        <div class="tuc-secondary">${user.firstName} ${user.lastName}
                            <c:if test="${user.accountType == 'ENTERPRISE_OWNER'}"> &middot; Owner</c:if>
                            <c:if test="${user.accountType == 'ENTERPRISE_MEMBER'}"> &middot; Member</c:if>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="tuc-icon tuc-icon--personal">
                        <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                        </svg>
                    </div>
                    <div class="tuc-text">
                        <div class="tuc-primary">${user.firstName} ${user.lastName}</div>
                        <div class="tuc-secondary">Personal account</div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </c:if>

    <!-- Controls -->
    <div class="topbar-controls">

        <!-- Notifications -->
        <a href="#" class="tb-btn" title="Notifications">
            <c:if test="${lowStockCount > 0}"><span class="dot"></span></c:if>
            <svg width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
            </svg>
        </a>

        <!-- User menu dropdown -->
        <div class="tb-relative">
            <button class="user-menu-btn" id="userMenuBtn" onclick="toggleUserMenu()">
                <span class="user-avatar-sm">
                    <c:choose>
                        <c:when test="${not empty user}">${fn:substring(user.firstName, 0, 1)}${fn:substring(user.lastName, 0, 1)}</c:when>
                        <c:otherwise>U</c:otherwise>
                    </c:choose>
                </span>
                <svg width="11" height="11" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/>
                </svg>
            </button>

            <div class="tb-dropdown-menu" id="userMenuDropdown">
                <div class="tb-dropdown-header">My Account</div>

                <a href="/spendilizer/profile/edit" class="tb-dropdown-item">
                    <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                    </svg>
                    Edit Personal Details
                </a>

                <a href="/spendilizer/profile/reset-password" class="tb-dropdown-item">
                    <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
                    </svg>
                    Reset Password
                </a>

                <div class="tb-dropdown-divider"></div>

                <form action="${pageContext.request.contextPath}/logout" method="post" class="logout-form">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <button type="submit" class="tb-dropdown-item danger">
                        <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H9m4 4v1a2 2 0 01-2 2H5a2 2 0 01-2-2V7a2 2 0 012-2h6a2 2 0 012 2v1"/>
                        </svg>
                        Sign Out
                    </button>
                </form>
            </div>
        </div>

    </div>

</header>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="/spendilizer/js/ims-shared.js"></script>
<script src="/spendilizer/js/navbar.js"></script>

