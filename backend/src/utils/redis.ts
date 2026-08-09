import Redis from 'ioredis';
import { env } from '../config/env';

let client: Redis | null = null;
let clientPromise: Promise<Redis | null> | null = null;

// کلاینت Redis تنبل با fallback امن — اگر Redis در دسترس نباشد null برمی‌گرداند
export function getRedis(): Promise<Redis | null> {
    if (client) return Promise.resolve(client);
    if (!clientPromise) {
        clientPromise = (async () => {
            const c = new Redis(env.REDIS_URL, {
                lazyConnect: true,
                maxRetriesPerRequest: 1,
                enableOfflineQueue: false,
                connectTimeout: 1500,
                retryStrategy: () => null,
            });
            try {
                await c.connect();
                client = c;
                return c;
            } catch {
                return null;
            }
        })();
    }
    return clientPromise;
}

export async function redisIsReady(): Promise<boolean> {
    const c = await getRedis();
    if (!c) return false;
    try {
        return (await c.ping()) === 'PONG';
    } catch {
        return false;
    }
}
