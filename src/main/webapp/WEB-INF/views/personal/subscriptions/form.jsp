<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${editMode ? 'Edit' : 'Add'} Subscription — Spendilizer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/spendilizer/css/ims-shared.css">
</head>
<body>

<%@ include file="../../navbar.jsp" %>
<div class="container-fluid p-0">
<div class="row g-0">
<div><jsp:include page="../sidebar.jsp" /></div>
<div class="main-content">

    <div class="breadcrumb-bar">
        <a href="/spendilizer/personal/subscriptions">Subscriptions</a>
        <span class="sep">›</span>
        <span class="current">${editMode ? 'Edit' : 'Add'}</span>
    </div>

    <div class="page-header">
        <h2>${editMode ? 'Edit Subscription' : 'Add Subscription'}</h2>
        <div class="page-subtitle">${editMode ? 'Update the subscription details below.' : 'Track a new recurring payment.'}</div>
    </div>

    <c:set var="formAction" value="${editMode
        ? '/spendilizer/personal/subscriptions/'.concat(subscription.id).concat('/edit')
        : '/spendilizer/personal/subscriptions/new'}"/>

    <div class="form-card">
        <div class="form-card-header">Subscription Details</div>
        <div class="form-card-body">

            <form action="${formAction}" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

                <div class="form-row">
                    <div class="form-group">
                        <label for="name">Service Name <span class="required">*</span></label>
                        <input type="text" id="name" name="name"
                               value="${subscription.name}"
                               placeholder="e.g. Netflix, Spotify, AWS"
                               required>
                    </div>
                    <div class="form-group">
                        <label for="provider">Provider <span class="optional">optional</span></label>
                        <input type="text" id="provider" name="provider"
                               value="${subscription.provider}"
                               placeholder="Company or brand name">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="amount">Amount (&#8377;) <span class="required">*</span></label>
                        <input type="number" id="amount" name="amount"
                               value="${subscription.amount}"
                               step="0.01" min="0.01" required
                               placeholder="0.00">
                    </div>
                    <div class="form-group">
                        <label for="billingCycle">Billing Cycle <span class="required">*</span></label>
                        <div class="select-wrapper">
                            <select id="billingCycle" name="billingCycle" required>
                                <c:forEach var="c" items="${cycles}">
                                    <option value="${c}" ${subscription.billingCycle == c ? 'selected' : ''}>${c}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="startDate">Start Date <span class="required">*</span></label>
                        <input type="date" id="startDate" name="startDate"
                               value="${subscription.startDate}" required>
                    </div>
                    <div class="form-group">
                        <label for="nextBillingDate">Next Billing Date <span class="required">*</span></label>
                        <input type="date" id="nextBillingDate" name="nextBillingDate"
                               value="${subscription.nextBillingDate}" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="category">Category <span class="required">*</span></label>
                        <div class="select-wrapper">
                            <select id="category" name="category" required>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat}" ${subscription.category == cat ? 'selected' : ''}>${cat}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    <c:if test="${editMode}">
                        <div class="form-group">
                            <label for="status">Status <span class="required">*</span></label>
                            <div class="select-wrapper">
                                <select id="status" name="status" required>
                                    <c:forEach var="st" items="${statuses}">
                                        <option value="${st}" ${subscription.status == st ? 'selected' : ''}>${st}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                    </c:if>
                </div>

                <div class="form-group">
                    <label for="notes">Notes <span class="optional">optional</span></label>
                    <textarea id="notes" name="notes" rows="2"
                              placeholder="Anything to remember about this subscription"><c:out value="${subscription.notes}"/></textarea>
                </div>

                <div class="form-divider"></div>

                <div class="form-actions">
                    <button type="submit" class="btn-save">
                        <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
                        </svg>
                        ${editMode ? 'Save Changes' : 'Add Subscription'}
                    </button>
                    <a href="/spendilizer/personal/subscriptions" class="btn-cancel">Cancel</a>
                </div>

            </form>
        </div>
    </div>

</div>
</div>
</div>
</body>
</html>
