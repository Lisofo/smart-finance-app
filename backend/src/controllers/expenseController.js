// backend/src/controllers/expenseController.js
const ExpenseService = require('../services/expenseService');
const { EXPENSE_CATEGORIES } = require('../constants/expenseCategories');
const {
  parseExpenseId,
  parseCreateExpenseBody,
  parseUpdateExpenseBody,
  parseFilterDate,
} = require('../utils/validation');

class ExpenseController {
  static async create(req, res, next) {
    try {
      const userId = req.user.userId;
      const parsed = parseCreateExpenseBody(req.body);
      if (!parsed.ok) {
        return res.status(400).json({ message: parsed.error });
      }
      const expense = await ExpenseService.createExpense(userId, parsed.value);
      res.status(201).json({ message: 'Expense created', expense });
    } catch (error) {
      next(error);
    }
  }

  static async getAll(req, res, next) {
    try {
      const userId = req.user.userId;
      const { category, startDate, endDate } = req.query;

      const startRes = parseFilterDate(startDate, 'startDate');
      if (!startRes.ok) return res.status(400).json({ message: startRes.error });
      const endRes = parseFilterDate(endDate, 'endDate');
      if (!endRes.ok) return res.status(400).json({ message: endRes.error });

      const filters = {};
      if (category !== undefined && category !== null && String(category).trim() !== '') {
        const c = String(category).trim();
        if (!EXPENSE_CATEGORIES.includes(c)) {
          return res.status(400).json({
            message: `category must be one of: ${EXPENSE_CATEGORIES.join(', ')}`,
          });
        }
        filters.category = c;
      }
      if (startRes.value !== undefined) filters.startDate = startRes.value;
      if (endRes.value !== undefined) filters.endDate = endRes.value;

      if (filters.startDate && filters.endDate && filters.startDate > filters.endDate) {
        return res.status(400).json({ message: 'startDate must be before or equal to endDate' });
      }

      const expenses = await ExpenseService.getUserExpenses(userId, filters);
      res.json({ expenses });
    } catch (error) {
      next(error);
    }
  }

  static async update(req, res, next) {
    try {
      const userId = req.user.userId;
      const idRes = parseExpenseId(req.params.id);
      if (!idRes.ok) return res.status(400).json({ message: idRes.error });

      const parsed = parseUpdateExpenseBody(req.body);
      if (!parsed.ok) {
        return res.status(400).json({ message: parsed.error });
      }

      const body = parsed.value;
      const updates = {};
      if (body.description !== undefined) updates.description = body.description;
      if (body.amount !== undefined) updates.amount = body.amount;
      if (body.category !== undefined) updates.category = body.category;
      if (body.expenseDate !== undefined) updates.expenseDate = body.expenseDate;

      const updated = await ExpenseService.updateExpense(idRes.value, userId, updates);
      res.json({ message: 'Expense updated', expense: updated });
    } catch (error) {
      if (error.message === 'Expense not found') {
        return res.status(404).json({ message: error.message });
      }
      next(error);
    }
  }

  static async delete(req, res, next) {
    try {
      const userId = req.user.userId;
      const idRes = parseExpenseId(req.params.id);
      if (!idRes.ok) return res.status(400).json({ message: idRes.error });

      await ExpenseService.deleteExpense(idRes.value, userId);
      res.json({ message: 'Expense deleted' });
    } catch (error) {
      if (error.message === 'Expense not found') {
        return res.status(404).json({ message: error.message });
      }
      next(error);
    }
  }
}

module.exports = ExpenseController;
