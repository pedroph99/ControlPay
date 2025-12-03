-- Triggers para o esquema Control Pay

-- Log de criacao de dependentes
DROP TRIGGER IF EXISTS trg_dependents_insert_log ON dependents;
DROP FUNCTION IF EXISTS log_dependents_insert();

CREATE OR REPLACE FUNCTION log_dependents_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO logs (user_id, action, entity, entity_id, ip_address)
    VALUES (NEW.principal_id, 'Dependente inserido com sucesso', 'dependents', NEW.id, NULL);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_dependents_insert_log
AFTER INSERT ON dependents
FOR EACH ROW
EXECUTE FUNCTION log_dependents_insert();

-- Log de insercao em transactions
DROP TRIGGER IF EXISTS trg_transactions_insert_log ON transactions;
DROP FUNCTION IF EXISTS log_transactions_insert();

CREATE OR REPLACE FUNCTION log_transactions_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO logs (user_id, action, entity, entity_id, ip_address)
    VALUES (NEW.user_id, 'inseriu transaction', 'transactions', NEW.id, NULL);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_transactions_insert_log
AFTER INSERT ON transactions
FOR EACH ROW
EXECUTE FUNCTION log_transactions_insert();

-- Log de insercao em fixed_expenses
DROP TRIGGER IF EXISTS trg_fixed_expenses_insert_log ON fixed_expenses;
DROP FUNCTION IF EXISTS log_fixed_expenses_insert();

CREATE OR REPLACE FUNCTION log_fixed_expenses_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO logs (user_id, action, entity, entity_id, ip_address)
    VALUES (NEW.user_id, 'inseriu fixed_expenses', 'fixed_expenses', NEW.id, NULL);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_fixed_expenses_insert_log
AFTER INSERT ON fixed_expenses
FOR EACH ROW
EXECUTE FUNCTION log_fixed_expenses_insert();

-- Log de alteracao do campo is_deleted em users
DROP TRIGGER IF EXISTS trg_users_is_deleted_log ON users;
DROP FUNCTION IF EXISTS log_users_is_deleted_change();

CREATE OR REPLACE FUNCTION log_users_is_deleted_change()
RETURNS TRIGGER AS $$
BEGIN
    IF COALESCE(OLD.is_deleted, FALSE) IS DISTINCT FROM COALESCE(NEW.is_deleted, FALSE) THEN
        INSERT INTO logs (user_id, action, entity, entity_id, ip_address)
        VALUES (NEW.id, 'alterou is_deleted de usuario', 'users', NEW.id, NULL);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_is_deleted_log
AFTER UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION log_users_is_deleted_change();

-- Cascateamento de is_deleted para dependentes (preserva dependente que estiver explicitamente falso)
DROP TRIGGER IF EXISTS trg_users_cascade_is_deleted ON users;
DROP FUNCTION IF EXISTS cascade_dependents_is_deleted();

CREATE OR REPLACE FUNCTION cascade_dependents_is_deleted()
RETURNS TRIGGER AS $$
BEGIN
    IF COALESCE(OLD.is_deleted, FALSE) IS DISTINCT FROM COALESCE(NEW.is_deleted, FALSE) THEN
        UPDATE users u
        SET is_deleted = NEW.is_deleted
        FROM dependents d
        WHERE d.principal_id = NEW.id
          AND d.dependent_id = u.id
          AND u.is_deleted IS DISTINCT FROM NEW.is_deleted
          AND NOT (u.is_deleted = TRUE);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_cascade_is_deleted
AFTER UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION cascade_dependents_is_deleted();

-- Log de alteracao do campo is_deleted em transactions
DROP TRIGGER IF EXISTS trg_transactions_is_deleted_log ON transactions;
DROP FUNCTION IF EXISTS log_transactions_is_deleted_change();

CREATE OR REPLACE FUNCTION log_transactions_is_deleted_change()
RETURNS TRIGGER AS $$
BEGIN
    IF COALESCE(OLD.is_deleted, FALSE) IS DISTINCT FROM COALESCE(NEW.is_deleted, FALSE) THEN
        INSERT INTO logs (user_id, action, entity, entity_id, ip_address)
        VALUES (NEW.user_id, 'alterou is_deleted de transaction', 'transactions', NEW.id, NULL);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_transactions_is_deleted_log
AFTER UPDATE ON transactions
FOR EACH ROW
EXECUTE FUNCTION log_transactions_is_deleted_change();

-- Log de alteracao do campo is_deleted em fixed_expenses
DROP TRIGGER IF EXISTS trg_fixed_expenses_is_deleted_log ON fixed_expenses;
DROP FUNCTION IF EXISTS log_fixed_expenses_is_deleted_change();

CREATE OR REPLACE FUNCTION log_fixed_expenses_is_deleted_change()
RETURNS TRIGGER AS $$
BEGIN
    IF COALESCE(OLD.is_deleted, FALSE) IS DISTINCT FROM COALESCE(NEW.is_deleted, FALSE) THEN
        INSERT INTO logs (user_id, action, entity, entity_id, ip_address)
        VALUES (NEW.user_id, 'alterou is_deleted de fixed_expenses', 'fixed_expenses', NEW.id, NULL);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_fixed_expenses_is_deleted_log
AFTER UPDATE ON fixed_expenses
FOR EACH ROW
EXECUTE FUNCTION log_fixed_expenses_is_deleted_change();
