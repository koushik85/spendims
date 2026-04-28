<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<title>Customers — IMS</title>
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

				<div class="page-header">
					<div>
						<h2>Customers</h2>
						<div class="page-subtitle">Manage your customer records</div>
					</div>
					<a href="${pageContext.request.contextPath}/customer/new"
						class="btn-primary-custom"> <svg width="14" height="14"
							fill="none" viewBox="0 0 24 24" stroke="currentColor"
							stroke-width="2.5">
                        <path stroke-linecap="round"
								stroke-linejoin="round" d="M12 4v16m8-8H4" />
                    </svg> Add Customer
					</a>
				</div>

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
					<div class="flash-error">
						<svg width="16" height="16" fill="none" viewBox="0 0 24 24"
							stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round"
								stroke-linejoin="round"
								d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
						${errorMessage}
					</div>
				</c:if>

				<div class="search-bar">
					<svg class="search-icon" width="15" height="15" fill="none"
						viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round"
							d="M21 21l-4.35-4.35M17 11A6 6 0 115 11a6 6 0 0112 0z" />
                </svg>
					<input type="text" id="searchInput" placeholder="Search customers…"
						onkeyup="filterTable('customerTable')">
				</div>

				<div class="table-card">
					<table id="customerTable">
						<thead>
							<tr>
								<th>#</th>
								<th>Name</th>
								<th>Email</th>
								<th>Phone</th>
								<th>GSTIN</th>
								<th>Actions</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="c" items="${customers}" varStatus="loop">
								<tr>
									<td class="text-muted" style="width: 48px;">${loop.index + 1}</td>
									<td class="fw-500">${c.displayName} <c:if
											test="${not empty c.companyName}">
											<br>
											<small class="text-muted">${c.firstName}
												${c.lastName}</small>
										</c:if>
									</td>
									<td class="text-muted">${c.email}</td>
									<td class="text-muted">${not empty c.phone ? c.phone : '—'}</td>
									<td class="text-muted">${not empty c.gstin ? c.gstin : '—'}</td>
									<td>
										<div class="flex-gap-6">
											<a
												href="${pageContext.request.contextPath}/customer/edit/${c.id}"
												class="btn-action btn-edit"> <svg width="12" height="12"
													fill="none" viewBox="0 0 24 24" stroke="currentColor"
													stroke-width="2.2">
                                                <path
														stroke-linecap="round" stroke-linejoin="round"
														d="M15.232 5.232l3.536 3.536M9 13l6.586-6.586a2 2 0 012.828 2.828L11.828 15.828a4 4 0 01-1.414.586l-3 .586.586-3a4 4 0 01.586-1.414z" />
                                            </svg> Edit
											</a>
											<form
												action="${pageContext.request.contextPath}/customer/delete/${c.id}"
												method="post" style="margin: 0;"
												onsubmit="return confirm('Delete this customer?')">
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
							<c:if test="${empty customers}">
								<tr>
									<td colspan="6">
										<div class="empty-state">
											<svg width="40" height="40" fill="none" viewBox="0 0 24 24"
												stroke="currentColor" stroke-width="1.5">
                                            <path stroke-linecap="round"
													stroke-linejoin="round"
													d="M17 20h5v-2a4 4 0 00-4-4H6a4 4 0 00-4 4v2h5M12 12a4 4 0 100-8 4 4 0 000 8z" />
                                        </svg>
											<p>
												No customers found. <a
													href="${pageContext.request.contextPath}/customer/new"
													style="color: var(--color-primary);">Add one now.</a>
											</p>
										</div>
									</td>
								</tr>
							</c:if>
						</tbody>
					</table>
					<c:if test="${not empty customers}">
						<div class="table-footer">
							Showing <span id="visibleCount">${customers.size()}</span> of
							${customers.size()} customers
						</div>
					</c:if>
				</div>

			</div>
		</div>
	</div>
	<script src="${pageContext.request.contextPath}/js/ims-shared.js"></script>
</body>
</html>
