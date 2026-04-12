// backend/src/routes/expenseRoutes.js
const express = require('express');
const ExpenseController = require('../controllers/expenseController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

// All expense routes require authentication
router.use(authMiddleware);

router.post('/', ExpenseController.create);
router.get('/', ExpenseController.getAll);
router.put('/:id', ExpenseController.update);
router.delete('/:id', ExpenseController.delete);

module.exports = router;