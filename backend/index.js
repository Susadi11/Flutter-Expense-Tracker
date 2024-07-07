import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import helmet from 'helmet';
import transactionRoutes from './routes/transactionRoutes.js';
import { mongoDBURL } from './config.js';

const app = express();
const port = process.env.PORT || 5555;

// Middleware
app.use(express.json());
app.use(cors({ origin: true }));
app.use(helmet());

// Connect to MongoDB
mongoose.connect(mongoDBURL, {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => {
  console.log('Connected to MongoDB');
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
})
.catch(err => {
  console.error('Error connecting to MongoDB:', err);
});

app.get('/', (req, res) => {
  res.send('Hello, world!');
});

// Mount transaction routes
app.use('/transactions', transactionRoutes);

// Error Handling Middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

console.log('Express app initialized');
