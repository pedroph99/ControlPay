-- Dados iniciais CONTROL PAY (PostgreSQL)

-- IMPORTANTE: assumir que já está conectado ao banco controlpay
-- (por exemplo, via POSTGRES_DB=controlpay no Docker)

INSERT INTO users (username, email, password_hash, role)
VALUES
-- Usuários Principais
('carlos', 'carlos@mail.com', 'hash1', 'UP'),
('julia', 'julia@mail.com', 'hash2', 'UP'),
('marcos', 'marcos@mail.com', 'hash3', 'UP'),
('ana', 'ana@mail.com', 'hash4', 'UP'),
('roberto', 'roberto@mail.com', 'hash5', 'UP'),

-- Dependentes
('pedro', 'pedro@mail.com', 'hash6', 'D'),
('marina', 'marina@mail.com', 'hash7', 'D'),
('sofia', 'sofia@mail.com', 'hash8', 'D'),
('lucas', 'lucas@mail.com', 'hash9', 'D'),
('gustavo', 'gustavo@mail.com', 'hash10', 'D'),
('melissa', 'melissa@mail.com', 'hash11', 'D'),
('paulo', 'paulo@mail.com', 'hash12', 'D'),

-- Administradores
('admin1', 'admin1@controlpay.com', 'hashadm1', 'ADM'),
('admin2', 'admin2@controlpay.com', 'hashadm2', 'ADM');

INSERT INTO dependents (principal_id, dependent_id)
VALUES
(1, 6),  -- Carlos -> Pedro
(1, 7),  -- Carlos -> Marina
(2, 8),  -- Julia -> Sofia
(2, 9),  -- Julia -> Lucas
(3, 10), -- Marcos -> Gustavo
(4, 11), -- Ana -> Melissa
(5, 12); -- Roberto -> Paulo

INSERT INTO transactions (user_id, value, type, category, description, date, time)
VALUES
-- Transações de Carlos (UP)
(1, 3500.00, 'entrada', 'Salário', 'Salário mensal', '2025-02-01', '08:30:00'),
(1, 250.90, 'saida', 'Alimentação', 'Compras no mercado', '2025-02-03', '14:20:00'),
(1, 79.00, 'saida', 'Transporte', 'Uber para trabalho', '2025-02-04', '07:55:00'),
(1, 420.00, 'saida', 'Contas', 'Luz + água', '2025-02-05', '18:10:00'),

-- Dependente Pedro
(6, 45.00, 'saida', 'Lazer', 'Cinema', '2025-02-02', '20:00:00'),
(6, 18.50, 'saida', 'Alimentação', 'Lanche', '2025-02-03', '16:40:00'),

-- Dependente Marina
(7, 120.00, 'saida', 'Roupas', 'Camisa nova', '2025-02-06', '11:10:00'),

-- Transações de Júlia (UP)
(2, 4500.00, 'entrada', 'Salário', 'Pagamento mensal', '2025-02-01', '09:00:00'),
(2, 300.20, 'saida', 'Mercado', 'Compras semanais', '2025-02-03', '17:30:00'),
(2, 150.00, 'saida', 'Saúde', 'Farmácia', '2025-02-04', '12:00:00'),

-- Dependente Sofia
(8, 50.00, 'saida', 'Escola', 'Material escolar', '2025-02-03', '10:00:00'),

-- Dependente Lucas
(9, 35.00, 'saida', 'Lazer', 'Jogos online', '2025-02-03', '21:00:00'),

-- Transações de Marcos (UP)
(3, 3900.00, 'entrada', 'Salário', 'Pagamento', '2025-02-01', '08:00:00'),
(3, 600.00, 'saida', 'Contas', 'Internet + energia', '2025-02-05', '19:00:00'),

-- Gustavo (dependente)
(10, 99.00, 'saida', 'Alimentação', 'Lanche no shopping', '2025-02-02', '15:45:00'),

-- Ana (UP)
(4, 3200.00, 'entrada', 'Salário', 'Pagamento mensal', '2025-02-01', '08:10:00'),
(4, 215.60, 'saida', 'Transporte', 'Manutenção do carro', '2025-02-04', '09:40:00'),

-- Melissa (dependente)
(11, 89.90, 'saida', 'Roupas', 'Blusa', '2025-02-06', '13:00:00'),

-- Roberto (UP)
(5, 5200.00, 'entrada', 'Salário', 'Pagamento mensal', '2025-02-01', '09:15:00'),
(5, 399.00, 'saida', 'Lazer', 'Restaurante', '2025-02-06', '20:00:00'),

-- Paulo (dependente)
(12, 22.00, 'saida', 'Alimentação', 'Café da manhã', '2025-02-03', '07:30:00'),

-- Muitos outros registros para volume de testes
(1, 200.00, 'saida', 'Lazer', 'Streaming anual', '2025-02-10', '12:20:00'),
(2, 650.00, 'saida', 'Casa', 'Cadeira nova', '2025-02-11', '16:00:00'),
(3, 78.90, 'saida', 'Alimentação', 'Padaria', '2025-02-12', '08:10:00'),
(4, 90.00, 'saida', 'Educação', 'Curso online', '2025-02-12', '14:20:00'),
(5, 1500.00, 'saida', 'Tecnologia', 'Smartphone', '2025-02-12', '19:30:00');

INSERT INTO fixed_expenses (user_id, value, category, description, recurrence_days, next_debit_date)
VALUES
(1, 120.00, 'Streaming', 'Netflix', 30, '2025-03-01'),
(1, 89.90, 'Internet', 'Plano 500mb', 30, '2025-03-05'),
(2, 250.00, 'Educação', 'Curso profissional', 30, '2025-03-10'),
(5, 500.00, 'Aluguel', 'Apartamento', 30, '2025-03-01');

INSERT INTO financial_goals (user_id, category, dependent_id, max_value, period_start, period_end)
VALUES
(1, 'Lazer', NULL, 400.00, '2025-02-01', '2025-02-28'),
(1, NULL, 6, 200.00, '2025-02-01', '2025-02-28'),
(2, 'Mercado', NULL, 800.00, '2025-02-01', '2025-02-28'),
(5, NULL, NULL, 1500.00, '2025-02-01', '2025-02-28');

INSERT INTO goal_notifications (goal_id, user_id, message)
VALUES
(1, 1, 'Você atingiu 80% da meta de Lazer.'),
(2, 1, 'Pedro atingiu 100% da meta de gastos.');

INSERT INTO logs (user_id, action, entity, entity_id, ip_address)
VALUES
(1, 'Login', 'users', 1, '127.0.0.1'),
(1, 'Criou dependente', 'dependents', 6, '127.0.0.1'),
(2, 'Adicionou transação', 'transactions', 15, '127.0.0.1'),
(14, 'Acesso administrativo', 'logs', NULL, '127.0.0.1');
