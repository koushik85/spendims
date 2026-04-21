<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<div id="sidebar-wrapper">

    <div class="sidebar-brand">
        <div class="brand-title">Spendilizer</div>
        <div class="brand-subtitle">Personal Finance</div>
    </div>

    <div class="sidebar-section-label">Main</div>
    <a href="/spendilizer/personal/dashboard"
       class="nav-link ${fn:contains(currentUri, '/personal/dashboard') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>
        </svg>
        Overview
    </a>

    <div class="sidebar-section-label">Tools</div>

    <a href="/spendilizer/personal/splits"
       class="nav-link ${fn:contains(currentUri, '/personal/splits') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
        </svg>
        Split Expenses
    </a>

    <a href="/spendilizer/personal/subscriptions"
       class="nav-link ${fn:contains(currentUri, '/personal/subscriptions') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
        </svg>
        Subscriptions
    </a>

    <div class="sidebar-footer">
        &copy; 2025 Spendilizer
    </div>
</div>
