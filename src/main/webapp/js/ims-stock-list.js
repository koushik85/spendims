// ── Stock list — restock modal ────────────────────────────────────────────
function openRestock(stockId, productName) {
    document.getElementById('restockForm').action = '/spendilizer/stock/adjust/' + stockId;
    document.getElementById('restockProductName').textContent = productName;
    document.getElementById('restockDelta').value = '';
    const modal = document.getElementById('restockModal');
    modal.style.display = 'flex';
    document.getElementById('restockDelta').focus();
}

function closeRestock() {
    document.getElementById('restockModal').style.display = 'none';
}

document.getElementById('restockModal').addEventListener('click', function(e) {
    if (e.target === this) closeRestock();
});
