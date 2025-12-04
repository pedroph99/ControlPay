# ControlPayWeb (client)

Frontend em React + backend Express para consumir o banco Postgres do ControlPay.

## Preparar ambiente
1. Suba o Postgres do projeto raiz: `docker-compose up -d` (usa `db/init`).
2. API (`client/api`): `cp .env.example .env` e ajuste se precisar. Depois `npm install` e `npm run dev` (porta 4000 por padrão).
3. Web (`client/web`): `cp .env.example .env` (aponta para `http://localhost:4000/api`), `npm install` e `npm run dev` (porta 5173).

## Rotas da API
- `POST /api/auth/login` — autentica por username/senha e devolve JWT. O login usa bcrypt se o hash estiver no formato `$2...`, senão confere texto puro (dados seed).
- `GET /api/users/me` — perfil do usuário logado.
- `GET /api/transactions/recent` — últimas transações; Admin vê todas, Principal vê próprias + dependentes, Dependente vê só as próprias.
- `POST /api/transactions` — cria transação (Principal pode direcionar para dependentes).
- `GET /api/fixed-expenses` — lista gastos fixos dentro do escopo do usuário.
- `GET /api/dependents` / `POST /api/dependents` — listagem e criação de dependentes (apenas Principal cria).

## Credenciais seed (dados de `db/init/02_bancoInsert.sql`)
- Principais: `carlos`/`hash1`, `julia`/`hash2`, ...
- Dependentes: `pedro`/`hash6`, `marina`/`hash7`, ...
- Admin: `admin1`/`hashadm1`.

## Fluxo na interface
1. Login na página `/login`.
2. Redirecionamento para a Home com:
   - Form de transações (entrada/saída) com seleção de dependente para Principais.
   - Lista de últimos gastos (respeita escopo).
   - Lista de gastos fixos ativos.
   - Se Principal: formulário para criar dependentes e listagem atual.
