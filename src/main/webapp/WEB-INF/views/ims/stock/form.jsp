<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<title>${empty stock.id ? 'Add Stock Entry' : 'Edit Stock Entry'}
	— IMS</title>
	<jsp:include page="/WEB-INF/views/include/styling.jsp" />
</head>
<body>
	<%@ include file="../../navbar.jsp"%>
	<div class="container-fluid p-0">
		<div class="row g-0">
			<div><jsp:include page="../sidebar.jsp" /></div>

			<div class="main-content">

				<%-- Breadcrumb --%>
				<div class="breadcrumb-bar">
					<a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
					<span class="sep">›</span> <a
						href="${pageContext.request.contextPath}/stock">Stock</a> <span
						class="sep">›</span> <span class="current">${empty stock.id ? 'New Entry' : 'Edit Entry'}</span>
				</div>

				<%-- Page header --%>
				<div class="page-header">
					<h2>
						<span class="header-icon"> <svg width="16" height="16"
								fill="none" viewBox="0 0 24 24" stroke="currentColor"
								stroke-width="2">
                            <path stroke-linecap="round"
									stroke-linejoin="round"
									d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10" />
                        </svg>
						</span> ${empty stock.id ? 'Add Stock Entry' : 'Edit Stock Entry'}
					</h2>
					<div class="page-subtitle">${empty stock.id ? 'Link a product to its inventory quantity and threshold.' : 'Update quantity, threshold, or status for this stock entry.'}
					</div>
				</div>

				<%-- Edit mode banner --%>
				<c:if test="${not empty stock.id}">
					<div class="edit-mode-banner">
						<svg width="15" height="15" fill="none" viewBox="0 0 24 24"
							stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round"
								stroke-linejoin="round"
								d="M13 16h-1v-4h-1m1-4h.01M12 2a10 10 0 100 20A10 10 0 0012 2z" />
                    </svg>
						Editing stock for: <strong>${stock.product.name}</strong>
						&nbsp;·&nbsp; Stock ID: ${stock.id}
					</div>
				</c:if>

				<%-- Form card --%>
				<div class="form-card">
					<div class="form-card-header">Stock Details</div>
					<div class="form-card-body">

						<form
							action="${pageContext.request.contextPath}/stock/${empty stock.id ? 'new' : 'edit/'.concat(stock.id)}"
							method="post">

							<%-- Product selector --%>
							<div class="form-group">
								<label for="productId"> Product <span class="required">*</span>
								</label>
								<div class="select-wrapper">
									<select id="productId" name="product.id"
										required
                                        ${not emptystock.id ? 'disabled' : ''}>
										<option value="" disabled ${emptystock.product ? 'selected' : ''}>
											— Select a product —</option>
										<c:forEach var="p" items="${products}">
											<option value="${p.id}"
												${stock.product.id == p.id ? 'selected' : ''}>
												${p.name}
												<c:if test="${not empty p.category}"> (${p.category.name})</c:if>
											</option>
										</c:forEach>
									</select>
								</div>
								<c:if test="${not empty stock.id}">
									<%-- Keep value on POST when disabled --%>
									<input type="hidden" name="product.id"
										value="${stock.product.id}">
									<div class="field-hint">Product cannot be changed after
										creation.</div>
								</c:if>
							</div>

							<%-- Quantity + Threshold side by side --%>
							<div class="form-row-2">
								<div class="form-group" style="margin-bottom: 0;">
									<label for="quantity"> Quantity <span class="required">*</span>
									</label> <input type="number" id="quantity" name="quantity"
										value="${not empty stock.quantity ? stock.quantity : 0}"
										min="0" required>
									<div class="field-hint">Current units on hand.</div>
								</div>

								<div class="form-group" style="margin-bottom: 0;">
									<label for="minThreshold"> Min Threshold <span
										class="required">*</span>
									</label> <input type="number" id="minThreshold" name="minThreshold"
										value="${not empty stock.minThreshold ? stock.minThreshold : 5}"
										min="0" required>
									<div class="field-hint">Alert when quantity reaches this
										level.</div>
								</div>
							</div>

							<div class="threshold-hint" id="lowStockWarning"
								style="display: none; margin-top: 16px;">
								<svg width="15" height="15" fill="none" viewBox="0 0 24 24"
									stroke="currentColor" stroke-width="2"
									style="flex-shrink: 0; margin-top: 1px;">
                                <path stroke-linecap="round"
										stroke-linejoin="round"
										d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" />
                            </svg>
								Current quantity is at or below the minimum threshold — this
								item will be flagged as low stock.
							</div>

							<div class="form-divider"></div>

							<div class="form-actions">
								<button type="submit" class="btn-save">
									<svg width="14" height="14" fill="none" viewBox="0 0 24 24"
										stroke="currentColor" stroke-width="2.5">
                                    <path stroke-linecap="round"
											stroke-linejoin="round" d="M5 13l4 4L19 7" />
                                </svg>
									${empty stock.id ? 'Create Entry' : 'Save Changes'}
								</button>
								<a href="${pageContext.request.contextPath}/stock"
									class="btn-cancel">Cancel</a>
							</div>

						</form>
					</div>
				</div>

			</div>
		</div>
	</div>

	<script src="${pageContext.request.contextPath}/js/ims-stock-form.js"></script>
</body>
</html>
