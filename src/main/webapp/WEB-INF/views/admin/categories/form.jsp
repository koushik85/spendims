<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${category.id == null ? 'New' : 'Edit'} Category — Admin</title>
    <link rel="stylesheet" href="/spendilizer/css/ims-shared.css">
</head>
<body>

<%@ include file="../../navbar.jsp" %>

<div class="container-fluid p-0">
    <div class="row g-0">
        <div><jsp:include page="../sidebar.jsp" /></div>
        <div class="main-content">

            <div class="breadcrumb-bar">
                <a href="/spendilizer/admin/categories">Categories</a>
                <span class="sep">/</span>
                <span class="current">${category.id == null ? 'New' : 'Edit'}</span>
            </div>

            <div class="page-header">
                <h2><span class="page-title-main">${category.id == null ? 'New Category' : 'Edit Category'}</span></h2>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="flash-error">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    ${errorMessage}
                </div>
            </c:if>

            <div class="form-card">
                <div class="form-card-header">${category.id == null ? 'Category Details' : 'Edit Details'}</div>
                <div class="form-card-body">
                    <c:set var="formAction" value="${category.id == null ? '/spendilizer/admin/categories/new' : '/spendilizer/admin/categories/edit/'.concat(category.id)}" />
                    <form method="post" action="${formAction}">
                        <div class="form-group">
                            <label>Name <span class="required">*</span></label>
                            <input type="text" name="name" value="${category.name}" required>
                        </div>
                        <div class="form-group">
                            <label>Description <span class="optional">(optional)</span></label>
                            <input type="text" name="description" value="${category.description}">
                        </div>
                        <div class="form-actions">
                            <button type="submit" class="btn-save">Save Category</button>
                            <a href="/spendilizer/admin/categories" class="btn-cancel">Cancel</a>
                        </div>
                    </form>
                </div>
            </div>

        </div>
    </div>
</div>

</body>
</html>
