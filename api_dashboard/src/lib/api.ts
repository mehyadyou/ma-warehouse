/// لایهٔ API داشبورد — همهٔ درخواست‌ها با توکن JWT مدیر
const TOKEN_KEY = 'api_dash_token';

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

export function setToken(token: string | null) {
  if (token) localStorage.setItem(TOKEN_KEY, token);
  else localStorage.removeItem(TOKEN_KEY);
}

export class ApiError extends Error {
  constructor(message: string, public status: number) {
    super(message);
  }
}

async function request<T>(method: string, path: string, body?: unknown): Promise<T> {
  const token = getToken();
  const res = await fetch(path, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });

  if (res.status === 401) {
    setToken(null);
    throw new ApiError('نشست شما منقضی شده است؛ دوباره وارد شوید', 401);
  }

  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new ApiError((data as { error?: string }).error ?? 'خطای نامشخص', res.status);
  }
  return data as T;
}

export interface ApiKeyRow {
  id: string;
  name: string;
  prefix: string;
  scopes: string[];
  isActive: boolean;
  expiresAt: string | null;
  lastUsedAt: string | null;
  useCount: number;
  createdAt: string;
  revokedAt: string | null;
  isExpired: boolean;
}

export interface CreateKeyResponse extends ApiKeyRow {
  key: string; // فقط یک بار
}

export const api = {
  login: async (phone: string, password: string) => {
    const data = await request<{ token: string; user: { name: string; role: string } }>(
      'POST',
      '/api/auth/login',
      { phone, password },
    );
    setToken(data.token);
    return data;
  },

  me: () => request<{ profile: { name: string; role: string } }>('GET', '/api/auth/profile'),

  listKeys: () => request<{ keys: ApiKeyRow[] }>('GET', '/api/manager/api-keys'),

  createKey: (input: { name: string; scopes: string[]; expiresAt: string | null }) =>
    request<CreateKeyResponse>('POST', '/api/manager/api-keys', input),

  revokeKey: (id: string) => request<{ ok: boolean }>('POST', `/api/manager/api-keys/${id}/revoke`),

  restoreKey: (id: string) => request<{ ok: boolean }>('POST', `/api/manager/api-keys/${id}/restore`),

  deleteKey: (id: string) => request<{ ok: boolean }>('DELETE', `/api/manager/api-keys/${id}`),

  scopes: () => request<{ scopes: string[] }>('GET', '/api/manager/api-keys/scopes'),
};
