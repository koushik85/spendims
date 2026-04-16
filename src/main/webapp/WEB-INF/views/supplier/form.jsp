<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>${empty supplier.id ? 'Add Supplier' : 'Edit Supplier'} — IMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="/spendilizer/css/ims-shared.css" rel="stylesheet">
</head>
<body>
<%@ include file="../navbar.jsp" %>
<div class="container-fluid p-0">
    <div class="row g-0">
        <div><jsp:include page="../sidebar.jsp"/></div>

        <div class="main-content">

            <%-- Breadcrumb --%>
            <div class="breadcrumb-bar">
                <a href="/spendilizer/dashboard">Dashboard</a>
                <span class="sep">›</span>
                <a href="/spendilizer/supplier">Suppliers</a>
                <span class="sep">›</span>
                <span class="current">${empty supplier.id ? 'New Supplier' : 'Edit Supplier'}</span>
            </div>

            <%-- Page Header --%>
            <div class="page-header with-icon">
                <h2>
                    <span class="header-icon">
                        <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a4 4 0 00-4-4H6a4 4 0 00-4 4v2h5M12 12a4 4 0 100-8 4 4 0 000 8z"/>
                        </svg>
                    </span>
                    ${empty supplier.id ? 'Add New Supplier' : 'Edit Supplier'}
                </h2>
                <div class="page-subtitle">
                    ${empty supplier.id ? 'Fill in the details to register a new supplier.' : 'Update the supplier details below.'}
                </div>
            </div>

            <%-- Edit mode banner --%>
            <c:if test="${not empty supplier.id}">
                <div class="edit-mode-banner">
                    <svg width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M12 2a10 10 0 100 20A10 10 0 0012 2z"/>
                    </svg>
                    Editing: <strong>${supplier.name}</strong> &nbsp;·&nbsp; ID: ${supplier.id}
                </div>
            </c:if>

            <%-- Form Card --%>
            <div class="form-card">
                <div class="form-card-header">Supplier Details</div>
                <div class="form-card-body">

                    <form action="/spendilizer/supplier/${empty supplier.id ? 'new' : 'edit/'.concat(supplier.id)}"
                          method="post">

                        <%-- Name + Email (side by side) --%>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="name">
                                    Supplier Name <span class="required">*</span>
                                </label>
                                <input type="text"
                                       id="name"
                                       name="name"
                                       value="${supplier.name}"
                                       placeholder="e.g. Acme Corp"
                                       required
                                       autofocus>
                            </div>

                            <div class="form-group">
                                <label for="email">
                                    Email <span class="required">*</span>
                                </label>
                                <input type="email"
                                       id="email"
                                       name="email"
                                       value="${supplier.email}"
                                       placeholder="contact@supplier.com"
                                       required>
                                <div class="field-hint">Must be unique across all suppliers.</div>
                            </div>
                        </div>

                        <%-- Phone --%>
                        <div class="form-group">
                            <label for="phone">
                                Phone <span class="optional">optional</span>
                            </label>
                            <input type="tel"
                                   id="phone"
                                   name="phone"
                                   value="${supplier.phone}"
                                   placeholder="e.g. +91 98765 43210">
                        </div>

                        <%-- Address --%>
                        <div class="form-group">
                            <label for="address">
                                Address <span class="optional">optional</span>
                            </label>
                            <textarea id="address"
                                      name="address"
                                      placeholder="Street, City, State, PIN…">${supplier.address}</textarea>
                        </div>

                        <%-- Status (edit only) --%>
                        <c:if test="${not empty supplier.id}">
                            <div class="form-group">
                                <label for="rowStatus">Status <span class="required">*</span></label>
                                <div class="select-wrapper">
                                    <select id="rowStatus" name="rowStatus">
                                        <c:forEach var="s" items="${statuses}">
                                            <option value="${s}" ${supplier.rowStatus == s ? 'selected' : ''}>${s}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="field-hint">Inactive suppliers won't appear in purchase forms.</div>
                            </div>
                        </c:if>

                        <div class="form-divider"></div>

                        <div class="form-actions">
                            <button type="submit" class="btn-save">
                                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
                                </svg>
                                ${empty supplier.id ? 'Create Supplier' : 'Save Changes'}
                            </button>
                            <a href="/spendilizer/supplier" class="btn-cancel">Cancel</a>
                        </div>

                    </form>
                </div>
            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
