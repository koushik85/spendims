// ── HSN autocomplete ───────────────────────────────────────────────────────
(function () {
    const hsnInput       = document.getElementById('hsnSearch');
    const hsnSuggestions = document.getElementById('hsnSuggestions');
    const hsnHiddenId    = document.getElementById('hsnId');

    if (!hsnInput) return;

    let debounceTimer;

    hsnInput.addEventListener('input', function () {
        clearTimeout(debounceTimer);
        const keyword = this.value.trim();
        if (keyword.length < 2) { hsnSuggestions.innerHTML = ''; return; }

        debounceTimer = setTimeout(() => {
            fetch('/spendilizer/api/hsn/search?keyword=' + encodeURIComponent(keyword))
                .then(res => { if (!res.ok) throw new Error('Network error'); return res.json(); })
                .then(data => {
                    hsnSuggestions.innerHTML = '';
                    if (data.length === 0) {
                        const noResult = document.createElement('div');
                        noResult.classList.add('suggestion-item');
                        noResult.style.color = '#999';
                        noResult.textContent = 'No results found';
                        hsnSuggestions.appendChild(noResult);
                        return;
                    }
                    data.forEach(hsn => {
                        const div = document.createElement('div');
                        div.classList.add('suggestion-item');
                        div.textContent = hsn.hsnCode + ' — ' + hsn.description;
                        div.addEventListener('mousedown', e => {
                            e.preventDefault();
                            hsnInput.value    = hsn.hsnCode;
                            hsnHiddenId.value = hsn.id;
                            hsnSuggestions.innerHTML = '';
                        });
                        hsnSuggestions.appendChild(div);
                    });
                })
                .catch(err => { console.error('HSN search failed:', err); hsnSuggestions.innerHTML = ''; });
        }, 300);
    });

    document.addEventListener('click', e => {
        if (!e.target.closest('.form-group')) hsnSuggestions.innerHTML = '';
    });

    hsnInput.addEventListener('keydown', e => {
        if (e.key === 'Escape') hsnSuggestions.innerHTML = '';
    });
})();

// ── SKU auto-generation ────────────────────────────────────────────────────
(function () {
    const masterProductSelect = document.getElementById('masterProductId');
    const categorySelect   = document.getElementById('category');
    const supplierSelect   = document.getElementById('supplier');
    const productNameInput = document.getElementById('name');
    const skuInput         = document.getElementById('sku');
    const descriptionInput = document.getElementById('description');
    const hsnInput         = document.getElementById('hsnSearch');
    const hsnIdInput       = document.getElementById('hsnId');
    const generateSkuBtn   = document.getElementById('generateSkuBtn');

    if (!categorySelect || !productNameInput || !skuInput) return;

    const categoryRequiredDefault = categorySelect.required;
    const supplierRequiredDefault = supplierSelect ? supplierSelect.required : false;

    function normalize(value) {
        return (value || '').trim().toLowerCase();
    }

    function removeTemporaryOptions(select) {
        if (!select) return;
        [...select.options]
            .filter(opt => opt.dataset.tempMaster === 'true')
            .forEach(opt => opt.remove());
    }

    function selectOrInjectOptionByText(select, text, injectedValue) {
        if (!select || !text) return;
        const wanted = normalize(text);
        const existing = [...select.options].find(opt => normalize(opt.textContent) === wanted);
        if (existing) {
            select.value = existing.value;
            return;
        }
        removeTemporaryOptions(select);
        const option = document.createElement('option');
        option.value = injectedValue != null ? String(injectedValue) : '__master__';
        option.textContent = text;
        option.dataset.tempMaster = 'true';
        select.appendChild(option);
        select.value = option.value;
    }

    function toggleMasterMode(isMasterMode) {
        productNameInput.readOnly = isMasterMode;
        skuInput.readOnly = isMasterMode;
        if (descriptionInput) descriptionInput.readOnly = isMasterMode;
        if (hsnInput) hsnInput.readOnly = isMasterMode;

        categorySelect.disabled = isMasterMode;
        categorySelect.required = isMasterMode ? false : categoryRequiredDefault;

        if (supplierSelect) {
            // Supplier stays editable in master mode so store owners can override vendor mapping.
            supplierSelect.disabled = false;
            supplierSelect.required = supplierRequiredDefault;
            if (!isMasterMode) removeTemporaryOptions(supplierSelect);
        }
        if (!isMasterMode) {
            removeTemporaryOptions(categorySelect);
        }

        if (generateSkuBtn) {
            generateSkuBtn.disabled = isMasterMode;
        }
    }

    function applyMasterSelection() {
        if (!masterProductSelect) return;
        const selectedOption = masterProductSelect.options[masterProductSelect.selectedIndex];
        const masterId = masterProductSelect.value;
        if (!masterId || !selectedOption) {
            toggleMasterMode(false);
            return;
        }

        const productName = selectedOption.dataset.name || '';
        const categoryName = selectedOption.dataset.category || '';

        productNameInput.value = productName;
        skuInput.value = '';
        if (descriptionInput) descriptionInput.value = selectedOption.dataset.description || '';

        const supplierName = selectedOption.dataset.supplier || '';
        const hsnCode = selectedOption.dataset.hsn || '';

        selectOrInjectOptionByText(categorySelect, categoryName, '__master__');
        // -1 keeps form binding numeric while signaling "use master supplier fallback" on backend.
        selectOrInjectOptionByText(supplierSelect, supplierName, -1);

        if (hsnInput) hsnInput.value = hsnCode;
        if (hsnIdInput) hsnIdInput.value = '';

        fetchGeneratedSkuByNames(categoryName, productName);
        toggleMasterMode(true);
    }

    function isMasterMode() {
        return !!(masterProductSelect && masterProductSelect.value);
    }

    function fetchGeneratedSkuByNames(categoryName, productName) {
        const normalizedCategory = (categoryName || '').trim();
        const normalizedProductName = (productName || '').trim();
        if (!normalizedCategory || !normalizedProductName || normalizedProductName.length < 2) return;

        fetch('/spendilizer/product/generate-sku'
            + '?categoryName=' + encodeURIComponent(normalizedCategory)
            + '&productName='  + encodeURIComponent(normalizedProductName))
            .then(res => res.text())
            .then(sku => { skuInput.value = sku; })
            .catch(err => { console.error('SKU generation failed:', err); });
    }

    function fetchGeneratedSku() {
        if (isMasterMode()) return;
        const categoryText = categorySelect.options[categorySelect.selectedIndex]?.text;
        const productName  = productNameInput.value;
        fetchGeneratedSkuByNames(categoryText, productName);
    }

    if (masterProductSelect) {
        masterProductSelect.addEventListener('change', applyMasterSelection);
        applyMasterSelection();
    }

    categorySelect.addEventListener('change', fetchGeneratedSku);
    productNameInput.addEventListener('blur', fetchGeneratedSku);
    if (generateSkuBtn) {
        generateSkuBtn.addEventListener('click', fetchGeneratedSku);
    }
})();
