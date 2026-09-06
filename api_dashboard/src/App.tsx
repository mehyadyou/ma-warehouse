import { useEffect, useState } from 'react';
import { api, getToken } from './lib/api';
import LoginPage from './pages/LoginPage';
import KeysPage from './pages/KeysPage';
import DocsPage from './pages/DocsPage';

type Tab = 'keys' | 'docs';

export default function App() {
  const [loggedIn, setLoggedIn] = useState<boolean>(!!getToken());
  const [userName, setUserName] = useState('');
  const [tab, setTab] = useState<Tab>('keys');

  // سنجش نشست ذخیره‌شده
  useEffect(() => {
    if (!getToken()) return;
    api
      .me()
      .then((r) => setUserName(r.profile.name))
      .catch(() => setLoggedIn(false));
  }, []);

  if (!loggedIn) {
    return (
      <LoginPage
        onSuccess={(name) => {
          setUserName(name);
          setLoggedIn(true);
        }}
      />
    );
  }

  return (
    <div className="app">
      <header className="topbar">
        <div className="brand">
          <span className="logo">ما</span>
          <div>
            <h1>داشبورد API</h1>
            <p>مدیریت کلیدهای دسترسی سیستم‌های بیرونی</p>
          </div>
        </div>
        <nav>
          <button className={tab === 'keys' ? 'tab active' : 'tab'} onClick={() => setTab('keys')}>
            کلیدها
          </button>
          <button className={tab === 'docs' ? 'tab active' : 'tab'} onClick={() => setTab('docs')}>
            مستندات
          </button>
        </nav>
        <div className="user">
          <span>{userName || 'مدیر'}</span>
          <button
            className="btn ghost"
            onClick={() => {
              localStorage.removeItem('api_dash_token');
              setLoggedIn(false);
            }}
          >
            خروج
          </button>
        </div>
      </header>
      <main>{tab === 'keys' ? <KeysPage /> : <DocsPage />}</main>
    </div>
  );
}
