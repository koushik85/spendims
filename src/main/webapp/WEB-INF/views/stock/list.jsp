<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Stock — IMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/spendilizer/css/ims-shared.css">
</head>
<body>
<%@ include file="../navbar.jsp" %>
<div class="container-fluid p-0">
    <div class="row g-0">
        <div><jsp:include page="../sidebar.jsp"/></div>

        <div class="main-content">

            <div class="page-header">
                <div>
                    <h2>Stock</h2>
                    <div class="page-subtitle">Monitor and manage inventory levels</div>
                </div>
                <a href="/spendilizer/stock/new" class="btn-primary-custom">
                    <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/>
                    </svg>
                    Add Stock Entry
                </a>
            </div>

            <%-- Flash messages --%>
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
                    <div class="label">Total Entries</div>
                    <div class="value">${totalCount}</div>
                </div>
                <c:if test="${lowStockCount > 0}">
                    <div class="summary-card warning">
                        <div class="label">⚠ Low Stock</div>
                        <div class="value">${lowStockCount}</div>
                    </div>
                </c:if>
            </div>

            <%-- Search --%>
            <div class="search-bar">
                <svg class="search-icon" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35M17 11A6 6 0 115 11a6 6 0 0112 0z"/>
                </svg>
                <input type="text" id="searchInput" placeholder="Search stock entries…" onkeyup="filterTable('stockTable')">
            </div>

            <div class="table-card">
                <table id="stockTable">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Product</th>
                            <th>Quantity</th>
                            <th>Min Threshold</th>
                            <th>Stock Level</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="s" items="${stocks}" varStatus="loop">
                            <tr>
                                <td style="color: var(--color-text-muted); width: 48px;">${loop.index + 1}</td>

                                <td style="font-weight: 500;">
                                    ${s.product.name}
                                    <div style="font-size:0.75rem; color:var(--color-text-muted);">
                                        ${s.product.category.name}
                                    </div>
                                </td>

                                <td>
                                    <span style="font-weight: 600; font-size: 0.95rem;">${s.quantity}</span>
                                    <span style="font-size: 0.75rem; color: var(--color-text-muted);"> units</span>
                                </td>

                                <td style="color: var(--color-text-muted);">${s.minThreshold}</td>

                                <td>
                                    <%-- Compute fill % capped at 100, show badge if low --%>
                                    <c:set var="pct" value="${s.minThreshold > 0 ? (s.quantity * 100 / s.minThreshold) : 100}"/>
                                    <c:set var="cappedPct" value="${pct > 100 ? 100 : pct}"/>
                                    <c:choose>
                                        <c:when test="${s.quantity == 0}">
                                            <c:set var="barClass" value="critical"/>
                                        </c:when>
                                        <c:when test="${s.quantity <= s.minThreshold}">
                                            <c:set var="barClass" value="low"/>
                                        </c:when>
                                        <c:otherwise>
                                            <c:set var="barClass" value="ok"/>
                                        </c:otherwise>
                                    </c:choose>

                                    <div class="stock-level">
                                        <div class="stock-bar-wrap">
                                            <div class="stock-bar-fill ${barClass}" style="width: ${cappedPct}%;"></div>
                                        </div>
                                        <c:if test="${s.quantity <= s.minThreshold}">
                                            <span class="badge-low">Low</span>
                                        </c:if>
                                    </div>
                                </td>
                                <td>
                                    <div style="display:flex; gap:6px; align-items:center; flex-wrap:wrap;">

                                        <%-- Quick adjust +1 --%>
                                        <form action="/spendilizer/stock/adjust/${s.id}" method="post" style="margin:0;">
                                            <input type="hidden" name="delta" value="1">
                                            <input type="hidden" name="note" value="Quick +1 adjustment">
                                            <button type="submit" class="btn-action btn-adjust-plus" title="Add 1 unit">
                                                <svg width="11" height="11" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/>
                                                </svg>
                                                +1
                                            </button>
                                        </form>

                                        <%-- Quick adjust -1 --%>
                                        <form action="/spendilizer/stock/adjust/${s.id}" method="post" style="margin:0;">
                                            <input type="hidden" name="delta" value="-1">
                                            <input type="hidden" name="note" value="Quick -1 adjustment">
                                            <button type="submit" class="btn-action btn-adjust-minus" title="Remove 1 unit">
                                                <svg width="11" height="11" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                                    <path stroke-linecap="round" stroke-linejoin="round" d="M20 12H4"/>
                                                </svg>
                                                -1
                                            </button>
                                        </form>

                                        <%-- Restock modal trigger --%>
                                        <button type="button" class="btn-action btn-adjust-plus"
                                                onclick="openRestock('${s.id}', '${s.product.name}')"
                                                title="Restock / custom adjust">
                                            Restock
                                        </button>

                                        <%-- Edit --%>
                                        <a href="/spendilizer/stock/edit/${s.id}" class="btn-action btn-edit">
                                            <svg width="12" height="12" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.2">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M15.232 5.232l3.536 3.536M9 13l6.586-6.586a2 2 0 012.828 2.828L11.828 15.828a4 4 0 01-1.414.586l-3 .586.586-3a4 4 0 01.586-1.414z"/>
                                            </svg>
                                            Edit
                                        </a>

                                        <%-- Deactivate --%>
                                        <form action="/spendilizer/stock/delete/${s.id}" method="post" style="margin:0;"
                                              onsubmit="return confirm('Deactivate this stock entry?')">
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

                        <c:if test="${empty stocks}">
                            <tr>
                                <td colspan="7">
                                    <div class="empty-state">
                                        <svg width="40" height="40" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10"/>
                                        </svg>
                                        <p>No stock entries found. <a href="/spendilizer/stock/new" style="color: var(--color-primary);">Add one now.</a></p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>

                <c:if test="${not empty stocks}">
                    <div class="table-footer">
                        Showing <span id="visibleCount">${stocks.size()}</span> of ${stocks.size()} entries
                    </div>
                </c:if>
            </div>

        </div>
    </div>
</div>

<%-- Restock Modal --%>
<div id="restockModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.4);z-index:1000;align-items:center;justify-content:center;">
    <div style="background:#fff;border-radius:12px;padding:28px 32px;width:360px;box-shadow:0 8px 32px rgba(0,0,0,0.18);">
        <h3 style="margin:0 0 4px;font-size:1rem;font-weight:600;">Restock / Adjust</h3>
        <p id="restockProductName" style="font-size:0.85rem;color:#64748b;margin:0 0 20px;"></p>
        <form id="restockForm" method="post">
            <div style="margin-bottom:14px;">
                <label style="font-size:0.8rem;font-weight:600;color:#475569;display:block;margin-bottom:6px;">
                    Quantity Change <span style="color:#dc2626;">*</span>
                </label>
                <input type="number" id="restockDelta" name="delta" placeholder="e.g. 50 (add) or -10 (remove)"
                       style="width:100%;padding:8px 12px;border:1px solid #e2e8f0;border-radius:6px;font-size:0.875rem;"
                       required>
                <div style="font-size:0.75rem;color:#94a3b8;margin-top:4px;">Positive = add stock. Negative = deduct.</div>
            </div>
            <div style="margin-bottom:20px;">
                <label style="font-size:0.8rem;font-weight:600;color:#475569;display:block;margin-bottom:6px;">
                    Reason / Note <span style="color:#94a3b8;font-weight:400;">(optional)</span>
                </label>
                <input type="text" name="note" placeholder="e.g. Supplier delivery, Damage writeoff…"
                       style="width:100%;padding:8px 12px;border:1px solid #e2e8f0;border-radius:6px;font-size:0.875rem;">
            </div>
            <div style="display:flex;gap:10px;">
                <button type="submit"
                        style="flex:1;padding:9px;background:#0f766e;color:#fff;border:none;border-radius:6px;font-size:0.875rem;font-weight:500;cursor:pointer;">
                    Apply
                </button>
                <button type="button" onclick="closeRestock()"
                        style="flex:1;padding:9px;background:#f1f5f9;color:#475569;border:1px solid #e2e8f0;border-radius:6px;font-size:0.875rem;cursor:pointer;">
                    Cancel
                </button>
            </div>
        </form>
    </div>
</div>

<script src="/spendilizer/js/ims-stock-list.js"></script>
<script src="/spendilizer/js/ims-shared.js"></script>
</body>
</html>
