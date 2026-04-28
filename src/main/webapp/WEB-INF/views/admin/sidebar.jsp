<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<div id="sidebar-wrapper" class="sidebar-admin">

    <div class="sidebar-brand">
        <div class="brand-title">Spendilizer</div>
        <div class="brand-subtitle">Super Admin</div>
    </div>

    <div class="sidebar-section-label">Overview</div>
    <a href="${pageContext.request.contextPath}/admin/dashboard"
       class="nav-link ${fn:contains(currentUri, '/admin/dashboard') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>
        </svg>
        Dashboard
    </a>

    <div class="sidebar-section-label">Catalog</div>
    <a href="${pageContext.request.contextPath}/admin/categories"
       class="nav-link ${fn:contains(currentUri, '/admin/categories') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/>
        </svg>
        Categories
    </a>
    <a href="${pageContext.request.contextPath}/admin/master-products"
       class="nav-link ${fn:contains(currentUri, '/admin/master-products') && !fn:contains(currentUri, '/requests') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/>
        </svg>
        Master Products
    </a>
    <a href="${pageContext.request.contextPath}/admin/master-products/requests"
       class="nav-link ${fn:contains(currentUri, '/requests') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 7h3m-3 4h3m-6-4h.01M9 16h.01"/>
        </svg>
        Product Requests
    </a>

    <div class="sidebar-section-label">Users</div>
    <a href="${pageContext.request.contextPath}/admin/enterprises"
       class="nav-link ${fn:contains(currentUri, '/admin/enterprises') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
        </svg>
        Enterprises
    </a>

    <div class="sidebar-footer">
        &copy; 2025 Spendilizer
    </div>
</div>
