import { useCallback, useEffect, useState } from 'react';
import { api, ApiKeyRow } from '../lib/api';
import { faDateTime, faDigits } from '../lib/persian';

const SCOPE_LABELS: Record<string, string> = {
  products: 'محصولات',
  inventory: 'موجودی',
  orders: 'سفارش‌ها',
  transactions: 'تراکنش‌ها',
  cartons: 'کارتن‌ها',
  warehouses: 'انبارها',
  carriers: 'باربری‌ها',
  deliveries: 'تحویل‌ها',
  users: 'کاربران',
};

export default function KeysPage() {
  const [keys, setKeys] = useState<ApiKeyRow[] | null>(null);
  const [error, setError] = useState('');
  const [showCreate, setShowCreate] = useState(false);
  const [revealed, setRevealed] = useState<{ name: string; key: string } | null>(null);

  const load = useCallback(async () => {
    try {
      const r = await api.listKeys();
      setKeys(r.keys);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'خطا');
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  async function act(fn: () => Promise<unknown>) {
    setError('');
    try {
      await fn();
      await load();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'عملیات ناموفق بود');
    }
  }

  return (
    <div className="page">
      <div className="page-head">
        <div>
          <h2>کلیدهای API</h2>
          <p className="muted">
            کلید خام فقط یک بار هنگام ساخت نمایش داده می‌شود — بعد از آن فقط پیشوند آن دیده می‌شود.
          </p>
        </div>
        <button className="btn primary" onClick={() => setShowCreate(true)}>
          + کلید جدید
        </button>
      </div>

      {error && <div className="error">{error}</div>}

      {keys === null ? (
        <div className="loading">در حال بارگذاری…</div>
      ) : keys.length === 0 ? (
        <div className="empty">هنوز کلیدی ساخته نشده است</div>
      ) : (
        <table className="table">
          <thead>
            <tr>
              <th>نام</th>
              <th>کلید</th>
              <th>دسترسی‌ها</th>
              <th>وضعیت</th>
              <th>تعداد استفاده</th>
              <th>آخرین استفاده</th>
              <th>ساخت</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {keys.map((k) => (
              <tr key={k.id} className={!k.isActive || k.isExpired ? 'row-off' : ''}>
                <td className="strong">{k.name}</td>
                <td dir="ltr" className="mono">
                  {k.prefix}••••
                </td>
                <td>
                  <div className="scopes">
                    {k.scopes.map((s) => (
                      <span key={s} className="chip">
                        {SCOPE_LABELS[s] ?? s}
                      </span>
                    ))}
                  </div>
                </td>
                <td>
                  {k.revokedAt ? (
                    <span className="badge red">باطل‌شده</span>
                  ) : k.isExpired ? (
                    <span className="badge orange">منقضی</span>
                  ) : k.isActive ? (
                    <span className="badge green">فعال</span>
                  ) : (
                    <span className="badge gray">غیرفعال</span>
                  )}
                </td>
                <td>{faDigits(k.useCount)}</td>
                <td>{faDateTime(k.lastUsedAt)}</td>
                <td>{faDateTime(k.createdAt)}</td>
                <td className="actions">
                  {!k.revokedAt && k.isActive && (
                    <button className="btn small warn" onClick={() => act(() => api.revokeKey(k.id))}>
                      ابطال
                    </button>
                  )}
                  {k.revokedAt && (
                    <button className="btn small" onClick={() => act(() => api.restoreKey(k.id))}>
                      فعال‌سازی
                    </button>
                  )}
                  <button className="btn small danger" onClick={() => act(() => api.deleteKey(k.id))}>
                    حذف
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {showCreate && (
        <CreateDialog
          onClose={() => setShowCreate(false)}
          onCreated={(name, key) => {
            setShowCreate(false);
            setRevealed({ name, key });
            void load();
          }}
        />
      )}

      {revealed && (
        <RevealedDialog name={revealed.name} apiKey={revealed.key} onClose={() => setRevealed(null)} />
      )}
    </div>
  );
}

function CreateDialog({
  onClose,
  onCreated,
}: {
  onClose: () => void;
  onCreated: (name: string, key: string) => void;
}) {
  const [name, setName] = useState('');
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [noExpiry, setNoExpiry] = useState(true);
  const [expiry, setExpiry] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  function toggle(scope: string) {
    setSelected((prev) => {
      const next = new Set(prev);
      if (next.has(scope)) next.delete(scope);
      else next.add(scope);
      return next;
    });
  }

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setError('');
    if (name.trim().length < 2) {
      setError('نام کلید حداقل ۲ حرف است');
      return;
    }
    if (selected.size === 0) {
      setError('حداقل یک دسترسی انتخاب کنید');
      return;
    }
    setBusy(true);
    try {
      const r = await api.createKey({
        name: name.trim(),
        scopes: [...selected],
        expiresAt: !noExpiry && expiry ? new Date(expiry).toISOString() : null,
      });
      onCreated(r.name, r.key);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'ساخت کلید ناموفق بود');
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="modal-back" onClick={onClose}>
      <form className="modal" onClick={(e) => e.stopPropagation()} onSubmit={submit}>
        <h3>ساخت کلید API جدید</h3>
        <label className="field">
          <span>نام (مثلاً «حسابداری سپیدار»)</span>
          <input value={name} onChange={(e) => setName(e.target.value)} maxLength={80} />
        </label>

        <div className="field">
          <span>دسترسی‌ها</span>
          <div className="scope-grid">
            {Object.entries(SCOPE_LABELS).map(([scope, label]) => (
              <label key={scope} className={selected.has(scope) ? 'scope on' : 'scope'}>
                <input
                  type="checkbox"
                  checked={selected.has(scope)}
                  onChange={() => toggle(scope)}
                />
                {label}
              </label>
            ))}
          </div>
        </div>

        <div className="field">
          <span>انقضا</span>
          <label className="radio">
            <input type="checkbox" checked={noExpiry} onChange={(e) => setNoExpiry(e.target.checked)} />
            بدون انقضا
          </label>
          {!noExpiry && (
            <input dir="ltr" type="datetime-local" value={expiry} onChange={(e) => setExpiry(e.target.value)} />
          )}
        </div>

        {error && <div className="error">{error}</div>}
        <div className="modal-actions">
          <button type="button" className="btn ghost" onClick={onClose}>
            انصراف
          </button>
          <button className="btn primary" disabled={busy}>
            {busy ? 'در حال ساخت…' : 'ساخت کلید'}
          </button>
        </div>
      </form>
    </div>
  );
}

function RevealedDialog({ name, apiKey, onClose }: { name: string; apiKey: string; onClose: () => void }) {
  const [copied, setCopied] = useState(false);

  async function copy() {
    await navigator.clipboard.writeText(apiKey);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  }

  return (
    <div className="modal-back">
      <div className="modal">
        <h3>کلید ساخته شد 🎉</h3>
        <p className="muted">
          کلید API برای «{name}» — <strong className="warn-text">فقط همین یک بار نمایش داده می‌شود</strong>. همین حالا
          کپی و در جای امن ذخیره کنید.
        </p>
        <div className="key-reveal" dir="ltr">
          {apiKey}
        </div>
        <div className="modal-actions">
          <button className="btn primary" onClick={copy}>
            {copied ? 'کپی شد ✓' : 'کپی کلید'}
          </button>
          <button className="btn ghost" onClick={onClose}>
            بستن
          </button>
        </div>
      </div>
    </div>
  );
}
