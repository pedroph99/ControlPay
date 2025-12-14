--1. Consultar Transações com Nome do Usuário (INNER JOIN)
--Objetivo: Listar o ID da transação, o nome do usuário responsável, o valor e a descrição, garantindo que apenas transações de usuários existentes sejam mostradas.
SELECT 
    t.id AS id_transacao,
    u.username AS nome_usuario,
    t.value AS valor,
    t.description AS descricao
FROM transactions t
INNER JOIN users u ON t.user_id = u.id;


--2. Listar Usuários e seus Dependentes (LEFT OUTER JOIN)
--Objetivo: Exibir todos os usuários principais e, se tiverem, os nomes de seus dependentes. Usuários sem dependentes também aparecem na lista (campo dependente será NULL).
SELECT 
    up.username AS usuario_principal,
    ud.username AS nome_dependente
FROM users up
LEFT JOIN dependents d ON up.id = d.principal_id
LEFT JOIN users ud ON d.dependent_id = ud.id
WHERE up.role = 'UP';


--3. Metas do Usuário Principal (IS NULL)
--Objetivo: Listar metas financeiras que pertencem exclusivamente ao usuário principal, ou seja, não estão vinculadas a nenhum dependente (dependent_id é nulo), exibindo também o nome do responsável.
SELECT 
    u.username AS responsavel,
    fg.category AS categoria,
    fg.max_value AS limite
FROM financial_goals fg
INNER JOIN users u ON fg.user_id = u.id
WHERE fg.dependent_id IS NULL;


--4. Transações de um Período Específico (BETWEEN)
--Objetivo: Listar todas as transações realizadas na primeira semana de Fevereiro de 2025.
SELECT 
    description,
    value,
    date
FROM transactions
WHERE date BETWEEN '2025-02-01' AND '2025-02-07';


--5. Filtrar Transações por Categorias Específicas (IN)
--Objetivo: Listar gastos focados apenas em 'Alimentação' e 'Transporte'.
SELECT 
    description,
    value,
    category
FROM transactions
WHERE category IN ('Alimentação', 'Transporte');


--6. Usuários com Gastos Fixos Cadastrados (EXISTS)
--Objetivo: Listar os nomes dos usuários que possuem pelo menos um gasto fixo (como Aluguel ou Internet) cadastrado no sistema.
SELECT username 
FROM users u
WHERE EXISTS (
    SELECT 1 
    FROM fixed_expenses fe 
    WHERE fe.user_id = u.id
);


--7. Total Gasto por Categoria (SUM + GROUP BY)
--Objetivo: Calcular o valor total gasto em cada categoria de despesa (tipo 'saida').
SELECT 
    category,
    SUM(value) AS total_gasto
FROM transactions
WHERE type = 'saida'
GROUP BY category;


--8. Categorias com Altos Gastos (HAVING)
--Objetivo: Mostrar apenas as categorias onde a soma total dos gastos ultrapassa R$ 300,00.
SELECT 
    category,
    SUM(value) AS total_gasto
FROM transactions
WHERE type = 'saida'
GROUP BY category
HAVING SUM(value) > 300.00;


--9. Média de Valor das Transações (AVG)
--Objetivo: Calcular a média geral dos valores de todas as transações registradas.
SELECT 
    AVG(value) AS media_valores
FROM transactions;


--10. Transações Acima da Média (Consulta Aninhada / Subquery)
--Objetivo: Listar as transações cujo valor individual é maior que a média de todas as transações do banco.
SELECT 
    description,
    value
FROM transactions
WHERE value > (
    SELECT AVG(value) FROM transactions
);


--11. Relatório Unificado de Grandes Despesas (UNION)
--Objetivo: Criar uma lista única contendo descrições de transações avulsas caras (> 500) e descrições de gastos fixos caros (> 400).
SELECT description, value, 'Transação Avulsa' AS tipo_origem
FROM transactions
WHERE value > 500 AND type = 'saida'

UNION

SELECT description, value, 'Gasto Fixo' AS tipo_origem
FROM fixed_expenses
WHERE value > 400;


--12. Maior Transação Realizada (MAX)
--Objetivo: Identificar o valor da transação mais alta registrada no sistema.
SELECT 
    MAX(value) AS maior_transacao
FROM transactions;


--13. Contagem de Transações por Usuário (COUNT + GROUP BY)
--Objetivo: Contar quantas transações cada usuário realizou.
SELECT 
    u.username,
    COUNT(t.id) AS qtd_transacoes
FROM users u
JOIN transactions t ON u.id = t.user_id
GROUP BY u.username;
