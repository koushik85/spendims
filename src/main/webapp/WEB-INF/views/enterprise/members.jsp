<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Team Members — Spendilizer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="/spendilizer/css/ims-shared.css" rel="stylesheet">
</head>
<body>
<%@ include file="../navbar.jsp" %>
<div class="container-fluid p-0">
    <div class="row g-0">
        <div><jsp:include page="../sidebar.jsp"/></div>

        <div class="main-content">

            <%-- Page Header --%>
            <div class="page-header">
                <div>
                    <h2>Team Members</h2>
                    <div class="page-subtitle">
                        ${enterprise.enterpriseName} &mdash; manage who has access to your workspace
                    </div>
                </div>
                <button type="button" class="btn-primary-custom"
                        data-bs-toggle="modal" data-bs-target="#addMemberModal">
                    <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"/>
                    </svg>
                    Add Member
                </button>
            </div>

            <%-- Flash messages --%>
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

            <%-- Members table --%>
            <div class="table-card">
                <table id="membersTable">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="m" items="${members}" varStatus="loop">
                            <tr>
                                <td class="text-muted" style="width:48px;">${loop.index + 1}</td>
                                <td class="fw-500">${m.firstName} ${m.lastName}</td>
                                <td class="text-muted">${m.email}</td>
                                <td>
                                    <span style="display:inline-flex;align-items:center;gap:6px;
                                                 background:#f0fdf9;color:#0f766e;border-radius:20px;
                                                 padding:3px 10px;font-size:0.78rem;font-weight:600;">
                                        <svg width="10" height="10" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                                        </svg>
                                        Member
                                    </span>
                                </td>
                                <td>
                                    <form action="/spendilizer/enterprise/members/remove/${m.userId}" method="post"
                                          onsubmit="return confirm('Remove ${m.firstName} from your team?')" style="margin:0;">
                                        <button type="submit" class="btn-action btn-delete">
                                            <svg width="12" height="12" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.2">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                                            </svg>
                                            Remove
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty members}">
                            <tr>
                                <td colspan="5">
                                    <div class="empty-state">
                                        <svg width="40" height="40" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
                                        </svg>
                                        <p>No team members yet. <a href="#" data-bs-toggle="modal" data-bs-target="#addMemberModal" style="color:var(--color-primary);">Add your first member.</a></p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>

                <c:if test="${not empty members}">
                    <div class="table-footer">
                        ${members.size()} team member<c:if test="${members.size() != 1}">s</c:if> in ${enterprise.enterpriseName}
                    </div>
                </c:if>
            </div>

        </div>
    </div>
</div>

<!-- ── Add Member Modal ──────────────────────────────────────── -->
<div class="modal fade" id="addMemberModal" tabindex="-1" aria-labelledby="addMemberLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width:440px;">
        <div class="modal-content" style="border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 8px 32px rgba(0,0,0,0.12);">
            <div class="modal-header" style="border-bottom:1px solid #f1f5f9;padding:20px 24px 16px;">
                <h5 class="modal-title" id="addMemberLabel"
                    style="font-size:1rem;font-weight:700;color:#0f172a;margin:0;">
                    Add team member
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="/spendilizer/enterprise/members/add" method="post">
                <div class="modal-body" style="padding:20px 24px;">
                    <p style="font-size:0.83rem;color:#64748b;margin-bottom:18px;">
                        The new member will be able to log in with the credentials you set below.
                    </p>

                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:14px;">
                        <div>
                            <label style="display:block;font-size:0.82rem;font-weight:600;color:#0f172a;margin-bottom:6px;">First name</label>
                            <input type="text" name="firstName" required
                                   placeholder="Jane"
                                   style="width:100%;padding:9px 12px;border:1px solid #e2e8f0;border-radius:8px;font-size:0.86rem;font-family:inherit;outline:none;transition:border-color .18s;">
                        </div>
                        <div>
                            <label style="display:block;font-size:0.82rem;font-weight:600;color:#0f172a;margin-bottom:6px;">Last name</label>
                            <input type="text" name="lastName" required
                                   placeholder="Smith"
                                   style="width:100%;padding:9px 12px;border:1px solid #e2e8f0;border-radius:8px;font-size:0.86rem;font-family:inherit;outline:none;transition:border-color .18s;">
                        </div>
                    </div>

                    <div style="margin-bottom:14px;">
                        <label style="display:block;font-size:0.82rem;font-weight:600;color:#0f172a;margin-bottom:6px;">Email address</label>
                        <input type="email" name="email" required
                               placeholder="jane@example.com"
                               style="width:100%;padding:9px 12px;border:1px solid #e2e8f0;border-radius:8px;font-size:0.86rem;font-family:inherit;outline:none;transition:border-color .18s;">
                    </div>

                    <div>
                        <label style="display:block;font-size:0.82rem;font-weight:600;color:#0f172a;margin-bottom:6px;">Temporary password</label>
                        <input type="password" name="password" required minlength="8"
                               placeholder="Min. 8 characters"
                               style="width:100%;padding:9px 12px;border:1px solid #e2e8f0;border-radius:8px;font-size:0.86rem;font-family:inherit;outline:none;transition:border-color .18s;">
                    </div>
                </div>
                <div class="modal-footer" style="border-top:1px solid #f1f5f9;padding:14px 24px;">
                    <button type="button" class="btn-secondary-custom" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn-primary-custom">
                        <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/>
                        </svg>
                        Add member
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
