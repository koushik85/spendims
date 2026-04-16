<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<style>
    #sidebar-wrapper {
        min-height: 100vh;
        background: #1e293b;
        width: 200px;
        position: fixed;
        top: 0;
        left: 0;
        z-index: 150;
        display: flex;
        flex-direction: column;
        box-shadow: 2px 0 12px rgba(0,0,0,0.15);
        transition: transform 0.25s ease;
    }

    .sidebar-brand {
        padding: 20px 20px 10px 20px;
        border-bottom: 1px solid rgba(255,255,255,0.08);
        margin-bottom: 8px;
    }

    .sidebar-brand .brand-title {
        font-size: 1.1rem;
        font-weight: 700;
        color: #ffffff;
        letter-spacing: 0.5px;
    }

    .sidebar-brand .brand-subtitle {
        font-size: 0.7rem;
        color: #94a3b8;
        letter-spacing: 1px;
        text-transform: uppercase;
        margin-top: 2px;
    }

    .sidebar-section-label {
        font-size: 0.65rem;
        font-weight: 600;
        color: #64748b;
        letter-spacing: 1.2px;
        text-transform: uppercase;
        padding: 14px 20px 6px 20px;
    }

    #sidebar-wrapper .nav-link {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 9px 20px;
        font-size: 0.85rem;
        color: #cbd5e1;
        text-decoration: none;
        border-left: 3px solid transparent;
        transition: all 0.18s ease;
        margin: 1px 0;
    }

    #sidebar-wrapper .nav-link:hover {
        background: rgba(255,255,255,0.06);
        color: #ffffff;
        border-left-color: #5eead4;
    }

    #sidebar-wrapper .nav-link.active {
        background: rgba(15, 118, 110, 0.25);
        color: #ffffff;
        border-left-color: #0f766e;
        font-weight: 500;
    }

    #sidebar-wrapper .nav-link .nav-icon {
        width: 16px;
        height: 16px;
        opacity: 0.7;
        flex-shrink: 0;
    }

    #sidebar-wrapper .nav-link.active .nav-icon,
    #sidebar-wrapper .nav-link:hover .nav-icon {
        opacity: 1;
    }

    .sidebar-footer {
        margin-top: auto;
        padding: 16px 20px;
        border-top: 1px solid rgba(255,255,255,0.08);
        font-size: 0.75rem;
        color: #64748b;
    }
</style>

<div id="sidebar-wrapper">

    <div class="sidebar-brand">
        <div class="brand-title">IMS</div>
        <div class="brand-subtitle">Inventory System</div>
    </div>

    <!-- Main -->
    <div class="sidebar-section-label">Main</div>
    <a href="/spendilizer/dashboard"
       class="nav-link ${fn:contains(currentUri, '/spendilizer/dashboard') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>
        </svg>
        Dashboard
    </a>

    <!-- Inventory -->
    <div class="sidebar-section-label">Inventory</div>

    <a href="/spendilizer/category"
       class="nav-link ${fn:contains(currentUri, '/spendilizer/category') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/>
        </svg>
        Category
    </a>
    
    <a href="/spendilizer/product"
       class="nav-link ${fn:contains(currentUri, '/spendilizer/product') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>
        </svg>
        Products
    </a>

    <a href="/spendilizer/stock"
       class="nav-link ${fn:contains(currentUri, '/spendilizer/stock') and not fn:contains(currentUri, '/spendilizer/stock-movement') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/>
        </svg>
        Stock
    </a>

    <a href="/spendilizer/supplier"
       class="nav-link ${fn:contains(currentUri, '/spendilizer/supplier') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
        </svg>
        Supplier
    </a>

    <!-- Sales -->
    <div class="sidebar-section-label">Sales</div>

    <a href="/spendilizer/customer"
       class="nav-link ${fn:contains(currentUri, '/spendilizer/customer') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M17 20h5v-2a4 4 0 00-4-4H6a4 4 0 00-4 4v2h5M12 12a4 4 0 100-8 4 4 0 000 8z"/>
        </svg>
        Customers
    </a>

    <a href="/spendilizer/order"
       class="nav-link ${fn:contains(currentUri, '/spendilizer/order') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
        </svg>
        Orders
    </a>

    <a href="/spendilizer/invoice"
       class="nav-link ${fn:contains(currentUri, '/spendilizer/invoice') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/>
        </svg>
        Invoices
    </a>

    <%-- Enterprise section: only visible to enterprise owners --%>
    <c:if test="${not empty user && user.accountType == 'ENTERPRISE_OWNER'}">
        <div class="sidebar-section-label">Enterprise</div>
        <a href="/spendilizer/enterprise/members"
           class="nav-link ${fn:contains(currentUri, '/spendilizer/enterprise') ? 'active' : ''}">
            <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
            </svg>
            Team Members
        </a>
    </c:if>

    <div class="sidebar-footer">
        &copy; 2025 IMS Platform
    </div>
</div>