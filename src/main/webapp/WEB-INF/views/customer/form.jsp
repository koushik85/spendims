<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>${empty customer.id ? 'Add Customer' : 'Edit Customer'} — IMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="/spendilizer/css/ims-shared.css" rel="stylesheet">
</head>
<body>
<%@ include file="../navbar.jsp" %>
<div class="container-fluid p-0">
    <div class="row g-0">
        <div><jsp:include page="../sidebar.jsp"/></div>
        <div class="main-content">

            <div class="breadcrumb-bar">
                <a href="/spendilizer/dashboard">Dashboard</a>
                <span class="sep">›</span>
                <a href="/spendilizer/customer">Customers</a>
                <span class="sep">›</span>
                <span class="current">${empty customer.id ? 'New Customer' : 'Edit Customer'}</span>
            </div>

            <div class="page-header with-icon">
                <h2>${empty customer.id ? 'Add New Customer' : 'Edit Customer'}</h2>
                <div class="page-subtitle">
                    ${empty customer.id ? 'Register a new customer.' : 'Update customer details.'}
                </div>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="flash-error" style="margin-left:40px;margin-right:8px;margin-bottom:16px;">
                    ${errorMessage}
                </div>
            </c:if>

            <c:if test="${not empty customer.id}">
                <div class="edit-mode-banner">
                    Editing: <strong>${customer.displayName}</strong> &nbsp;·&nbsp; ID: ${customer.id}
                </div>
            </c:if>

            <div class="form-card">
                <div class="form-card-header">Customer Details</div>
                <div class="form-card-body">
                    <form action="/spendilizer/customer/${empty customer.id ? 'new' : 'edit/'.concat(customer.id)}" method="post">

                        <div class="form-row">
                            <div class="form-group">
                                <label for="firstName">First Name <span class="required">*</span></label>
                                <input type="text" id="firstName" name="firstName" value="${customer.firstName}"
                                       placeholder="e.g. Rahul" required autofocus>
                            </div>
                            <div class="form-group">
                                <label for="lastName">Last Name <span class="optional">optional</span></label>
                                <input type="text" id="lastName" name="lastName" value="${customer.lastName}"
                                       placeholder="e.g. Sharma">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="companyName">Company Name <span class="optional">optional</span></label>
                            <input type="text" id="companyName" name="companyName" value="${customer.companyName}"
                                   placeholder="e.g. Acme Pvt. Ltd.">
                            <div class="field-hint">Used as display name when filled.</div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="email">Email <span class="required">*</span></label>
                                <input type="email" id="email" name="email" value="${customer.email}"
                                       placeholder="customer@example.com" required>
                                <div class="field-hint">Must be unique.</div>
                            </div>
                            <div class="form-group">
                                <label for="phone">Phone <span class="optional">optional</span></label>
                                <input type="tel" id="phone" name="phone" value="${customer.phone}"
                                       placeholder="+91 98765 43210">
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="gstin">GSTIN <span class="optional">optional</span></label>
                                <input type="text" id="gstin" name="gstin" value="${customer.gstin}"
                                       maxlength="15" placeholder="e.g. 29AAAAA0000A1Z5">
                            </div>
                            <div class="form-group">
                                <label for="pan">PAN <span class="optional">optional</span></label>
                                <input type="text" id="pan" name="pan" value="${customer.pan}"
                                       maxlength="10" placeholder="e.g. AAAAA0000A">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="billingAddress">Billing Address <span class="optional">optional</span></label>
                            <textarea id="billingAddress" name="billingAddress" rows="3"
                                      placeholder="Street, City, State, PIN…">${customer.billingAddress}</textarea>
                        </div>

                        <div class="form-group">
                            <label for="shippingAddress">Shipping Address <span class="optional">optional</span></label>
                            <textarea id="shippingAddress" name="shippingAddress" rows="3"
                                      placeholder="Leave blank if same as billing…">${customer.shippingAddress}</textarea>
                        </div>

                        <div class="form-group">
                            <label for="notes">Notes <span class="optional">optional</span></label>
                            <textarea id="notes" name="notes" rows="2"
                                      placeholder="Any internal notes…">${customer.notes}</textarea>
                        </div>

                        <c:if test="${not empty customer.id}">
                            <div class="form-group">
                                <label for="rowStatus">Status <span class="required">*</span></label>
                                <div class="select-wrapper">
                                    <select id="rowStatus" name="rowStatus">
                                        <c:forEach var="s" items="${statuses}">
                                            <option value="${s}" ${customer.rowStatus == s ? 'selected' : ''}>${s}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                        </c:if>

                        <div class="form-divider"></div>
                        <div class="form-actions">
                            <button type="submit" class="btn-save">
                                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
                                </svg>
                                ${empty customer.id ? 'Create Customer' : 'Save Changes'}
                            </button>
                            <a href="/spendilizer/customer" class="btn-cancel">Cancel</a>
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
