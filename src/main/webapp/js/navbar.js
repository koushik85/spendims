// ── User menu ────────────────────────────────────────────────
function toggleUserMenu() {
    document.getElementById('userMenuDropdown').classList.toggle('open');
}
document.addEventListener('click', function(e) {
    const btn  = document.getElementById('userMenuBtn');
    const menu = document.getElementById('userMenuDropdown');
    if (btn && menu && !btn.contains(e.target) && !menu.contains(e.target)) {
        menu.classList.remove('open');
    }
});

// ── Global search ────────────────────────────────────────────
(function () {
    const input    = document.getElementById('globalSearchInput');
    const dropdown = document.getElementById('searchDropdown');
    if (!input || !dropdown) return;

    let debounce, activeIdx = -1, items = [];

    input.addEventListener('input', function () {
        clearTimeout(debounce);
        const q = this.value.trim();
        if (q.length < 2) { close(); return; }
        dropdown.innerHTML = '<div class="sd-loading">Searching…</div>';
        dropdown.classList.add('open');
        debounce = setTimeout(() => fetchResults(q), 280);
    });

    input.addEventListener('keydown', function (e) {
        if (!dropdown.classList.contains('open')) return;
        if (e.key === 'ArrowDown')  { e.preventDefault(); moveFocus(1); }
        else if (e.key === 'ArrowUp')   { e.preventDefault(); moveFocus(-1); }
        else if (e.key === 'Enter')     { e.preventDefault(); if (activeIdx >= 0 && items[activeIdx]) location.href = items[activeIdx].dataset.url; }
        else if (e.key === 'Escape')    { close(); input.blur(); }
    });

    document.addEventListener('click', function (e) {
        if (!document.getElementById('globalSearchWrap').contains(e.target)) close();
    });

    function fetchResults(q) {
        fetch('/spendilizer/api/search?q=' + encodeURIComponent(q))
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
        return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }
})();
