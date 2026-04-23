<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>${empty category.id ? 'Add Category' : 'Edit Category'} — IMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/spendilizer/css/ims-shared.css">
</head>
<body>
<%@ include file="../../navbar.jsp" %>
<div class="container-fluid p-0">
    <div class="row g-0">
        <div><jsp:include page="../sidebar.jsp"/></div>

        <div class="main-content">

            <%-- Breadcrumb --%>
            <div class="breadcrumb-bar">
                <a href="/spendilizer/dashboard">Dashboard</a>
                <span class="sep">›</span>
                <a href="/spendilizer/category">Categories</a>
                <span class="sep">›</span>
                <span class="current">${empty category.id ? 'New Category' : 'Edit Category'}</span>
            </div>

            <%-- Page header --%>
            <div class="page-header">
                <h2>
                    <span class="header-icon">
                        <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/>
                        </svg>
                    </span>
                    ${empty category.id ? 'Add New Category' : 'Edit Category'}
                </h2>
                <div class="page-subtitle">
                    ${empty category.id ? 'Fill in the details to create a new category.' : 'Update the category details below.'}
                </div>
            </div>

            <%-- Edit mode banner --%>
            <c:if test="${not empty category.id}">
                <div class="edit-mode-banner">
                    <svg width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M12 2a10 10 0 100 20A10 10 0 0012 2z"/>
                    </svg>
                    Editing: <strong>${category.name}</strong> &nbsp;·&nbsp; ID: ${category.id}
                </div>
            </c:if>

            <%-- Error message --%>
            <c:if test="${not empty errorMessage}">
                <div class="flash-error">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    ${errorMessage}
                </div>
            </c:if>

            <%-- Form card --%>
            <div class="form-card">
                <div class="form-card-header">Category Details</div>
                <div class="form-card-body">

                    <form action="/spendilizer/category/${empty category.id ? 'new' : 'edit/'.concat(category.id)}"
                          method="post">

                        <div class="form-group">
                            <label for="name">
                                Category Name <span class="required">*</span>
                            </label>
                            <input type="text"
                                   id="name"
                                   name="name"
                                   value="${category.name}"
                                   placeholder="e.g. Electronics, Office Supplies…"
                                   required
                                   autofocus>
                            <div class="field-hint">Must be unique. Used to group products.</div>
                        </div>

                        <div class="form-group">
                            <label for="description">
                                Description <span class="optional">optional</span>
                            </label>
                            <textarea id="description"
                                      name="description"
                                      placeholder="Brief description of this category…">${category.description}</textarea>
                        </div>

                        <div class="form-divider"></div>

                        <div class="form-actions">
                            <button type="submit" class="btn-save">
                                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
                                </svg>
                                ${empty category.id ? 'Create Category' : 'Save Changes'}
                            </button>
                            <a href="/spendilizer/category" class="btn-cancel">
                                Cancel
                            </a>
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
