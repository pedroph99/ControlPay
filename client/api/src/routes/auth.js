const express = require('express');
const { pool } = require('../db');
const { comparePassword, issueToken } = require('../auth');

const router = express.Router();

router.post('/login', async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ error: 'Informe username e senha' });
  }

  try {
    const { rows } = await pool.query(
      'SELECT id, username, password_hash, role, is_deleted FROM users WHERE username = $1 LIMIT 1',
      [username],
    );

    const user = rows[0];
    if (!user || user.is_deleted) {
      return res.status(401).json({ error: 'Credenciais inválidas' });
    }

    const passwordOk = await comparePassword(password, user.password_hash);
    if (!passwordOk) {
      return res.status(401).json({ error: 'Credenciais inválidas' });
    }

    const userId = Number(user.id);
    const token = issueToken({ id: userId, role: user.role, username: user.username });
    return res.json({
      token,
      user: { id: userId, username: user.username, role: user.role },
    });
  } catch (err) {
    console.error('Erro no login', err);
    return res.status(500).json({ error: 'Erro ao autenticar' });
  }
});

module.exports = router;
