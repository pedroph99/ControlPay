import React, { useEffect, useMemo, useState } from 'react';
import { dependentsApi, fixedExpensesApi, transactionsApi } from '../services/api';
import type { Dependent, FixedExpense, Transaction } from '../types';
import { useAuth } from '../state/AuthContext';

type TransactionForm = {
  value: string;
  type: Transaction['type'];
  category: string;
  description: string;
  date: string;
  time: string;
  userId?: number;
};

type NewDependent = {
  username: string;
  email: string;
  password: string;
};

const emptyTransaction: TransactionForm = {
  value: '',
  type: 'saida',
  category: '',
  description: '',
  date: '',
  time: '',
};

const emptyDependent: NewDependent = {
  username: '',
  email: '',
  password: '',
};

function HomePage() {
  const { user, token, logout } = useAuth();
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [fixedExpenses, setFixedExpenses] = useState<FixedExpense[]>([]);
  const [dependents, setDependents] = useState<Dependent[]>([]);
  const [transactionForm, setTransactionForm] = useState<TransactionForm>(emptyTransaction);
  const [newDependent, setNewDependent] = useState<NewDependent>(emptyDependent);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const isPrincipal = user?.role === 'UP';

  const peopleOptions = useMemo(() => {
    if (!user) return [];
    const base = [{ id: user.id, label: `${user.username} (você)` }];
    if (isPrincipal) {
      base.push(
        ...dependents.map((dep) => ({
          id: dep.user_id,
          label: `${dep.username} (dependente)`,
        })),
      );
    }
    return base;
  }, [user, dependents, isPrincipal]);

  const loadData = async () => {
    if (!token) return;
    setLoading(true);
    setError(null);
    try {
      const [recent, fixed, deps] = await Promise.all([
        transactionsApi.recent(token),
        fixedExpensesApi.list(token),
        isPrincipal ? dependentsApi.list(token) : Promise.resolve({ dependents: [] }),
      ]);

      setTransactions(recent.transactions);
      setFixedExpenses(fixed.fixedExpenses);
      setDependents(deps.dependents);
      if (!transactionForm.userId && user?.id) {
        setTransactionForm((prev) => ({ ...prev, userId: user.id }));
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao carregar dados');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [token, user?.role]);

  const handleTransactionSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    if (!token) return;
    setError(null);
    setSuccess(null);
    const numericValue = Number(transactionForm.value);
    if (Number.isNaN(numericValue)) {
      setError('Valor inválido');
      return;
    }

    try {
      await transactionsApi.create(token, {
        ...transactionForm,
        value: numericValue,
      });
      setTransactionForm((prev) => ({
        ...emptyTransaction,
        userId: prev.userId ?? user?.id,
      }));
      setSuccess('Transação registrada com sucesso');
      const refreshed = await transactionsApi.recent(token);
      setTransactions(refreshed.transactions);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao salvar transação');
    }
  };

  const handleDependentSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    if (!token) return;
    setError(null);
    setSuccess(null);
    try {
      const { dependent } = await dependentsApi.create(token, newDependent);
      setDependents((prev) => [...prev, dependent]);
      setNewDependent(emptyDependent);
      setSuccess('Dependente criado');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao criar dependente');
    }
  };

  return (
    <div className="page">
      <header className="topbar">
        <div>
          <p className="eyebrow">ControlPayWeb</p>
          <h1>Olá, {user?.username}</h1>
          <p className="muted">Papel: {user?.role === 'UP' ? 'Principal' : user?.role === 'D' ? 'Dependente' : 'Admin'}</p>
        </div>
        <div className="top-actions">
          <span className="pill">Sessão ativa</span>
          <button className="ghost-btn" type="button" onClick={logout}>
            Sair
          </button>
        </div>
      </header>

      {error && <div className="alert">{error}</div>}
      {success && <div className="success">{success}</div>}

      <section className="grid two-cols">
        <div className="panel">
          <div className="panel-header">
            <p className="eyebrow">Transações</p>
            <h2>Registrar uma transação</h2>
            <p className="muted">Controle rápido de entradas e saídas.</p>
          </div>
          <form className="form" onSubmit={handleTransactionSubmit}>
            <div className="form-grid two">
              <label className="form-label" htmlFor="value">
                Valor
                <input
                  id="value"
                  type="number"
                  step="0.01"
                  value={transactionForm.value}
                  onChange={(e) => setTransactionForm({ ...transactionForm, value: e.target.value })}
                  required
                />
              </label>
              <label className="form-label" htmlFor="type">
                Tipo
                <select
                  id="type"
                  value={transactionForm.type}
                  onChange={(e) => setTransactionForm({ ...transactionForm, type: e.target.value as Transaction['type'] })}
                >
                  <option value="entrada">Entrada</option>
                  <option value="saida">Saída</option>
                </select>
              </label>
            </div>

            {peopleOptions.length > 1 && (
              <label className="form-label" htmlFor="user">
                Para quem?
                <select
                  id="user"
                  value={transactionForm.userId}
                  onChange={(e) => setTransactionForm({ ...transactionForm, userId: Number(e.target.value) })}
                >
                  {peopleOptions.map((person) => (
                    <option key={person.id} value={person.id}>{person.label}</option>
                  ))}
                </select>
              </label>
            )}

            <label className="form-label" htmlFor="category">
              Categoria
              <input
                id="category"
                type="text"
                value={transactionForm.category}
                onChange={(e) => setTransactionForm({ ...transactionForm, category: e.target.value })}
                placeholder="Ex: Mercado, Transporte..."
              />
            </label>

            <label className="form-label" htmlFor="description">
              Descrição
              <input
                id="description"
                type="text"
                value={transactionForm.description}
                onChange={(e) => setTransactionForm({ ...transactionForm, description: e.target.value })}
                placeholder="Observações opcionais"
              />
            </label>

            <div className="form-grid two">
              <label className="form-label" htmlFor="date">
                Data
                <input
                  id="date"
                  type="date"
                  value={transactionForm.date}
                  onChange={(e) => setTransactionForm({ ...transactionForm, date: e.target.value })}
                />
              </label>
              <label className="form-label" htmlFor="time">
                Hora
                <input
                  id="time"
                  type="time"
                  value={transactionForm.time}
                  onChange={(e) => setTransactionForm({ ...transactionForm, time: e.target.value })}
                />
              </label>
            </div>

            <button className="primary-btn" type="submit">Salvar transação</button>
          </form>
        </div>

        <div className="panel list-panel">
          <div className="panel-header">
            <p className="eyebrow">Últimas movimentações</p>
            <h2>Recentes</h2>
            <p className="muted">Atualizado a cada lançamento.</p>
          </div>
          {loading ? (
            <p className="muted">Carregando...</p>
          ) : (
            <ul className="list">
              {transactions.map((t) => (
                <li key={t.id} className="list-item">
                  <div>
                    <p className="list-title">
                      {t.description || 'Sem descrição'}
                      <span className={`tag ${t.type === 'entrada' ? 'tag-in' : 'tag-out'}`}>
                        {t.type}
                      </span>
                    </p>
                    <p className="muted small">
                      {t.username} • {t.category || 'Sem categoria'} • {t.date} {t.time}
                    </p>
                  </div>
                  <strong className={t.type === 'entrada' ? 'value in' : 'value out'}>
                    {t.type === 'saida' ? '-' : '+'}
                    R$ {t.value.toFixed(2)}
                  </strong>
                </li>
              ))}
              {transactions.length === 0 && <p className="muted">Nenhuma transação registrada.</p>}
            </ul>
          )}
        </div>
      </section>

      <section className="grid two-cols">
        <div className="panel list-panel">
          <div className="panel-header">
            <p className="eyebrow">Gastos fixos</p>
            <h2>Próximos débitos</h2>
            <p className="muted">Itens ativos e não deletados.</p>
          </div>
          {loading ? (
            <p className="muted">Carregando...</p>
          ) : (
            <ul className="list">
              {fixedExpenses.map((fx) => (
                <li key={fx.id} className="list-item">
                  <div>
                    <p className="list-title">{fx.description || fx.category || 'Gasto fixo'}</p>
                    <p className="muted small">
                      {fx.username} • próxima data: {fx.next_debit_date} • {fx.recurrence_days} dias
                    </p>
                  </div>
                  <strong className="value out">R$ {fx.value.toFixed(2)}</strong>
                </li>
              ))}
              {fixedExpenses.length === 0 && <p className="muted">Nenhum gasto fixo cadastrado.</p>}
            </ul>
          )}
        </div>

        {isPrincipal && (
          <div className="panel">
            <div className="panel-header">
              <p className="eyebrow">Dependentes</p>
              <h2>Gerenciar dependentes</h2>
              <p className="muted">Crie novos acessos vinculados.</p>
            </div>
            <form className="form" onSubmit={handleDependentSubmit}>
              <label className="form-label" htmlFor="dep-username">
                Username
                <input
                  id="dep-username"
                  type="text"
                  value={newDependent.username}
                  onChange={(e) => setNewDependent({ ...newDependent, username: e.target.value })}
                  required
                />
              </label>
              <label className="form-label" htmlFor="dep-email">
                Email
                <input
                  id="dep-email"
                  type="email"
                  value={newDependent.email}
                  onChange={(e) => setNewDependent({ ...newDependent, email: e.target.value })}
                  required
                />
              </label>
              <label className="form-label" htmlFor="dep-password">
                Senha
                <input
                  id="dep-password"
                  type="password"
                  value={newDependent.password}
                  onChange={(e) => setNewDependent({ ...newDependent, password: e.target.value })}
                  required
                />
              </label>
              <button className="primary-btn" type="submit">Adicionar dependente</button>
            </form>

            <div className="dependents-list">
              <h3 className="muted">Lista atual</h3>
              <ul className="list compact">
                {dependents.map((dep) => (
                  <li key={dep.user_id} className="list-item">
                    <div>
                      <p className="list-title">{dep.username}</p>
                      <p className="muted small">{dep.email}</p>
                    </div>
                    <span className="pill">ID {dep.user_id}</span>
                  </li>
                ))}
                {dependents.length === 0 && <p className="muted">Nenhum dependente cadastrado.</p>}
              </ul>
            </div>
          </div>
        )}
      </section>
    </div>
  );
}

export default HomePage;
