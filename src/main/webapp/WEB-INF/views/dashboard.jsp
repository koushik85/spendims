<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — IMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/spendilizer/css/ims-shared.css">
</head>
<body>

<%@ include file="navbar.jsp" %>

<div class="container-fluid p-0">
    <div class="row g-0">

        <div>
            <jsp:include page="sidebar.jsp" />
        </div>

        <div class="main-content">

            <%-- ── Page header ──────────────────────────────────────── --%>
            <div class="page-header">
                <div>
                    <h2>Admin Dashboard</h2>
                    <div class="page-subtitle">Overview of your inventory system</div>
                </div>
                <div class="page-date" id="js-date"></div>
            </div>

            <%-- ── Low-stock banner ────────────────────────────────── --%>
            <c:if test="${lowStockCount > 0}">
                <div class="alert-banner">
                    <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                    </svg>
                    <span>
                        <strong>${lowStockCount} product(s)</strong> are below minimum stock threshold.&nbsp;
                        <a href="/spendilizer/stock">View stock &rarr;</a>
                    </span>
                </div>
            </c:if>

            <%-- ── Stat cards ───────────────────────────────────────── --%>
            <div class="row g-3">

                <div class="col-6 col-md-4 col-lg-2">
                    <div class="stat-card card-teal">
                        <div class="stat-icon">
                            <svg width="17" height="17" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/>
                            </svg>
                        </div>
                        <div class="stat-label">Products</div>
                        <div class="stat-value">${productCount}</div>
                        <div class="stat-hint">total active</div>
                    </div>
                </div>

                <div class="col-6 col-md-4 col-lg-2">
                    <div class="stat-card card-blue">
                        <div class="stat-icon">
                            <svg width="17" height="17" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/>
                            </svg>
                        </div>
                        <div class="stat-label">Categories</div>
                        <div class="stat-value">${categoryCount}</div>
                        <div class="stat-hint">total active</div>
                    </div>
                </div>

                <div class="col-6 col-md-4 col-lg-2">
                    <div class="stat-card card-purple">
                        <div class="stat-icon">
                            <svg width="17" height="17" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
                            </svg>
                        </div>
                        <div class="stat-label">Suppliers</div>
                        <div class="stat-value">${supplierCount}</div>
                        <div class="stat-hint">total active</div>
                    </div>
                </div>

                <div class="col-6 col-md-4 col-lg-2">
                    <div class="stat-card card-green">
                        <div class="stat-icon">
                            <svg width="17" height="17" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                        </div>
                        <div class="stat-label">In Stock</div>
                        <div class="stat-value">${inStockCount}</div>
                        <div class="stat-hint">products stocked</div>
                    </div>
                </div>

                <div class="col-6 col-md-4 col-lg-2">
                    <div class="stat-card card-red">
                        <div class="stat-icon">
                            <svg width="17" height="17" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                            </svg>
                        </div>
                        <div class="stat-label">Low Stock</div>
                        <div class="stat-value">${lowStockCount}</div>
                        <div class="stat-hint">below threshold</div>
                    </div>
                </div>

                <div class="col-6 col-md-4 col-lg-2">
                    <div class="stat-card card-amber">
                        <div class="stat-icon">
                            <svg width="17" height="17" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                            </svg>
                        </div>
                        <div class="stat-label">Movements</div>
                        <div class="stat-value">${movementCount}</div>
                        <div class="stat-hint">total logged</div>
                    </div>
                </div>

            </div>
            <%-- end stat cards --%>

            <%-- ── Sales stat cards ────────────────────────────────────── --%>
            <div class="section-title">Sales overview</div>
            <div class="row g-3">

                <div class="col-6 col-md-4 col-lg-3">
                    <div class="stat-card card-blue">
                        <div class="stat-icon">
                            <svg width="17" height="17" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a4 4 0 00-4-4H6a4 4 0 00-4 4v2h5M12 12a4 4 0 100-8 4 4 0 000 8z"/>
                            </svg>
                        </div>
                        <div class="stat-label">Customers</div>
                        <div class="stat-value">${customerCount}</div>
                        <div class="stat-hint">active</div>
                    </div>
                </div>

                <div class="col-6 col-md-4 col-lg-3">
                    <div class="stat-card card-teal">
                        <div class="stat-icon">
                            <svg width="17" height="17" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                            </svg>
                        </div>
                        <div class="stat-label">Orders</div>
                        <div class="stat-value">${totalOrders}</div>
                        <div class="stat-hint">${pendingOrders} in progress</div>
                    </div>
                </div>

                <div class="col-6 col-md-4 col-lg-3">
                    <div class="stat-card card-green">
                        <div class="stat-icon">
                            <svg width="17" height="17" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                        </div>
                        <div class="stat-label">Revenue</div>
                        <div class="stat-value" style="font-size:1.1rem;">&#8377;<fmt:formatNumber value="${paidRevenue}" pattern="#,##0"/></div>
                        <div class="stat-hint">paid invoices</div>
                    </div>
                </div>

                <div class="col-6 col-md-4 col-lg-3">
                    <div class="stat-card card-amber">
                        <div class="stat-icon">
                            <svg width="17" height="17" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/>
                            </svg>
                        </div>
                        <div class="stat-label">Unpaid Invoices</div>
                        <div class="stat-value">${unpaidInvoices}</div>
                        <div class="stat-hint">sent / overdue</div>
                    </div>
                </div>

            </div>
            <%-- end sales stat cards --%>

            <%-- ── Quick actions ─────────────────────────────────────── --%>
            <div class="section-title">Quick actions</div>
            <div class="row g-2">
                <div class="col-12 col-sm-6 col-lg-3">
                    <a href="/spendilizer/product/new" class="quick-action">
                        <span class="qa-icon">
                            <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/>
                            </svg>
                        </span>
                        Add new product
                    </a>
                </div>

                <div class="col-12 col-sm-6 col-lg-3">
                    <a href="/spendilizer/supplier/new" class="quick-action">
                        <span class="qa-icon">
                            <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5"/>
                            </svg>
                        </span>
                        Add supplier
                    </a>
                </div>

                <div class="col-12 col-sm-6 col-lg-3">
                    <a href="/spendilizer/category/new" class="quick-action">
                        <span class="qa-icon">
                            <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/>
                            </svg>
                        </span>
                        Add category
                    </a>
                </div>

                <div class="col-12 col-sm-6 col-lg-3">
                    <a href="/spendilizer/stock-movement" class="quick-action">
                        <span class="qa-icon">
                            <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                            </svg>
                        </span>
                        View movement log
                    </a>
                </div>

                <div class="col-12 col-sm-6 col-lg-3">
                    <a href="/spendilizer/stock" class="quick-action">
                        <span class="qa-icon">
                            <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 10h16M4 14h16M4 18h16"/>
                            </svg>
                        </span>
                        Stock overview
                    </a>
                </div>

                <div class="col-12 col-sm-6 col-lg-3">
                    <a href="/spendilizer/product" class="quick-action">
                        <span class="qa-icon">
                            <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h8m-8 6h16"/>
                            </svg>
                        </span>
                        All products
                    </a>
                </div>

                <div class="col-12 col-sm-6 col-lg-3">
                    <a href="/spendilizer/order/new" class="quick-action">
                        <span class="qa-icon">
                            <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/>
                            </svg>
                        </span>
                        New order
                    </a>
                </div>

                <div class="col-12 col-sm-6 col-lg-3">
                    <a href="/spendilizer/invoice/new" class="quick-action">
                        <span class="qa-icon">
                            <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2m-3 7h3m-3 4h3"/>
                            </svg>
                        </span>
                        New invoice
                    </a>
                </div>

                <div class="col-12 col-sm-6 col-lg-3">
                    <a href="/spendilizer/customer/new" class="quick-action">
                        <span class="qa-icon">
                            <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"/>
                            </svg>
                        </span>
                        Add customer
                    </a>
                </div>

            </div>
            <%-- end quick actions --%>

            <%-- ── Recent movements table ─────────────────────────── --%>
            <div class="section-title">Recent stock movements</div>
            <div class="activity-card">
                <div class="activity-header">
                    <span>Latest movements</span>
                    <a href="/spendilizer/stock-movement">View all &rarr;</a>
                </div>

                <table class="activity-table">
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Type</th>
                            <th>Qty</th>
                            <th>Note</th>
                            <th>Date / Time</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="m" items="${recentMovements}">
                            <tr>
                                <td>
                                    <div class="product-cell">
                                        <span class="product-dot"></span>
                                        <c:out value="${m.product.name}" default="—"/>
                                    </div>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${m.type == 'IN'}">
                                            <span class="badge-pill badge-in">
                                                <svg width="8" height="8" viewBox="0 0 8 8" fill="currentColor"><circle cx="4" cy="4" r="4"/></svg>
                                                IN
                                            </span>
                                        </c:when>
                                        <c:when test="${m.type == 'OUT'}">
                                            <span class="badge-pill badge-out">
                                                <svg width="8" height="8" viewBox="0 0 8 8" fill="currentColor"><circle cx="4" cy="4" r="4"/></svg>
                                                OUT
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-pill badge-adj">
                                                <svg width="8" height="8" viewBox="0 0 8 8" fill="currentColor"><circle cx="4" cy="4" r="4"/></svg>
                                                ADJ
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="qty-cell">
                                    <c:choose>
                                        <c:when test="${m.type == 'IN'}">+${m.quantity}</c:when>
                                        <c:when test="${m.type == 'OUT'}">-${m.quantity}</c:when>
                                        <c:otherwise>${m.quantity}</c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="note-cell">
                                    <c:choose>
                                        <c:when test="${not empty m.note}"><c:out value="${m.note}"/></c:when>
                                        <c:otherwise><span style="opacity:0.4">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="date-cell"><c:out value="${m.movedAt}" default="—"/></td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty recentMovements}">
                            <tr>
                                <td colspan="5">
                                    <div class="empty-state">
                                        <svg width="36" height="36" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                                        </svg>
                                        <p>No movements recorded yet.</p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            <%-- end movements table --%>

        </div><%-- end .main-content --%>
    </div>
</div>

<script>initLiveDate('js-date');</script>
</body>
</html>
