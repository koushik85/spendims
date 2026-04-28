<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Personal Finance — Spendilizer</title>
<jsp:include
	page="${pageContext.request.contextPath}/include/styling.jsp" />
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/ims-shared.css">
</head>
<body>

	<%@ include file="../navbar.jsp"%>

	<div class="container-fluid p-0">
		<div class="row g-0">
			<div><jsp:include page="sidebar.jsp" /></div>

			<div class="main-content">

				<div class="page-header flex">
					<div>
						<h2>
							<span class="greeting">Hi, ${user.firstName}</span> <span
								class="page-title-main">My Finance</span>
						</h2>
						<div class="page-subtitle">Your splits and subscriptions at
							a glance</div>
					</div>
					<div class="page-date" id="js-date"></div>
				</div>

				<%-- Stats row --%>
				<div class="row g-3 mb-4">
					<div class="col-6 col-md-3">
						<div class="stat-card card-purple">
							<div class="stat-icon">
								<svg width="17" height="17" fill="none" viewBox="0 0 24 24"
									stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round"
										stroke-linejoin="round"
										d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
                            </svg>
							</div>
							<div class="stat-label">Active Groups</div>
							<div class="stat-value">${activeGroupCount}</div>
							<div class="stat-hint">split groups</div>
						</div>
					</div>
					<div class="col-6 col-md-3">
						<div class="stat-card card-teal">
							<div class="stat-icon">
								<svg width="17" height="17" fill="none" viewBox="0 0 24 24"
									stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round"
										stroke-linejoin="round"
										d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                            </svg>
							</div>
							<div class="stat-label">Subscriptions</div>
							<div class="stat-value">${activeSubCount}</div>
							<div class="stat-hint">active</div>
						</div>
					</div>
					<div class="col-6 col-md-3">
						<div class="stat-card card-amber">
							<div class="stat-icon">
								<svg width="17" height="17" fill="none" viewBox="0 0 24 24"
									stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round"
										stroke-linejoin="round"
										d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
							</div>
							<div class="stat-label">Monthly Cost</div>
							<div class="stat-value" style="font-size: 1.05rem;">
								&#8377;
								<fmt:formatNumber value="${monthlyCost}" pattern="#,##0.00" />
							</div>
							<div class="stat-hint">subscriptions</div>
						</div>
					</div>
					<div class="col-6 col-md-3">
						<div class="stat-card card-red">
							<div class="stat-icon">
								<svg width="17" height="17" fill="none" viewBox="0 0 24 24"
									stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round"
										stroke-linejoin="round"
										d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                            </svg>
							</div>
							<div class="stat-label">Renewals</div>
							<div class="stat-value">${upcomingRenewals.size()}</div>
							<div class="stat-hint">due in 7 days</div>
						</div>
					</div>
				</div>

				<div class="row g-3">

					<%-- Recent split groups --%>
					<div class="col-12 col-lg-6">
						<div class="activity-card">
							<div class="activity-header">
								<span>Recent split groups</span> <a
									href="${pageContext.request.contextPath}/personal/splits">View
									all &rarr;</a>
							</div>
							<c:choose>
								<c:when test="${empty recentGroups}">
									<div class="empty-state" style="padding: 28px 0;">
										<svg width="32" height="32" fill="none" viewBox="0 0 24 24"
											stroke="currentColor" stroke-width="1.5">
                                        <path stroke-linecap="round"
												stroke-linejoin="round"
												d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
                                    </svg>
										<p>
											No groups yet. <a
												href="${pageContext.request.contextPath}/personal/splits/new">Create
												one &rarr;</a>
										</p>
									</div>
								</c:when>
								<c:otherwise>
									<table class="activity-table">
										<thead>
											<tr>
												<th>Group</th>
												<th>Date</th>
												<th>Status</th>
											</tr>
										</thead>
										<tbody>
											<c:forEach var="g" items="${recentGroups}">
												<tr>
													<td><a
														href="${pageContext.request.contextPath}/personal/splits/${g.id}"
														style="color: var(--color-primary); text-decoration: none; font-weight: 500;"><c:out
																value="${g.name}" /></a></td>
													<td class="date-cell">${g.eventDate != null ? g.eventDate : '—'}</td>
													<td><c:choose>
															<c:when test="${g.status == 'ACTIVE'}">
																<span class="badge-pill badge-in">ACTIVE</span>
															</c:when>
															<c:otherwise>
																<span class="badge-pill badge-out">CLOSED</span>
															</c:otherwise>
														</c:choose></td>
												</tr>
											</c:forEach>
										</tbody>
									</table>
								</c:otherwise>
							</c:choose>
						</div>
					</div>

					<%-- Upcoming renewals --%>
					<div class="col-12 col-lg-6">
						<div class="activity-card">
							<div class="activity-header">
								<span>Upcoming renewals (7 days)</span> <a
									href="${pageContext.request.contextPath}/personal/subscriptions">View
									all &rarr;</a>
							</div>
							<c:choose>
								<c:when test="${empty upcomingRenewals}">
									<div class="empty-state" style="padding: 28px 0;">
										<svg width="32" height="32" fill="none" viewBox="0 0 24 24"
											stroke="currentColor" stroke-width="1.5">
                                        <path stroke-linecap="round"
												stroke-linejoin="round"
												d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                    </svg>
										<p>No renewals in the next 7 days.</p>
									</div>
								</c:when>
								<c:otherwise>
									<table class="activity-table">
										<thead>
											<tr>
												<th>Subscription</th>
												<th>Amount</th>
												<th>Due</th>
											</tr>
										</thead>
										<tbody>
											<c:forEach var="s" items="${upcomingRenewals}">
												<tr>
													<td style="font-weight: 500;"><c:out value="${s.name}" /></td>
													<td>&#8377;<fmt:formatNumber value="${s.amount}"
															pattern="#,##0.00" /></td>
													<td class="date-cell">${s.nextBillingDate}</td>
												</tr>
											</c:forEach>
										</tbody>
									</table>
								</c:otherwise>
							</c:choose>
						</div>
					</div>

				</div>

			</div>
		</div>
	</div>

	<script>
		initLiveDate('js-date');
	</script>
</body>
</html>
