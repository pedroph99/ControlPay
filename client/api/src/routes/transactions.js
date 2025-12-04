const express = require('express');
const { pool } = require('../db');
const { authenticate } = require('../auth');
const { getUserScopeIds } = require('../utils/userScope');

const router = express.Router();
router.use(authenticate);

const normalizeType = (type) => (type === 'entrada' || type === 'saida' ? type : null);

router.get('/recent', async (req, res) => {
  const limit = Math.min(Number(req.query.limit) || 10, 50);
  try {
    const scope = await getUserScopeIds(req.user);
    const params = [];
    let query = `
      SELECT t.id,
             t.user_id,
             u.username,
             u.role,
             t.value,
             t.type,
             t.category,
             t.description,
             t.date,
             t.time
      FROM transactions t
      JOIN users u ON u.id = t.user_id
      WHERE t.is_deleted = FALSE AND u.is_deleted = FALSE
    `;

    if (scope) {
      params.push(scope);
      query += ` AND t.user_id = ANY($${params.length}::bigint[])`;
    }

    params.push(limit);
    query += ` ORDER BY t.date DESC, t.time DESC LIMIT $${params.length}`;

    const { rows } = await pool.query(query, params);
    const normalized = rows.map((t) => ({
      ...t,
      id: Number(t.id),
      user_id: Number(t.user_id),
      value: Number(t.value),
    }));
    return res.json({ transactions: normalized });
  } catch (err) {
    console.error('Erro ao buscar transações', err);
    return res.status(500).json({ error: 'Erro ao buscar transações' });
  }
});

router.post('/', async (req, res) => {
  const {
    value,
    type,
    category,
    description,
    date,
    time,
    userId,
  } = req.body;

  const normalizedType = normalizeType(type);
  const numericValue = Number(value);
  if (!normalizedType || Number.isNaN(numericValue)) {
    return res.status(400).json({ error: 'Tipo ou valor inválido' });
  }

  const targetUserId = Number(userId) || req.user.id;

  try {
    const scope = await getUserScopeIds(req.user);
    if (scope && !scope.includes(targetUserId)) {
      return res.status(403).json({ error: 'Usuário alvo fora do seu escopo' });
    }

    const userCheck = await pool.query(
      'SELECT id FROM users WHERE id = $1 AND is_deleted = FALSE',
      [targetUserId],
    );
    if (userCheck.rowCount === 0) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }

    const now = new Date();
    const payloadDate = date || now.toISOString().slice(0, 10);
    const payloadTime = time || now.toISOString().slice(11, 19);

    const { rows } = await pool.query(
      `INSERT INTO transactions (user_id, value, type, category, description, date, time)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, user_id, value, type, category, description, date, time`,
      [
        targetUserId,
        numericValue,
        normalizedType,
        category || null,
        description || null,
        payloadDate,
        payloadTime,
      ],
    );

    const created = rows[0];
    return res.status(201).json({
      transaction: {
        ...created,
        id: Number(created.id),
        user_id: Number(created.user_id),
        value: Number(created.value),
      },
    });
  } catch (err) {
    console.error('Erro ao criar transação', err);
    return res.status(500).json({ error: 'Erro ao criar transação' });
  }
});

module.exports = router;
