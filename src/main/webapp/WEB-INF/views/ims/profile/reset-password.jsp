<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<title>Reset Password — IMS</title>
<jsp:include page="/WEB-INF/views/include/styling.jsp" />
</head>
<body>
	<%@ include file="../../navbar.jsp"%>
	<div class="container-fluid p-0">
		<div class="row g-0">
			<div><jsp:include page="../sidebar.jsp" /></div>

			<div class="main-content">

				<div class="breadcrumb-bar">
					<a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
					<span class="sep">›</span> <span class="current">Reset
						Password</span>
				</div>

				<div class="page-header">
					<h2>
						<span class="header-icon"> <svg width="16" height="16"
								fill="none" viewBox="0 0 24 24" stroke="currentColor"
								stroke-width="2">
                            <path stroke-linecap="round"
									stroke-linejoin="round"
									d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                        </svg>
						</span> Reset Password
					</h2>
					<div class="page-subtitle">Change your account password.</div>
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

				<div class="form-card">
					<div class="form-card-header">Change Password</div>
					<div class="form-card-body">
						<form
							action="${pageContext.request.contextPath}/profile/reset-password"
							method="post" id="pwForm">

							<div class="form-group">
								<label for="currentPassword">Current Password <span
									class="required">*</span></label>
								<div style="position: relative;">
									<input type="password" id="currentPassword"
										name="currentPassword" required autofocus>
									<button type="button" class="pw-toggle-btn"
										onclick="togglePw('currentPassword','eyeCurrent')"
										tabindex="-1">
										<svg id="eyeCurrent" width="16" height="16" fill="none"
											viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                        <path stroke-linecap="round"
												stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                        <path stroke-linecap="round"
												stroke-linejoin="round"
												d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                    </svg>
									</button>
								</div>
							</div>

							<div class="form-group">
								<label for="newPassword">New Password <span
									class="required">*</span></label>
								<div style="position: relative;">
									<input type="password" id="newPassword" name="newPassword"
										required minlength="8">
									<button type="button" class="pw-toggle-btn"
										onclick="togglePw('newPassword','eyeNew')" tabindex="-1">
										<svg id="eyeNew" width="16" height="16" fill="none"
											viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                        <path stroke-linecap="round"
												stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                        <path stroke-linecap="round"
												stroke-linejoin="round"
												d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                    </svg>
									</button>
								</div>
								<div class="field-hint">Minimum 8 characters.</div>
							</div>

							<div class="form-group">
								<label for="confirmPassword">Confirm New Password <span
									class="required">*</span></label>
								<div style="position: relative;">
									<input type="password" id="confirmPassword"
										name="confirmPassword" required>
									<button type="button" class="pw-toggle-btn"
										onclick="togglePw('confirmPassword','eyeConfirm')"
										tabindex="-1">
										<svg id="eyeConfirm" width="16" height="16" fill="none"
											viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                        <path stroke-linecap="round"
												stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                        <path stroke-linecap="round"
												stroke-linejoin="round"
												d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                    </svg>
									</button>
								</div>
								<div id="matchHint" class="field-hint"></div>
							</div>

							<div class="form-divider"></div>

							<div class="form-actions">
								<button type="submit" class="btn-save">
									<svg width="14" height="14" fill="none" viewBox="0 0 24 24"
										stroke="currentColor" stroke-width="2.5">
                                    <path stroke-linecap="round"
											stroke-linejoin="round" d="M5 13l4 4L19 7" />
                                </svg>
									Change Password
								</button>
								<a href="${pageContext.request.contextPath}/dashboard"
									class="btn-cancel">Cancel</a>
							</div>

						</form>
					</div>
				</div>

			</div>
		</div>
	</div>

	<style>
.pw-toggle-btn {
	position: absolute;
	right: 10px;
	top: 50%;
	transform: translateY(-50%);
	background: none;
	border: none;
	cursor: pointer;
	color: var(--color-text-muted);
	padding: 2px;
	line-height: 1;
}

.pw-toggle-btn:hover {
	color: var(--color-text);
}
</style>

	<script src="${pageContext.request.contextPath}/js/ims-shared.js"></script>
	<script>
		document
				.getElementById('confirmPassword')
				.addEventListener(
						'input',
						function() {
							const match = this.value === document
									.getElementById('newPassword').value;
							const hint = document.getElementById('matchHint');
							hint.textContent = this.value ? (match ? '✓ Passwords match'
									: 'Passwords do not match')
									: '';
							hint.style.color = match ? 'var(--color-success)'
									: 'var(--color-danger)';
						});
	</script>
</body>
</html>
