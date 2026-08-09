import Redis from 'ioredis';

const url = process.env.REDIS_URL ?? 'redis://localhost:6379';

export const redis = new Redis(url, {
    lazyConnect: true,
    maxRetriesPerRequest: 1,
    enableOfflineQueue: false,
});

let pingOk: boolean | null = null;

// بررسی سالم بودن Redis — با کش نتیجه، برای فراخوانی‌های مکرر
export const redisHealthy = async (): Promise<boolean> => {
    if (pingOk !== null) return pingOk;
    try {
        await redis.ping();
        pingOk = true;
    } catch {
        pingOk = false;
    }
    return pingOk;
};
