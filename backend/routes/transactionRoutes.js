const express = require('express');
const router = express.Router();
const Transaction = require('../models/transaction');

// Add a new transaction
router.post('/add-transaction', async (req, res) => {
  const { title, amount, date, type, category } = req.body;

  const transaction = new Transaction({
    title,
    amount,
    date: new Date(date), // Ensure the date is correctly parsed
    type,
    category
  });

  try {
    const savedTransaction = await transaction.save();
    res.status(201).json(savedTransaction);
  } catch (error) {
    res.status(500).json({ error: 'Failed to add transaction' });
  }
});

module.exports = router;
