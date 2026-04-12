// backend/src/services/expenseService.js
const ExpenseModel = require('../models/expenseModel');

class ExpenseService {
  static async createExpense(userId, { description, amount, category, expenseDate }) {
    if (!description || !amount) {
      throw new Error('Description and amount are required');
    }
    if (amount <= 0) {
      throw new Error('Amount must be positive');
    }

    const expense = await ExpenseModel.create({
      userId,
      description,
      amount,
      category: category || null,
      expenseDate: expenseDate || new Date().toISOString().split('T')[0]
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

    if (updates.amount !== undefined && updates.amount <= 0) {
      throw new Error('Amount must be positive');
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