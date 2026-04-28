// ── Movement type selector (IN / OUT cards) ───────────────────────────────
function selectType(type) {
    const cardIn  = document.getElementById('card-IN');
    const cardOut = document.getElementById('card-OUT');
    if (cardIn)  cardIn.classList.toggle('selected',  type === 'IN');
    if (cardOut) cardOut.classList.toggle('selected', type === 'OUT');
    const radio = document.querySelector('input[value="' + type + '"]');
    if (radio) radio.checked = true;
}

// ── Fetch current stock info for selected product ─────────────────────────
function fetchStockInfo(productId) {
    if (!productId) return;
    const info = document.getElementById('stockInfo');
    const text = document.getElementById('stockInfoText');
    if (!info || !text) return;
    info.style.display = 'flex';
    text.textContent = 'Loading stock info…';

    fetch(ctx + '/stock/api/by-product/' + productId)
        .then(r => r.ok ? r.json() : null)
        .then(data => {
            text.textContent = data
                ? 'Current stock: ' + data.quantity + ' units  ·  Min threshold: ' + data.minThreshold
                : 'No stock entry found for this product.';
        })
        .catch(() => { text.textContent = 'Could not load stock info.'; });
}
