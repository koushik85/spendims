<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Stock Movements — IMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ims-shared.css">
</head>
<body>
<%@ include file="../../navbar.jsp" %>
<div class="container-fluid p-0">
    <div class="row g-0">
        <div><jsp:include page="../sidebar.jsp"/></div>

        <div class="main-content">

            <div class="page-header">
                <div>
                    <h2>Stock Movements</h2>
                    <div class="page-subtitle">Track all inventory IN / OUT transactions</div>
                </div>
                <a href="${pageContext.request.contextPath}/stock-movement/new" class="btn-primary-custom">
                    <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/>
                    </svg>
                    Record Movement
                </a>
            </div>

            <%-- Flash --%>
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

            <%-- Summary cards --%>
            <div class="summary-row">
                <div class="summary-card">
                    <div class="label">Total Movements</div>
                    <div class="value">${movements.size()}</div>
                </div>
                <div class="summary-card in-card">
                    <div class="label">▲ Stock IN</div>
                    <div class="value">${inCount}</div>
                </div>
                <div class="summary-card out-card">
                    <div class="label">▼ Stock OUT</div>
                    <div class="value">${outCount}</div>
                </div>
            </div>

            <%-- Filter bar --%>
            <form action="${pageContext.request.contextPath}/stock-movement" method="get">
                <div class="filter-bar">
                    <%-- Live search --%>
                    <div class="search-wrap">
                        <svg class="search-icon" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35M17 11A6 6 0 115 11a6 6 0 0112 0z"/>
                        </svg>
                        <input type="text" id="searchInput" placeholder="Search movements…" onkeyup="filterTable('movementTable')">
                    </div>

                    <%-- Product filter --%>
                    <select name="productId" onchange="this.form.submit()">
                        <option value="">All products</option>
                        <c:forEach var="p" items="${products}">
                            <option value="${p.id}" ${filterProductId == p.id ? 'selected' : ''}>${p.name}</option>
                        </c:forEach>
                    </select>

                    <%-- Type filter --%>
                    <select name="type" onchange="this.form.submit()">
                        <option value="">All types</option>
                        <c:forEach var="t" items="${types}">
                            <option value="${t}" ${filterType == t ? 'selected' : ''}>${t}</option>
                        </c:forEach>
                    </select>

                    <%-- Clear filters --%>
                    <c:if test="${not empty filterProductId or not empty filterType}">
                        <a href="${pageContext.request.contextPath}/stock-movement" class="btn-filter">
                            <svg width="12" height="12" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
                            </svg>
                            Clear filters
                        </a>
                    </c:if>
                </div>
            </form>

            <div class="table-card">
                <table id="movementTable">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Product</th>
                            <th>Type</th>
                            <th>Quantity</th>
                            <th>Date</th>
                            <th>Note</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="m" items="${movements}" varStatus="loop">
                            <tr>
                                <td style="color:var(--color-text-muted); width:48px;">${loop.index + 1}</td>

                                <td style="font-weight:500;">
                                    ${m.product.name}
                                    <div style="font-size:0.75rem; color:var(--color-text-muted);">
                                        ${m.product.category.name}
                                    </div>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${m.type == 'IN'}">
                                            <span class="badge-in">▲ IN</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-out">▼ OUT</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${m.type == 'IN'}">
                                            <span class="qty-pill in">+${m.quantity}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="qty-pill out">-${m.quantity}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td style="color:var(--color-text-muted); font-size:0.8rem; white-space:nowrap;">
                                    ${m.movedAtFormatted}
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${not empty m.note}">
                                            <span class="note-chip" title="${m.note}">${m.note}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="font-style:italic; opacity:0.4; font-size:0.8rem;">—</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div style="display:flex; gap:6px; align-items:center;">
                                        <a href="${pageContext.request.contextPath}/stock-movement/edit/${m.id}" class="btn-action btn-edit">
                                            <svg width="12" height="12" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.2">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M15.232 5.232l3.536 3.536M9 13l6.586-6.586a2 2 0 012.828 2.828L11.828 15.828a4 4 0 01-1.414.586l-3 .586.586-3a4 4 0 01.586-1.414z"/>
                                            </svg>
                                            Edit Note
                                        </a>
                                        <form action="${pageContext.request.contextPath}/stock-movement/delete/${m.id}" method="post" style="margin:0;"
                                              onsubmit="return confirm('Deactivate this movement record?')">
                                            <button type="submit" class="btn-action btn-delete">
                                                <svg width="12" height="12" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.2">
                                                    <path stroke-linecap="round" stroke-linejoin="round" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636"/>
                                                </svg>
                                                Delete
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty movements}">
                            <tr>
                                <td colspan="8">
                                    <div class="empty-state">
                                        <svg width="40" height="40" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"/>
                                        </svg>
                                        <p>No movements found. <a href="${pageContext.request.contextPath}/stock-movement/new" style="color:var(--color-primary);">Record one now.</a></p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>

                <c:if test="${not empty movements}">
                    <div class="table-footer">
                        Showing <span id="visibleCount">${movements.size()}</span> of ${movements.size()} movements
                    </div>
                </c:if>
            </div>

        </div>
    </div>
</div>

</body>
</html>
