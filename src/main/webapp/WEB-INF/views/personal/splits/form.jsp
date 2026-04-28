<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Split Group — Spendilizer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ims-shared.css">
    <style>
        .member-row {
            display: grid;
            grid-template-columns: 1fr 1fr auto;
            gap: 12px;
            align-items: center;
            margin-bottom: 10px;
        }
        .member-row .btn-remove-member {
            width: 32px;
            height: 32px;
            border: 1px solid var(--color-border);
            border-radius: var(--radius-md);
            background: transparent;
            color: var(--color-text-muted);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            transition: all 0.15s;
        }
        .member-row .btn-remove-member:hover {
            background: var(--color-danger-lt);
            color: var(--color-danger);
            border-color: var(--color-danger);
        }
        .member-row .spacer { width: 32px; }
        .members-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 14px;
        }
        .members-col-labels {
            display: grid;
            grid-template-columns: 1fr 1fr auto;
            gap: 12px;
            margin-bottom: 6px;
        }
        .members-col-labels span {
            font-size: 0.75rem;
            font-weight: 600;
            color: var(--color-text-muted);
        }
    </style>
</head>
<body>

<%@ include file="../../navbar.jsp" %>
<div class="container-fluid p-0">
<div class="row g-0">
<div><jsp:include page="../sidebar.jsp" /></div>
<div class="main-content">

    <div class="breadcrumb-bar">
        <a href="${pageContext.request.contextPath}/personal/splits">Split Groups</a>
        <span class="sep">›</span>
        <span class="current">New Group</span>
    </div>

    <div class="page-header">
        <h2>Create Split Group</h2>
        <div class="page-subtitle">Set up a group to track and split shared expenses</div>
    </div>

    <form action="${pageContext.request.contextPath}/personal/splits/new" method="post">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

        <%-- Group details --%>
        <div class="form-card">
            <div class="form-card-header">Group Details</div>
            <div class="form-card-body">

                <div class="form-group">
                    <label for="name">Group Name <span class="required">*</span></label>
                    <input type="text" id="name" name="name"
                           placeholder="e.g. Goa Trip, Team Dinner, Flat Expenses"
                           required autofocus>
                </div>

                <div class="form-group">
                    <label for="description">Description <span class="optional">optional</span></label>
                    <textarea id="description" name="description" rows="2"
                              placeholder="A short note about this group"></textarea>
                </div>

                <div class="form-group" style="margin-bottom:0;">
                    <label for="eventDate">Event Date <span class="optional">optional</span></label>
                    <input type="date" id="eventDate" name="eventDate">
                    <div class="field-hint">Leave blank for ongoing groups.</div>
                </div>

            </div>
        </div>

        <%-- Members --%>
        <div class="form-card" style="margin-top:16px;">
            <div class="form-card-header">
                <div style="display:flex;align-items:center;justify-content:space-between;">
                    Members
                    <button type="button" class="btn-cancel" onclick="addMemberRow()"
                            style="padding:5px 14px;font-size:0.78rem;">+ Add Member</button>
                </div>
            </div>
            <div class="form-card-body">

                <div class="field-hint" style="margin-bottom:14px;">
                    You are automatically added as the first member. Add others by name — if they have a Spendilizer account, enter their registered email to link them.
                </div>

                <div class="members-col-labels">
                    <span>Name <span style="color:var(--color-danger)">*</span></span>
                    <span>Email (optional)</span>
                    <span style="width:32px;"></span>
                </div>

                <div id="membersList">
                    <div class="member-row">
                        <input type="text" name="memberName" class="form-group"
                               style="margin:0;padding:10px 14px;border:1px solid var(--color-border);border-radius:var(--radius-md);font-size:0.86rem;font-family:inherit;width:100%;outline:none;box-sizing:border-box;"
                               placeholder="Name" required>
                        <input type="email" name="memberEmail"
                               style="padding:10px 14px;border:1px solid var(--color-border);border-radius:var(--radius-md);font-size:0.86rem;font-family:inherit;width:100%;outline:none;box-sizing:border-box;"
                               placeholder="email@example.com">
                        <span class="spacer"></span>
                    </div>
                    <div class="member-row">
                        <input type="text" name="memberName"
                               style="padding:10px 14px;border:1px solid var(--color-border);border-radius:var(--radius-md);font-size:0.86rem;font-family:inherit;width:100%;outline:none;box-sizing:border-box;"
                               placeholder="Name">
                        <input type="email" name="memberEmail"
                               style="padding:10px 14px;border:1px solid var(--color-border);border-radius:var(--radius-md);font-size:0.86rem;font-family:inherit;width:100%;outline:none;box-sizing:border-box;"
                               placeholder="email@example.com">
                        <button type="button" class="btn-remove-member" onclick="this.closest('.member-row').remove()" title="Remove">
                            <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
                            </svg>
                        </button>
                    </div>
                </div>

                <div class="form-divider"></div>

                <div class="form-actions">
                    <button type="submit" class="btn-save">
                        <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
                        </svg>
                        Create Group
                    </button>
                    <a href="${pageContext.request.contextPath}/personal/splits" class="btn-cancel">Cancel</a>
                </div>

            </div>
        </div>

    </form>

</div>
</div>
</div>

<script>
const INPUT_STYLE = 'padding:10px 14px;border:1px solid var(--color-border);border-radius:var(--radius-md);font-size:0.86rem;font-family:inherit;width:100%;outline:none;box-sizing:border-box;';

function addMemberRow() {
    const row = document.createElement('div');
    row.className = 'member-row';
    row.innerHTML = `
        <input type="text" name="memberName" style="${INPUT_STYLE}" placeholder="Name">
        <input type="email" name="memberEmail" style="${INPUT_STYLE}" placeholder="email@example.com">
        <button type="button" class="btn-remove-member" onclick="this.closest('.member-row').remove()" title="Remove">
            <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
            </svg>
        </button>
    `;
    document.getElementById('membersList').appendChild(row);
}
</script>
</body>
</html>
