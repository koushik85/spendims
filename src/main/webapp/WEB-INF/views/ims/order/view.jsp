<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt"%>
<!DOCTYPE html>
<html>
<head>
<title>Order ${order.orderNumber} — IMS</title>
<jsp:include
	page="${pageContext.request.contextPath}/include/styling.jsp" />
<link href="${pageContext.request.contextPath}/css/ims-shared.css"
	rel="stylesheet">
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
						href="${pageContext.request.contextPath}/order">Orders</a> <span
						class="sep">›</span> <span class="current">${order.orderNumber}</span>
				</div>

				<div class="page-header" style="align-items: flex-start;">
					<div>
						<h2 style="display: flex; align-items: center; gap: 12px;">
							${order.orderNumber} <span
								class="status-badge status-${order.status}">${order.status}</span>
						</h2>
						<div class="page-subtitle">
							Customer: <strong>${order.customer.displayName}</strong>
							&nbsp;·&nbsp; Date: ${order.orderDateFormatted}
						</div>
					</div>
					<c:if test="${order.status == 'DRAFT'}">
						<a
							href="${pageContext.request.contextPath}/order/edit/${order.id}"
							class="btn-primary-custom">Edit Order</a>
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
					<c:if test="${order.status == 'DRAFT'}">
						<button type="button" class="btn-action-lg btn-confirm"
							data-bs-toggle="modal" data-bs-target="#confirmModal">
							Confirm Order</button>
						<button type="button" class="btn-action-lg btn-cancel-lg"
							data-bs-toggle="modal" data-bs-target="#cancelModal">
							Cancel Order</button>
					</c:if>
					<c:if test="${order.status == 'CONFIRMED'}">
						<button type="button" class="btn-action-lg btn-ship"
							data-bs-toggle="modal" data-bs-target="#shipModal">Mark
							Shipped</button>
						<button type="button" class="btn-action-lg btn-cancel-lg"
							data-bs-toggle="modal" data-bs-target="#cancelModal">
							Cancel Order</button>
					</c:if>
					<c:if test="${order.status == 'SHIPPED'}">
						<button type="button" class="btn-action-lg btn-deliver"
							data-bs-toggle="modal" data-bs-target="#deliverModal">
							Mark Delivered</button>
						<button type="button" class="btn-action-lg btn-cancel-lg"
							data-bs-toggle="modal" data-bs-target="#cancelModal">
							Cancel Order</button>
					</c:if>
					<%-- Invoice link whenever one exists --%>
					<c:if test="${not empty linkedInvoice}">
						<a
							href="${pageContext.request.contextPath}/invoice/${linkedInvoice.id}"
							class="btn-action-lg btn-print" style="text-decoration: none;">
							&#128196; Invoice ${linkedInvoice.invoiceNumber} <span
							class="status-badge status-${linkedInvoice.status}"
							style="font-size: 0.65rem; padding: 2px 7px; margin-left: 6px;">${linkedInvoice.status}</span>
						</a>
					</c:if>
				</div>

				<%-- Detail Grid --%>
				<div class="detail-grid">
					<div class="detail-card">
						<h4>Order Info</h4>
						<div class="detail-row">
							<span class="detail-label">Order No.</span><span
								class="detail-value">${order.orderNumber}</span>
						</div>
						<div class="detail-row">
							<span class="detail-label">Order Date</span><span
								class="detail-value">${order.orderDateFormatted}</span>
						</div>
						<div class="detail-row">
							<span class="detail-label">Expected Delivery</span><span
								class="detail-value">${order.expectedDeliveryFormatted}</span>
						</div>
						<div class="detail-row">
							<span class="detail-label">Payment Mode</span><span
								class="detail-value">${order.paymentMode.label}</span>
						</div>
						<div class="detail-row">
							<span class="detail-label">Status</span><span
								class="detail-value"><span
								class="status-badge status-${order.status}">${order.status}</span></span>
						</div>
						<c:if test="${not empty linkedInvoice}">
							<div class="detail-row">
								<span class="detail-label">Invoice</span> <span
									class="detail-value"> <a
									href="${pageContext.request.contextPath}/invoice/${linkedInvoice.id}"
									style="color: var(--color-primary);">
										${linkedInvoice.invoiceNumber} </a>
								</span>
							</div>
						</c:if>
					</div>
					<div class="detail-card">
						<h4>Customer</h4>
						<div class="detail-row">
							<span class="detail-label">Name</span><span class="detail-value">${order.customer.displayName}</span>
						</div>
						<div class="detail-row">
							<span class="detail-label">Email</span><span class="detail-value">${order.customer.email}</span>
						</div>
						<div class="detail-row">
							<span class="detail-label">Phone</span><span class="detail-value">${not empty order.customer.phone ? order.customer.phone : '—'}</span>
						</div>
						<div class="detail-row">
							<span class="detail-label">GSTIN</span><span class="detail-value">${not empty order.customer.gstin ? order.customer.gstin : '—'}</span>
						</div>
					</div>
					<c:if
						test="${not empty order.billingAddress or not empty order.shippingAddress}">
						<div class="detail-card">
							<h4>Addresses</h4>
							<c:if test="${not empty order.billingAddress}">
								<div class="detail-row"
									style="flex-direction: column; gap: 4px;">
									<span class="detail-label">Billing</span> <span
										style="font-size: 0.85rem; white-space: pre-wrap;">${order.billingAddress}</span>
								</div>
							</c:if>
							<c:if test="${not empty order.shippingAddress}">
								<div class="detail-row"
									style="flex-direction: column; gap: 4px; margin-top: 10px;">
									<span class="detail-label">Shipping</span> <span
										style="font-size: 0.85rem; white-space: pre-wrap;">${order.shippingAddress}</span>
								</div>
							</c:if>
						</div>
					</c:if>
					<c:if test="${not empty order.notes}">
						<div class="detail-card">
							<h4>Notes</h4>
							<p style="font-size: 0.875rem; margin: 0; white-space: pre-wrap;">${order.notes}</p>
						</div>
					</c:if>
				</div>

				<%-- Line Items --%>
				<div class="table-card">
					<div
						style="padding: 16px 20px; border-bottom: 1px solid var(--color-border); font-weight: 600; font-size: 0.9rem;">
						Order Items</div>
					<table class="items-table">
						<thead>
							<tr>
								<th>#</th>
								<th>Product / Description</th>
								<th style="text-align: right;">Qty</th>
								<th style="text-align: right;">Unit Price</th>
								<th style="text-align: right;">Disc %</th>
								<th style="text-align: right;">Tax %</th>
								<th style="text-align: right;">Amount</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="item" items="${order.items}" varStatus="loop">
								<tr>
									<td class="text-muted">${loop.index + 1}</td>
									<td><c:if test="${not empty item.product}">
											<div class="fw-500">${item.product.name}</div>
										</c:if> <c:if test="${not empty item.description}">
											<div class="text-muted" style="font-size: 0.8rem;">${item.description}</div>
										</c:if></td>
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
								<fmt:formatNumber value="${order.subtotal}" pattern="#,##0.00" />
							</div>
							<div class="totals-row">
								<span class="text-muted">Discount</span> &nbsp; −&#8377;
								<fmt:formatNumber value="${order.totalDiscount}"
									pattern="#,##0.00" />
							</div>
							<div class="totals-row">
								<span class="text-muted">Tax (GST)</span> &nbsp; +&#8377;
								<fmt:formatNumber value="${order.totalTax}" pattern="#,##0.00" />
							</div>
							<div class="totals-row grand">
								Total &nbsp; &#8377;
								<fmt:formatNumber value="${order.totalAmount}"
									pattern="#,##0.00" />
							</div>
						</div>
					</div>
				</div>

			</div>
		</div>
	</div>

	<%-- ═══ CONFIRM MODAL ═══ --%>
	<div class="modal fade" id="confirmModal" tabindex="-1">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content"
				style="border-radius: 12px; border: none; box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);">
				<div class="modal-header"
					style="border-bottom: 1px solid var(--color-border); padding: 18px 24px;">
					<h5 class="modal-title" style="font-size: 1rem; font-weight: 600;">Confirm
						Order ${order.orderNumber}?</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body" style="padding: 20px 24px;">
					<p
						style="font-size: 0.875rem; color: var(--color-text-muted); margin-bottom: 14px;">
						Stock will be deducted for the following items and a draft invoice
						will be auto-generated:</p>
					<table
						style="width: 100%; font-size: 0.83rem; border-collapse: collapse;">
						<thead>
							<tr
								style="background: #f8fafc; border-bottom: 1px solid var(--color-border);">
								<th
									style="padding: 6px 10px; text-align: left; font-weight: 600; color: var(--color-text-muted); font-size: 0.72rem; text-transform: uppercase;">Product</th>
								<th
									style="padding: 6px 10px; text-align: right; font-weight: 600; color: var(--color-text-muted); font-size: 0.72rem; text-transform: uppercase;">Qty</th>
								<th
									style="padding: 6px 10px; text-align: right; font-weight: 600; color: var(--color-text-muted); font-size: 0.72rem; text-transform: uppercase;">Amount</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="item" items="${order.items}">
								<tr style="border-bottom: 1px solid var(--color-border);">
									<td style="padding: 7px 10px;"><c:if
											test="${not empty item.product}">${item.product.name}</c:if>
										<c:if
											test="${empty item.product and not empty item.description}">${item.description}</c:if>
									</td>
									<td style="padding: 7px 10px; text-align: right;">${item.quantity}</td>
									<td
										style="padding: 7px 10px; text-align: right; font-weight: 500;">&#8377;<fmt:formatNumber
											value="${item.amount}" pattern="#,##0.00" /></td>
								</tr>
							</c:forEach>
						</tbody>
					</table>
					<div
						style="display: flex; justify-content: flex-end; padding-top: 10px; font-size: 0.9rem; font-weight: 700;">
						Total: &#8377;
						<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00" />
					</div>
					<div
						style="margin-top: 14px; padding: 10px 14px; background: #eff6ff; border-radius: 6px; font-size: 0.82rem; color: #1d4ed8;">
						&#10003; A draft invoice will be created automatically and can be
						reviewed before sending to the customer.</div>
				</div>
				<div class="modal-footer"
					style="border-top: 1px solid var(--color-border); padding: 14px 24px; gap: 10px;">
					<button type="button" class="btn-action-lg" data-bs-dismiss="modal"
						style="background: #f1f5f9; color: #475569; border: 1px solid var(--color-border);">
						Go Back</button>
					<form
						action="${pageContext.request.contextPath}/order/${order.id}/confirm"
						method="post" style="margin: 0;">
						<button type="submit" class="btn-action-lg btn-confirm">
							Yes, Confirm Order</button>
					</form>
				</div>
			</div>
		</div>
	</div>

	<%-- ═══ SHIP MODAL ═══ --%>
	<div class="modal fade" id="shipModal" tabindex="-1">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content"
				style="border-radius: 12px; border: none; box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);">
				<div class="modal-header"
					style="border-bottom: 1px solid var(--color-border); padding: 18px 24px;">
					<h5 class="modal-title" style="font-size: 1rem; font-weight: 600;">Mark
						Order Shipped?</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body" style="padding: 20px 24px;">
					<div style="font-size: 0.875rem; margin-bottom: 12px;">
						<span style="color: var(--color-text-muted);">Order</span> <strong>${order.orderNumber}</strong>
						&nbsp;·&nbsp; <span style="color: var(--color-text-muted);">Customer</span>
						<strong>${order.customer.displayName}</strong>
					</div>
					<div
						style="font-size: 0.875rem; color: var(--color-text-muted); margin-bottom: 8px;">
						${order.items.size()} item(s) &nbsp;·&nbsp; Total &#8377;
						<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00" />
					</div>
					<c:if test="${not empty order.shippingAddress}">
						<div
							style="margin-top: 12px; padding: 10px 14px; background: #f8fafc; border-radius: 6px; font-size: 0.82rem;">
							<div
								style="font-weight: 600; margin-bottom: 4px; color: var(--color-text-muted); font-size: 0.72rem; text-transform: uppercase;">Ship
								To</div>
							<div style="white-space: pre-wrap;">${order.shippingAddress}</div>
						</div>
					</c:if>
					<c:if test="${not empty linkedInvoice}">
						<div
							style="margin-top: 12px; padding: 10px 14px; background: #f0fdf4; border-radius: 6px; font-size: 0.82rem; color: #15803d;">
							&#128196; Invoice ${linkedInvoice.invoiceNumber} is linked to
							this order.</div>
					</c:if>
				</div>
				<div class="modal-footer"
					style="border-top: 1px solid var(--color-border); padding: 14px 24px; gap: 10px;">
					<button type="button" class="btn-action-lg" data-bs-dismiss="modal"
						style="background: #f1f5f9; color: #475569; border: 1px solid var(--color-border);">
						Go Back</button>
					<form
						action="${pageContext.request.contextPath}/order/${order.id}/ship"
						method="post" style="margin: 0;">
						<button type="submit" class="btn-action-lg btn-ship">Mark
							as Shipped</button>
					</form>
				</div>
			</div>
		</div>
	</div>

	<%-- ═══ DELIVER MODAL ═══ --%>
	<div class="modal fade" id="deliverModal" tabindex="-1">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content"
				style="border-radius: 12px; border: none; box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);">
				<div class="modal-header"
					style="border-bottom: 1px solid var(--color-border); padding: 18px 24px;">
					<h5 class="modal-title" style="font-size: 1rem; font-weight: 600;">Mark
						Order Delivered?</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body" style="padding: 20px 24px;">
					<div style="font-size: 0.875rem; margin-bottom: 12px;">
						<span style="color: var(--color-text-muted);">Order</span> <strong>${order.orderNumber}</strong>
						&nbsp;·&nbsp; <span style="color: var(--color-text-muted);">Customer</span>
						<strong>${order.customer.displayName}</strong>
					</div>
					<div style="font-size: 0.875rem; color: var(--color-text-muted);">
						Total &#8377;
						<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00" />
					</div>
					<c:if test="${not empty linkedInvoice}">
						<div
							style="margin-top: 14px; padding: 10px 14px; background: #eff6ff; border-radius: 6px; font-size: 0.82rem; color: #1d4ed8;">
							&#128196; Invoice <a
								href="${pageContext.request.contextPath}/invoice/${linkedInvoice.id}"
								style="color: #1d4ed8; font-weight: 500;">${linkedInvoice.invoiceNumber}</a>
							is <span class="status-badge status-${linkedInvoice.status}"
								style="font-size: 0.65rem;">${linkedInvoice.status}</span> —
							remember to send it to the customer after delivery.
						</div>
					</c:if>
				</div>
				<div class="modal-footer"
					style="border-top: 1px solid var(--color-border); padding: 14px 24px; gap: 10px;">
					<button type="button" class="btn-action-lg" data-bs-dismiss="modal"
						style="background: #f1f5f9; color: #475569; border: 1px solid var(--color-border);">
						Go Back</button>
					<form
						action="${pageContext.request.contextPath}/order/${order.id}/deliver"
						method="post" style="margin: 0;">
						<button type="submit" class="btn-action-lg btn-deliver">Confirm
							Delivery</button>
					</form>
				</div>
			</div>
		</div>
	</div>

	<%-- ═══ CANCEL MODAL ═══ --%>
	<div class="modal fade" id="cancelModal" tabindex="-1">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content"
				style="border-radius: 12px; border: none; box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);">
				<div class="modal-header"
					style="border-bottom: 1px solid var(--color-border); padding: 18px 24px;">
					<h5 class="modal-title" style="font-size: 1rem; font-weight: 600;">Cancel
						Order ${order.orderNumber}?</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body" style="padding: 20px 24px;">
					<c:choose>
						<c:when test="${order.status == 'DRAFT'}">
							<p
								style="font-size: 0.875rem; color: var(--color-text-muted); margin: 0;">
								This order is a draft. No stock has been reserved. Cancelling
								will discard it permanently.</p>
						</c:when>
						<c:otherwise>
							<p style="font-size: 0.875rem; margin-bottom: 12px;">
								Stock for the following items will be <strong>restored</strong>:
							</p>
							<table
								style="width: 100%; font-size: 0.83rem; border-collapse: collapse;">
								<tbody>
									<c:forEach var="item" items="${order.items}">
										<tr style="border-bottom: 1px solid var(--color-border);">
											<td style="padding: 6px 10px;"><c:if
													test="${not empty item.product}">${item.product.name}</c:if>
											</td>
											<td
												style="padding: 6px 10px; text-align: right; color: var(--color-text-muted);">+${item.quantity}
												units restored</td>
										</tr>
									</c:forEach>
								</tbody>
							</table>
							<c:if test="${not empty linkedInvoice}">
								<div
									style="margin-top: 12px; padding: 10px 14px; background: #fff7ed; border-radius: 6px; font-size: 0.82rem; color: #b45309;">
									&#9888; Invoice ${linkedInvoice.invoiceNumber} is linked to
									this order — it will remain and must be cancelled separately.</div>
							</c:if>
						</c:otherwise>
					</c:choose>
				</div>
				<div class="modal-footer"
					style="border-top: 1px solid var(--color-border); padding: 14px 24px; gap: 10px;">
					<button type="button" class="btn-action-lg" data-bs-dismiss="modal"
						style="background: #f1f5f9; color: #475569; border: 1px solid var(--color-border);">
						Go Back</button>
					<form
						action="${pageContext.request.contextPath}/order/${order.id}/cancel"
						method="post" style="margin: 0;">
						<button type="submit" class="btn-action-lg btn-cancel-lg">Yes,
							Cancel Order</button>
					</form>
				</div>
			</div>
		</div>
	</div>

</body>
</html>
