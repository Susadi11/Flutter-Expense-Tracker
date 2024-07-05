import mongoose from 'mongoose';

const transactionSchema = new mongoose.Schema({
  title: {
     type: String,
     required: true },

  amount: { 
    type: Number, 
    required: true },

  date: { 
    type: Date, 
    required: true },

  type: { 
    type: String, 
    required: true },

  category: { 
    type: String,
    required: true },
});

const Transaction = mongoose.model('Transaction', transactionSchema);

export default Transaction;