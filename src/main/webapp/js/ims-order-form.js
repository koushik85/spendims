// ── Order form — line-item management ────────────────────────────────────
// NOTE: PRODUCTS array and buildProductSelect() are injected by order/form.jsp
//       (server-side JSTL) and must be defined before this file loads.

let rowIndex = document.querySelectorAll('#itemsContainer tr').length;

function addRow() {
    const idx = rowIndex++;
    const tbody = document.getElementById('itemsContainer');
    const rowNum = tbody.querySelectorAll('tr').length + 1;
    const tr = document.createElement('tr');
    tr.dataset.row = idx;
    tr.innerHTML =
        '<td style="color:var(--color-text-muted);width:28px;">' + rowNum + '</td>' +
        '<td class="td-product">' + buildProductSelect(null, idx) + '</td>' +
        '<td class="td-desc"><input type="text" name="itemDescription" placeholder="Description"></td>' +
        '<td class="td-qty td-num"><input type="number" name="itemQuantity" value="1" min="1" required onchange="recalcTotals()"></td>' +
        '<td class="td-price td-num"><input type="number" name="itemUnitPrice" value="0" min="0" step="0.01" required onchange="recalcTotals()"></td>' +
        '<td class="td-disc td-num"><input type="number" name="itemDiscountPercent" value="0" min="0" max="100" step="0.01" onchange="recalcTotals()"></td>' +
        '<td class="td-tax td-num"><input type="number" name="itemTaxPercent" value="18" min="0" step="0.01" onchange="recalcTotals()"></td>' +
        '<td class="td-action"><button type="button" class="btn-remove-row" onclick="removeRow(this)">' +
            '<svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">' +
            '<path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/></svg>' +
        '</button></td>';
    tbody.appendChild(tr);
    updateRowNumbers();
    updateItemCount();
    recalcTotals();
}

function removeRow(btn) {
    btn.closest('tr').remove();
    updateRowNumbers();
    updateItemCount();
    recalcTotals();
}

function onProductChange(select, idx) {
    const opt = select.options[select.selectedIndex];
    const price = opt.dataset.price;
    const row = select.closest('tr');
    if (price && row) {
        const priceInput = row.querySelector('[name="itemUnitPrice"]');
        if (priceInput) priceInput.value = parseFloat(price).toFixed(2);
    }
    recalcTotals();
}

function recalcTotals() {
    const rows = document.querySelectorAll('#itemsContainer tr');
    let subtotal = 0, discount = 0, tax = 0;
    rows.forEach(function(row) {
        const qty    = parseFloat(row.querySelector('[name="itemQuantity"]')?.value)        || 0;
        const price  = parseFloat(row.querySelector('[name="itemUnitPrice"]')?.value)       || 0;
        const disc   = parseFloat(row.querySelector('[name="itemDiscountPercent"]')?.value) || 0;
        const taxPct = parseFloat(row.querySelector('[name="itemTaxPercent"]')?.value)      || 0;
        const gross   = qty * price;
        const discAmt = gross * disc / 100;
        const taxAmt  = (gross - discAmt) * taxPct / 100;
        subtotal += gross;
        discount += discAmt;
        tax      += taxAmt;
    });
    const fmt = function(n) { return '\u20B9' + n.toFixed(2); };
    document.getElementById('tSubtotal').textContent = fmt(subtotal);
    document.getElementById('tDiscount').textContent = '\u2212\u20B9' + discount.toFixed(2);
    document.getElementById('tTax').textContent      = '+\u20B9' + tax.toFixed(2);
    document.getElementById('tTotal').textContent    = fmt(subtotal - discount + tax);
}

function updateRowNumbers() {
    document.querySelectorAll('#itemsContainer tr').forEach(function(tr, i) {
        const first = tr.querySelector('td:first-child');
        if (first) first.textContent = i + 1;
    });
}

function updateItemCount() {
    const n = document.querySelectorAll('#itemsContainer tr').length;
    document.getElementById('itemCount').textContent = n + ' item' + (n !== 1 ? 's' : '');
}

document.getElementById('customerId').addEventListener('change', function() {
    const opt = this.options[this.selectedIndex];
    const ba = document.getElementById('billingAddress');
    const sa = document.getElementById('shippingAddress');
    if (ba && !ba.value.trim()) ba.value = opt.dataset.billing  || '';
    if (sa && !sa.value.trim()) sa.value = opt.dataset.shipping || '';
});

window.addEventListener('DOMContentLoaded', function() {
    const od = document.getElementById('orderDate');
    if (od && !od.value) od.value = new Date().toISOString().slice(0, 10);
    if (document.querySelectorAll('#itemsContainer tr').length === 0) addRow();
    updateItemCount();
    recalcTotals();
});
