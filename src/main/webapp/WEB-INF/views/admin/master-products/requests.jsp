<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="jakarta.tags.functions" prefix="fn"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Product Requests — Admin</title>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/ims-shared.css">
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
							<span class="page-title-main">Product Requests</span>
						</h2>
						<div class="page-subtitle">Review user submissions to add
							products to the master catalog.</div>
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
								<th>Product</th>
								<th>Category</th>
								<th>Requested By</th>
								<th>Date</th>
								<th>Status</th>
								<th>Actions</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="r" items="${requests}">
								<tr>
									<td>
										<div style="font-weight: 500;">${r.name}</div> <c:if
											test="${not empty r.description}">
											<div class="text-muted" style="font-size: 0.78rem;">${r.description}</div>
										</c:if>
									</td>
									<td><span class="category-pill">${r.categoryName}</span></td>
									<td>
										<div style="font-weight: 500;">${r.requestedBy.firstName}
											${r.requestedBy.lastName}</div>
										<div class="text-muted" style="font-size: 0.78rem;">${r.requestedBy.email}</div>
									</td>
									<td class="text-muted"
										style="font-size: 0.8rem; white-space: nowrap;">${r.requestedAt}</td>
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
									<td><c:if test="${r.requestStatus == 'PENDING'}">
											<div class="flex-gap-6">
												<form method="post"
													action="${pageContext.request.contextPath}/admin/master-products/requests/${r.id}/approve">
													<button class="btn-action btn-adjust-plus">Approve</button>
												</form>
												<button class="btn-action btn-delete"
													onclick="openReject(${r.id})">Reject</button>
											</div>
										</c:if> <c:if
											test="${r.requestStatus == 'REJECTED' and not empty r.reviewNote}">
											<span class="text-muted"
												style="font-size: 0.78rem; font-style: italic;">${r.reviewNote}</span>
										</c:if></td>
								</tr>
							</c:forEach>
							<c:if test="${empty requests}">
								<tr>
									<td colspan="6"
										style="text-align: center; padding: 40px; color: var(--color-text-muted);">No
										product requests yet.</td>
								</tr>
							</c:if>
						</tbody>
					</table>
				</div>

			</div>
		</div>
	</div>

	<%-- Reject modal --%>
	<div id="rejectOverlay"
		style="display: none; position: fixed; inset: 0; background: rgba(0, 0, 0, 0.4); z-index: 500; align-items: center; justify-content: center;">
		<div
			style="background: #fff; border-radius: 12px; padding: 28px; max-width: 440px; width: 90%; box-shadow: 0 8px 32px rgba(0, 0, 0, 0.18);">
			<h5 style="margin: 0 0 16px; font-size: 1rem; font-weight: 700;">Reject
				Request</h5>
			<form id="rejectForm" method="post">
				<div class="form-group">
					<label>Reason <span class="optional">(optional)</span></label>
					<textarea name="reviewNote" rows="3"
						placeholder="Reason for rejection…"></textarea>
				</div>
				<div class="form-actions">
					<button type="submit" class="btn-save"
						style="background: var(--color-danger);">Confirm Reject</button>
					<button type="button" class="btn-cancel" onclick="closeReject()">Cancel</button>
				</div>
			</form>
		</div>
	</div>

	<script>
    function openReject(id) {
    	document.getElementById('rejectForm').action = ctx + '/admin/master-products/requests/' + id + '/reject';
        const overlay = document.getElementById('rejectOverlay');
        overlay.style.display = 'flex';
    }
    function closeReject() {
        document.getElementById('rejectOverlay').style.display = 'none';
    }
</script>

</body>
</html>
