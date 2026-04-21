<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>${empty invoice.id ? 'New Invoice' : 'Edit Invoice'} — IMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="/spendilizer/css/ims-shared.css" rel="stylesheet">
</head>
<body>
<%@ include file="../../navbar.jsp" %>

<%-- Product data as JSON — safe, no DOM-parsing fragility --%>
<script>
const PRODUCTS = [
    <c:forEach var="p" items="${products}" varStatus="loop">
    { id: "${p.id}", name: "<c:out value="${p.name}"/>", sku: "<c:out value="${p.sku}"/>", price: ${p.sellingPrice}, hsn: "<c:out value="${not empty p.hsn ? p.hsn.hsnCode : ''}"/>" }<c:if test="${!loop.last}">,</c:if>
    </c:forEach>
];

function buildProductSelect(selectedId, rowIdx) {
    let html = '<select name="itemProductId" onchange="onProductChange(this,' + rowIdx + ')">';
    html += '<option value="">— Select product —</option>';
    for (const p of PRODUCTS) {
        const sel = (selectedId && String(p.id) === String(selectedId)) ? ' selected' : '';
        html += '<option value="' + p.id + '" data-price="' + p.price + '" data-hsn="' + p.hsn + '"' + sel + '>'
              + p.name + ' (' + p.sku + ')</option>';
    }
    html += '</select>';
    return html;
}
</script>

<div class="container-fluid p-0">
    <div class="row g-0">
        <div><jsp:include page="../sidebar.jsp"/></div>
        <div class="main-content">

            <div class="breadcrumb-bar">
                <a href="/spendilizer/dashboard">Dashboard</a>
                <span class="sep">›</span>
                <a href="/spendilizer/invoice">Invoices</a>
                <span class="sep">›</span>
                <span class="current">${empty invoice.id ? 'New Invoice' : 'Edit Invoice'}</span>
            </div>

            <div class="page-header with-icon">
                <h2>${empty invoice.id ? 'Create Invoice' : 'Edit Invoice'}</h2>
                <div class="page-subtitle">
                    ${empty invoice.id ? 'Fill in customer, dates, and line items.' : 'Update the draft invoice.'}
                </div>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="flash-error" style="margin-left:40px;margin-right:8px;margin-bottom:16px;">${errorMessage}</div>
            </c:if>

            <form action="/spendilizer/invoice/${empty invoice.id ? 'new' : 'edit/'.concat(invoice.id)}" method="post" id="invoiceForm">

                <div class="form-card">
                    <div class="form-card-header">Invoice Details</div>
                    <div class="form-card-body">

                        <div class="form-row">
                            <div class="form-group">
                                <label for="customerId">Customer <span class="required">*</span></label>
                                <div class="select-wrapper">
                                    <select id="customerId" name="customer.id" required>
                                        <option value="">— Select Customer —</option>
                                        <c:forEach var="cust" items="${customers}">
                                            <option value="${cust.id}"
                                                    data-billing="${cust.billingAddress}"
                                                    data-shipping="${cust.shippingAddress}"
                                                    data-gstin="${cust.gstin}"
                                                ${invoice.customer != null && invoice.customer.id == cust.id ? 'selected' : ''}>
                                                <c:out value="${cust.displayName}"/>
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="salesOrderId">Linked Order <span class="optional">optional</span></label>
                                <div class="select-wrapper">
                                    <select id="salesOrderId" name="salesOrder.id">
                                        <option value="">— None —</option>
                                        <c:forEach var="ord" items="${orders}">
                                            <option value="${ord.id}"
                                                ${invoice.salesOrder != null && invoice.salesOrder.id == ord.id ? 'selected' : ''}>
                                                <c:out value="${ord.orderNumber}"/> — <c:out value="${ord.customer.displayName}"/>
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="invoiceDate">Invoice Date <span class="required">*</span></label>
                                <input type="date" id="invoiceDate" name="invoiceDate"
                                       value="${not empty invoice.invoiceDate ? invoice.invoiceDate : ''}" required>
                            </div>
                            <div class="form-group">
                                <label for="dueDate">Due Date <span class="optional">optional</span></label>
                                <input type="date" id="dueDate" name="dueDate"
                                       value="${not empty invoice.dueDate ? invoice.dueDate : ''}">
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="paymentMode">Payment Mode <span class="required">*</span></label>
                                <div class="select-wrapper">
                                    <select id="paymentMode" name="paymentMode" required>
                                        <c:forEach var="mode" items="${paymentModes}">
                                            <option value="${mode}" ${invoice.paymentMode == mode ? 'selected' : ''}>
                                                ${mode.label}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="customerGstin">Customer GSTIN <span class="optional">optional</span></label>
                                <input type="text" id="customerGstin" name="customerGstin"
                                       value="${invoice.customerGstin}" maxlength="15" placeholder="29AAAAA0000A1Z5">
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="billingAddress">Billing Address <span class="optional">optional</span></label>
                                <textarea id="billingAddress" name="billingAddress" rows="2">${invoice.billingAddress}</textarea>
                            </div>
                            <div class="form-group">
                                <label for="shippingAddress">Shipping Address <span class="optional">optional</span></label>
                                <textarea id="shippingAddress" name="shippingAddress" rows="2">${invoice.shippingAddress}</textarea>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="notes">Notes <span class="optional">optional</span></label>
                                <textarea id="notes" name="notes" rows="2">${invoice.notes}</textarea>
                            </div>
                            <div class="form-group">
                                <label for="termsAndConditions">Terms &amp; Conditions <span class="optional">optional</span></label>
                                <textarea id="termsAndConditions" name="termsAndConditions" rows="2">${invoice.termsAndConditions}</textarea>
                            </div>
                        </div>

                    </div>
                </div>

                <%-- Line Items --%>
                <div class="items-section">
                    <div class="items-header">
                        <span>Line Items</span>
                        <span id="itemCount" style="font-size:0.78rem;font-weight:400;color:var(--color-text-muted);"></span>
                    </div>

                    <div class="items-table-wrap">
                        <table class="items-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th class="td-product">Product</th>
                                    <th class="td-desc">Description</th>
                                    <th class="td-hsn">HSN</th>
                                    <th class="td-qty num">Qty</th>
                                    <th class="td-price num">Unit Price (₹)</th>
                                    <th class="td-disc num">Disc %</th>
                                    <th class="td-tax num">Tax %</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody id="itemsContainer">
                                <c:choose>
                                    <c:when test="${not empty invoice.items}">
                                        <c:forEach var="item" items="${invoice.items}" varStatus="loop">
                                            <tr data-row="${loop.index}">
                                                <td style="color:var(--color-text-muted);width:28px;">${loop.index+1}</td>
                                                <td class="td-product">
                                                    <select name="itemProductId" onchange="onProductChange(this,${loop.index})">
                                                        <option value="">— Select product —</option>
                                                        <c:forEach var="p" items="${products}">
                                                            <option value="${p.id}"
                                                                    data-price="${p.sellingPrice}"
                                                                    data-hsn="${not empty p.hsn ? p.hsn.hsnCode : ''}"
                                                                ${item.product != null && item.product.id == p.id ? 'selected' : ''}>
                                                                <c:out value="${p.name}"/> (<c:out value="${p.sku}"/>)
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                </td>
                                                <td class="td-desc">
                                                    <input type="text" name="itemDescription" value="<c:out value="${item.description}"/>" placeholder="Description">
                                                </td>
                                                <td class="td-hsn">
                                                    <input type="text" name="itemHsnCode" value="<c:out value="${item.hsnCode}"/>" placeholder="HSN">
                                                </td>
                                                <td class="td-qty td-num">
                                                    <input type="number" name="itemQuantity" value="${item.quantity}" min="1" required onchange="recalcTotals()">
                                                </td>
                                                <td class="td-price td-num">
                                                    <input type="number" name="itemUnitPrice" value="${item.unitPrice}" min="0" step="0.01" required onchange="recalcTotals()">
                                                </td>
                                                <td class="td-disc td-num">
                                                    <input type="number" name="itemDiscountPercent" value="${item.discountPercent}" min="0" max="100" step="0.01" onchange="recalcTotals()">
                                                </td>
                                                <td class="td-tax td-num">
                                                    <input type="number" name="itemTaxPercent" value="${item.taxPercent}" min="0" step="0.01" onchange="recalcTotals()">
                                                </td>
                                                <td class="td-action">
                                                    <button type="button" class="btn-remove-row" onclick="removeRow(this)">
                                                        <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                                            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
                                                        </svg>
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:when test="${not empty prefillItems}">
                                        <c:forEach var="item" items="${prefillItems}" varStatus="loop">
                                            <tr data-row="${loop.index}">
                                                <td style="color:var(--color-text-muted);width:28px;">${loop.index+1}</td>
                                                <td class="td-product">
                                                    <select name="itemProductId" onchange="onProductChange(this,${loop.index})">
                                                        <option value="">— Select product —</option>
                                                        <c:forEach var="p" items="${products}">
                                                            <option value="${p.id}"
                                                                    data-price="${p.sellingPrice}"
                                                                    data-hsn="${not empty p.hsn ? p.hsn.hsnCode : ''}"
                                                                ${item.product != null && item.product.id == p.id ? 'selected' : ''}>
                                                                <c:out value="${p.name}"/> (<c:out value="${p.sku}"/>)
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                </td>
                                                <td class="td-desc">
                                                    <input type="text" name="itemDescription" value="<c:out value="${item.description}"/>" placeholder="Description">
                                                </td>
                                                <td class="td-hsn">
                                                    <input type="text" name="itemHsnCode" placeholder="HSN">
                                                </td>
                                                <td class="td-qty td-num">
                                                    <input type="number" name="itemQuantity" value="${item.quantity}" min="1" required onchange="recalcTotals()">
                                                </td>
                                                <td class="td-price td-num">
                                                    <input type="number" name="itemUnitPrice" value="${item.unitPrice}" min="0" step="0.01" required onchange="recalcTotals()">
                                                </td>
                                                <td class="td-disc td-num">
                                                    <input type="number" name="itemDiscountPercent" value="${item.discountPercent}" min="0" max="100" step="0.01" onchange="recalcTotals()">
                                                </td>
                                                <td class="td-tax td-num">
                                                    <input type="number" name="itemTaxPercent" value="${item.taxPercent}" min="0" step="0.01" onchange="recalcTotals()">
                                                </td>
                                                <td class="td-action">
                                                    <button type="button" class="btn-remove-row" onclick="removeRow(this)">
                                                        <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                                            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
                                                        </svg>
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>

                    <button type="button" class="btn-add-row" onclick="addRow()">+ Add Line Item</button>

                    <div class="totals-panel">
                        <div class="totals-grid">
                            <div class="t-row"><span class="t-label">Subtotal</span><span class="t-val" id="tSubtotal">₹0.00</span></div>
                            <div class="t-row"><span class="t-label">Discount</span><span class="t-val" id="tDiscount">−₹0.00</span></div>
                            <div class="t-row"><span class="t-label">Tax (GST)</span><span class="t-val" id="tTax">+₹0.00</span></div>
                            <div class="t-row grand"><span class="t-label">Total</span><span class="t-val" id="tTotal">₹0.00</span></div>
                        </div>
                    </div>
                </div>

                <div class="form-actions" style="margin-left:40px;">
                    <button type="submit" class="btn-save">
                        <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
                        </svg>
                        ${empty invoice.id ? 'Create Invoice' : 'Save Changes'}
                    </button>
                    <a href="/spendilizer/invoice" class="btn-cancel">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="/spendilizer/js/ims-invoice-form.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
