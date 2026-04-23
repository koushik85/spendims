<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enterprises — Admin</title>
    <link rel="stylesheet" href="/spendilizer/css/ims-shared.css">
</head>
<body>

<%@ include file="../navbar.jsp" %>

<div class="container-fluid p-0">
    <div class="row g-0">
        <div><jsp:include page="sidebar.jsp" /></div>
        <div class="main-content">

            <div class="page-header flex">
                <div>
                    <h2><span class="page-title-main">Enterprises</span></h2>
                    <div class="page-subtitle">Approve or reject business account registrations.</div>
                </div>
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
                            <th>Business Name</th>
                            <th>Owner</th>
                            <th>Email</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="e" items="${enterprises}">
                            <tr>
                                <td>${e.enterpriseName}</td>
                                <td>${e.owner.firstName} ${e.owner.lastName}</td>
                                <td>${e.owner.email}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${e.approvalStatus == 'PENDING'}"><span class="badge-pending">Pending</span></c:when>
                                        <c:when test="${e.approvalStatus == 'APPROVED'}"><span class="badge-approved">Approved</span></c:when>
                                        <c:otherwise><span class="badge-rejected">Rejected</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:if test="${e.approvalStatus == 'PENDING'}">
                                        <div class="flex-gap-6">
                                            <form method="post" action="/spendilizer/admin/enterprises/${e.enterpriseId}/approve">
                                                <button class="btn-action btn-adjust-plus">Approve</button>
                                            </form>
                                            <form method="post" action="/spendilizer/admin/enterprises/${e.enterpriseId}/reject">
                                                <button class="btn-action btn-delete">Reject</button>
                                            </form>
                                        </div>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty enterprises}">
                            <tr><td colspan="5" style="text-align:center;padding:40px;color:var(--color-text-muted);">No enterprises registered yet.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

        </div>
    </div>
</div>

</body>
</html>
