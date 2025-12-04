const express = require('express');
const { pool } = require('../db');
const { authenticate, requireRole, hashPassword } = require('../auth');

const router = express.Router();

router.use(authenticate);

router.get('/', requireRole('UP', 'ADM'), async (req, res) => {
  try {
    const principalId = req.user.role === 'ADM' && req.query.principalId
      ? Number(req.query.principalId)
      : req.user.id;

    const { rows } = await pool.query(
      `SELECT d.id,
              d.dependent_id    AS user_id,
              u.username,
              u.email,
              u.role,
              u.is_deleted,
              d.created_at
       FROM dependents d
       JOIN users u ON u.id = d.dependent_id
       WHERE d.principal_id = $1`,
      [principalId],
    );

    const normalized = rows.map((dep) => ({
      ...dep,
      id: Number(dep.id),
      user_id: Number(dep.user_id),
    }));

    return res.json({ dependents: normalized });
  } catch (err) {
    console.error('Erro ao listar dependentes', err);
    return res.status(500).json({ error: 'Erro ao carregar dependentes' });
  }
});

router.post('/', requireRole('UP'), async (req, res) => {
  const { username, email, password } = req.body;
  if (!username || !email || !password) {
    return res.status(400).json({ error: 'username, email e senha são obrigatórios' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const passwordHash = await hashPassword(password);
    const userInsert = await client.query(
      `INSERT INTO users (username, email, password_hash, role)
       VALUES ($1, $2, $3, 'D')
       RETURNING id, username, email, role`,
      [username, email, passwordHash],
    );
    const dependentUser = {
      ...userInsert.rows[0],
      id: Number(userInsert.rows[0].id),
    };

    const linkInsert = await client.query(
      `INSERT INTO dependents (principal_id, dependent_id)
       VALUES ($1, $2)
       RETURNING id, created_at`,
      [req.user.id, dependentUser.id],
    );
    const link = linkInsert.rows[0];

    await client.query('COMMIT');
    return res.status(201).json({
      dependent: {
        id: Number(link.id),
        user_id: dependentUser.id,
        username: dependentUser.username,
        email: dependentUser.email,
        role: dependentUser.role,
        created_at: link.created_at,
      },
    });
  } catch (err) {
    await client.query('ROLLBACK');
    if (err.code === '23505') {
      return res
        .status(409)
        .json({ error: 'username ou email já está em uso' });
    }
    console.error('Erro ao criar dependente', err);
    return res.status(500).json({ error: 'Erro ao criar dependente' });
  } finally {
    client.release();
  }
});

module.exports = router;
