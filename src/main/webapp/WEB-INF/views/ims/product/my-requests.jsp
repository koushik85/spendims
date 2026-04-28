<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>My Product Requests - IMS</title>
<jsp:include
	page="${pageContext.request.contextPath}/include/styling.jsp" />
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/ims-shared.css">
</head>
<body>

	<%@ include file="../../navbar.jsp"%>

	<div class="container-fluid p-0">
		<div class="row g-0">
			<div><jsp:include page="../../ims/sidebar.jsp" /></div>
			<div class="main-content">

				<div class="breadcrumb-bar">
					<a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
					<span class="sep">&#8250;</span> <a
						href="${pageContext.request.contextPath}/product">Products</a> <span
						class="sep">&#8250;</span> <span class="current">My
						Requests</span>
				</div>

				<div class="page-header flex">
					<div>
						<h2>
							<span class="page-title-main">My Product Requests</span>
						</h2>
						<div class="page-subtitle">Track requests you've submitted
							for the master catalog.</div>
					</div>
					<a href="${pageContext.request.contextPath}/product/request-master"
						class="btn-primary-custom"> <svg width="14" height="14"
							fill="none" viewBox="0 0 24 24" stroke="currentColor"
							stroke-width="2.5">
                        <path stroke-linecap="round"
								stroke-linejoin="round" d="M12 4v16m8-8H4" />
                    </svg> New Request
					</a>
				</div>

				<div class="table-card">
					<table>
						<thead>
							<tr>
								<th>Product</th>
								<th>Category</th>
								<th>Submitted</th>
								<th>Status</th>
								<th>Review Note</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="r" items="${requests}">
								<tr>
									<td style="font-weight: 500;">${r.name}</td>
									<td>${r.categoryName}</td>
									<td class="text-muted"
										style="font-size: 0.82rem; white-space: nowrap;">${r.requestedAt}</td>
									<td><c:choose>
											<c:when test="${r.requestStatus == 'PENDING'}">
												<span class="badge-pending">Pending</span>
											</c:when>
											<c:when test="${r.requestStatus == 'APPROVED'}">
												<span class="badge-approved">Approved</span>
											</c:when>
											<c:otherwise>
												<span class="badge-rejected">Rejected</span>
											</c:otherwise>
										</c:choose></td>
									<td class="text-muted" style="font-size: 0.82rem;">${r.reviewNote}</td>
								</tr>
							</c:forEach>
							<c:if test="${empty requests}">
								<tr>
									<td colspan="5"
										style="text-align: center; padding: 40px; color: var(--color-text-muted);">
										No requests submitted yet.</td>
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
