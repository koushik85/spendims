// ── Low-stock threshold warning (stock/form) ──────────────────────────────
(function () {
    const qtyInput = document.getElementById('quantity');
    const thrInput = document.getElementById('minThreshold');
    const warning  = document.getElementById('lowStockWarning');

    if (!qtyInput || !thrInput || !warning) return;

    function checkLowStock() {
        const qty = parseInt(qtyInput.value) || 0;
        const thr = parseInt(thrInput.value) || 0;
        warning.style.display = (qty <= thr && thr > 0) ? 'flex' : 'none';
    }

    qtyInput.addEventListener('input', checkLowStock);
    thrInput.addEventListener('input', checkLowStock);
    checkLowStock(); // run on load for edit mode
})();
