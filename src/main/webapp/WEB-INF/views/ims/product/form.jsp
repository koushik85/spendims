<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>${empty product.id ? 'Add Product' : 'Edit Product'} — IMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
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
                <a href="${pageContext.request.contextPath}/product">Products</a>
                <span class="sep">›</span>
                <span class="current">${empty product.id ? 'New Product' : 'Edit Product'}</span>
            </div>

            <%-- Page header --%>
            <div class="page-header">
                <h2>
                    <span class="header-icon">
                        <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/>
                        </svg>
                    </span>
                    ${empty product.id ? 'Add New Product' : 'Edit Product'}
                </h2>
                <div class="page-subtitle">
                    ${empty product.id ? 'Fill in the details to add a new product to inventory.' : 'Update the product details below.'}
                </div>
            </div>

            <%-- Edit mode banner --%>
            <c:if test="${not empty product.id}">
                <div class="edit-mode-banner">
                    <svg width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M12 2a10 10 0 100 20A10 10 0 0012 2z"/>
                    </svg>
                    Editing: <strong>${product.name}</strong> &nbsp;·&nbsp; SKU: ${product.sku} &nbsp;·&nbsp; ID: ${product.id}
                </div>
                <div class="field-hint" style="margin-bottom: 14px;">
                    Master-derived fields (Name, SKU, Category, HSN) are locked. You can still update pricing, supplier, and description.
                </div>
            </c:if>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" style="margin-bottom: 16px;">
                    ${errorMessage}
                </div>
            </c:if>

            <%-- Form card --%>
            <div class="form-card">
                <div class="form-card-header">Product Details</div>
                <div class="form-card-body">

                    <form action="${pageContext.request.contextPath}/product/${empty product.id ? 'new' : 'edit/'.concat(product.id)}"
                          method="post">

                        <c:if test="${empty product.id}">
                            <div class="section-label">Master Catalog</div>
                            <div class="form-grid">
                                <div class="form-group span-2">
                                    <label for="masterProductId">Select From Master Product <span class="required">*</span></label>
                                    <div class="select-wrapper">
                                        <select id="masterProductId" name="masterProductId" required <c:if test="${empty masterProducts}">disabled</c:if>>
                                            <option value="" disabled selected>Select a master product…</option>
                                            <c:forEach var="m" items="${masterProducts}">
                                                <option value="${m.id}"
                                                        data-name="<c:out value='${m.name}'/>"
                                                        data-category="<c:out value='${m.categoryName}'/>"
                                                        data-hsn="<c:out value='${m.hsnCode}'/>"
                                                        data-description="<c:out value='${m.description}'/>">
                                                    <c:out value="${m.name}"/>
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="field-hint">Users can create products only from the master list. Select one to auto-fill details and set store pricing.</div>
                                    <div class="field-hint" style="margin-top: 8px;">
                                        Product not listed?
                                        <a href="${pageContext.request.contextPath}/product/request-master">Request Add to Master List</a>
                                        ·
                                        <a href="${pageContext.request.contextPath}/product/my-requests">View My Requests</a>
                                    </div>
                                    <c:if test="${empty masterProducts}">
                                        <div class="alert alert-warning" style="margin-top: 10px; margin-bottom: 0;">
                                            No active master products are available right now. Submit a request to add one.
                                        </div>
                                    </c:if>
                                </div>
                            </div>

                            <div class="form-divider"></div>
                        </c:if>

                        <%-- Basic Info --%>
                        <div class="section-label">Basic Information</div>

                        <div class="form-grid">

                            <div class="form-group">
                                <label for="name">Product Name <span class="required">*</span></label>
                                <input type="text"
                                       id="name"
                                       name="name"
                                       value="${product.name}"
                                       placeholder="e.g. Wireless Mouse"
                                       required
                                        <c:if test="${not empty product.id}">readonly</c:if>
                                       autofocus>
                            </div>

                            <div class="form-group">
                                <label for="category">Category <span class="required">*</span></label>
                                <div class="select-wrapper">
                                    <select id="category" name="category.id" <c:if test="${empty product.id}">required</c:if> <c:if test="${not empty product.id}">disabled</c:if>>
                                        <option value="" disabled ${empty product.category ? 'selected' : ''}>Select a category…</option>
                                        <c:forEach var="cat" items="${categories}">
                                            <option value="${cat.id}"
                                                ${not empty product.category and product.category.id == cat.id ? 'selected' : ''}>
                                                ${cat.name}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="sku">SKU <span class="required">*</span></label>
                                <div class="sku-wrapper">
                                    <input type="text"
                                        id="sku"
                                        name="sku"
                                        value="${product.sku}"
                                        placeholder="Auto-generated"
                                        <c:if test="${not empty product.id}">readonly</c:if>
                                        required>
                                    <c:if test="${empty product.id}">
                                        <button type="button"
                                            id="generateSkuBtn"
                                            class="sku-generate-btn">
                                            ↻ Generate
                                        </button>
                                    </c:if>
                                </div>
                                 <div class="field-hint">Auto-fills</div>
                            </div>

                            <div class="form-group" style="position: relative;">
                                <label for="hsnSearch">HSN Code <span class="required">*</span></label>

                                <input type="text"
                                    id="hsnSearch"
                                    placeholder="Search HSN (e.g. laptop, mobile)"
                                    value="${product.hsn.hsnCode}"
                                    autocomplete="off"
                                    <c:if test="${empty product.id}">required</c:if>
                                    <c:if test="${not empty product.id}">readonly</c:if>>

                                <input type="hidden"
                                     id="hsnId"
                                     name="hsn.id"
                                     value="${product.hsn.id}"
                                     <c:if test="${not empty product.id}">disabled</c:if>>

                                <div id="hsnSuggestions" class="suggestions-box"></div>
                                <div class="field-hint">
                                    <c:choose>
                                        <c:when test="${not empty product.id}">Locked for master-derived products</c:when>
                                        <c:otherwise>Search and select valid HSN code</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="form-group span-2">
                                <label for="description">Description <span class="optional">optional</span></label>
                                <textarea id="description"
                                          name="description"
                                          placeholder="Brief description of this product…">${product.description}</textarea>
                            </div>

                        </div>

                        <div class="form-divider"></div>

                        <%-- Pricing & Classification --%>
                        <div class="section-label">Pricing &amp; Classification</div>

                        <div class="form-grid">

                            <div class="form-group">
                                <label for="costPrice">Cost Price <span class="required">*</span></label>
                                <div class="input-prefix-wrapper">
                                    <input type="number"
                                           id="costPrice"
                                           name="costPrice"
                                           value="${product.costPrice}"
                                           placeholder="0.00"
                                           step="0.01"
                                           min="0"
                                           required>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="sellingPrice">Selling Price <span class="required">*</span></label>
                                <div class="input-prefix-wrapper">
                                    <input type="number"
                                           id="sellingPrice"
                                           name="sellingPrice"
                                           value="${product.sellingPrice}"
                                           placeholder="0.00"
                                           step="0.01"
                                           min="0"
                                           required>
                                </div>
                                <div class="field-hint">Used to auto-fill order and invoice unit price.</div>
                            </div>

                            <div class="form-group">
                                <label for="mrp">MRP <span class="required">*</span></label>
                                <div class="input-prefix-wrapper">
                                    <input type="number"
                                           id="mrp"
                                           name="mrp"
                                           value="${product.mrp}"
                                           placeholder="0.00"
                                           step="0.01"
                                           min="0"
                                           required>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="supplier">Supplier <span class="required">*</span></label>
                                <div class="select-wrapper">
                                    <select id="supplier" name="supplier.id" required>
                                        <option value="" disabled ${empty product.supplier ? 'selected' : ''}>Select a supplier...</option>
                                        <c:forEach var="sup" items="${suppliers}">
                                            <option value="${sup.id}"
                                                ${not empty product.supplier and product.supplier.id == sup.id ? 'selected' : ''}>
                                                ${sup.name}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <c:if test="${empty suppliers}">
                                    <div class="field-hint">No suppliers found. <a href="${pageContext.request.contextPath}/supplier/new">Add a supplier first</a>.</div>
                                </c:if>
                            </div>

                        </div>

                        <div class="form-divider"></div>

                        <div class="form-actions">
                            <button type="submit" class="btn-save">
                                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
                                </svg>
                                ${empty product.id ? 'Create Product From Master' : 'Save Changes'}
                            </button>
                            <a href="${pageContext.request.contextPath}/product" class="btn-cancel">Cancel</a>
                        </div>

                    </form>
                </div>
            </div>

        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/ims-product-form.js"></script>
</body>
</html>
