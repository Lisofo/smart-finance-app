// backend/src/services/expenseService.js
const ExpenseModel = require('../models/expenseModel');

class ExpenseService {
  static async createExpense(userId, payload) {
    const { description, amount, category, expenseDate } = payload;
    const dateStr =
      expenseDate || new Date().toISOString().split('T')[0];

    const expense = await ExpenseModel.create({
      userId,
      description,
      amount,
      category: category || null,
      expenseDate: dateStr,
    });
    return expense;
  }

  static async getUserExpenses(userId, filters = {}) {
    return await ExpenseModel.findByUser(userId, filters);
  }

  static async updateExpense(id, userId, updates) {
    const existing = await ExpenseModel.findByIdAndUser(id, userId);
    if (!existing) {
      throw new Error('Expense not found');
    }

    const updated = await ExpenseModel.update(id, userId, updates);
    return updated;
  }

  static async deleteExpense(id, userId) {
    const deleted = await ExpenseModel.delete(id, userId);
    if (!deleted) {
      throw new Error('Expense not found');
    }
    return { id: deleted.id };
  }
}

module.exports = ExpenseService;
