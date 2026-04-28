<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt"%>
<!DOCTYPE html>
<html>
<head>
<title>Products — IMS</title>
<jsp:include page="/WEB-INF/views/include/styling.jsp" />
</head>
<body>
	<%@ include file="../../navbar.jsp"%>
	<div class="container-fluid p-0">
		<div class="row g-0">
			<div><jsp:include page="../sidebar.jsp" /></div>

			<div class="main-content">

				<div class="page-header">
					<div>
						<h2>Products</h2>
						<div class="page-subtitle">Manage your product inventory</div>
					</div>
					<div style="display: flex; gap: 8px; align-items: center;">
						<a
							href="${pageContext.request.contextPath}/product/request-master"
							class="btn-secondary-custom">Request Master Product</a> <a
							href="${pageContext.request.contextPath}/product/new"
							class="btn-primary-custom"> <svg width="14" height="14"
								fill="none" viewBox="0 0 24 24" stroke="currentColor"
								stroke-width="2.5">
                            <path stroke-linecap="round"
									stroke-linejoin="round" d="M12 4v16m8-8H4" />
                        </svg> Add Product
						</a>
					</div>
				</div>

				<%-- Flash message --%>
				<c:if test="${not empty successMessage}">
					<div class="flash-success">
						<svg width="16" height="16" fill="none" viewBox="0 0 24 24"
							stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round"
								stroke-linejoin="round"
								d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
						${successMessage}
					</div>
				</c:if>

				<c:if test="${not empty errorMessage}">
					<div class="alert alert-danger" style="margin-bottom: 12px;">
						${errorMessage}</div>
				</c:if>

				<div class="search-bar">
					<svg class="search-icon" width="15" height="15" fill="none"
						viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round"
							d="M21 21l-4.35-4.35M17 11A6 6 0 115 11a6 6 0 0112 0z" />
                </svg>
					<input type="text" id="searchInput" placeholder="Search products…"
						onkeyup="filterTable('productTable')">
				</div>

				<div class="table-card">
					<table id="productTable">
						<thead>
							<tr>
								<th>#</th>
								<th>Product</th>
								<th>Category</th>
								<th>Supplier</th>
								<th>Cost Price</th>
								<th>Selling Price</th>
								<th>MRP</th>
								<th>Actions</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="p" items="${products}" varStatus="loop">
								<tr>
									<td style="color: var(--color-text-muted); width: 48px;">${loop.index + 1}</td>
									<td>
										<div class="product-name-cell">
											<div class="product-avatar">${p.name.substring(0,1)}</div>
											<div>
												<div class="product-name">${p.name}</div>
												<div class="product-sku">SKU: ${p.sku}</div>
											</div>
										</div>
									</td>
									<td><c:choose>
											<c:when test="${not empty p.category}">
												<span class="category-pill">${p.category.name}</span>
											</c:when>
											<c:otherwise>
												<span
													style="font-style: italic; opacity: 0.45; font-size: 0.82rem;">—</span>
											</c:otherwise>
										</c:choose></td>
									<td><c:choose>
											<c:when test="${not empty p.supplier}">
												<span class="supplier-pill">${p.supplier.name}</span>
											</c:when>
											<c:otherwise>
												<span
													style="font-style: italic; opacity: 0.45; font-size: 0.82rem;">—</span>
											</c:otherwise>
										</c:choose></td>
									<td class="price-cell">₹<fmt:formatNumber
											value="${p.costPrice}" pattern="#,##0.00" />
									</td>
									<td class="price-cell">₹<fmt:formatNumber
											value="${p.sellingPrice}" pattern="#,##0.00" />
									</td>
									<td class="price-cell">₹<fmt:formatNumber value="${p.mrp}"
											pattern="#,##0.00" />
									</td>
									<td>
										<div style="display: flex; gap: 6px; align-items: center;">
											<a
												href="${pageContext.request.contextPath}/product/edit/${p.id}"
												class="btn-action btn-edit"> <svg width="12" height="12"
													fill="none" viewBox="0 0 24 24" stroke="currentColor"
													stroke-width="2.2">
                                                <path
														stroke-linecap="round" stroke-linejoin="round"
														d="M15.232 5.232l3.536 3.536M9 13l6.586-6.586a2 2 0 012.828 2.828L11.828 15.828a4 4 0 01-1.414.586l-3 .586.586-3a4 4 0 01.586-1.414z" />
                                            </svg> Edit
											</a>
											<form
												action="${pageContext.request.contextPath}/product/delete/${p.id}"
												method="post" style="margin: 0;"
												onsubmit="return confirm('Deactivate product: ${p.name}?')">
												<button type="submit" class="btn-action btn-delete">
													<svg width="12" height="12" fill="none" viewBox="0 0 24 24"
														stroke="currentColor" stroke-width="2.2">
                                                    <path
															stroke-linecap="round" stroke-linejoin="round"
															d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636" />
                                                </svg>
													Delete
												</button>
											</form>
										</div>
									</td>
								</tr>
							</c:forEach>

							<c:if test="${empty products}">
								<tr>
									<td colspan="8">
										<div class="empty-state">
											<svg width="40" height="40" fill="none" viewBox="0 0 24 24"
												stroke="currentColor" stroke-width="1.5">
                                            <path stroke-linecap="round"
													stroke-linejoin="round"
													d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                                        </svg>
											<p>
												No products found. <a
													href="${pageContext.request.contextPath}/product/new"
													style="color: var(--color-primary);">Add one now.</a>
											</p>
											<p style="margin-top: 6px; font-size: 0.86rem;">
												Missing product in catalog? <a
													href="${pageContext.request.contextPath}/product/request-master"
													style="color: var(--color-primary);">Request add to
													master list.</a>
											</p>
										</div>
									</td>
								</tr>
							</c:if>
						</tbody>
					</table>

					<c:if test="${not empty products}">
						<div class="table-footer">
							Showing <span id="visibleCount">${products.size()}</span> of
							${products.size()} products
						</div>
					</c:if>
				</div>

			</div>
		</div>
	</div>

</body>
</html>
