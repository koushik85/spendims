<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — Spendilizer</title>
    <jsp:include page="${pageContext.request.contextPath}/include/styling.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ims-shared.css">
</head>
<body>

<%@ include file="../navbar.jsp" %>

<div class="container-fluid p-0">
    <div class="row g-0">
        <div><jsp:include page="sidebar.jsp" /></div>
        <div class="main-content">

            <div class="page-header">
                <div>
                    <h2><span class="greeting">Hi, ${user.firstName}</span><span class="page-title-main">Admin Dashboard</span></h2>
                    <div class="page-subtitle">Platform overview and pending approvals</div>
                </div>
            </div>

            <%-- Stat cards --%>
            <div class="row g-3 mb-4" style="margin-left:20px;margin-right:20px;">
                <div class="col-md-3">
                    <div class="stat-card card-teal" style="margin-left:0;">
                        <div class="stat-icon">
                            <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
                            </svg>
                        </div>
                        <div class="stat-label">Total Users</div>
                        <div class="stat-value">${allUsers.size()}</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card card-amber" style="margin-left:0;">
                        <div class="stat-icon">
                            <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5"/>
                            </svg>
                        </div>
                        <div class="stat-label">Pending Enterprises</div>
                        <div class="stat-value">${pendingEnterprises.size()}</div>
                        <div class="stat-hint"><a href="${pageContext.request.contextPath}/admin/enterprises" style="color:inherit;">Review &rarr;</a></div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card card-purple" style="margin-left:0;">
                        <div class="stat-icon">
                            <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                            </svg>
                        </div>
                        <div class="stat-label">Pending Requests</div>
                        <div class="stat-value">${pendingProductRequests.size()}</div>
                        <div class="stat-hint"><a href="${pageContext.request.contextPath}/admin/master-products/requests" style="color:inherit;">Review &rarr;</a></div>
                    </div>
                </div>
            </div>

            <%-- Pending enterprise approvals --%>
            <c:if test="${not empty pendingEnterprises}">
                <div class="section-title">Pending Enterprise Approvals</div>
                <div class="table-card">
                    <table>
                        <thead>
                            <tr>
                                <th>Business</th>
                                <th>Owner</th>
                                <th>Email</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="e" items="${pendingEnterprises}">
                                <tr>
                                    <td>${e.enterpriseName}</td>
                                    <td>${e.owner.firstName} ${e.owner.lastName}</td>
                                    <td>${e.owner.email}</td>
                                    <td>
                                        <div class="flex-gap-6">
                                            <form method="post" action="${pageContext.request.contextPath}/admin/enterprises/${e.enterpriseId}/approve">
                                                <button class="btn-action btn-adjust-plus">Approve</button>
                                            </form>
                                            <form method="post" action="${pageContext.request.contextPath}/admin/enterprises/${e.enterpriseId}/reject">
                                                <button class="btn-action btn-delete">Reject</button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:if>

            <%-- Pending product requests --%>
            <c:if test="${not empty pendingProductRequests}">
                <div class="section-title">Pending Product Requests</div>
                <div class="table-card">
                    <table>
                        <thead>
                            <tr>
                                <th>Product</th>
                                <th>SKU</th>
                                <th>Requested By</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${pendingProductRequests}">
                                <tr>
                                    <td>${r.name}</td>
                                    <td><span class="text-muted" style="font-family:monospace;font-size:0.8rem;">${r.sku}</span></td>
                                    <td>${r.requestedBy.firstName} ${r.requestedBy.lastName}</td>
                                    <td>
                                        <div class="flex-gap-6">
                                            <form method="post" action="${pageContext.request.contextPath}/admin/master-products/requests/${r.id}/approve">
                                                <button class="btn-action btn-adjust-plus">Approve</button>
                                            </form>
                                            <a href="${pageContext.request.contextPath}/admin/master-products/requests" class="btn-action btn-delete">Reject</a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:if>

            <c:if test="${empty pendingEnterprises && empty pendingProductRequests}">
                <div class="empty-state" style="margin-left:40px;">
                    <svg width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    <p>No pending approvals. All caught up!</p>
                </div>
            </c:if>

        </div>
    </div>
</div>

</body>
</html>
