// backend/src/models/expenseModel.js
const pool = require('../config/db');

class ExpenseModel {
  static async create({ userId, description, amount, category, expenseDate }) {
    const query = `
      INSERT INTO expenses (user_id, description, amount, category, expense_date)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id, user_id, description, amount::float, category, expense_date, created_at, updated_at
    `; // Se agregó ::float en el RETURNING
    const values = [userId, description, amount, category, expenseDate];
    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async findByUser(userId, filters = {}) {
    let query = `
      SELECT id, description, amount::float, category, expense_date, created_at, updated_at
      FROM expenses
      WHERE user_id = $1
    `; // Se agregó ::float aquí
    const values = [userId];
    let paramIndex = 2;

    if (filters.category) {
      query += ` AND category = $${paramIndex}`;
      values.push(filters.category);
      paramIndex++;
    }

    if (filters.startDate) {
      query += ` AND expense_date >= $${paramIndex}`;
      values.push(filters.startDate);
      paramIndex++;
    }

    if (filters.endDate) {
      query += ` AND expense_date <= $${paramIndex}`;
      values.push(filters.endDate);
      paramIndex++;
    }

    query += ` ORDER BY expense_date DESC, created_at DESC`;
    const result = await pool.query(query, values);
    return result.rows;
  }

  static async findByIdAndUser(id, userId) {
    const query = `
      SELECT id, description, amount::float, category, expense_date, created_at, updated_at
      FROM expenses
      WHERE id = $1 AND user_id = $2
    `; // Se agregó ::float aquí
    const result = await pool.query(query, [id, userId]);
    return result.rows[0];
  }

  static async update(id, userId, updates) {
    const fields = [];
    const values = [];
    let paramIndex = 1;

    if (updates.description !== undefined) {
      fields.push(`description = $${paramIndex++}`);
      values.push(updates.description);
    }
    if (updates.amount !== undefined) {
      fields.push(`amount = $${paramIndex++}`);
      values.push(updates.amount);
    }
    if (updates.category !== undefined) {
      fields.push(`category = $${paramIndex++}`);
      values.push(updates.category);
    }
    if (updates.expenseDate !== undefined) {
      fields.push(`expense_date = $${paramIndex++}`);
      values.push(updates.expenseDate);
    }

    if (fields.length === 0) return null;

    fields.push(`updated_at = CURRENT_TIMESTAMP`);
    values.push(id, userId);

    const query = `
      UPDATE expenses
      SET ${fields.join(', ')}
      WHERE id = $${paramIndex++} AND user_id = $${paramIndex}
      RETURNING id, description, amount::float, category, expense_date, updated_at
    `; // Se agregó ::float en el RETURNING
    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async delete(id, userId) {
    const query = `DELETE FROM expenses WHERE id = $1 AND user_id = $2 RETURNING id`;
    const result = await pool.query(query, [id, userId]);
    return result.rows[0];
  }
}

module.exports = ExpenseModel;