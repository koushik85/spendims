<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Sales Orders — IMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/ims-shared.css" rel="stylesheet">
</head>
<body>
<%@ include file="../../navbar.jsp" %>
<div class="container-fluid p-0">
    <div class="row g-0">
        <div><jsp:include page="../sidebar.jsp"/></div>
        <div class="main-content">

            <div class="page-header">
                <div>
                    <h2>Sales Orders</h2>
                    <div class="page-subtitle">Track and manage customer orders</div>
                </div>
                <a href="${pageContext.request.contextPath}/order/new" class="btn-primary-custom">
                    <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/>
                    </svg>
                    New Order
                </a>
            </div>

            <c:if test="${not empty successMessage}">
                <div class="flash-success">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    ${successMessage}
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="flash-error">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    ${errorMessage}
                </div>
            </c:if>

            <div class="search-bar">
                <svg class="search-icon" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35M17 11A6 6 0 115 11a6 6 0 0112 0z"/>
                </svg>
                <input type="text" id="searchInput" placeholder="Search orders…" onkeyup="filterTable('orderTable')">
            </div>

            <div class="table-card">
                <table id="orderTable">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Order No.</th>
                            <th>Customer</th>
                            <th>Date</th>
                            <th>Items</th>
                            <th>Total</th>
                            <th>Payment</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="o" items="${orders}" varStatus="loop">
                            <tr>
                                <td class="text-muted" style="width:48px;">${loop.index + 1}</td>
                                <td class="fw-500">
                                    <a href="${pageContext.request.contextPath}/order/${o.id}" style="color:var(--color-primary);text-decoration:none;">
                                        ${o.orderNumber}
                                    </a>
                                </td>
                                <td>${o.customer.displayName}</td>
                                <td class="text-muted">${o.orderDateFormatted}</td>
                                <td class="text-muted">${o.items.size()}</td>
                                <td class="fw-500">&#8377;${o.totalAmount}</td>
                                <td class="text-muted">${o.paymentMode.label}</td>
                                <td><span class="status-badge status-${o.status}">${o.status}</span></td>
                                <td>
                                    <div class="flex-gap-6">
                                        <a href="${pageContext.request.contextPath}/order/${o.id}" class="btn-action btn-edit">View</a>
                                        <c:if test="${o.status == 'DRAFT'}">
                                            <a href="${pageContext.request.contextPath}/order/edit/${o.id}" class="btn-action btn-edit">Edit</a>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty orders}">
                            <tr>
                                <td colspan="9">
                                    <div class="empty-state">
                                        <svg width="40" height="40" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                                        </svg>
                                        <p>No orders yet. <a href="${pageContext.request.contextPath}/order/new" style="color:var(--color-primary);">Create one now.</a></p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
                <c:if test="${not empty orders}">
                    <div class="table-footer">
                        Showing <span id="visibleCount">${orders.size()}</span> of ${orders.size()} orders
                    </div>
                </c:if>
            </div>

        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/ims-shared.js"></script>
</body>
</html>
