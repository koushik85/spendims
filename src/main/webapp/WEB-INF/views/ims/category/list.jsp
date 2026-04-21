<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Categories — IMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/spendilizer/css/ims-shared.css">
</head>
<body>
<%@ include file="../../navbar.jsp" %>
<div class="container-fluid p-0">
    <div class="row g-0">
        <div><jsp:include page="../sidebar.jsp"/></div>

        <div class="main-content">

            <div class="page-header">
                <div>
                    <h2>Categories</h2>
                    <div class="page-subtitle">Manage product categories</div>
                </div>
                <a href="/spendilizer/category/new" class="btn-primary-custom">
                    <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/>
                    </svg>
                    Add Category
                </a>
            </div>

            <%-- Flash message --%>
            <c:if test="${not empty successMessage}">
                <div class="flash-success">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    ${successMessage}
                </div>
            </c:if>

            <%-- Search --%>
            <div class="search-bar">
                <svg class="search-icon" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35M17 11A6 6 0 115 11a6 6 0 0112 0z"/>
                </svg>
                <input type="text" id="searchInput" placeholder="Search categories…" onkeyup="filterTable('categoryTable')">
            </div>

            <div class="table-card">
                <table id="categoryTable">
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
                                <td style="color: var(--color-text-muted); width: 48px;">${loop.index + 1}</td>
                                <td style="font-weight: 500;">${cat.name}</td>
                                <td style="color: var(--color-text-muted); max-width: 320px;">
                                    <c:choose>
                                        <c:when test="${not empty cat.description}">${cat.description}</c:when>
                                        <c:otherwise><span style="font-style:italic; opacity:0.5;">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div style="display:flex; gap: 6px; align-items: center;">
                                        <a href="/spendilizer/category/edit/${cat.id}" class="btn-action btn-edit">
                                            <svg width="12" height="12" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.2">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M15.232 5.232l3.536 3.536M9 13l6.586-6.586a2 2 0 012.828 2.828L11.828 15.828a4 4 0 01-1.414.586l-3 .586.586-3a4 4 0 01.586-1.414z"/>
                                            </svg>
                                            Edit
                                        </a>
                                        <form action="/spendilizer/category/delete/${cat.id}" method="post" style="margin:0;"
                                              onsubmit="return confirm('Deactivate this category?')">
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

                        <c:if test="${empty categories}">
                            <tr>
                                <td colspan="5">
                                    <div class="empty-state">
                                        <svg width="40" height="40" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/>
                                        </svg>
                                        <p>No categories found. <a href="/spendilizer/category/new" style="color: var(--color-primary);">Add one now.</a></p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>

                <c:if test="${not empty categories}">
                    <div class="table-footer">
                        Showing <span id="visibleCount">${categories.size()}</span> of ${categories.size()} categories
                    </div>
                </c:if>
            </div>

        </div>
    </div>
</div>

</body>
</html>
