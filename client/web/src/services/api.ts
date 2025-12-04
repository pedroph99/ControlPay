import type { AuthResponse, Dependent, FixedExpense, Transaction, User } from '../types';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000/api';

async function request<T>(path: string, options: RequestInit = {}, token?: string): Promise<T> {
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...(options.headers || {}),
  };

  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  const response = await fetch(`${API_URL}${path}`, {
    ...options,
    headers,
  });

  const data = await response.json().catch(() => ({}));

  if (!response.ok) {
    throw new Error(data.error || 'Erro inesperado');
  }

  return data as T;
}

export const authApi = {
  login: (username: string, password: string) =>
    request<AuthResponse>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ username, password }),
    }),
};

export const userApi = {
  me: (token: string) => request<{ user: User }>('/users/me', {}, token),
};

export const transactionsApi = {
  recent: (token: string, limit = 8) =>
    request<{ transactions: Transaction[] }>(`/transactions/recent?limit=${limit}`, {}, token),
  create: (
    token: string,
    payload: Partial<Transaction> & { value: number; type: Transaction['type']; userId?: number },
  ) =>
    request<{ transaction: Transaction }>('/transactions', {
      method: 'POST',
      body: JSON.stringify(payload),
    }, token),
};

export const dependentsApi = {
  list: (token: string) => request<{ dependents: Dependent[] }>('/dependents', {}, token),
  create: (
    token: string,
    payload: { username: string; email: string; password: string },
  ) =>
    request<{ dependent: Dependent }>('/dependents', {
      method: 'POST',
      body: JSON.stringify(payload),
    }, token),
};

export const fixedExpensesApi = {
  list: (token: string) => request<{ fixedExpenses: FixedExpense[] }>('/fixed-expenses', {}, token),
};
