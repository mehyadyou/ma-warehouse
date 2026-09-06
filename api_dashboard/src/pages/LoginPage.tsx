import { useState } from 'react';
import { api } from '../lib/api';

export default function LoginPage({ onSuccess }: { onSuccess: (name: string) => void }) {
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setError('');
    setBusy(true);
    try {
      const r = await api.login(phone.trim(), password);
      if (r.user.role !== 'MANAGER') {
        throw new Error('فقط مدیر به این داشبورد دسترسی دارد');
      }
      onSuccess(r.user.name);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'ورود ناموفق بود');
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="login-wrap">
      <form className="login-card" onSubmit={submit}>
        <div className="login-logo">ما</div>
        <h2>داشبورد API</h2>
        <p className="muted">ورود مدیر — کلیدهای API سیستم‌های بیرونی</p>
        <input
          dir="ltr"
          placeholder="09xxxxxxxxx"
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
          autoComplete="username"
        />
        <input
          dir="ltr"
          type="password"
          placeholder="رمز عبور (۶ رقم)"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          autoComplete="current-password"
        />
        {error && <div className="error">{error}</div>}
        <button className="btn primary" disabled={busy}>
          {busy ? 'در حال ورود…' : 'ورود'}
        </button>
      </form>
    </div>
  );
}
