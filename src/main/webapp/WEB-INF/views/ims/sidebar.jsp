<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="uri" value="${pageContext.request.requestURI}"/>

<div id="sidebar-wrapper">

    <div class="sidebar-brand">
        <div class="brand-title">Spendilizer</div>
        <div class="brand-subtitle">Inventory</div>
    </div>

    <!-- Main -->
    <div class="sidebar-section-label">Main</div>
    <a href="${ctx}/dashboard"
       class="nav-link ${fn:contains(uri, '/dashboard') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>
        </svg>
        Dashboard
    </a>

    <!-- Inventory -->
    <div class="sidebar-section-label">Inventory</div>

    <a href="${ctx}/product"
       class="nav-link ${fn:contains(uri, '/product') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>
        </svg>
        Products
    </a>

    <a href="${ctx}/stock"
       class="nav-link ${fn:contains(uri, '/stock') and not fn:contains(uri, '/stock-movement') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/>
        </svg>
        Stock
    </a>

    <a href="${ctx}/supplier"
       class="nav-link ${fn:contains(uri, '/supplier') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
        </svg>
        Supplier
    </a>

    <!-- Sales -->
    <div class="sidebar-section-label">Sales</div>

    <a href="${ctx}/customer"
       class="nav-link ${fn:contains(uri, '/customer') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M17 20h5v-2a4 4 0 00-4-4H6a4 4 0 00-4 4v2h5M12 12a4 4 0 100-8 4 4 0 000 8z"/>
        </svg>
        Customers
    </a>

    <a href="${ctx}/order"
       class="nav-link ${fn:contains(uri, '/order') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
        </svg>
        Orders
    </a>

    <a href="${ctx}/invoice"
       class="nav-link ${fn:contains(uri, '/invoice') ? 'active' : ''}">
        <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/>
        </svg>
        Invoices
    </a>

    <%-- Enterprise section: only visible to enterprise owners --%>
    <c:if test="${not empty user && user.accountType == 'ENTERPRISE_OWNER'}">
        <div class="sidebar-section-label">Enterprise</div>
        <a href="${ctx}/enterprise/members"
           class="nav-link ${fn:contains(uri, '/enterprise') ? 'active' : ''}">
            <svg class="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
            </svg>
            Team Members
        </a>
    </c:if>

    <div class="sidebar-footer">
        &copy; 2025 Spendilizer
    </div>
</div>