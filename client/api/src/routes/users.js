const express = require('express');
const { pool } = require('../db');
const { authenticate } = require('../auth');

const router = express.Router();

router.get('/me', authenticate, async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT id, username, email, role FROM users WHERE id = $1 AND is_deleted = FALSE',
      [req.user.id],
    );
    const user = rows[0];
    if (!user) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    return res.json({ user: { ...user, id: Number(user.id) } });
  } catch (err) {
    console.error('Erro ao buscar perfil', err);
    return res.status(500).json({ error: 'Erro ao carregar perfil' });
  }
});

module.exports = router;
