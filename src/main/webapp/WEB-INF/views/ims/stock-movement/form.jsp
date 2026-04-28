<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>${empty movement.id ? 'Record Movement' : 'Edit Movement'} — IMS</title>
    <jsp:include page="${pageContext.request.contextPath}/include/styling.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ims-shared.css">
</head>
<body>
<%@ include file="../../navbar.jsp" %>
<div class="container-fluid p-0">
    <div class="row g-0">
        <div><jsp:include page="../sidebar.jsp"/></div>

        <div class="main-content">

            <%-- Breadcrumb --%>
            <div class="breadcrumb-bar">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <span class="sep">›</span>
                <a href="${pageContext.request.contextPath}/stock-movement">Stock Movements</a>
                <span class="sep">›</span>
                <span class="current">${empty movement.id ? 'Record Movement' : 'Edit Movement'}</span>
            </div>

            <%-- Page header --%>
            <div class="page-header">
                <h2>
                    <span class="header-icon">
                        <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"/>
                        </svg>
                    </span>
                    ${empty movement.id ? 'Record Stock Movement' : 'Edit Movement'}
                </h2>
                <div class="page-subtitle">
                    ${empty movement.id
                        ? 'Log an inventory IN or OUT transaction for a product.'
                        : 'Only the note can be updated. Type, product and quantity are locked.'}
                </div>
            </div>

            <%-- Edit mode: read-only details banner --%>
            <c:if test="${not empty movement.id}">
                <div class="edit-mode-banner">
                    <div class="detail-item">
                        <div class="di-label">Movement ID</div>
                        <div class="di-value">#${movement.id}</div>
                    </div>
                    <div class="detail-item">
                        <div class="di-label">Product</div>
                        <div class="di-value">${movement.product.name}</div>
                    </div>
                    <div class="detail-item">
                        <div class="di-label">Type</div>
                        <div class="di-value">
                            <c:choose>
                                <c:when test="${movement.type == 'IN'}"><span class="badge-in">▲ IN</span></c:when>
                                <c:otherwise><span class="badge-out">▼ OUT</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="detail-item">
                        <div class="di-label">Quantity</div>
                        <div class="di-value">${movement.quantity} units</div>
                    </div>
                    <div class="detail-item">
                        <div class="di-label">Date</div>
                        <div class="di-value" style="font-size:0.8rem;">
                            <fmt:formatDate value="${movement.movementDate}" pattern="dd MMM yyyy, HH:mm"/>
                        </div>
                    </div>
                </div>
            </c:if>

            <%-- Form card --%>
            <div class="form-card">
                <div class="form-card-header">
                    ${empty movement.id ? 'Movement Details' : 'Update Note'}
                </div>
                <div class="form-card-body">

                    <form action="${pageContext.request.contextPath}/stock-movement/${empty movement.id ? 'new' : 'edit/'.concat(movement.id)}"
                          method="post">

                        <%-- ══ ADD MODE ONLY fields ══ --%>
                        <c:if test="${empty movement.id}">

                            <div class="form-group">
                                <label>Movement Type <span class="required">*</span></label>
                                <div class="type-selector">

                                    <label class="type-card in-card" id="card-IN" onclick="selectType('IN')">
                                        <input type="radio" name="type" value="IN" required>
                                        <div class="type-icon">
                                            <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.2">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m0-16l-4 4m4-4l4 4"/>
                                            </svg>
                                        </div>
                                        <div>
                                            <div class="type-label">Stock IN</div>
                                            <div class="type-desc">Receiving / restocking goods</div>
                                        </div>
                                    </label>

                                    <label class="type-card out-card" id="card-OUT" onclick="selectType('OUT')">
                                        <input type="radio" name="type" value="OUT">
                                        <div class="type-icon">
                                            <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.2">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M12 20V4m0 16l-4-4m4 4l4-4"/>
                                            </svg>
                                        </div>
                                        <div>
                                            <div class="type-label">Stock OUT</div>
                                            <div class="type-desc">Dispatching / consuming goods</div>
                                        </div>
                                    </label>

                                </div>
                            </div>

                            <div class="form-group">
                                <label for="productId">Product <span class="required">*</span></label>
                                <div class="select-wrapper">
                                    <select id="productId" name="product.id" required onchange="fetchStockInfo(this.value)">
                                        <option value="" disabled selected>— Select a product —</option>
                                        <c:forEach var="p" items="${products}">
                                            <option value="${p.id}">${p.name}
                                                <c:if test="${not empty p.category}"> (${p.category.name})</c:if>
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="stock-info" id="stockInfo">
                                    <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M12 2a10 10 0 100 20A10 10 0 0012 2z"/>
                                    </svg>
                                    <span id="stockInfoText"></span>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="quantity">Quantity <span class="required">*</span></label>
                                <input type="number" id="quantity" name="quantity" min="1" value="1" required>
                                <div class="field-hint">Number of units being moved.</div>
                            </div>

                        </c:if>
                        <%-- ══ END ADD MODE ══ --%>

                        <%-- Note — shared by both modes --%>
                        <div class="form-group">
                            <label for="note">
                                Note <span class="optional">optional</span>
                            </label>
                            <textarea id="note"
                                      name="note"
                                      placeholder="e.g. Received from supplier, Damaged goods disposal…">${movement.note}</textarea>
                            <div class="field-hint">
                                ${empty movement.id
                                    ? 'Add any relevant context for this movement.'
                                    : 'Provide context such as supplier name, order reference, or reason for disposal.'}
                            </div>
                        </div>

                        <div class="form-divider"></div>

                        <div class="form-actions">
                            <button type="submit" class="btn-save">
                                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
                                </svg>
                                ${empty movement.id ? 'Record Movement' : 'Save Note'}
                            </button>
                            <a href="${pageContext.request.contextPath}/stock-movement" class="btn-cancel">Cancel</a>
                        </div>

                    </form>
                </div>
            </div>

        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/ims-stock-movement-form.js"></script>
</body>
</html>
