-- Views para o esquema Control Pay

-- Hierarquia de principais e dependentes
DROP VIEW IF EXISTS vw_users_dependents;
CREATE VIEW vw_users_dependents AS
SELECT
    d.id                AS dependent_link_id,
    d.principal_id,
    up.username         AS principal_username,
    up.is_deleted       AS principal_is_deleted,
    d.dependent_id,
    ud.username         AS dependent_username,
    ud.is_deleted       AS dependent_is_deleted,
    d.created_at        AS link_created_at
FROM dependents d
JOIN users up ON up.id = d.principal_id
JOIN users ud ON ud.id = d.dependent_id;

-- Transacoes enriquecidas (apenas registros nao deletados)
DROP VIEW IF EXISTS vw_transactions_enriched;
CREATE VIEW vw_transactions_enriched AS
SELECT
    t.id,
    t.user_id,
    u.username,
    u.role,
    t.value,
    t.type,
    t.category,
    t.description,
    t.date,
    t.time,
    t.created_at,
    t.is_deleted       AS transaction_is_deleted,
    u.is_deleted       AS user_is_deleted
FROM transactions t
JOIN users u ON u.id = t.user_id
WHERE t.is_deleted = FALSE AND u.is_deleted = FALSE;

-- Resumo mensal de entradas/saidas por usuario
DROP VIEW IF EXISTS vw_monthly_summary;
CREATE VIEW vw_monthly_summary AS
SELECT
    u.id                                           AS user_id,
    u.username,
    DATE_TRUNC('month', t.date)::date              AS month_start,
    SUM(CASE WHEN t.type = 'entrada' THEN t.value ELSE 0 END) AS total_entradas,
    SUM(CASE WHEN t.type = 'saida'   THEN t.value ELSE 0 END) AS total_saidas,
    SUM(CASE WHEN t.type = 'entrada' THEN t.value ELSE -t.value END) AS saldo,
    COUNT(*) AS total_transacoes
FROM transactions t
JOIN users u ON u.id = t.user_id
WHERE t.is_deleted = FALSE AND u.is_deleted = FALSE
GROUP BY u.id, u.username, DATE_TRUNC('month', t.date);

-- Gastos fixos ativos e nao deletados
DROP VIEW IF EXISTS vw_fixed_expenses_next;
CREATE VIEW vw_fixed_expenses_next AS
SELECT
    fe.id,
    fe.user_id,
    u.username,
    fe.value,
    fe.category,
    fe.description,
    fe.recurrence_days,
    fe.next_debit_date,
    fe.is_active,
    fe.created_at,
    u.is_deleted AS user_is_deleted
FROM fixed_expenses fe
JOIN users u ON u.id = fe.user_id
WHERE fe.is_active = TRUE AND fe.is_deleted = FALSE AND u.is_deleted = FALSE;

-- Progresso de metas (somando saidas do periodo)
DROP VIEW IF EXISTS vw_goal_progress;
CREATE VIEW vw_goal_progress AS
SELECT
    fg.id,
    fg.user_id,
    u.username              AS user_username,
    fg.dependent_id,
    ud.username             AS dependent_username,
    fg.category,
    fg.max_value,
    fg.period_start,
    fg.period_end,
    COALESCE(SUM(CASE WHEN t.type = 'saida' THEN t.value ELSE 0 END), 0) AS gasto_no_periodo,
    CASE
        WHEN fg.max_value > 0
             THEN COALESCE(SUM(CASE WHEN t.type = 'saida' THEN t.value ELSE 0 END), 0) / fg.max_value
        ELSE NULL
    END AS percentual_utilizado
FROM financial_goals fg
JOIN users u ON u.id = fg.user_id
LEFT JOIN users ud ON ud.id = fg.dependent_id
LEFT JOIN transactions t
    ON t.user_id = COALESCE(fg.dependent_id, fg.user_id)
   AND t.is_deleted = FALSE
   AND t.date BETWEEN fg.period_start AND fg.period_end
WHERE fg.is_deleted = FALSE
  AND u.is_deleted = FALSE
  AND (ud.id IS NULL OR ud.is_deleted = FALSE)
GROUP BY fg.id, fg.user_id, u.username, fg.dependent_id, ud.username, fg.category, fg.max_value, fg.period_start, fg.period_end;

-- Logs com info do usuario
DROP VIEW IF EXISTS vw_logs_enriched;
CREATE VIEW vw_logs_enriched AS
SELECT
    l.id,
    l.user_id,
    u.username,
    u.role,
    l.action,
    l.entity,
    l.entity_id,
    l.timestamp,
    l.ip_address
FROM logs l
LEFT JOIN users u ON u.id = l.user_id;
