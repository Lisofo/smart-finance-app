// backend/src/controllers/expenseController.js
const ExpenseService = require('../services/expenseService');

class ExpenseController {
  static async create(req, res, next) {
    try {
      const userId = req.user.userId;
      const expense = await ExpenseService.createExpense(userId, req.body);
      res.status(201).json({ message: 'Expense created', expense });
    } catch (error) {
      if (error.message.includes('required') || error.message.includes('positive')) {
        return res.status(400).json({ message: error.message });
      }
      next(error);
    }
  }

  static async getAll(req, res, next) {
    try {
      const userId = req.user.userId;
      const { category, startDate, endDate } = req.query;
      const filters = { category, startDate, endDate };
      // Remove undefined filters
      Object.keys(filters).forEach(key => filters[key] === undefined && delete filters[key]);
      
      const expenses = await ExpenseService.getUserExpenses(userId, filters);
      res.json({ expenses });
    } catch (error) {
      next(error);
    }
  }

  static async update(req, res, next) {
    try {
      const userId = req.user.userId;
      const expenseId = parseInt(req.params.id);
      const updated = await ExpenseService.updateExpense(expenseId, userId, req.body);
      res.json({ message: 'Expense updated', expense: updated });
    } catch (error) {
      if (error.message === 'Expense not found') {
        return res.status(404).json({ message: error.message });
      }
      if (error.message.includes('positive')) {
        return res.status(400).json({ message: error.message });
      }
      next(error);
    }
  }

  static async delete(req, res, next) {
    try {
      const userId = req.user.userId;
      const expenseId = parseInt(req.params.id);
      await ExpenseService.deleteExpense(expenseId, userId);
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