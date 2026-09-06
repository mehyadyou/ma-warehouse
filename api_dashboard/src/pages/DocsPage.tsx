import { useEffect, useState } from 'react';
import { faDigits } from '../lib/persian';

interface Endpoint {
  path: string;
  scope: string;
  summary: string;
  params: string[];
}

const ENDPOINTS: Endpoint[] = [
  { path: '/api/v1/products', scope: 'products', summary: 'لیست محصولات با مدل‌ها و قیمت‌ها', params: ['q', 'page', 'pageSize'] },
  { path: '/api/v1/inventory', scope: 'inventory', summary: 'موجودی فعلی به تفکیک محصول/مدل/انبار', params: ['warehouseId', 'page', 'pageSize'] },
  { path: '/api/v1/orders', scope: 'orders', summary: 'سفارش‌ها با اقلام و وضعیت', params: ['status', 'from', 'to', 'page', 'pageSize'] },
  { path: '/api/v1/transactions', scope: 'transactions', summary: 'تراکنش‌های ورود/خروج/مرجوعی', params: ['type', 'warehouseId', 'from', 'to', 'page', 'pageSize'] },
  { path: '/api/v1/cartons', scope: 'cartons', summary: 'کارتن‌ها با سریال و وضعیت', params: ['status', 'warehouseId', 'serial', 'page', 'pageSize'] },
  { path: '/api/v1/warehouses', scope: 'warehouses', summary: 'لیست انبارها', params: [] },
  { path: '/api/v1/carriers', scope: 'carriers', summary: 'لیست باربری‌ها', params: [] },
  { path: '/api/v1/deliveries', scope: 'deliveries', summary: 'تحویل‌ها با اطلاعات راننده و سفارش', params: ['status', 'driverId', 'page', 'pageSize'] },
  { path: '/api/v1/users', scope: 'users', summary: 'کاربران فعال سیستم', params: [] },
];

export default function DocsPage() {
  const [origin, setOrigin] = useState('');

  useEffect(() => {
    // آدرس سرور — در توسعه خالی است (همان origin)؛ در استقرار آدرس واقعی را نشان بده
    setOrigin(window.location.origin.includes('5180') ? 'http://localhost:3000' : window.location.origin);
  }, []);

  return (
    <div className="page">
      <div className="page-head">
        <div>
          <h2>مستندات API عمومی (v1)</h2>
          <p className="muted">API فقط‌خواندنی — احراز با کلید در هدر Authorization: Bearer</p>
        </div>
      </div>

      <section className="doc-section">
        <h3>شروع سریع</h3>
        <p>۱. در تب «کلیدها» یک کلید بسازید و دسترسی‌های لازم را انتخاب کنید.</p>
        <p>۲. کلید را در هدر هر درخواست بفرستید:</p>
        <pre dir="ltr">{`curl "${origin}/api/v1/products?pageSize=10" \\
  -H "Authorization: Bearer ma_live_xxxxxxxxxxxxxxxx..."`}</pre>
        <p>۳. پاسخ همیشه این ساختار را دارد:</p>
        <pre dir="ltr">{`{
  "data": [ ... ],
  "meta": { "total": 95, "page": 1, "pageSize": 25, "totalPages": 4 }
}`}</pre>
        <p className="muted">
          توضیح کامل ماشین‌خوان: <code dir="ltr">{origin}/api/v1/openapi.json</code>
        </p>
      </section>

      <section className="doc-section">
        <h3>اندپوینت‌ها ({faDigits(ENDPOINTS.length)} مسیر)</h3>
        <table className="table">
          <thead>
            <tr>
              <th>مسیر</th>
              <th>اسکوپ لازم</th>
              <th>توضیح</th>
              <th>پارامترها</th>
            </tr>
          </thead>
          <tbody>
            {ENDPOINTS.map((e) => (
              <tr key={e.path}>
                <td dir="ltr" className="mono strong">
                  GET {e.path}
                </td>
                <td>
                  <span className="chip">{e.scope}</span>
                </td>
                <td>{e.summary}</td>
                <td dir="ltr" className="mono muted">
                  {e.params.length ? e.params.join(' · ') : '—'}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </section>

      <section className="doc-section">
        <h3>خطاها</h3>
        <table className="table">
          <thead>
            <tr>
              <th>کد</th>
              <th>معنا</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td className="mono">401</td>
              <td>کلید ارسال نشده / نامعتبر / باطل‌شده / منقضی</td>
            </tr>
            <tr>
              <td className="mono">403</td>
              <td>کلید معتبر است ولی اسکوپِ این مسیر را ندارد</td>
            </tr>
            <tr>
              <td className="mono">429</td>
              <td>بیش از ۱۲۰ درخواست در دقیقه — کمی صبر کنید</td>
            </tr>
          </tbody>
        </table>
      </section>
    </div>
  );
}
