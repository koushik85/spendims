<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${masterProduct.id == null ? 'New' : 'Edit'} Master Product — Admin</title>
    <link rel="stylesheet" href="/spendilizer/css/ims-shared.css">
</head>
<body>

<%@ include file="../../navbar.jsp" %>

<div class="container-fluid p-0">
    <div class="row g-0">
        <div><jsp:include page="../sidebar.jsp" /></div>
        <div class="main-content">

            <div class="breadcrumb-bar">
                <a href="/spendilizer/admin/master-products">Master Products</a>
                <span class="sep">/</span>
                <span class="current">${masterProduct.id == null ? 'New' : 'Edit'}</span>
            </div>

            <div class="page-header">
                <h2><span class="page-title-main">${masterProduct.id == null ? 'New Master Product' : 'Edit Master Product'}</span></h2>
            </div>

            <div class="form-card wide">
                <div class="form-card-header">${masterProduct.id == null ? 'Product Details' : 'Edit Details'}</div>
                <div class="form-card-body">
                    <c:set var="formAction" value="${masterProduct.id == null ? '/spendilizer/admin/master-products/new' : '/spendilizer/admin/master-products/edit/'.concat(masterProduct.id)}" />
                    <form method="post" action="${formAction}">
                        <div class="form-row">
                            <div class="form-group">
                                <label>Product Name <span class="required">*</span></label>
                                <input type="text" name="name" value="${masterProduct.name}" required>
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label>Category <span class="required">*</span></label>
                                <input type="text" name="categoryName" value="${masterProduct.categoryName}" required>
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label>HSN Code <span class="required">*</span></label>
                                <input type="text" name="hsnCode" value="${masterProduct.hsnCode}" required>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Description <span class="optional">(optional)</span></label>
                            <textarea name="description">${masterProduct.description}</textarea>
                        </div>
                        <div class="form-actions">
                            <button type="submit" class="btn-save">Save Product</button>
                            <a href="/spendilizer/admin/master-products" class="btn-cancel">Cancel</a>
                        </div>
                    </form>
                </div>
            </div>

        </div>
    </div>
</div>

</body>
</html>
