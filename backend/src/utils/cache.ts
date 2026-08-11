import { getRedis } from './redis';

// کش سبک با TTL — اگر Redis در دسترس نبود، مستقیم fn اجرا می‌شود (fail-open)
export async function cached<T>(key: string, ttlSec: number, fn: () => Promise<T>): Promise<T> {
    try {
        const redis = await getRedis();
        if (redis) {
            const hit = await redis.get(key);
            if (hit) return JSON.parse(hit) as T;
            const data = await fn();
            await redis.set(key, JSON.stringify(data), 'EX', ttlSec);
            return data;
        }
    } catch {
        // Redis ناموفق → بدون کش
    }
    return fn();
}
