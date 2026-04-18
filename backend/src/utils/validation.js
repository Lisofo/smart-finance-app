const { EXPENSE_CATEGORIES } = require('../constants/expenseCategories');

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function isNonEmptyString(v) {
  return typeof v === 'string' && v.trim().length > 0;
}

function parsePositiveAmount(raw) {
  const n = typeof raw === 'number' ? raw : parseFloat(String(raw).replace(',', '.'));
  if (!Number.isFinite(n)) return { ok: false, error: 'Amount must be a valid number' };
  if (n <= 0) return { ok: false, error: 'Amount must be positive' };
  if (n > 1e12) return { ok: false, error: 'Amount is too large' };
  return { ok: true, value: n };
}

function parseOptionalCategory(raw) {
  if (raw === undefined || raw === null || raw === '') return { ok: true, value: null };
  if (typeof raw !== 'string') return { ok: false, error: 'Category must be a string' };
  const c = raw.trim();
  if (!c) return { ok: true, value: null };
  if (!EXPENSE_CATEGORIES.includes(c)) {
    return { ok: false, error: `Category must be one of: ${EXPENSE_CATEGORIES.join(', ')}` };
  }
  return { ok: true, value: c };
}

function parseExpenseDate(raw) {
  if (raw === undefined || raw === null || raw === '') {
    return { ok: true, value: null };
  }
  const s = String(raw).trim();
  if (!/^\d{4}-\d{2}-\d{2}$/.test(s)) {
    return { ok: false, error: 'expenseDate must be YYYY-MM-DD' };
  }
  const d = new Date(`${s}T00:00:00.000Z`);
  if (Number.isNaN(d.getTime())) return { ok: false, error: 'expenseDate is invalid' };
  return { ok: true, value: s };
}

function parseFilterDate(raw, fieldName) {
  if (raw === undefined || raw === null || raw === '') return { ok: true, value: undefined };
  const s = String(raw).trim();
  if (!/^\d{4}-\d{2}-\d{2}$/.test(s)) {
    return { ok: false, error: `${fieldName} must be YYYY-MM-DD` };
  }
  const d = new Date(`${s}T00:00:00.000Z`);
  if (Number.isNaN(d.getTime())) return { ok: false, error: `${fieldName} is invalid` };
  return { ok: true, value: s };
}

function validateEmailPasswordRegister(email, password) {
  if (!isNonEmptyString(email) || !isNonEmptyString(password)) {
    return { ok: false, error: 'Email and password are required' };
  }
  const em = email.trim().toLowerCase();
  if (!EMAIL_RE.test(em)) return { ok: false, error: 'Invalid email format' };
  if (password.length < 6) return { ok: false, error: 'Password must be at least 6 characters' };
  if (password.length > 128) return { ok: false, error: 'Password is too long' };
  return { ok: true, email: em, password };
}

function validateEmailPasswordLogin(email, password) {
  if (!isNonEmptyString(email) || !isNonEmptyString(password)) {
    return { ok: false, error: 'Email and password are required' };
  }
  return { ok: true, email: email.trim().toLowerCase(), password };
}

function parseExpenseId(raw) {
  const id = Number.parseInt(String(raw), 10);
  if (!Number.isFinite(id) || id < 1) {
    return { ok: false, error: 'Invalid expense id' };
  }
  return { ok: true, value: id };
}

function parseCreateExpenseBody(body) {
  const b = body || {};
  const description = typeof b.description === 'string' ? b.description.trim() : '';
  if (!description) return { ok: false, error: 'Description is required' };
  if (description.length > 2000) return { ok: false, error: 'Description is too long' };

  const amountRes = parsePositiveAmount(b.amount);
  if (!amountRes.ok) return amountRes;

  const catRes = parseOptionalCategory(b.category);
  if (!catRes.ok) return catRes;

  const dateRes = parseExpenseDate(b.expenseDate);
  if (!dateRes.ok) return dateRes;

  return {
    ok: true,
    value: {
      description,
      amount: amountRes.value,
      category: catRes.value,
      expenseDate: dateRes.value,
    },
  };
}

function parseUpdateExpenseBody(body) {
  const b = body || {};
  const updates = {};

  if (b.description !== undefined) {
    if (typeof b.description !== 'string' || !b.description.trim()) {
      return { ok: false, error: 'Description cannot be empty' };
    }
    const d = b.description.trim();
    if (d.length > 2000) return { ok: false, error: 'Description is too long' };
    updates.description = d;
  }

  if (b.amount !== undefined) {
    const amountRes = parsePositiveAmount(b.amount);
    if (!amountRes.ok) return amountRes;
    updates.amount = amountRes.value;
  }

  if (b.category !== undefined) {
    const catRes = parseOptionalCategory(b.category);
    if (!catRes.ok) return catRes;
    updates.category = catRes.value;
  }

  if (b.expenseDate !== undefined) {
    const dateRes = parseExpenseDate(b.expenseDate);
    if (!dateRes.ok) return dateRes;
    updates.expenseDate = dateRes.value;
  }

  if (Object.keys(updates).length === 0) {
    return { ok: false, error: 'No valid fields to update' };
  }

  return { ok: true, value: updates };
}

module.exports = {
  parsePositiveAmount,
  parseOptionalCategory,
  parseExpenseDate,
  parseFilterDate,
  validateEmailPasswordRegister,
  validateEmailPasswordLogin,
  parseExpenseId,
  parseCreateExpenseBody,
  parseUpdateExpenseBody,
};
