import https from 'https';
import { AppError } from '../../common/exceptions/AppError';

const TGJU_URL = 'https://api.tgju.org/v1/widget/market-summary?c=price_dollar_rl';
const ALANCHAND_URL = 'https://api.alanchand.com/?type=currencies';
const CACHE_TTL_MS = 5 * 60 * 1000;
const REQUEST_TIMEOUT_MS = 10_000;

type RateSource = 'alanchand' | 'tgju' | 'last-known';

// ── کش درون‌فرایندی: نرخ آخرین موفق + منبع + زمان دریافت ──
let cached: { price: number; source: RateSource; fetchedAt: Date } | null = null;

// ریست کش — فقط برای تست
export const __resetCache = () => { cached = null; };

// استخراج نرخ از پاسخ tgju با چند مسیر دفاعی (فرمت دقیق ممکن است تغییر کند)
export const extractPrice = (json: any): number | null => {
    const candidates: any[] = [];
    if (json?.market) candidates.push(json.market.price_dollar_rl);
    if (json?.data) candidates.push(json.data.price_dollar_rl);
    candidates.push(json?.price_dollar_rl);

    for (const c of candidates) {
        if (!c) continue;
        for (const key of ['p', 'price', 'value', 'last']) {
            const raw = c[key];
            if (raw === undefined || raw === null || raw === '') continue;
            const num = parseFloat(String(raw).replace(/[^\d.]/g, ''));
            if (!isNaN(num) && num > 0) return num;
        }
    }
    return null;
};

// استخراج نرخ دلار (تومان) از پاسخ alanchand — usd.sell مستقیماً تومان است
export const extractAlanChandPrice = (json: any): number | null => {
    const raw = json?.usd?.sell;
    if (raw === undefined || raw === null || raw === '') return null;
    const num = parseFloat(String(raw).replace(/[^\d.]/g, ''));
    return !isNaN(num) && num > 0 ? num : null;
};

// فقط برای سرویس‌های نرخ (tgju/alanchand) — اگر گواهی معتبر دارند می‌توان حذفش کرد
const rateAgent = new https.Agent({ rejectUnauthorized: false });

const fetchJson = (url: string, headers: Record<string, string>): Promise<any> =>
    new Promise((resolve, reject) => {
        const req = https.get(
            url,
            {
                headers,
                // اعتبارسنجی گواهی فقط برای همین دو سرویس نرخ نادیده گرفته می‌شود —
                // دامنه‌ی NODE_TLS_REJECT_UNAUTHORIZED سراسری حذف شده تا MITM در بقیه‌ی اتصالات قابل تشخیص باشد
                agent: rateAgent,
            },
            (res) => {
                let body = '';
                res.on('data', (chunk) => (body += chunk));
                res.on('end', () => {
                    try {
                        resolve(JSON.parse(body));
                    } catch {
                        reject(new Error('پاسخ قابل خواندن نیست'));
                    }
                });
            },
        );
        req.setTimeout(REQUEST_TIMEOUT_MS, () => req.destroy(new Error('timeout')));
        req.on('error', reject);
    });

const fetchFromAlanChand = async (token: string): Promise<number> => {
    const json = await fetchJson(`${ALANCHAND_URL}&token=${encodeURIComponent(token)}`, {
        Accept: 'application/json',
        'User-Agent': 'ma-warehouse-backend',
    });
    const price = extractAlanChandPrice(json);
    if (price) return price;
    throw new Error('نرخ دلار در پاسخ alanchand یافت نشد');
};

const fetchFromTgju = async (): Promise<number> => {
    const json = await fetchJson(TGJU_URL, {
        Accept: 'application/json',
        'User-Agent': 'ma-warehouse-backend',
    });
    const price = extractPrice(json);
    if (price) return price;
    throw new Error('نرخ دلار در پاسخ tgju یافت نشد');
};

export const rateService = {
    //نرخ دلار آزاد (تومان): اول alanchand (اگر توکن تعریف شده باشد)، بعد tgju بدون کلید،
    //کش ۵ دقیقه، و در نهایت بازگشت به آخرین نرخ شناخته‌شده
    getDollarRate: async (): Promise<{ price: number; source: RateSource; updatedAt: string }> => {
        if (cached && Date.now() - cached.fetchedAt.getTime() < CACHE_TTL_MS) {
            return { price: cached.price, source: cached.source, updatedAt: cached.fetchedAt.toISOString() };
        }

        const token = process.env.ALANCHAND_TOKEN;
        if (token) {
            try {
                const price = await fetchFromAlanChand(token);
                cached = { price, source: 'alanchand', fetchedAt: new Date() };
                return { price, source: 'alanchand', updatedAt: cached.fetchedAt.toISOString() };
            } catch {
                // افتادن به tgju
            }
        }

        try {
            const price = await fetchFromTgju();
            cached = { price, source: 'tgju', fetchedAt: new Date() };
            return { price, source: 'tgju', updatedAt: cached.fetchedAt.toISOString() };
        } catch {
            if (cached) {
                return { price: cached.price, source: 'last-known', updatedAt: cached.fetchedAt.toISOString() };
            }
            throw new AppError('دریافت نرخ دلار ممکن نشد؛ لطفاً بعداً تلاش کنید', 502);
        }
    },
};