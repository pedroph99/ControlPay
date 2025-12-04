const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret';

const issueToken = (payload) =>
  jwt.sign(payload, JWT_SECRET, {
    expiresIn: '4h',
  });

const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token nulo ou ausente' });
  }

  const token = authHeader.replace('Bearer ', '');
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const id = Number(decoded.id);
    req.user = {
      id: Number.isNaN(id) ? decoded.id : id,
      role: decoded.role,
      username: decoded.username,
    };
    return next();
  } catch (err) {
    return res.status(401).json({ error: 'Token inválido' });
  }
};

const requireRole = (...roles) => (req, res, next) => {
  if (!roles.includes(req.user.role)) {
    return res.status(403).json({ error: 'Acesso negado para este papel' });
  }
  return next();
};

const looksHashed = (hash) => hash?.startsWith('$2');

const comparePassword = async (plain, hash) => {
  if (!hash) return false;
  if (looksHashed(hash)) {
    return bcrypt.compare(plain, hash);
  }
  // fallback simples para dados seed que não estão com bcrypt
  return plain === hash;
};

const hashPassword = async (plain) => bcrypt.hash(plain, 10);

module.exports = {
  authenticate,
  requireRole,
  comparePassword,
  hashPassword,
  issueToken,
};
