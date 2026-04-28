<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Subscriptions — Spendilizer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ims-shared.css">
    <style>
        .sub-card { background:#fff;border:1px solid var(--color-border);border-radius:var(--radius-lg);padding:20px;transition:box-shadow 0.18s;height:100%; }
        .sub-card:hover { box-shadow:var(--shadow-md); }
        .sub-name { font-weight:700;font-size:0.95rem; }
        .sub-provider { font-size:0.75rem;color:var(--color-text-muted); }
        .sub-amount { font-family:monospace;font-weight:700;font-size:1.1rem;color:var(--color-primary); }
        .sub-cycle { font-size:0.72rem;color:var(--color-text-muted); }
        .sub-due { font-size:0.75rem;font-weight:500; }
        .cat-badge { display:inline-block;padding:2px 8px;border-radius:20px;font-size:0.68rem;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;background:var(--color-primary-lt);color:var(--color-primary); }
        .status-badge-active { background:var(--color-success-lt);color:var(--color-success); }
        .status-badge-paused { background:var(--color-warning-lt);color:var(--color-warning); }
        .status-badge-cancelled { background:#f1f5f9;color:#94a3b8; }
        .sub-actions { display:flex;gap:6px;margin-top:14px;flex-wrap:wrap; }
        .sub-actions form { margin:0; }
        .sub-actions button, .sub-actions a {
            font-size:0.72rem;padding:4px 10px;
            border-radius:5px;border:1px solid var(--color-border);
            background:transparent;color:var(--color-text-muted);
            cursor:pointer;text-decoration:none;font-family:inherit;
            transition:all 0.15s;
        }
        .sub-actions button:hover, .sub-actions a:hover { background:var(--color-bg); }
        .summary-strip { background:#fff;border:1px solid var(--color-border);border-radius:var(--radius-lg);padding:16px 24px;margin-bottom:24px;margin-left:40px;display:flex;gap:32px;align-items:center; }
        .ss-item { display:flex;flex-direction:column; }
        .ss-val { font-family:monospace;font-size:1.15rem;font-weight:700;color:var(--color-text); }
        .ss-lbl { font-size:0.72rem;color:var(--color-text-muted);text-transform:uppercase;letter-spacing:0.5px; }
    </style>
</head>
<body>

<%@ include file="../../navbar.jsp" %>
<div class="container-fluid p-0">
<div class="row g-0">
<div><jsp:include page="../sidebar.jsp" /></div>
<div class="main-content">

    <div class="page-header flex">
        <div>
            <h2>Subscriptions</h2>
            <div class="page-subtitle">Track your recurring payments</div>
        </div>
        <a href="${pageContext.request.contextPath}/personal/subscriptions/new" class="btn-primary-custom">
            <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/>
            </svg>
            Add Subscription
        </a>
    </div>

    <c:if test="${not empty success}">
        <div class="alert-banner" style="background:var(--color-success-lt);border-color:var(--color-success);color:var(--color-success);">
            <c:out value="${success}"/>
        </div>
    </c:if>

    <%-- Renewal notifications --%>
    <c:if test="${not empty notifications}">
        <div style="margin-left:40px;margin-bottom:20px;background:#fefce8;border:1px solid #fde047;border-radius:var(--radius-lg);padding:14px 18px;">
            <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;">
                <div style="display:flex;align-items:center;gap:8px;font-weight:600;font-size:0.82rem;color:#854d0e;">
                    <svg width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
                    </svg>
                    Upcoming Renewals
                </div>
                <form action="${pageContext.request.contextPath}/personal/subscriptions/notifications/dismiss-all" method="post" style="margin:0;">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <button type="submit" style="font-size:0.72rem;background:none;border:1px solid #fde047;border-radius:5px;padding:3px 10px;color:#854d0e;cursor:pointer;">Dismiss all</button>
                </form>
            </div>
            <div style="display:flex;flex-direction:column;gap:6px;">
                <c:forEach var="n" items="${notifications}">
                    <div style="display:flex;align-items:center;justify-content:space-between;background:#fff;border:1px solid #fde047;border-radius:8px;padding:8px 14px;">
                        <div style="font-size:0.82rem;color:#78350f;">
                            <strong><c:out value="${n.subscription.name}"/></strong>
                            renews in
                            <c:choose>
                                <c:when test="${n.daysUntilDue == 0}"><strong style="color:#dc2626;">today</strong></c:when>
                                <c:when test="${n.daysUntilDue == 1}"><strong style="color:#dc2626;">1 day</strong></c:when>
                                <c:otherwise><strong>${n.daysUntilDue} days</strong></c:otherwise>
                            </c:choose>
                            &nbsp;·&nbsp; <span style="font-family:monospace;">&#8377;<fmt:formatNumber value="${n.subscription.amount}" pattern="#,##0.00"/></span>
                            &nbsp;·&nbsp; <span style="color:var(--color-text-muted);">${n.subscription.nextBillingDate}</span>
                        </div>
                        <form action="${pageContext.request.contextPath}/personal/subscriptions/notifications/${n.id}/remove" method="post" style="margin:0;">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                            <button type="submit" title="Dismiss" style="background:none;border:none;cursor:pointer;color:#a16207;font-size:1rem;line-height:1;padding:0 4px;">&#x2715;</button>
                        </form>
                    </div>
                </c:forEach>
            </div>
        </div>
    </c:if>

    <%-- Summary strip --%>
    <c:if test="${activeCount > 0}">
        <div class="summary-strip">
            <div class="ss-item">
                <span class="ss-val">${activeCount}</span>
                <span class="ss-lbl">Active</span>
            </div>
            <div class="ss-item">
                <span class="ss-val">&#8377;<fmt:formatNumber value="${monthlyCost}" pattern="#,##0.00"/></span>
                <span class="ss-lbl">Monthly cost</span>
            </div>
            <div class="ss-item">
                <span class="ss-val">&#8377;<fmt:formatNumber value="${monthlyCost * 12}" pattern="#,##0"/></span>
                <span class="ss-lbl">Yearly estimate</span>
            </div>
        </div>
    </c:if>

    <c:choose>
        <c:when test="${empty subscriptions}">
            <div class="activity-card">
                <div class="empty-state">
                    <svg width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                    </svg>
                    <p>No subscriptions yet.</p>
                    <a href="${pageContext.request.contextPath}/personal/subscriptions/new" class="btn-primary-custom">Add your first subscription</a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div style="margin-left:40px;">
            <div class="row g-3">
                <c:forEach var="s" items="${subscriptions}">
                    <div class="col-12 col-md-6 col-lg-4">
                        <div class="sub-card">
                            <div style="display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:6px;">
                                <div>
                                    <div class="sub-name"><c:out value="${s.name}"/></div>
                                    <c:if test="${not empty s.provider}">
                                        <div class="sub-provider"><c:out value="${s.provider}"/></div>
                                    </c:if>
                                </div>
                                <span class="cat-badge
                                    <c:choose>
                                        <c:when test="${s.status == 'ACTIVE'}">status-badge-active</c:when>
                                        <c:when test="${s.status == 'PAUSED'}">status-badge-paused</c:when>
                                        <c:otherwise>status-badge-cancelled</c:otherwise>
                                    </c:choose>">${s.status}</span>
                            </div>

                            <div style="display:flex;align-items:baseline;gap:6px;margin:10px 0 4px;">
                                <span class="sub-amount">&#8377;<fmt:formatNumber value="${s.amount}" pattern="#,##0.00"/></span>
                                <span class="sub-cycle">/ ${s.billingCycle}</span>
                            </div>

                            <div style="display:flex;gap:10px;align-items:center;">
                                <span class="cat-badge">${s.category}</span>
                                <span class="sub-due" style="color:${s.status == 'ACTIVE' ? 'var(--color-text-muted)' : '#94a3b8'};">
                                    Next: ${s.nextBillingDate}
                                </span>
                            </div>

                            <div class="sub-actions">
                                <a href="${pageContext.request.contextPath}/personal/subscriptions/${s.id}/edit">Edit</a>
                                <c:if test="${s.status == 'ACTIVE'}">
                                    <form action="${pageContext.request.contextPath}/personal/subscriptions/${s.id}/status" method="post">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <input type="hidden" name="status" value="PAUSED">
                                        <button type="submit">Pause</button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/personal/subscriptions/${s.id}/status" method="post">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <input type="hidden" name="status" value="CANCELLED">
                                        <button type="submit" onclick="return confirm('Cancel this subscription?')">Cancel</button>
                                    </form>
                                </c:if>
                                <c:if test="${s.status == 'PAUSED' || s.status == 'CANCELLED'}">
                                    <form action="${pageContext.request.contextPath}/personal/subscriptions/${s.id}/status" method="post">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <input type="hidden" name="status" value="ACTIVE">
                                        <button type="submit" style="color:var(--color-success);border-color:var(--color-success);">Reactivate</button>
                                    </form>
                                </c:if>
                                <form action="${pageContext.request.contextPath}/personal/subscriptions/${s.id}/delete" method="post">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                    <button type="submit" style="color:var(--color-danger);border-color:var(--color-danger);"
                                            onclick="return confirm('Delete this subscription?')">Delete</button>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
            </div>
        </c:otherwise>
    </c:choose>

</div>
</div>
</div>
</body>
</html>
