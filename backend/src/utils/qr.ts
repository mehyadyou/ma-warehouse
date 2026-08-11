import crypto from 'crypto';
import { AppError } from '../common/exceptions/AppError';
import { env } from '../config/env';

const QR_SECRET = env.QR_SECRET;

const SEPARATOR = '|';
const PREFIX = 'MA';

export interface QrPayloadParts {
    productCode: string;
    modelCode: string;
    capacityPerBox: number;
    uuid: string;
}

const sanitize = (value: string): string => value.replace(/\|/g, '/').trim();

// امضای کامل (۱۲۸ بیت / ۳۲ هگز) — طول قبلی ۱۶ هگز (۶۴ بیت) برای بروت‌فورس ضعیف بود
const HMAC_LENGTH = 32;

const digest = (body: string): string =>
    crypto.createHmac('sha256', QR_SECRET).update(body).digest('hex');

const signBody = (body: string): string => digest(body).slice(0, HMAC_LENGTH);

// هر دو طول ۱۶ (قدیمی — QRهای چاپ‌شده) و ۳۲ (جدید) پذیرفته می‌شود — گذار بدون شکستن QRهای موجود
const verifyBody = (body: string, hmac: string): boolean => {
    const full = digest(body);
    return hmac.length === HMAC_LENGTH
        ? full.slice(0, HMAC_LENGTH) === hmac
        : full.slice(0, 16) === hmac;
};

export const signPayload = (parts: QrPayloadParts): { qrPayload: string; hmac: string } => {
    const body = [
        PREFIX,
        sanitize(parts.productCode),
        sanitize(parts.modelCode),
        String(parts.capacityPerBox),
        parts.uuid,
    ].join(SEPARATOR);

    const hmac = signBody(body);

    return { qrPayload: `${body}${SEPARATOR}${hmac}`, hmac };
};

export interface VerifiedPayload extends QrPayloadParts {
    hmac: string;
    raw: string;
}

export const verifyPayload = (raw: string): VerifiedPayload => {
    const segments = raw.split(SEPARATOR);
    if (segments.length !== 6 || segments[0] !== PREFIX) {
        throw new AppError('فرمت QR نامعتبر است', 400);
    }

    const [, productCode, modelCode, capacityRaw, uuid, hmac] = segments;
    const body = segments.slice(0, 5).join(SEPARATOR);

    if (!verifyBody(body, hmac!)) {
        throw new AppError('امضای QR نامعتبر است', 400);
    }

    return {
        productCode: productCode!,
        modelCode: modelCode!,
        capacityPerBox: parseInt(capacityRaw!, 10),
        uuid: uuid!,
        hmac: hmac!,
        raw,
    };
};

export const buildQrFor = (parts: QrPayloadParts): { qrPayload: string; hmac: string } =>
    signPayload(parts);

export interface SerialQrParts {
    serial: string;
    uuid: string;
}

// فرمت جدید (v2): محتوای QR همان سریال کارتن است
// MA|SN|<serial>|<uuid>|<hmac>
export const buildQrForSerial = (parts: SerialQrParts): { qrPayload: string; hmac: string } => {
    const body = [PREFIX, 'SN', sanitize(parts.serial), parts.uuid].join(SEPARATOR);
    const hmac = signBody(body);
    return { qrPayload: `${body}${SEPARATOR}${hmac}`, hmac };
};

export interface VerifiedSerialPayload {
    serial: string;
    uuid: string;
    hmac: string;
    raw: string;
}

export const verifySerialPayload = (raw: string): VerifiedSerialPayload => {
    const segments = raw.split(SEPARATOR);
    if (segments.length !== 5 || segments[0] !== PREFIX || segments[1] !== 'SN') {
        throw new AppError('فرمت QR نامعتبر است', 400);
    }

    const [, , serial, uuid, hmac] = segments;
    const body = segments.slice(0, 4).join(SEPARATOR);

    if (!verifyBody(body, hmac!)) {
        throw new AppError('امضای QR نامعتبر است', 400);
    }

    return { serial: serial!, uuid: uuid!, hmac: hmac!, raw };
};
