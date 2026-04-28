<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Categories — Admin</title>
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
                    <h2><span class="page-title-main">Categories</span></h2>
                    <div class="page-subtitle">Global categories visible to all users.</div>
                </div>
                <a href="${pageContext.request.contextPath}/admin/categories/new" class="btn-primary-custom">
                    <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/>
                    </svg>
                    Add Category
                </a>
            </div>

            <c:if test="${not empty successMessage}">
                <div class="flash-success">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    ${successMessage}
                </div>
            </c:if>

            <div class="table-card">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Name</th>
                            <th>Description</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="cat" items="${categories}" varStatus="loop">
                            <tr>
                                <td class="col-index">${loop.index + 1}</td>
                                <td style="font-weight:500;">${cat.name}</td>
                                <td class="text-muted">${cat.description}</td>
                                <td>
                                    <div class="flex-gap-6">
                                        <a href="${pageContext.request.contextPath}/admin/categories/edit/${cat.id}" class="btn-action btn-edit">Edit</a>
                                        <form method="post" action="${pageContext.request.contextPath}/admin/categories/delete/${cat.id}"
                                              onsubmit="return confirm('Deactivate this category?')">
                                            <button class="btn-action btn-delete">Delete</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty categories}">
                            <tr><td colspan="5" style="text-align:center;padding:40px;color:var(--color-text-muted);">No categories yet. Add one above.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

        </div>
    </div>
</div>

</body>
</html>
