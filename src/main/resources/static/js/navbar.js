// ── Bell notification dropdown ───────────────────────────────
function toggleBell() {
	const dropdown = document.getElementById('bellDropdown');
	if (!dropdown) return;
	const isOpen = dropdown.classList.contains('open');
	if (!isOpen) {
		dropdown.classList.add('open');
		markNotificationsSeen();
	} else {
		dropdown.classList.remove('open');
	}
}

function markNotificationsSeen() {
	const badge = document.getElementById('bellBadge');
	if (!badge) return;
	fetch(ctx + '/api/notifications/mark-seen', {
		method: 'POST',
		headers: { [_csrfHeader]: _csrfToken }
	})
		.then(r => r.json())
		.then(() => {
			if (badge) badge.style.display = 'none';
			// Remove new highlight from all items
			document.querySelectorAll('.notif-item--new').forEach(el => {
				el.classList.remove('notif-item--new');
			});
		})
		.catch(() => { });
}

function removeNotif(id) {
	fetch(ctx + '/api/notifications/' + id + '/remove', {
		method: 'POST',
		headers: { [_csrfHeader]: _csrfToken }
	})
		.then(r => r.json())
		.then(data => {
			const el = document.getElementById('notif-' + id);
			if (el) el.remove();

			const badge = document.getElementById('bellBadge');
			if (badge) {
				if (data.newCount > 0) {
					badge.textContent = data.newCount;
					badge.style.display = '';
				} else {
					badge.style.display = 'none';
				}
			}

			const list = document.getElementById('notifList');
			if (list && list.querySelectorAll('.notif-item').length === 0) {
				list.innerHTML = '<div class="notif-empty">You\'re all caught up!</div>';
				const footer = document.querySelector('.notif-panel-footer');
				if (footer) footer.style.display = 'none';
				const clearBtn = document.querySelector('.notif-clear-all');
				if (clearBtn) clearBtn.style.display = 'none';
			}
		})
		.catch(() => { });
}

function clearAllNotifs() {
	const items = document.querySelectorAll('.notif-item');
	const ids = Array.from(items).map(el => el.id.replace('notif-', ''));

	Promise.all(ids.map(id =>
		fetch(ctx + '/api/notifications/' + id + '/remove', {
			method: 'POST',
			headers: { [_csrfHeader]: _csrfToken }
		})
	)).then(() => {
		const list = document.getElementById('notifList');
		if (list) list.innerHTML = '<div class="notif-empty">You\'re all caught up!</div>';
		const badge = document.getElementById('bellBadge');
		if (badge) badge.style.display = 'none';
		const footer = document.querySelector('.notif-panel-footer');
		if (footer) footer.style.display = 'none';
		const clearBtn = document.querySelector('.notif-clear-all');
		if (clearBtn) clearBtn.style.display = 'none';
	}).catch(() => { });
}

document.addEventListener('click', function(e) {
	const btn = document.getElementById('bellBtn');
	const dropdown = document.getElementById('bellDropdown');
	if (btn && dropdown && !btn.contains(e.target) && !dropdown.contains(e.target)) {
		dropdown.classList.remove('open');
	}
});

// ── User menu ────────────────────────────────────────────────
function toggleUserMenu() {
	document.getElementById('userMenuDropdown').classList.toggle('open');
}
document.addEventListener('click', function(e) {
	const btn = document.getElementById('userMenuBtn');
	const menu = document.getElementById('userMenuDropdown');
	if (btn && menu && !btn.contains(e.target) && !menu.contains(e.target)) {
		menu.classList.remove('open');
	}
});

// ── Global search ────────────────────────────────────────────
(function() {
	const input = document.getElementById('globalSearchInput');
	const dropdown = document.getElementById('searchDropdown');
	if (!input || !dropdown) return;

	let debounce, activeIdx = -1, items = [];

	input.addEventListener('input', function() {
		clearTimeout(debounce);
		const q = this.value.trim();
		if (q.length < 2) { close(); return; }
		dropdown.innerHTML = '<div class="sd-loading">Searching…</div>';
		dropdown.classList.add('open');
		debounce = setTimeout(() => fetchResults(q), 280);
	});

	input.addEventListener('keydown', function(e) {
		if (!dropdown.classList.contains('open')) return;
		if (e.key === 'ArrowDown') { e.preventDefault(); moveFocus(1); }
		else if (e.key === 'ArrowUp') { e.preventDefault(); moveFocus(-1); }
		else if (e.key === 'Enter') { e.preventDefault(); if (activeIdx >= 0 && items[activeIdx]) location.href = items[activeIdx].dataset.url; }
		else if (e.key === 'Escape') { close(); input.blur(); }
	});

	document.addEventListener('click', function(e) {
		if (!document.getElementById('globalSearchWrap').contains(e.target)) close();
	});

	function fetchResults(q) {
		fetch(ctx + '/api/search?q=' + encodeURIComponent(q))
			.then(r => r.json())
			.then(render)
			.catch(() => { dropdown.innerHTML = '<div class="sd-empty">Search unavailable.</div>'; });
	}

	function render(results) {
		activeIdx = -1;
		items = [];
		if (!results.length) {
			dropdown.innerHTML = '<div class="sd-empty">No results found.</div>';
			return;
		}
		let html = '';
		results.forEach(r => {
			html += '<a class="sd-item" href="' + r.url + '" data-url="' + r.url + '">'
				+ '<span class="sd-type-badge sd-badge-' + r.type + '">' + r.type + '</span>'
				+ '<span class="sd-label">' + escHtml(r.label) + '</span>'
				+ (r.sub ? '<span class="sd-sub">' + escHtml(r.sub) + '</span>' : '')
				+ '</a>';
		});
		dropdown.innerHTML = html;
		items = Array.from(dropdown.querySelectorAll('.sd-item'));
	}

	function moveFocus(dir) {
		if (!items.length) return;
		if (activeIdx >= 0) items[activeIdx].classList.remove('active');
		activeIdx = Math.max(0, Math.min(items.length - 1, activeIdx + dir));
		items[activeIdx].classList.add('active');
		items[activeIdx].scrollIntoView({ block: 'nearest' });
	}

	function close() {
		dropdown.classList.remove('open');
		dropdown.innerHTML = '';
		activeIdx = -1; items = [];
	}

	function escHtml(s) {
		return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
	}
})();
