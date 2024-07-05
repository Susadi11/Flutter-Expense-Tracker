const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const transactionRoutes = require('./routes/transactionRoutes');

const app = express();
const port = process.env.PORT || 3000;

app.use(bodyParser.json());

mongoose.connect('mongodb+srv://it22079404:86OIVhDTw9v4ANUI@expenses.xd59dkt.mongodb.net/?retryWrites=true&w=majority&appName=expenses', {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log('Connected to MongoDB');
}).catch(err => {
  console.error('Error connecting to MongoDB:', err);
});

// Mount transaction routes
app.use('/api', transactionRoutes);

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
