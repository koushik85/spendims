<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt"%>
<!DOCTYPE html>
<html>
<head>
<title>${empty order.id ? 'New Order' : 'Edit Order'}— IMS</title>
<jsp:include page="/WEB-INF/views/include/styling.jsp" />
</head>
<body>
	<%@ include file="../../navbar.jsp"%>

	<%-- Inject product data as JSON — avoids fragile DOM-parsing approach --%>
	<script>
const PRODUCTS = [
    <c:forEach var="p" items="${products}" varStatus="loop">
    { id: "${p.id}", name: "<c:out value="${p.name}"/>", sku: "<c:out value="${p.sku}"/>", price: ${p.sellingPrice} }<c:if test="${!loop.last}">,</c:if>
    </c:forEach>
];

function buildProductSelect(selectedId, rowIdx) {
    let html = '<select name="itemProductId" onchange="onProductChange(this,' + rowIdx + ')">';
    html += '<option value="">— Select product —</option>';
    for (const p of PRODUCTS) {
        const sel = (selectedId && String(p.id) === String(selectedId)) ? ' selected' : '';
        html += '<option value="' + p.id + '" data-price="' + p.price + '"' + sel + '>'
              + p.name + ' (' + p.sku + ')</option>';
    }
    html += '</select>';
    return html;
}
</script>

	<div class="container-fluid p-0">
		<div class="row g-0">
			<div><jsp:include page="../sidebar.jsp" /></div>
			<div class="main-content">

				<div class="breadcrumb-bar">
					<a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
					<span class="sep">›</span> <a
						href="${pageContext.request.contextPath}/order">Orders</a> <span
						class="sep">›</span> <span class="current">${empty order.id ? 'New Order' : 'Edit Order'}</span>
				</div>

				<div class="page-header with-icon">
					<h2>${empty order.id ? 'Create Sales Order' : 'Edit Order'}</h2>
					<div class="page-subtitle">${empty order.id ? 'Select customer, add items.' : 'Update the draft order.'}
					</div>
				</div>

				<c:if test="${not empty errorMessage}">
					<div class="flash-error"
						style="margin-left: 40px; margin-right: 8px; margin-bottom: 16px;">${errorMessage}</div>
				</c:if>

				<form
					action="${pageContext.request.contextPath}/order/${empty order.id ? 'new' : 'edit/'.concat(order.id)}"
					method="post" id="orderForm">

					<%-- Header card --%>
					<div class="form-card">
						<div class="form-card-header">Order Details</div>
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
													${order.customer != null && order.customer.id == cust.id ? 'selected' : ''}>
													<c:out value="${cust.displayName}" />
												</option>
											</c:forEach>
										</select>
									</div>
								</div>
								<div class="form-group">
									<label for="orderDate">Order Date <span
										class="required">*</span></label> <input type="date" id="orderDate"
										name="orderDate"
										value="${not empty order.orderDate ? order.orderDate : ''}"
										required>
								</div>
							</div>

							<div class="form-row">
								<div class="form-group">
									<label for="expectedDeliveryDate">Expected Delivery <span
										class="optional">optional</span></label> <input type="date"
										id="expectedDeliveryDate" name="expectedDeliveryDate"
										value="${not empty order.expectedDeliveryDate ? order.expectedDeliveryDate : ''}">
								</div>
								<div class="form-group">
									<label for="paymentMode">Payment Mode <span
										class="required">*</span></label>
									<div class="select-wrapper">
										<select id="paymentMode" name="paymentMode" required>
											<c:forEach var="mode" items="${paymentModes}">
												<option value="${mode}"
													${order.paymentMode == mode or (empty order.id and mode == 'CASH') ? 'selected' : ''}>
													${mode.label}</option>
											</c:forEach>
										</select>
									</div>
								</div>
							</div>

							<div class="form-row">
								<div class="form-group" style="grid-column: 1/-1;">
									<label for="notes">Notes <span class="optional">optional</span></label>
									<input type="text" id="notes" name="notes"
										value="${order.notes}" placeholder="Internal notes…">
								</div>
							</div>

							<div class="form-row">
								<div class="form-group">
									<label for="billingAddress">Billing Address <span
										class="optional">optional</span></label>
									<textarea id="billingAddress" name="billingAddress" rows="2">${order.billingAddress}</textarea>
								</div>
								<div class="form-group">
									<label for="shippingAddress">Shipping Address <span
										class="optional">optional</span></label>
									<textarea id="shippingAddress" name="shippingAddress" rows="2">${order.shippingAddress}</textarea>
								</div>
							</div>

						</div>
					</div>

					<%-- Line Items --%>
					<div class="items-section">
						<div class="items-header">
							<span>Line Items</span> <span id="itemCount"
								style="font-size: 0.78rem; font-weight: 400; color: var(--color-text-muted);"></span>
						</div>

						<div class="items-table-wrap">
							<table class="items-table">
								<thead>
									<tr>
										<th>#</th>
										<th class="td-product">Product</th>
										<th class="td-desc">Description</th>
										<th class="td-qty num">Qty</th>
										<th class="td-price num">Unit Price (₹)</th>
										<th class="td-disc num">Disc %</th>
										<th class="td-tax num">Tax %</th>
										<th></th>
									</tr>
								</thead>
								<tbody id="itemsContainer">
									<c:choose>
										<c:when test="${not empty order.items}">
											<c:forEach var="item" items="${order.items}" varStatus="loop">
												<tr data-row="${loop.index}">
													<td style="color: var(--color-text-muted); width: 28px;">${loop.index+1}</td>
													<td class="td-product"><select name="itemProductId"
														onchange="onProductChange(this,${loop.index})">
															<option value="">— Select product —</option>
															<c:forEach var="p" items="${products}">
																<option value="${p.id}" data-price="${p.sellingPrice}"
																	${item.product != null && item.product.id == p.id ? 'selected' : ''}>
																	<c:out value="${p.name}" /> (
																	<c:out value="${p.sku}" />)
																</option>
															</c:forEach>
													</select></td>
													<td class="td-desc"><input type="text"
														name="itemDescription"
														value="<c:out value="${item.description}"/>"
														placeholder="Description"></td>
													<td class="td-qty td-num"><input type="number"
														name="itemQuantity" value="${item.quantity}" min="1"
														required onchange="recalcTotals()"></td>
													<td class="td-price td-num"><input type="number"
														name="itemUnitPrice" value="${item.unitPrice}" min="0"
														step="0.01" required onchange="recalcTotals()"></td>
													<td class="td-disc td-num"><input type="number"
														name="itemDiscountPercent" value="${item.discountPercent}"
														min="0" max="100" step="0.01" onchange="recalcTotals()">
													</td>
													<td class="td-tax td-num"><input type="number"
														name="itemTaxPercent" value="${item.taxPercent}" min="0"
														step="0.01" onchange="recalcTotals()"></td>
													<td class="td-action">
														<button type="button" class="btn-remove-row"
															onclick="removeRow(this)">
															<svg width="13" height="13" fill="none"
																viewBox="0 0 24 24" stroke="currentColor"
																stroke-width="2.5">
                                                            <path
																	stroke-linecap="round" stroke-linejoin="round"
																	d="M6 18L18 6M6 6l12 12" />
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

						<button type="button" class="btn-add-row" onclick="addRow()">
							+ Add Line Item</button>

						<div class="totals-panel">
							<div class="totals-grid">
								<div class="t-row">
									<span class="t-label">Subtotal</span><span class="t-val"
										id="tSubtotal">₹0.00</span>
								</div>
								<div class="t-row">
									<span class="t-label">Discount</span><span class="t-val"
										id="tDiscount">−₹0.00</span>
								</div>
								<div class="t-row">
									<span class="t-label">Tax (GST)</span><span class="t-val"
										id="tTax">+₹0.00</span>
								</div>
								<div class="t-row grand">
									<span class="t-label">Total</span><span class="t-val"
										id="tTotal">₹0.00</span>
								</div>
							</div>
						</div>
					</div>

					<div class="form-actions" style="margin-left: 40px;">
						<button type="submit" class="btn-save">
							<svg width="14" height="14" fill="none" viewBox="0 0 24 24"
								stroke="currentColor" stroke-width="2.5">
                            <path stroke-linecap="round"
									stroke-linejoin="round" d="M5 13l4 4L19 7" />
                        </svg>
							${empty order.id ? 'Create Order' : 'Save Changes'}
						</button>
						<a href="${pageContext.request.contextPath}/order"
							class="btn-cancel">Cancel</a>
					</div>

				</form>
			</div>
		</div>
	</div>

	<script src="${pageContext.request.contextPath}/js/ims-order-form.js"></script>
</body>
</html>
