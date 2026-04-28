// ── Table live-filter (all list pages) ────────────────────────────────────
// tableId: the id attribute of the <table> element
function filterTable(tableId) {
    const input = document.getElementById('searchInput').value.toLowerCase();
    const rows  = document.querySelectorAll('#' + tableId + ' tbody tr');
    let visible = 0;
    rows.forEach(row => {
        const show = row.textContent.toLowerCase().includes(input);
        row.style.display = show ? '' : 'none';
        if (show) visible++;
    });
    const countEl = document.getElementById('visibleCount');
    if (countEl) countEl.textContent = visible;
}

// ── Password visibility toggle (login & signup) ────────────────────────────
const _EYE_OPEN = `<path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
    <path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>`;
const _EYE_SHUT = `<path stroke-linecap="round" stroke-linejoin="round"
    d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/>`;

function togglePw(inputId, iconId) {
    const inp    = document.getElementById(inputId);
    const ico    = document.getElementById(iconId);
    const hidden = inp.type === 'password';
    inp.type     = hidden ? 'text' : 'password';
    ico.innerHTML = hidden ? _EYE_SHUT : _EYE_OPEN;
}

// ── Live date display (dashboard header) ───────────────────────────────────
function initLiveDate(elementId) {
    const el = document.getElementById(elementId);
    if (!el) return;
    el.textContent = new Date().toLocaleDateString('en-IN', {
        weekday: 'short', day: 'numeric', month: 'short', year: 'numeric'
    });
}

// ── Sidebar toggle ──────────────────────────────────────────────────────────
function toggleSidebar() {
    const collapsed = document.body.classList.toggle('sidebar-collapsed');
    localStorage.setItem('sidebarCollapsed', collapsed ? '1' : '0');
}

// Restore sidebar state on load
(function () {
    if (localStorage.getItem('sidebarCollapsed') === '1') {
        document.body.classList.add('sidebar-collapsed');
    }
})();
