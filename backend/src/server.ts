import http from 'http';
import { createApp } from './app';
import { initSocketServer } from './realtime/socket.server';
import { startOutboxDispatcher } from './realtime/outbox';

const app = createApp();
const PORT = process.env.PORT || 3000;

// تحویل مطمئن رویدادهای تراکنشی (نوتیفیکیشن + ریل‌تایم) از جدول Outbox
// فاصلهٔ ۱ ثانیه‌ای: «به محض ثبت سفارش» با حفظ الگوی تراکنشی (emit داخل تراکنش نمی‌شود)
startOutboxDispatcher(1000);

const httpServer = http.createServer(app);

initSocketServer(httpServer)
  .then(() => {
    httpServer.listen(PORT, () =>
      console.log(`Server running on port ${PORT} (HTTP + WebSocket)`),
    );
  })
  .catch((err) => {
    console.error('Realtime init failed, falling back to HTTP-only:', err);
    httpServer.listen(PORT, () =>
      console.log(`Server running on port ${PORT} (HTTP only)`),
    );
  });
