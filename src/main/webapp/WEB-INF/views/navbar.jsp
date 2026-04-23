<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<link href="https://cdn.datatables.net/1.13.4/css/dataTables.bootstrap5.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/buttons/2.4.1/css/buttons.bootstrap5.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

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

    <!-- Page context -->
    <div class="topbar-context">
        <span class="topbar-page">Spendilizer</span>
        <span class="topbar-sep"></span>
        <c:choose>
            <c:when test="${pageContext.session.getAttribute('currentModule') == 'PERSONAL'}">
                <span class="topbar-sub">Personal Finance</span>
            </c:when>
            <c:when test="${pageContext.session.getAttribute('currentModule') == 'ADMIN'}">
                <span class="topbar-sub" style="color:#6366f1;">Super Admin</span>
            </c:when>
            <c:otherwise>
                <span class="topbar-sub">Inventory</span>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Search (IMS only) -->
    <c:if test="${pageContext.session.getAttribute('currentModule') != 'PERSONAL' && pageContext.session.getAttribute('currentModule') != 'ADMIN'}">
    <div class="topbar-search" id="globalSearchWrap">
        <svg class="search-icon" width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
        </svg>
        <input type="text" id="globalSearchInput" placeholder="Search products, suppliers…"
               autocomplete="off" spellcheck="false">
        <div class="search-dropdown" id="searchDropdown"></div>
    </div>
    </c:if>

    <!-- User / Enterprise context chip -->
    <c:if test="${not empty user}">
        <div class="topbar-user-chip">
            <c:choose>
                <c:when test="${user.accountType == 'SUPER_ADMIN'}">
                    <div class="tuc-icon" style="background:#ede9fe;color:#6366f1;">
                        <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
                        </svg>
                    </div>
                    <div class="tuc-text">
                        <div class="tuc-primary">${user.firstName} ${user.lastName}</div>
                        <div class="tuc-secondary">Super Admin</div>
                    </div>
                </c:when>
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

    <!-- Module toggle (enterprise users only, not SUPER_ADMIN) -->
    <c:if test="${not empty user && (user.accountType == 'ENTERPRISE_OWNER' || user.accountType == 'ENTERPRISE_MEMBER')}">
        <div class="module-toggle">
            <a href="/spendilizer/switch-module?to=PERSONAL"
               class="mod-btn ${pageContext.session.getAttribute('currentModule') == 'PERSONAL' ? 'mod-btn--active' : ''}">
                <svg width="12" height="12" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                </svg>
                Personal
            </a>
            <a href="/spendilizer/switch-module?to=IMS"
               class="mod-btn ${pageContext.session.getAttribute('currentModule') != 'PERSONAL' ? 'mod-btn--active' : ''}">
                <svg width="12" height="12" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
                </svg>
                IMS
            </a>
        </div>
    </c:if>

    <!-- Controls -->
    <div class="topbar-controls">

        <!-- Notifications bell -->
        <div class="tb-relative">
            <button class="tb-btn" id="bellBtn" onclick="toggleBell()" title="Notifications">
                <c:if test="${newNotificationCount > 0}">
                    <span class="bell-badge" id="bellBadge">${newNotificationCount}</span>
                </c:if>
                <svg width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
                </svg>
            </button>

            <div class="notif-panel" id="bellDropdown">
                <div class="notif-panel-header">
                    <span>Notifications</span>
                    <c:if test="${not empty navNotifications}">
                        <button class="notif-clear-all" onclick="clearAllNotifs()">Clear all</button>
                    </c:if>
                </div>

                <div id="notifList">
                    <c:choose>
                        <c:when test="${empty navNotifications}">
                            <div class="notif-empty">You're all caught up!</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="n" items="${navNotifications}">
                                <div class="notif-item ${n.state == 'NEW' ? 'notif-item--new' : ''}" id="notif-${n.id}">
                                    <div class="notif-icon">
                                        <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                                        </svg>
                                    </div>
                                    <div class="notif-body">
                                        <div class="notif-title">
                                            <c:out value="${n.subscription.name}"/>
                                            <c:choose>
                                                <c:when test="${n.daysUntilDue == 0}"> renews <strong style="color:var(--color-danger);">today</strong></c:when>
                                                <c:when test="${n.daysUntilDue == 1}"> renews in <strong>1 day</strong></c:when>
                                                <c:otherwise> renews in <strong>${n.daysUntilDue} days</strong></c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="notif-meta">&#8377;<fmt:formatNumber value="${n.subscription.amount}" pattern="#,##0.00"/> &middot; ${n.subscription.nextBillingDate}</div>
                                    </div>
                                    <button class="notif-dismiss-btn" onclick="removeNotif(${n.id})" title="Dismiss">&#x2715;</button>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>

                <c:if test="${not empty navNotifications}">
                    <div class="notif-panel-footer">
                        <a href="/spendilizer/personal/subscriptions">View subscriptions &rarr;</a>
                    </div>
                </c:if>
            </div>
        </div>

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


<script>
    const _csrfToken  = '${_csrf.token}';
    const _csrfHeader = '${_csrf.headerName}';
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="/spendilizer/js/ims-shared.js"></script>
<script src="/spendilizer/js/navbar.js"></script>

