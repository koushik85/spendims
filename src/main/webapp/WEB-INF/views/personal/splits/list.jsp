<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Split Groups — Spendilizer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ims-shared.css">
</head>
<body>

<%@ include file="../../navbar.jsp" %>
<div class="container-fluid p-0">
<div class="row g-0">
<div><jsp:include page="../sidebar.jsp" /></div>
<div class="main-content">

    <div class="page-header flex">
        <div>
            <h2>Split Expenses</h2>
            <div class="page-subtitle">Track shared expenses and settle up</div>
        </div>
        <a href="${pageContext.request.contextPath}/personal/splits/new" class="btn-primary-custom">
            <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/>
            </svg>
            New Group
        </a>
    </div>

    <c:if test="${not empty success}">
        <div class="alert-banner" style="background:var(--color-success-lt);border-color:var(--color-success);color:var(--color-success);">
            <c:out value="${success}"/>
        </div>
    </c:if>

    <c:choose>
        <c:when test="${empty groups}">
            <div class="activity-card">
                <div class="empty-state" style="padding:60px 0;">
                    <svg width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
                    </svg>
                    <p>No split groups yet.</p>
                    <a href="${pageContext.request.contextPath}/personal/splits/new" class="btn-primary-custom">Create your first group</a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="row g-3">
                <c:forEach var="g" items="${groups}">
                    <div class="col-12 col-md-6 col-lg-4">
                        <a href="${pageContext.request.contextPath}/personal/splits/${g.id}" style="text-decoration:none;">
                            <div class="stat-card" style="cursor:pointer;transition:box-shadow 0.18s ease;border:1px solid var(--color-border);"
                                 onmouseover="this.style.boxShadow='var(--shadow-md)'"
                                 onmouseout="this.style.boxShadow=''">
                                <div style="display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:10px;">
                                    <div style="font-weight:600;font-size:0.95rem;color:var(--color-text);">
                                        <c:out value="${g.name}"/>
                                    </div>
                                    <c:choose>
                                        <c:when test="${g.status == 'ACTIVE'}">
                                            <span class="badge-pill badge-in">ACTIVE</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-pill badge-out">CLOSED</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <c:if test="${not empty g.description}">
                                    <div style="font-size:0.78rem;color:var(--color-text-muted);margin-bottom:8px;">
                                        <c:out value="${g.description}"/>
                                    </div>
                                </c:if>
                                <div style="font-size:0.75rem;color:var(--color-text-muted);display:flex;gap:16px;margin-top:auto;">
                                    <span>${g.members.size()} members</span>
                                    <span>${g.expenses.size()} expenses</span>
                                    <c:if test="${g.eventDate != null}"><span>${g.eventDate}</span></c:if>
                                </div>
                            </div>
                        </a>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

</div>
</div>
</div>
</body>
</html>
