<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt"%>
<!DOCTYPE html>
<html>
<head>
<title>Invoice ${invoice.invoiceNumber} — IMS</title>
<jsp:include page="/WEB-INF/views/include/styling.jsp" />
<style>
/* ── Print invoice layout ── */
.print-invoice {
	display: none;
}

@media print {
	body * {
		visibility: hidden;
	}
	.print-invoice, .print-invoice * {
		visibility: visible;
	}
	.print-invoice {
		display: block;
		position: absolute;
		inset: 0;
		padding: 32px 40px;
		background: #fff;
		font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
		font-size: 13px;
		color: #111;
	}
	/* hide screen-only elements */
	#sidebar-wrapper, nav, .action-bar, .breadcrumb-bar {
		display: none !important;
	}
}

/* ── Invoice document styles (used inside .print-invoice) ── */
.inv-doc {
	max-width: 860px;
	margin: 0 auto;
}

.inv-header {
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	padding-bottom: 20px;
	border-bottom: 2px solid #111;
	margin-bottom: 24px;
}

.inv-title {
	font-size: 2rem;
	font-weight: 800;
	letter-spacing: -1px;
	color: #111;
}

.inv-seller {
	margin-top: 6px;
	font-size: 0.82rem;
	color: #444;
	line-height: 1.5;
}

.inv-seller strong {
	font-size: 1rem;
	color: #111;
}

.inv-meta {
	text-align: right;
	font-size: 0.83rem;
	color: #444;
	line-height: 1.7;
}

.inv-meta .inv-number {
	font-size: 1.1rem;
	font-weight: 700;
	color: #111;
	margin-bottom: 4px;
}

.inv-parties {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 24px;
	margin-bottom: 24px;
}

.inv-party-box {
	background: #f8fafc;
	border: 1px solid #e2e8f0;
	border-radius: 8px;
	padding: 14px 18px;
	font-size: 0.83rem;
	line-height: 1.6;
}

.inv-party-box .label {
	font-size: 0.68rem;
	font-weight: 700;
	text-transform: uppercase;
	letter-spacing: 0.8px;
	color: #64748b;
	margin-bottom: 6px;
}

.inv-party-box .name {
	font-size: 0.95rem;
	font-weight: 600;
	color: #111;
}

.inv-party-box .sub {
	color: #475569;
}

.inv-items-table {
	width: 100%;
	border-collapse: collapse;
	font-size: 0.82rem;
	margin-bottom: 0;
}

.inv-items-table th {
	background: #111;
	color: #fff;
	padding: 8px 12px;
	font-size: 0.72rem;
	font-weight: 600;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.inv-items-table th.r, .inv-items-table td.r {
	text-align: right;
}

.inv-items-table td {
	padding: 8px 12px;
	border-bottom: 1px solid #e2e8f0;
	vertical-align: top;
}

.inv-items-table tr:last-child td {
	border-bottom: none;
}

.inv-items-table tr:nth-child(even) td {
	background: #f8fafc;
}

.inv-totals {
	display: flex;
	justify-content: flex-end;
	margin-top: 0;
	border-top: 1px solid #e2e8f0;
	padding-top: 12px;
}

.inv-totals-grid {
	width: 280px;
	font-size: 0.83rem;
}

.inv-tot-row {
	display: flex;
	justify-content: space-between;
	padding: 3px 0;
	color: #475569;
}

.inv-tot-row.grand {
	font-size: 1rem;
	font-weight: 700;
	color: #111;
	border-top: 2px solid #111;
	padding-top: 8px;
	margin-top: 6px;
}

.inv-footer {
	margin-top: 32px;
	display: grid;
	grid-template-columns: 1fr auto;
	gap: 24px;
	font-size: 0.8rem;
	color: #475569;
}

.inv-footer .terms {
	border-top: 1px solid #e2e8f0;
	padding-top: 12px;
}

.inv-footer .sig {
	text-align: center;
	border-top: 1px solid #e2e8f0;
	padding-top: 12px;
	min-width: 180px;
}

.inv-footer .sig .line {
	height: 40px;
	border-bottom: 1px solid #111;
	margin-bottom: 6px;
}
</style>
</head>
<body>
	<%@ include file="../../navbar.jsp"%>
	<div class="container-fluid p-0">
		<div class="row g-0">
			<div><jsp:include page="../sidebar.jsp" /></div>
			<div class="main-content">

				<div class="breadcrumb-bar">
					<a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
					<span class="sep">›</span> <a
						href="${pageContext.request.contextPath}/invoice">Invoices</a> <span
						class="sep">›</span> <span class="current">${invoice.invoiceNumber}</span>
				</div>

				<div class="page-header" style="align-items: flex-start;">
					<div>
						<h2 style="display: flex; align-items: center; gap: 12px;">
							${invoice.invoiceNumber} <span
								class="status-badge status-${invoice.status}">${invoice.status}</span>
						</h2>
						<div class="page-subtitle">
							Customer: <strong>${invoice.customer.displayName}</strong>
							&nbsp;·&nbsp; Date: ${invoice.invoiceDateFormatted} &nbsp;·&nbsp;
							Payment: <strong>${invoice.paymentMode.label}</strong>
							<c:if test="${not empty invoice.salesOrder}">
                            &nbsp;·&nbsp; Order: <a
									href="${pageContext.request.contextPath}/order/${invoice.salesOrder.id}"
									style="color: var(--color-primary);">${invoice.salesOrder.orderNumber}</a>
							</c:if>
						</div>
					</div>
					<c:if test="${invoice.status == 'DRAFT'}">
						<a
							href="${pageContext.request.contextPath}/invoice/edit/${invoice.id}"
							class="btn-primary-custom">Edit Invoice</a>
					</c:if>
				</div>

				<c:if test="${not empty successMessage}">
					<div class="flash-success">${successMessage}</div>
				</c:if>
				<c:if test="${not empty errorMessage}">
					<div class="flash-error">${errorMessage}</div>
				</c:if>

				<%-- Status Action Bar --%>
				<div class="action-bar">
					<a
						href="${pageContext.request.contextPath}/invoice/${invoice.id}/pdf"
						class="btn-action-lg btn-send"
						style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">
						Download Invoice </a>
					<c:if test="${invoice.status == 'DRAFT'}">
						<button type="button" class="btn-action-lg btn-send"
							data-bs-toggle="modal" data-bs-target="#sendModal">Mark
							Sent</button>
						<button type="button" class="btn-action-lg btn-cancel-lg"
							data-bs-toggle="modal" data-bs-target="#invCancelModal">
							Cancel Invoice</button>
					</c:if>
					<c:if
						test="${invoice.status == 'SENT' || invoice.status == 'OVERDUE'}">
						<button type="button" class="btn-action-lg btn-pay"
							data-bs-toggle="modal" data-bs-target="#payModal">Mark
							Paid</button>
						<button type="button" class="btn-action-lg btn-cancel-lg"
							data-bs-toggle="modal" data-bs-target="#invCancelModal">
							Cancel Invoice</button>
					</c:if>
				</div>

				<%-- Detail Grid --%>
				<div class="detail-grid">
					<div class="detail-card">
						<h4>Invoice Info</h4>
						<div class="detail-row">
							<span class="detail-label">Invoice No.</span><span
								class="detail-value">${invoice.invoiceNumber}</span>
						</div>
						<div class="detail-row">
							<span class="detail-label">Invoice Date</span><span
								class="detail-value">${invoice.invoiceDateFormatted}</span>
						</div>
						<div class="detail-row">
							<span class="detail-label">Due Date</span><span
								class="detail-value">${invoice.dueDateFormatted}</span>
						</div>
						<div class="detail-row">
							<span class="detail-label">Payment Mode</span><span
								class="detail-value">${invoice.paymentMode.label}</span>
						</div>
						<div class="detail-row">
							<span class="detail-label">Status</span><span
								class="detail-value"><span
								class="status-badge status-${invoice.status}">${invoice.status}</span></span>
						</div>
						<c:if test="${not empty invoice.salesOrder}">
							<div class="detail-row">
								<span class="detail-label">Linked Order</span><span
									class="detail-value"><a
									href="${pageContext.request.contextPath}/order/${invoice.salesOrder.id}"
									style="color: var(--color-primary);">${invoice.salesOrder.orderNumber}</a></span>
							</div>
						</c:if>
					</div>
					<div class="detail-card">
						<h4>Customer</h4>
						<div class="detail-row">
							<span class="detail-label">Name</span><span class="detail-value">${invoice.customer.displayName}</span>
						</div>
						<div class="detail-row">
							<span class="detail-label">Email</span><span class="detail-value">${invoice.customer.email}</span>
						</div>
						<div class="detail-row">
							<span class="detail-label">Phone</span><span class="detail-value">${not empty invoice.customer.phone ? invoice.customer.phone : '—'}</span>
						</div>
						<div class="detail-row">
							<span class="detail-label">GSTIN</span><span class="detail-value">${not empty invoice.customerGstin ? invoice.customerGstin : '—'}</span>
						</div>
					</div>
					<c:if
						test="${not empty invoice.billingAddress or not empty invoice.shippingAddress}">
						<div class="detail-card">
							<h4>Addresses</h4>
							<c:if test="${not empty invoice.billingAddress}">
								<div class="detail-row"
									style="flex-direction: column; gap: 4px;">
									<span class="detail-label">Billing</span> <span
										style="font-size: 0.85rem; white-space: pre-wrap;">${invoice.billingAddress}</span>
								</div>
							</c:if>
							<c:if test="${not empty invoice.shippingAddress}">
								<div class="detail-row"
									style="flex-direction: column; gap: 4px; margin-top: 10px;">
									<span class="detail-label">Shipping</span> <span
										style="font-size: 0.85rem; white-space: pre-wrap;">${invoice.shippingAddress}</span>
								</div>
							</c:if>
						</div>
					</c:if>
					<c:if
						test="${not empty invoice.notes or not empty invoice.termsAndConditions}">
						<div class="detail-card">
							<h4>Notes &amp; Terms</h4>
							<c:if test="${not empty invoice.notes}">
								<p
									style="font-size: 0.875rem; margin-bottom: 10px; white-space: pre-wrap;">${invoice.notes}</p>
							</c:if>
							<c:if test="${not empty invoice.termsAndConditions}">
								<div class="detail-label"
									style="font-size: 0.72rem; margin-bottom: 4px;">TERMS
									&amp; CONDITIONS</div>
								<p style="font-size: 0.85rem; margin: 0; white-space: pre-wrap;">${invoice.termsAndConditions}</p>
							</c:if>
						</div>
					</c:if>
				</div>

				<%-- Line Items --%>
				<div class="table-card">
					<div
						style="padding: 16px 20px; border-bottom: 1px solid var(--color-border); font-weight: 600; font-size: 0.9rem;">
						Invoice Items</div>
					<table>
						<thead>
							<tr>
								<th>#</th>
								<th>Description</th>
								<th>HSN</th>
								<th style="text-align: right;">Qty</th>
								<th style="text-align: right;">Unit Price</th>
								<th style="text-align: right;">Disc %</th>
								<th style="text-align: right;">Tax %</th>
								<th style="text-align: right;">Amount</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="item" items="${invoice.items}" varStatus="loop">
								<tr>
									<td class="text-muted">${loop.index + 1}</td>
									<td><c:if test="${not empty item.product}">
											<div class="fw-500">${item.product.name}</div>
										</c:if> <c:if test="${not empty item.description}">
											<div class="text-muted" style="font-size: 0.8rem;">${item.description}</div>
										</c:if></td>
									<td class="text-muted">${not empty item.hsnCode ? item.hsnCode : '—'}</td>
									<td style="text-align: right;">${item.quantity}</td>
									<td style="text-align: right;">&#8377;<fmt:formatNumber
											value="${item.unitPrice}" pattern="#,##0.00" /></td>
									<td style="text-align: right;">${item.discountPercent}%</td>
									<td style="text-align: right;">${item.taxPercent}%</td>
									<td style="text-align: right; font-weight: 500;">&#8377;<fmt:formatNumber
											value="${item.amount}" pattern="#,##0.00" /></td>
								</tr>
							</c:forEach>
						</tbody>
					</table>
					<div
						style="padding: 16px 24px; border-top: 1px solid var(--color-border);">
						<div style="max-width: 320px; margin-left: auto;">
							<div class="totals-row">
								<span class="text-muted">Subtotal</span> &nbsp; &#8377;
								<fmt:formatNumber value="${invoice.subtotal}" pattern="#,##0.00" />
							</div>
							<div class="totals-row">
								<span class="text-muted">Discount</span> &nbsp; −&#8377;
								<fmt:formatNumber value="${invoice.totalDiscount}"
									pattern="#,##0.00" />
							</div>
							<div class="totals-row">
								<span class="text-muted">Tax (GST)</span> &nbsp; +&#8377;
								<fmt:formatNumber value="${invoice.totalTax}" pattern="#,##0.00" />
							</div>
							<div class="totals-row grand">
								Total &nbsp; &#8377;
								<fmt:formatNumber value="${invoice.totalAmount}"
									pattern="#,##0.00" />
							</div>
						</div>
					</div>
				</div>

			</div>
		</div>
	</div>

	<%-- ══════════════════════════════════════════════════
     PRINTABLE CUSTOMER-FACING INVOICE DOCUMENT
     Visible only during window.print()
════════════════════════════════════════════════════ --%>
	<div class="print-invoice">
		<div class="inv-doc">

			<%-- Header: seller left, invoice meta right --%>
			<div class="inv-header">
				<div>
					<div class="inv-title">INVOICE</div>
					<div class="inv-seller">
						<strong>${invoice.createdBy.userBasicDetails.userFirstName}
								${invoice.createdBy.userBasicDetails.userLastName}</strong>
							<br>
						<c:if test="${not empty invoice.createdBy.userBasicDetails.pan}">
                        PAN: ${invoice.createdBy.userBasicDetails.pan}<br>
						</c:if>
						${invoice.createdBy.userEmail}
					</div>
				</div>
				<div class="inv-meta">
					<div class="inv-number">${invoice.invoiceNumber}</div>
					<div>
						Invoice Date: <strong>${invoice.invoiceDateFormatted}</strong>
					</div>
					<div>
						Due Date: <strong>${invoice.dueDateFormatted}</strong>
					</div>
					<div>
						Payment Mode: <strong>${invoice.paymentMode.label}</strong>
					</div>
					<div style="margin-top: 6px;">
						<span class="status-badge status-${invoice.status}">${invoice.status}</span>
					</div>
					<c:if test="${not empty invoice.salesOrder}">
						<div style="margin-top: 4px; font-size: 0.78rem; color: #64748b;">
							Ref. Order: ${invoice.salesOrder.orderNumber}</div>
					</c:if>
				</div>
			</div>

			<%-- Bill To / Ship To --%>
			<div class="inv-parties">
				<div class="inv-party-box">
					<div class="label">Bill To</div>
					<div class="name">${invoice.customer.displayName}</div>
					<c:if test="${not empty invoice.customer.email}">
						<div class="sub">${invoice.customer.email}</div>
					</c:if>
					<c:if test="${not empty invoice.customer.phone}">
						<div class="sub">${invoice.customer.phone}</div>
					</c:if>
					<c:if test="${not empty invoice.billingAddress}">
						<div class="sub" style="margin-top: 4px; white-space: pre-wrap;">${invoice.billingAddress}</div>
					</c:if>
					<c:if test="${not empty invoice.customerGstin}">
						<div class="sub" style="margin-top: 4px;">GSTIN:
							${invoice.customerGstin}</div>
					</c:if>
				</div>
				<c:choose>
					<c:when test="${not empty invoice.shippingAddress}">
						<div class="inv-party-box">
							<div class="label">Ship To</div>
							<div class="name">${invoice.customer.displayName}</div>
							<div class="sub" style="white-space: pre-wrap;">${invoice.shippingAddress}</div>
						</div>
					</c:when>
					<c:otherwise>
						<div class="inv-party-box">
							<div class="label">Contact</div>
							<div class="sub">${invoice.customer.email}</div>
							<c:if test="${not empty invoice.customer.phone}">
								<div class="sub">${invoice.customer.phone}</div>
							</c:if>
						</div>
					</c:otherwise>
				</c:choose>
			</div>

			<%-- Line Items Table --%>
			<table class="inv-items-table">
				<thead>
					<tr>
						<th style="width: 28px;">#</th>
						<th>Description</th>
						<th>HSN</th>
						<th class="r" style="width: 50px;">Qty</th>
						<th class="r" style="width: 90px;">Rate (&#8377;)</th>
						<th class="r" style="width: 55px;">Disc%</th>
						<th class="r" style="width: 55px;">Tax%</th>
						<th class="r" style="width: 100px;">Amount (&#8377;)</th>
					</tr>
				</thead>
				<tbody>
					<c:forEach var="item" items="${invoice.items}" varStatus="loop">
						<tr>
							<td>${loop.index + 1}</td>
							<td><c:if test="${not empty item.product}">
									<strong>${item.product.name}</strong>
									<br>
								</c:if> <c:if test="${not empty item.description}">
									<span style="color: #475569;">${item.description}</span>
								</c:if></td>
							<td style="color: #64748b;">${not empty item.hsnCode ? item.hsnCode : ''}</td>
							<td class="r">${item.quantity}</td>
							<td class="r"><fmt:formatNumber value="${item.unitPrice}"
									pattern="#,##0.00" /></td>
							<td class="r">${item.discountPercent}%</td>
							<td class="r">${item.taxPercent}%</td>
							<td class="r" style="font-weight: 600;"><fmt:formatNumber
									value="${item.amount}" pattern="#,##0.00" /></td>
						</tr>
					</c:forEach>
				</tbody>
			</table>

			<%-- Totals --%>
			<div class="inv-totals">
				<div class="inv-totals-grid">
					<div class="inv-tot-row">
						<span>Subtotal</span><span>&#8377;<fmt:formatNumber
								value="${invoice.subtotal}" pattern="#,##0.00" /></span>
					</div>
					<div class="inv-tot-row">
						<span>Discount</span><span>−&#8377;<fmt:formatNumber
								value="${invoice.totalDiscount}" pattern="#,##0.00" /></span>
					</div>
					<div class="inv-tot-row">
						<span>Tax (GST)</span><span>+&#8377;<fmt:formatNumber
								value="${invoice.totalTax}" pattern="#,##0.00" /></span>
					</div>
					<div class="inv-tot-row grand">
						<span>TOTAL</span><span>&#8377;<fmt:formatNumber
								value="${invoice.totalAmount}" pattern="#,##0.00" /></span>
					</div>
				</div>
			</div>

			<%-- Footer: Terms + Signature --%>
			<div class="inv-footer">
				<div class="terms">
					<div
						style="font-weight: 600; margin-bottom: 6px; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.5px;">Terms
						&amp; Conditions</div>
					<c:choose>
						<c:when test="${not empty invoice.termsAndConditions}">
							<div style="white-space: pre-wrap;">${invoice.termsAndConditions}</div>
						</c:when>
						<c:otherwise>
                        Payment is due by ${invoice.dueDateFormatted}. Please include the invoice number in your payment reference.
                    </c:otherwise>
					</c:choose>
					<c:if test="${not empty invoice.notes}">
						<div
							style="margin-top: 10px; font-weight: 600; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.5px;">Notes</div>
						<div style="white-space: pre-wrap;">${invoice.notes}</div>
					</c:if>
				</div>
				<div class="sig">
					<div class="line"></div>
					<div style="font-weight: 600;">Authorised Signatory</div>
					<div style="color: #64748b;">${invoice.createdBy.userBasicDetails.userFirstName}
							${invoice.createdBy.userBasicDetails.userLastName}</div>
				</div>
			</div>

		</div>
		<%-- /inv-doc --%>
	</div>
	<%-- /print-invoice --%>

	<%-- ═══ MARK SENT MODAL ═══ --%>
	<div class="modal fade" id="sendModal" tabindex="-1">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content"
				style="border-radius: 12px; border: none; box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);">
				<div class="modal-header"
					style="border-bottom: 1px solid var(--color-border); padding: 18px 24px;">
					<h5 class="modal-title" style="font-size: 1rem; font-weight: 600;">Mark
						Invoice as Sent?</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body" style="padding: 20px 24px;">
					<div style="font-size: 0.875rem; margin-bottom: 12px;">
						<span style="color: var(--color-text-muted);">Invoice</span> <strong>${invoice.invoiceNumber}</strong>
						&nbsp;·&nbsp; <span style="color: var(--color-text-muted);">Customer</span>
						<strong>${invoice.customer.displayName}</strong>
					</div>
					<div
						style="font-size: 0.875rem; color: var(--color-text-muted); margin-bottom: 4px;">
						Total &#8377;
						<fmt:formatNumber value="${invoice.totalAmount}"
							pattern="#,##0.00" />
						&nbsp;·&nbsp; Due ${invoice.dueDateFormatted}
					</div>
					<div
						style="margin-top: 14px; padding: 10px 14px; background: #eff6ff; border-radius: 6px; font-size: 0.82rem; color: #1d4ed8;">
						This marks the invoice as sent to the customer. Use <strong>Print
							/ PDF</strong> to download or share the invoice document.
					</div>
				</div>
				<div class="modal-footer"
					style="border-top: 1px solid var(--color-border); padding: 14px 24px; gap: 10px;">
					<button type="button" class="btn-action-lg" data-bs-dismiss="modal"
						style="background: #f1f5f9; color: #475569; border: 1px solid var(--color-border);">
						Go Back</button>
					<form
						action="${pageContext.request.contextPath}/invoice/${invoice.id}/send"
						method="post" style="margin: 0;">
						<button type="submit" class="btn-action-lg btn-send">Confirm
							— Mark Sent</button>
					</form>
				</div>
			</div>
		</div>
	</div>

	<%-- ═══ MARK PAID MODAL ═══ --%>
	<div class="modal fade" id="payModal" tabindex="-1">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content"
				style="border-radius: 12px; border: none; box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);">
				<div class="modal-header"
					style="border-bottom: 1px solid var(--color-border); padding: 18px 24px;">
					<h5 class="modal-title" style="font-size: 1rem; font-weight: 600;">Mark
						Invoice as Paid?</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body" style="padding: 20px 24px;">
					<div style="font-size: 0.875rem; margin-bottom: 12px;">
						<span style="color: var(--color-text-muted);">Invoice</span> <strong>${invoice.invoiceNumber}</strong>
						&nbsp;·&nbsp; <span style="color: var(--color-text-muted);">Customer</span>
						<strong>${invoice.customer.displayName}</strong>
					</div>
					<div
						style="font-size: 1.1rem; font-weight: 700; margin-bottom: 4px;">
						&#8377;
						<fmt:formatNumber value="${invoice.totalAmount}"
							pattern="#,##0.00" />
					</div>
					<div style="font-size: 0.82rem; color: var(--color-text-muted);">Due
						${invoice.dueDateFormatted}</div>
					<div
						style="margin-top: 14px; padding: 10px 14px; background: #f0fdf4; border-radius: 6px; font-size: 0.82rem; color: #15803d;">
						&#10003; Confirming payment received. This action cannot be
						undone.</div>
				</div>
				<div class="modal-footer"
					style="border-top: 1px solid var(--color-border); padding: 14px 24px; gap: 10px;">
					<button type="button" class="btn-action-lg" data-bs-dismiss="modal"
						style="background: #f1f5f9; color: #475569; border: 1px solid var(--color-border);">
						Go Back</button>
					<form
						action="${pageContext.request.contextPath}/invoice/${invoice.id}/pay"
						method="post" style="margin: 0;">
						<button type="submit" class="btn-action-lg btn-pay">Confirm
							Payment</button>
					</form>
				</div>
			</div>
		</div>
	</div>

	<%-- ═══ CANCEL INVOICE MODAL ═══ --%>
	<div class="modal fade" id="invCancelModal" tabindex="-1">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content"
				style="border-radius: 12px; border: none; box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);">
				<div class="modal-header"
					style="border-bottom: 1px solid var(--color-border); padding: 18px 24px;">
					<h5 class="modal-title" style="font-size: 1rem; font-weight: 600;">Cancel
						Invoice ${invoice.invoiceNumber}?</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body" style="padding: 20px 24px;">
					<p
						style="font-size: 0.875rem; color: var(--color-text-muted); margin-bottom: 14px;">
						This will void invoice <strong>${invoice.invoiceNumber}</strong>
						for <strong>${invoice.customer.displayName}</strong> (&#8377;
						<fmt:formatNumber value="${invoice.totalAmount}"
							pattern="#,##0.00" />
						). This action cannot be undone.
					</p>
					<c:if test="${not empty invoice.salesOrder}">
						<div
							style="padding: 10px 14px; background: #fff7ed; border-radius: 6px; font-size: 0.82rem; color: #b45309;">
							&#9888; This invoice is linked to order <a
								href="${pageContext.request.contextPath}/order/${invoice.salesOrder.id}"
								style="color: #b45309; font-weight: 500;">${invoice.salesOrder.orderNumber}</a>.
							The order will not be affected.
						</div>
					</c:if>
				</div>
				<div class="modal-footer"
					style="border-top: 1px solid var(--color-border); padding: 14px 24px; gap: 10px;">
					<button type="button" class="btn-action-lg" data-bs-dismiss="modal"
						style="background: #f1f5f9; color: #475569; border: 1px solid var(--color-border);">
						Go Back</button>
					<form
						action="${pageContext.request.contextPath}/invoice/${invoice.id}/cancel"
						method="post" style="margin: 0;">
						<button type="submit" class="btn-action-lg btn-cancel-lg">Yes,
							Cancel Invoice</button>
					</form>
				</div>
			</div>
		</div>
	</div>

</body>
</html>
