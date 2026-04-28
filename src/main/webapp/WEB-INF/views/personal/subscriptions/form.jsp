<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${editMode ? 'Edit' : 'Add'}Subscription — Spendilizer</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/ims-shared.css">
</head>
<body>

	<%@ include file="../../navbar.jsp"%>
	<div class="container-fluid p-0">
		<div class="row g-0">
			<div><jsp:include page="../sidebar.jsp" /></div>
			<div class="main-content">

				<div class="breadcrumb-bar">
					<a href="${pageContext.request.contextPath}/personal/subscriptions">Subscriptions</a> <span
						class="sep">›</span> <span class="current">${editMode ? 'Edit' : 'Add'}</span>
				</div>

				<div class="page-header">
					<h2>${editMode ? 'Edit Subscription' : 'Add Subscription'}</h2>
					<div class="page-subtitle">${editMode ? 'Update the subscription details below.' : 'Track a new recurring payment.'}</div>
				</div>

				<c:choose>
					<c:when test="${editMode}">
						<c:url var="formAction"
							value="/personal/subscriptions/${subscription.id}/edit" />
					</c:when>
					<c:otherwise>
						<c:url var="formAction" value="/personal/subscriptions/new" />
					</c:otherwise>
				</c:choose>

				<div class="form-card">
					<div class="form-card-header">Subscription Details</div>
					<div class="form-card-body">

						<form action="${formAction}" method="post">
							<input type="hidden" name="${_csrf.parameterName}"
								value="${_csrf.token}">

							<div class="form-row">
								<div class="form-group">
									<label for="name">Service Name <span class="required">*</span></label>
									<input type="text" id="name" name="name"
										value="${subscription.name}"
										placeholder="e.g. Netflix, Spotify, AWS" required>
								</div>
								<div class="form-group">
									<label for="provider">Provider <span class="optional">optional</span></label>
									<input type="text" id="provider" name="provider"
										value="${subscription.provider}"
										placeholder="Company or brand name">
								</div>
							</div>

							<div class="form-row">
								<div class="form-group">
									<label for="amount">Amount (&#8377;) <span
										class="required">*</span></label> <input type="number" id="amount"
										name="amount" value="${subscription.amount}" step="0.01"
										min="0.01" required placeholder="0.00">
								</div>
								<div class="form-group">
									<label for="billingCycle">Billing Cycle <span
										class="required">*</span></label>
									<div class="select-wrapper">
										<select id="billingCycle" name="billingCycle" required
											onchange="updateNextBillingPreview()">
											<c:forEach var="c" items="${cycles}">
												<option value="${c}"
													${subscription.billingCycle == c ? 'selected' : ''}>${c}</option>
											</c:forEach>
										</select>
									</div>
								</div>
							</div>

							<div class="form-row">
								<div class="form-group">
									<label for="startDate">Start Date <span
										class="required">*</span></label> <input type="date" id="startDate"
										name="startDate" value="${subscription.startDate}" required
										onchange="updateNextBillingPreview()">
									<div class="field-hint">The date you first subscribed.</div>
								</div>
								<div class="form-group">
									<label>Next Billing Date</label>
									<div id="nextBillingPreview"
										style="padding: 9px 12px; background: var(--color-bg); border: 1px solid var(--color-border); border-radius: var(--radius-md); font-family: monospace; font-size: 0.88rem; color: var(--color-text-muted); min-height: 40px;">
										<c:choose>
											<c:when test="${not empty subscription.nextBillingDate}">${subscription.nextBillingDate}</c:when>
											<c:otherwise>Set start date &amp; cycle to preview</c:otherwise>
										</c:choose>
									</div>
									<div class="field-hint">Auto-calculated from start date
										&amp; cycle.</div>
								</div>
							</div>

							<div class="form-row">
								<div class="form-group">
									<label for="category">Category <span class="required">*</span></label>
									<div class="select-wrapper">
										<select id="category" name="category" required>
											<c:forEach var="cat" items="${categories}">
												<option value="${cat}"
													${subscription.category == cat ? 'selected' : ''}>${cat}</option>
											</c:forEach>
										</select>
									</div>
								</div>
								<c:if test="${editMode}">
									<div class="form-group">
										<label for="status">Status <span class="required">*</span></label>
										<div class="select-wrapper">
											<select id="status" name="status" required>
												<c:forEach var="st" items="${statuses}">
													<option value="${st}"
														${subscription.status == st ? 'selected' : ''}>${st}</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</c:if>
							</div>

							<div class="form-group">
								<label for="notes">Notes <span class="optional">optional</span></label>
								<textarea id="notes" name="notes" rows="2"
									placeholder="Anything to remember about this subscription"><c:out
										value="${subscription.notes}" /></textarea>
							</div>

							<div class="form-divider"></div>

							<div class="form-actions">
								<button type="submit" class="btn-save">
									<svg width="14" height="14" fill="none" viewBox="0 0 24 24"
										stroke="currentColor" stroke-width="2.5">
                            <path stroke-linecap="round"
											stroke-linejoin="round" d="M5 13l4 4L19 7" />
                        </svg>
									${editMode ? 'Save Changes' : 'Add Subscription'}
								</button>
								<a
									href="${pageContext.request.contextPath}/personal/subscriptions"
									class="btn-cancel">Cancel</a>
							</div>

						</form>
					</div>
				</div>

			</div>
		</div>
	</div>

	<script>
		const CYCLE_DAYS = {
			WEEKLY : 7,
			MONTHLY : 30,
			QUARTERLY : 91,
			YEARLY : 365
		};

		function updateNextBillingPreview() {
			const startVal = document.getElementById('startDate').value;
			const cycle = document.getElementById('billingCycle').value;
			const preview = document.getElementById('nextBillingPreview');

			if (!startVal || !cycle) {
				preview.textContent = 'Set start date & cycle to preview';
				return;
			}

			let next = new Date(startVal + 'T00:00:00');
			const today = new Date();
			today.setHours(0, 0, 0, 0);

			while (next <= today) {
				if (cycle === 'WEEKLY')
					next.setDate(next.getDate() + 7);
				else if (cycle === 'MONTHLY')
					next.setMonth(next.getMonth() + 1);
				else if (cycle === 'QUARTERLY')
					next.setMonth(next.getMonth() + 3);
				else if (cycle === 'YEARLY')
					next.setFullYear(next.getFullYear() + 1);
			}

			const yyyy = next.getFullYear();
			const mm = String(next.getMonth() + 1).padStart(2, '0');
			const dd = String(next.getDate()).padStart(2, '0');
			preview.textContent = yyyy + '-' + mm + '-' + dd;
		}

		// Run on load if values already present (edit mode)
		window.addEventListener('DOMContentLoaded', updateNextBillingPreview);
	</script>
</body>
</html>
