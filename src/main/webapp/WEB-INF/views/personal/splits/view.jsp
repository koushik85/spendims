<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${group.name} — Spendilizer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ims-shared.css">
    <style>
        .balance-row { display:flex;align-items:center;justify-content:space-between;padding:10px 0;border-bottom:1px solid var(--color-border); }
        .balance-row:last-child { border-bottom:none; }
        .balance-name { font-weight:500;font-size:0.88rem; }
        .balance-amount { font-family:monospace;font-size:0.88rem;font-weight:600; }
        .bal-positive { color:var(--color-success); }
        .bal-negative { color:var(--color-danger); }
        .settle-row { display:flex;align-items:center;gap:8px;padding:9px 12px;border-radius:8px;background:var(--color-accent-lt);margin-bottom:8px;font-size:0.85rem; }
        .settle-from { font-weight:600;color:var(--color-danger); }
        .settle-to   { font-weight:600;color:var(--color-success); }
        .settle-amt  { font-family:monospace;font-weight:700;color:var(--color-primary);margin-left:auto; }
        .expense-row { display:flex;align-items:flex-start;justify-content:space-between;padding:12px 0;border-bottom:1px solid var(--color-border); }
        .expense-row:last-child { border-bottom:none; }
        .modal-overlay { display:none;position:fixed;inset:0;background:rgba(0,0,0,0.4);z-index:1000;align-items:center;justify-content:center; }
        .modal-overlay.open { display:flex; }
        .modal-box { background:#fff;border-radius:12px;padding:28px;max-width:520px;width:90%;max-height:90vh;overflow-y:auto; }
        .modal-title { font-size:1rem;font-weight:700;margin-bottom:20px; }
        .member-linked { display:inline-flex;align-items:center;gap:4px;font-size:0.7rem;color:var(--color-success);font-weight:500; }
        .member-unlinked { font-size:0.7rem;color:var(--color-text-muted); }
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
        <span class="sep">/</span>
        <span class="current"><c:out value="${group.name}"/></span>
    </div>

    <c:if test="${not empty success}">
        <div class="alert-banner" style="background:var(--color-success-lt);border-color:var(--color-success);color:var(--color-success);margin-bottom:16px;">
            <c:out value="${success}"/>
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert-banner" style="background:var(--color-danger-lt);border-color:var(--color-danger);color:var(--color-danger);margin-bottom:16px;">
            <c:out value="${error}"/>
        </div>
    </c:if>

    <div class="page-header flex">
        <div>
            <h2>
                <c:out value="${group.name}"/>
                &nbsp;
                <c:choose>
                    <c:when test="${group.status == 'ACTIVE'}"><span class="badge-pill badge-in" style="font-size:0.65rem;">ACTIVE</span></c:when>
                    <c:otherwise><span class="badge-pill badge-out" style="font-size:0.65rem;">CLOSED</span></c:otherwise>
                </c:choose>
            </h2>
            <div class="page-subtitle">
                <c:if test="${not empty group.description}"><c:out value="${group.description}"/> &nbsp;&middot;&nbsp;</c:if>
                <c:if test="${group.eventDate != null}">${group.eventDate} &nbsp;&middot;&nbsp;</c:if>
                ${members.size()} members
            </div>
        </div>
        <div style="display:flex;gap:8px;flex-wrap:wrap;">
            <c:if test="${group.status == 'ACTIVE'}">
                <%-- Any linked member can add their own expense --%>
                <c:if test="${myMember != null}">
                    <button class="btn-primary-custom" onclick="openModal('addExpenseModal')">
                        <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/>
                        </svg>
                        Add My Expense
                    </button>
                </c:if>
                <%-- Only creator can add members and close the group --%>
                <c:if test="${isCreator}">
                    <button class="btn-secondary-custom" onclick="openModal('addMemberModal')">+ Member</button>
                    <form action="${pageContext.request.contextPath}/personal/splits/${group.id}/close" method="post" style="margin:0;">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                        <button type="submit" class="btn-secondary-custom" onclick="return confirm('Close this group?')">Close Group</button>
                    </form>
                </c:if>
            </c:if>
            <c:if test="${isCreator}">
                <form action="${pageContext.request.contextPath}/personal/splits/${group.id}/delete" method="post" style="margin:0;">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <button type="submit" class="btn-secondary-custom" style="color:var(--color-danger);border-color:var(--color-danger);"
                            onclick="return confirm('Delete this group and all its data?')">Delete</button>
                </form>
            </c:if>
        </div>
    </div>

    <%-- Info banner for non-creator linked members --%>
    <c:if test="${myMember != null && !isCreator}">
        <div class="alert-banner" style="background:#f0f9ff;border-color:#bae6fd;color:#0369a1;margin-bottom:16px;">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                <path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
            You are a member of this group as <strong>${myMember.name}</strong>. You can add expenses you paid.
        </div>
    </c:if>
    <c:if test="${myMember == null}">
        <div class="alert-banner" style="background:#fafafa;border-color:var(--color-border);color:var(--color-text-muted);margin-bottom:16px;">
            You are viewing this group as a guest. Link your account to a member slot to add expenses.
        </div>
    </c:if>

    <div class="row g-3">

        <%-- Expenses column --%>
        <div class="col-12 col-lg-7">
            <div class="activity-card">
                <div class="activity-header"><span>Expenses</span></div>
                <c:choose>
                    <c:when test="${empty expenses}">
                        <div class="empty-state">
                            <svg width="36" height="36" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                            <p>No expenses yet.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="activity-body">
                        <c:forEach var="exp" items="${expenses}">
                            <div class="expense-row">
                                <div>
                                    <div style="font-weight:600;font-size:0.9rem;"><c:out value="${exp.description}"/></div>
                                    <div style="font-size:0.75rem;color:var(--color-text-muted);margin-top:3px;">
                                        Paid by <strong>${exp.paidBy.name}</strong> &middot; ${exp.expenseDate} &middot; ${exp.splitType}
                                    </div>
                                    <div style="font-size:0.75rem;color:var(--color-text-muted);margin-top:4px;">
                                        <c:forEach var="split" items="${exp.splits}" varStatus="s">
                                            ${split.member.name}: &#8377;<fmt:formatNumber value="${split.shareAmount}" pattern="#,##0.00"/>
                                            <c:if test="${!s.last}"> &middot; </c:if>
                                        </c:forEach>
                                    </div>
                                </div>
                                <div style="text-align:right;flex-shrink:0;margin-left:16px;">
                                    <div style="font-family:monospace;font-weight:700;font-size:0.95rem;">&#8377;<fmt:formatNumber value="${exp.amount}" pattern="#,##0.00"/></div>
                                    <c:if test="${group.status == 'ACTIVE'}">
                                        <form action="${pageContext.request.contextPath}/personal/splits/${group.id}/expense/${exp.id}/delete" method="post" style="margin:4px 0 0 0;">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <button type="submit" style="background:none;border:none;color:var(--color-danger);font-size:0.72rem;cursor:pointer;padding:0;"
                                                    onclick="return confirm('Delete this expense?')">Remove</button>
                                        </form>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <%-- Right column --%>
        <div class="col-12 col-lg-5">

            <div class="activity-card" style="margin-bottom:16px;">
                <div class="activity-header"><span>Balances</span></div>
                <div class="activity-body">
                <c:if test="${empty balances}">
                    <p style="text-align:center;padding:8px 0;font-size:0.85rem;color:var(--color-text-muted);margin:0;">No expenses yet.</p>
                </c:if>
                <c:forEach var="b" items="${balances}">
                    <div class="balance-row">
                        <span class="balance-name">${b.memberName}</span>
                        <div style="text-align:right;">
                            <c:choose>
                                <c:when test="${b.netBalance > 0}">
                                    <span class="balance-amount bal-positive">+&#8377;<fmt:formatNumber value="${b.netBalance}" pattern="#,##0.00"/></span>
                                    <div style="font-size:0.7rem;color:var(--color-text-muted);">gets back</div>
                                </c:when>
                                <c:when test="${b.netBalance < 0}">
                                    <span class="balance-amount bal-negative">-&#8377;<fmt:formatNumber value="${-b.netBalance}" pattern="#,##0.00"/></span>
                                    <div style="font-size:0.7rem;color:var(--color-text-muted);">owes</div>
                                </c:when>
                                <c:otherwise>
                                    <span class="balance-amount" style="color:var(--color-text-muted);">settled up</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:forEach>
                </div>
            </div>

            <div class="activity-card" style="margin-bottom:16px;">
                <div class="activity-header"><span>Suggested Settlements</span></div>
                <div class="activity-body">
                <c:choose>
                    <c:when test="${empty settlements}">
                        <p style="text-align:center;padding:8px 0;font-size:0.85rem;color:var(--color-text-muted);margin:0;">Everyone is settled up!</p>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="s" items="${settlements}">
                            <div class="settle-row">
                                <span class="settle-from"><c:out value="${s.from}"/></span>
                                <span style="color:var(--color-text-muted);">&rarr;</span>
                                <span class="settle-to"><c:out value="${s.to}"/></span>
                                <span class="settle-amt">&#8377;<fmt:formatNumber value="${s.amount}" pattern="#,##0.00"/></span>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </div>
            </div>

            <div class="activity-card">
                <div class="activity-header"><span>Members</span></div>
                <div class="activity-body">
                <c:forEach var="m" items="${members}">
                    <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--color-border);">
                        <div style="width:32px;height:32px;border-radius:50%;background:var(--color-primary-lt);color:var(--color-primary);display:flex;align-items:center;justify-content:center;font-weight:700;font-size:0.82rem;flex-shrink:0;">
                            ${fn:substring(m.name,0,1)}
                        </div>
                        <div style="flex:1;min-width:0;">
                            <div style="font-weight:500;font-size:0.85rem;">${m.name}</div>
                            <c:choose>
                                <c:when test="${m.linkedUser != null}">
                                    <span class="member-linked">
                                        <svg width="10" height="10" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
                                        </svg>
                                        Linked account
                                    </span>
                                </c:when>
                                <c:when test="${not empty m.email}">
                                    <span class="member-unlinked">${m.email} &middot; not registered</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="member-unlinked">no account</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:forEach>
                <c:if test="${isCreator}">
                    <p style="margin:12px 0 0;font-size:0.75rem;color:var(--color-text-muted);">
                        Members with a registered account are automatically linked when you add them by email.
                    </p>
                </c:if>
                </div>
            </div>

        </div>
    </div>

</div>
</div>
</div>

<%-- Add Expense Modal — paid by = current user automatically --%>
<div class="modal-overlay" id="addExpenseModal">
    <div class="modal-box">
        <div class="modal-title">Add My Expense</div>
        <p style="font-size:0.8rem;color:var(--color-text-muted);margin:0 0 16px;">
            Adding as <strong>${myMember.name}</strong> (you)
        </p>
        <form action="${pageContext.request.contextPath}/personal/splits/${group.id}/add-expense" method="post">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

            <div class="form-group">
                <label>Description <span class="required">*</span></label>
                <input type="text" name="description" placeholder="e.g. Hotel booking, Dinner" required>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Amount (&#8377;) <span class="required">*</span></label>
                    <input type="number" name="amount" step="0.01" min="0.01" required id="expenseAmount">
                </div>
                <div class="form-group">
                    <label>Date <span class="required">*</span></label>
                    <input type="date" name="expenseDate" required>
                </div>
            </div>
            <div class="form-group">
                <label>Split type <span class="required">*</span></label>
                <select name="splitType" id="splitTypeSelect" onchange="onSplitTypeChange(this.value)">
                    <option value="EQUAL">Equal split among all members</option>
                    <option value="CUSTOM">Custom amounts per member</option>
                </select>
            </div>

            <div id="customSharesSection" style="display:none;margin-bottom:16px;">
                <div class="form-group" style="margin-bottom:8px;">
                    <label>Amount per member</label>
                </div>
                <c:forEach var="m" items="${members}">
                    <div style="display:flex;align-items:center;gap:12px;margin-bottom:8px;">
                        <span style="min-width:110px;font-size:0.84rem;font-weight:500;color:var(--color-text);"><c:out value="${m.name}"/></span>
                        <input type="number" name="share_${m.id}" class="share-input"
                               step="0.01" min="0" placeholder="0.00"
                               style="width:130px;padding:8px 12px;border:1px solid var(--color-border);border-radius:var(--radius-md);font-size:0.84rem;font-family:inherit;outline:none;">
                    </div>
                </c:forEach>
                <div id="shareRemaining" style="font-size:0.78rem;margin-top:6px;"></div>
            </div>

            <div class="form-actions" style="margin-top:8px;">
                <button type="submit" class="btn-save">Add Expense</button>
                <button type="button" class="btn-cancel" onclick="closeModal('addExpenseModal')">Cancel</button>
            </div>
        </form>
    </div>
</div>

<%-- Add Member Modal (creator only) --%>
<c:if test="${isCreator}">
<div class="modal-overlay" id="addMemberModal">
    <div class="modal-box">
        <div class="modal-title">Add Member</div>
        <form action="${pageContext.request.contextPath}/personal/splits/${group.id}/add-member" method="post">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
            <div class="form-group">
                <label>Name <span class="required">*</span></label>
                <input type="text" name="name" placeholder="Member name" required>
            </div>
            <div class="form-group">
                <label>Email <span class="optional">optional</span></label>
                <input type="email" name="email" placeholder="Their Spendilizer email">
                <div class="field-hint">If they have a Spendilizer account, the group will appear in their portal automatically.</div>
            </div>
            <div class="form-actions" style="margin-top:8px;">
                <button type="submit" class="btn-save">Add Member</button>
                <button type="button" class="btn-cancel" onclick="closeModal('addMemberModal')">Cancel</button>
            </div>
        </form>
    </div>
</div>
</c:if>

<script>
function openModal(id) { document.getElementById(id).classList.add('open'); }
function closeModal(id) { document.getElementById(id).classList.remove('open'); }
document.querySelectorAll('.modal-overlay').forEach(el => {
    el.addEventListener('click', e => { if (e.target === el) el.classList.remove('open'); });
});
function onSplitTypeChange(val) {
    document.getElementById('customSharesSection').style.display = val === 'CUSTOM' ? 'block' : 'none';
}
const amtInput = document.getElementById('expenseAmount');
if (amtInput) {
    amtInput.addEventListener('input', updateRemaining);
    document.querySelectorAll('.share-input').forEach(i => i.addEventListener('input', updateRemaining));
}
function updateRemaining() {
    const total = parseFloat(document.getElementById('expenseAmount').value) || 0;
    let assigned = 0;
    document.querySelectorAll('.share-input').forEach(i => assigned += parseFloat(i.value) || 0);
    const rem = total - assigned;
    const el = document.getElementById('shareRemaining');
    if (Math.abs(rem) < 0.01) { el.textContent = 'Amounts balance correctly.'; el.style.color = 'var(--color-success)'; }
    else { el.textContent = 'Remaining: ₹' + rem.toFixed(2); el.style.color = rem < 0 ? 'var(--color-danger)' : 'var(--color-text-muted)'; }
}
</script>
</body>
</html>
