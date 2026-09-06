import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5180,
    proxy: {
      // توسعه: درخواست‌های /api به بک‌اند محلی
      '/api': 'http://localhost:3000',
    },
  },
});
