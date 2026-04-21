<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Profile — IMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/spendilizer/css/ims-shared.css">
</head>
<body>
<%@ include file="../../navbar.jsp" %>
<div class="container-fluid p-0">
    <div class="row g-0">
        <div><jsp:include page="../sidebar.jsp"/></div>

        <div class="main-content">

            <div class="breadcrumb-bar">
                <a href="/spendilizer/dashboard">Dashboard</a>
                <span class="sep">›</span>
                <span class="current">Edit Profile</span>
            </div>

            <div class="page-header">
                <h2>
                    <span class="header-icon">
                        <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                        </svg>
                    </span>
                    Edit Profile
                </h2>
                <div class="page-subtitle">Update your personal details.</div>
            </div>

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

            <div class="form-card">
                <div class="form-card-header">Personal Details</div>
                <div class="form-card-body">
                    <form action="/spendilizer/profile/edit" method="post">

                        <div class="form-row">
                            <div class="form-group">
                                <label for="firstName">First Name <span class="required">*</span></label>
                                <input type="text" id="firstName" name="firstName"
                                       value="${profileUser.firstName}" required autofocus>
                            </div>
                            <div class="form-group">
                                <label for="lastName">Last Name</label>
                                <input type="text" id="lastName" name="lastName"
                                       value="${profileUser.lastName}">
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Email</label>
                            <input type="email" value="${profileUser.email}" disabled>
                            <div class="field-hint">Email cannot be changed.</div>
                        </div>

                        <div class="form-group">
                            <label for="pan">PAN <span class="optional">optional</span></label>
                            <input type="text" id="pan" name="pan"
                                   value="${profileUser.pan}"
                                   placeholder="e.g. ABCDE1234F"
                                   maxlength="10"
                                   style="text-transform:uppercase;">
                        </div>

                        <c:if test="${profileUser.accountType == 'ENTERPRISE_OWNER' or profileUser.accountType == 'ENTERPRISE_MEMBER'}">
                            <div class="form-group">
                                <label>Enterprise</label>
                                <input type="text" value="${profileUser.enterprise.enterpriseName}" disabled>
                                <div class="field-hint">
                                    ${profileUser.accountType == 'ENTERPRISE_OWNER' ? 'You are the owner of this enterprise.' : 'You are a member of this enterprise.'}
                                </div>
                            </div>
                        </c:if>

                        <div class="form-divider"></div>

                        <div class="form-actions">
                            <button type="submit" class="btn-save">
                                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
                                </svg>
                                Save Changes
                            </button>
                            <a href="/spendilizer/dashboard" class="btn-cancel">Cancel</a>
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
