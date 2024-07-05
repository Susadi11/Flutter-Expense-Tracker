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

// Get all transactions
router.get('/transactions', async (req, res) => {
  try {
    const transactions = await Transaction.find();
    res.status(200).json(transactions);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch transactions' });
  }
});

// Get a transaction by ID
router.get('/transaction/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const transaction = await Transaction.findById(id);
    if (transaction) {
      res.status(200).json(transaction);
    } else {
      res.status(404).json({ error: 'Transaction not found' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch transaction' });
  }
});

module.exports = router;
