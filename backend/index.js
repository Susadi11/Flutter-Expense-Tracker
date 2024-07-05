import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import helmet from 'helmet';
import bodyParser from 'body-parser';
import transactionRoutes from './routes/transactionRoutes.js';
import { mongoDBURL } from './config.js';

const app = express();
const port = process.env.PORT || 5555;

// Middleware
app.use(bodyParser.json());
app.use(cors());
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

// Mount transaction routes
app.use('/', transactionRoutes);


// Error Handling Middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});