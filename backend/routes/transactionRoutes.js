import express from 'express';
import Transaction from '../models/transaction.js';

const router = express.Router();

// Test route to ensure the routes are reachable
router.get('/test', (req, res) => {
  res.send('Transaction routes are working!');
});

// Add a new transaction
router.post('/add', async (req, res) => {
  const { title, amount, date, type, category } = req.body;

  const transaction = new Transaction({
    title,
    amount,
    date: new Date(date),
    type,
    category
  });

  try {
    const savedTransaction = await transaction.save();
    res.status(201).json(savedTransaction);
  } catch (error) {
    console.error(error.message);
    res.status(500).send('Server error');
  }
});

// Get all transactions
router.get('/', async (req, res) => {
  try {
    const transactions = await Transaction.find({});
    res.status(200).json(transactions);
  } catch (error) {
    console.error(error.message);
    res.status(500).send('Server error');
  }
});

// Get a transaction by ID
router.get('/:id', async (req, res) => {
  try {
    const transaction = await Transaction.findById(req.params.id);
    if (!transaction) {
      return res.status(404).send('Transaction not found');
    }
    res.status(200).json(transaction);
  } catch (error) {
    console.error(error.message);
    res.status(500).send('Server error');
  }
});

// Update a transaction by ID
router.put('/:id', async (req, res) => {
  try {
    const updatedTransaction = await Transaction.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedTransaction) {
      return res.status(404).send('Transaction not found');
    }
    res.status(200).json(updatedTransaction);
  } catch (error) {
    console.error(error.message);
    res.status(500).send('Server error');
  }
});

// Delete a transaction by ID
router.delete('/:id', async (req, res) => {
  try {
    const deletedTransaction = await Transaction.findByIdAndDelete(req.params.id);
    if (!deletedTransaction) {
      return res.status(404).send('Transaction not found');
    }
    res.status(200).send('Transaction deleted successfully');
  } catch (error) {
    console.error(error.message);
    res.status(500).send('Server error');
  }
});

export default router;
