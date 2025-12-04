require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const transactionRoutes = require('./routes/transactions');
const dependentRoutes = require('./routes/dependents');
const fixedExpensesRoutes = require('./routes/fixedExpenses');

const app = express();

const allowedOrigins = process.env.CORS_ORIGIN
  ? process.env.CORS_ORIGIN.split(',').map((o) => o.trim())
  : ['http://localhost:5173'];

app.use(cors({ origin: allowedOrigins }));
app.use(express.json());

app.get('/api/health', (_, res) => res.json({ status: 'ok' }));
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/dependents', dependentRoutes);
app.use('/api/fixed-expenses', fixedExpensesRoutes);

const port = process.env.PORT || 4000;
app.listen(port, () => {
  console.log(`ControlPayWeb API rodando na porta ${port}`);
});
