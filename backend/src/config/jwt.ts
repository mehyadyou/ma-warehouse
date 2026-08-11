import jwt, { SignOptions } from 'jsonwebtoken';
import { env } from './env';

const JWT_SECRET: string = env.JWT_SECRET;
// مدت اعتبار توکن اکسس — منبع حقیقت: ACCESS_TOKEN_TTL (مثل "15m" یا "30d")
const JWT_EXPIRES_IN = process.env.ACCESS_TOKEN_TTL || '15m';

export interface JwtPayload {
    id: string;
    role: string;
    warehouseId?: string;
    ver?: number;
}

export const signToken = (payload: JwtPayload, tokenVersion?: number): string => {
    const options: SignOptions = {
        expiresIn: JWT_EXPIRES_IN as any,
    };
    return jwt.sign(
        { ...payload, ver: tokenVersion ?? payload.ver ?? 0 },
        JWT_SECRET,
        options,
    );
};

export const verifyToken = (token: string): JwtPayload => {
    return jwt.verify(token, JWT_SECRET) as JwtPayload;
};