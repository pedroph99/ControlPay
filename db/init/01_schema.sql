-- =====================================
--     SCHEMA: CONTROL PAY (PostgreSQL)
-- =====================================

-- Se quiser criar o banco antes (rodando em outro contexto):
-- CREATE DATABASE controlpay;
-- \c controlpay   -- no psql, para conectar

-- Tipos ENUM (PostgreSQL)
CREATE TYPE role_enum AS ENUM ('UP', 'D', 'ADM');
CREATE TYPE transaction_type AS ENUM ('entrada', 'saida');

-- Usuários
CREATE TABLE users (
    id              BIGSERIAL PRIMARY KEY,
    username        VARCHAR(80) NOT NULL UNIQUE,
    email           VARCHAR(120) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    role            role_enum NOT NULL,
    is_deleted      BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dependentes
CREATE TABLE dependents (
    id              BIGSERIAL PRIMARY KEY,
    principal_id    BIGINT NOT NULL,
    dependent_id    BIGINT NOT NULL UNIQUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (principal_id) REFERENCES users(id),
    FOREIGN KEY (dependent_id) REFERENCES users(id)
);

-- Transações
CREATE TABLE transactions (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,                  -- UP ou D
    value           DECIMAL(12,2) NOT NULL,
    type            transaction_type NOT NULL,
    category        VARCHAR(80),
    description     TEXT,
    date            DATE NOT NULL,
    time            TIME NOT NULL,
    is_deleted      BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Histórico de transações (edições)
CREATE TABLE transaction_history (
    id              BIGSERIAL PRIMARY KEY,
    transaction_id  BIGINT NOT NULL,
    modified_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_value       DECIMAL(12,2),
    old_description TEXT,
    old_category    VARCHAR(80),
    old_type        transaction_type,
    
    FOREIGN KEY (transaction_id) REFERENCES transactions(id)
);

-- Anexos de comprovantes
CREATE TABLE receipts (
    id              BIGSERIAL PRIMARY KEY,
    transaction_id  BIGINT NOT NULL,
    file_path       VARCHAR(255) NOT NULL,
    uploaded_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (transaction_id) REFERENCES transactions(id)
);

-- Gastos fixos
CREATE TABLE fixed_expenses (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    value           DECIMAL(12,2) NOT NULL,
    category        VARCHAR(80),
    description     TEXT,
    recurrence_days INT NOT NULL,            -- RN-09
    next_debit_date DATE NOT NULL,
    is_active       BOOLEAN DEFAULT TRUE,
    is_deleted      BOOLEAN DEFAULT FALSE,
    
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Metas financeiras
CREATE TABLE financial_goals (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,          -- UP
    category        VARCHAR(80),
    dependent_id    BIGINT,                   -- opcional
    max_value       DECIMAL(12,2) NOT NULL,
    period_start    DATE NOT NULL,
    period_end      DATE NOT NULL,
    is_deleted      BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (dependent_id) REFERENCES users(id)
);

-- Alertas de metas
CREATE TABLE goal_notifications (
    id              BIGSERIAL PRIMARY KEY,
    goal_id         BIGINT NOT NULL,
    user_id         BIGINT NOT NULL,
    message         VARCHAR(255) NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (goal_id) REFERENCES financial_goals(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Logs de auditoria
CREATE TABLE logs (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT,
    action          VARCHAR(255) NOT NULL,
    entity          VARCHAR(50),
    entity_id       BIGINT,
    timestamp       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address      VARCHAR(50),

    FOREIGN KEY (user_id) REFERENCES users(id)
);
