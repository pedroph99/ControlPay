export type Role = 'ADM' | 'UP' | 'D';

export interface User {
  id: number;
  username: string;
  email?: string;
  role: Role;
}

export interface Transaction {
  id: number;
  user_id: number;
  username: string;
  role: Role;
  value: number;
  type: 'entrada' | 'saida';
  category?: string;
  description?: string;
  date: string;
  time: string;
}

export interface FixedExpense {
  id: number;
  user_id: number;
  username: string;
  value: number;
  category?: string;
  description?: string;
  recurrence_days: number;
  next_debit_date: string;
  is_active: boolean;
}

export interface Dependent {
  id: number;
  user_id: number;
  username: string;
  email: string;
  role: Role;
  created_at: string;
  is_deleted?: boolean;
}

export interface AuthResponse {
  token: string;
  user: User;
}
