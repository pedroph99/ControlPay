const express = require('express');
const { pool } = require('../db');
const { authenticate } = require('../auth');
const { getUserScopeIds } = require('../utils/userScope');

const router = express.Router();
router.use(authenticate);

router.get('/', async (req, res) => {
  try {
    const scope = await getUserScopeIds(req.user);
    const params = [];
    let query = `
      SELECT fe.id,
             fe.user_id,
             u.username,
             fe.value,
             fe.category,
             fe.description,
             fe.recurrence_days,
             fe.next_debit_date,
             fe.is_active
      FROM fixed_expenses fe
      JOIN users u ON u.id = fe.user_id
      WHERE fe.is_deleted = FALSE AND u.is_deleted = FALSE
    `;

    if (scope) {
      params.push(scope);
      query += ` AND fe.user_id = ANY($${params.length}::bigint[])`;
    }

    const { rows } = await pool.query(query, params);
    const normalized = rows.map((fx) => ({
      ...fx,
      id: Number(fx.id),
      user_id: Number(fx.user_id),
      value: Number(fx.value),
      recurrence_days: Number(fx.recurrence_days),
    }));
    return res.json({ fixedExpenses: normalized });
  } catch (err) {
    console.error('Erro ao listar gastos fixos', err);
    return res.status(500).json({ error: 'Erro ao listar gastos fixos' });
  }
});

module.exports = router;
