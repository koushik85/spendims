// ── Role dropdown (navbar) ─────────────────────────────────────────────────
function toggleRoleDropdown() {
    document.getElementById('roleDropdownMenu').classList.toggle('open');
}

function selectRole(role) {
    document.getElementById('selectedRoleInput').value = role;
    document.getElementById('roleForm').submit();
}

document.addEventListener('click', function (e) {
    const btn  = document.getElementById('roleDropdownBtn');
    const menu = document.getElementById('roleDropdownMenu');
    if (btn && menu && !btn.contains(e.target) && !menu.contains(e.target)) {
        menu.classList.remove('open');
    }
});
