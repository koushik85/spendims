<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="jakarta.tags.functions" prefix="fn"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Master Products - Admin</title>
<jsp:include page="/WEB-INF/views/include/styling.jsp" />
</head>
<body>

	<%@ include file="../../navbar.jsp"%>

	<div class="container-fluid p-0">
		<div class="row g-0">
			<div><jsp:include page="../sidebar.jsp" /></div>
			<div class="main-content">

				<div class="page-header flex">
					<div>
						<h2>
							<span class="page-title-main">Master Products</span>
						</h2>
						<div class="page-subtitle">Global product catalog available
							to all enterprise users.</div>
					</div>
					<div class="flex-gap-6">
						<a
							href="${pageContext.request.contextPath}/admin/master-products/requests"
							class="btn-secondary-custom">View Requests</a> <a
							href="${pageContext.request.contextPath}/admin/master-products/new"
							class="btn-primary-custom"> <svg width="14" height="14"
								fill="none" viewBox="0 0 24 24" stroke="currentColor"
								stroke-width="2.5">
                            <path stroke-linecap="round"
									stroke-linejoin="round" d="M12 4v16m8-8H4" />
                        </svg> Add Product
						</a>
					</div>
				</div>

				<c:if test="${not empty successMessage}">
					<div class="flash-success">
						<svg width="16" height="16" fill="none" viewBox="0 0 24 24"
							stroke="currentColor" stroke-width="2" style="flex-shrink: 0;">
                        <path stroke-linecap="round"
								stroke-linejoin="round"
								d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
						${successMessage}
					</div>
				</c:if>

				<div class="table-card">
					<table>
						<thead>
							<tr>
								<th>#</th>
								<th>Name</th>
								<th>Category</th>
								<th>HSN</th>
								<th>Actions</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="mp" items="${masterProducts}" varStatus="loop">
								<tr>
									<td class="col-index">${loop.index + 1}</td>
									<td style="font-weight: 500;">${mp.name}</td>
									<td><span class="category-pill">${mp.categoryName}</span></td>
									<td class="text-muted">${mp.hsnCode}</td>
									<td>
										<div class="flex-gap-6">
											<a
												href="${pageContext.request.contextPath}/admin/master-products/edit/${mp.id}"
												class="btn-action btn-edit">Edit</a>
											<form method="post"
												action="${pageContext.request.contextPath}/admin/master-products/delete/${mp.id}"
												onsubmit="return confirm('Deactivate this product?')">
												<button class="btn-action btn-delete">Delete</button>
											</form>
										</div>
									</td>
								</tr>
							</c:forEach>
							<c:if test="${empty masterProducts}">
								<tr>
									<td colspan="6"
										style="text-align: center; padding: 40px; color: var(--color-text-muted);">No
										master products yet.</td>
								</tr>
							</c:if>
						</tbody>
					</table>
				</div>

			</div>
		</div>
	</div>

</body>
</html>
