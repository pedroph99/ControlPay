const { pool } = require('../db');

async function getUserScopeIds(user) {
  if (user.role === 'ADM') {
    return null; // admin enxerga tudo
  }

  const ids = [Number(user.id)];
  if (user.role === 'UP') {
    const { rows } = await pool.query(
      'SELECT dependent_id FROM dependents WHERE principal_id = $1',
      [user.id],
    );
    ids.push(...rows.map((r) => Number(r.dependent_id)));
  }
  return ids;
}

module.exports = { getUserScopeIds };
