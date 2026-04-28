// ── Account type card selector (signup) ───────────────────────────────────
function selectType(type) {
    const isEnt = (type === 'ENTERPRISE');
    document.getElementById('card-individual').classList.toggle('active', !isEnt);
    document.getElementById('card-enterprise').classList.toggle('active',  isEnt);
    document.getElementById('accountTypeInput').value = type;
    const companyField = document.getElementById('field-company');
    companyField.style.display = isEnt ? '' : 'none';
    document.getElementById('enterpriseName').required = isEnt;
    const hi = document.getElementById('hint-individual');
    const he = document.getElementById('hint-enterprise');
    if (hi && he) { hi.style.display = isEnt ? 'none' : ''; he.style.display = isEnt ? '' : 'none'; }
    const approvalNote = document.getElementById('enterprise-approval-note');
    if (approvalNote) approvalNote.style.display = isEnt ? '' : 'none';
}

// ── PAN validation ─────────────────────────────────────────────────────────
const PAN_RE = /^[A-Z]{5}[0-9]{4}[A-Z]$/;

function validatePan(input) {
    const val = input.value.toUpperCase();
    input.value = val;
    const err = document.getElementById('panError');
    if (val === '') {
        err.style.display = 'none';
        input.style.borderColor = '';
        return true;
    }
    const valid = PAN_RE.test(val);
    err.style.display = valid ? 'none' : 'block';
    input.style.borderColor = valid ? '#16a34a' : '#dc2626';
    return valid;
}

// Block submit if PAN is filled but invalid
document.addEventListener('DOMContentLoaded', function () {
    const form = document.getElementById('signupForm');
    if (!form) return;
    form.addEventListener('submit', function (e) {
        const panInput = document.getElementById('pan');
        if (panInput && panInput.value.trim() !== '') {
            if (!validatePan(panInput)) {
                e.preventDefault();
                panInput.focus();
            }
        }
    });
});
