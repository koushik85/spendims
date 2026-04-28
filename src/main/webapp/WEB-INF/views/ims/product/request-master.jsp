<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Request Master Product - IMS</title>
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
						class="sep">&#8250;</span> <span class="current">Request
						Master Product</span>
				</div>

				<div class="page-header">
					<div>
						<h2>
							<span class="page-title-main">Request Product</span>
						</h2>
						<div class="page-subtitle">Submit a product for the global
							master catalog — a Super Admin will review it.</div>
					</div>
				</div>

				<c:if test="${not empty errorMessage}">
					<div class="flash-error">
						<svg width="16" height="16" fill="none" viewBox="0 0 24 24"
							stroke="currentColor" stroke-width="2" style="flex-shrink: 0;">
                        <path stroke-linecap="round"
								stroke-linejoin="round"
								d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
						${errorMessage}
					</div>
				</c:if>

				<div class="form-card" style="max-width: 760px;">
					<div class="form-card-header">Product Request Details</div>
					<div class="form-card-body">
						<form method="post"
							action="${pageContext.request.contextPath}/product/request-master">
							<div class="form-grid">
								<div class="form-group">
									<label for="name">Product Name <span class="required">*</span></label>
									<input type="text" id="name" name="name"
										value="${request.name}" required>
								</div>
								<div class="form-group">
									<label for="categoryName">Category <span
										class="required">*</span></label> <input type="text" id="categoryName"
										name="categoryName" value="${request.categoryName}" required>
								</div>

								<div class="form-group" style="position: relative;">
									<label for="hsnSearch">HSN Code <span class="required">*</span></label>
									<input type="text" id="hsnSearch" name="hsnCode"
										placeholder="Search HSN (e.g. laptop, mobile)"
										value="${request.hsnCode}" autocomplete="off" required>
									<input type="hidden" id="hsnId" value="">
									<div id="hsnSuggestions" class="suggestions-box"></div>
									<div class="field-hint">Search and select a valid HSN
										code.</div>
								</div>

								<div class="form-group span-2">
									<label for="description">Description <span
										class="optional">optional</span></label>
									<textarea id="description" name="description" rows="3"
										placeholder="Brief description of the requested product...">${request.description}</textarea>
								</div>
							</div>

							<div class="form-divider"></div>

							<div class="form-actions">
								<button type="submit" class="btn-save">Submit Request</button>
								<a href="${pageContext.request.contextPath}/product"
									class="btn-cancel">Cancel</a>
							</div>
						</form>
					</div>
				</div>

			</div>
		</div>
	</div>

	<script src="${pageContext.request.contextPath}/js/ims-product-form.js"></script>
</body>
</html>
