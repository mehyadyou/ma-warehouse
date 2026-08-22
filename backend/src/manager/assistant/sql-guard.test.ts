import { describe, it, expect } from 'vitest';
import { validateReadOnlySql, maskSensitiveColumns } from './sql-guard';

describe('validateReadOnlySql', () => {
    it('SELECT ساده را می‌پذیرد', () => {
        const r = validateReadOnlySql('SELECT id, name FROM "Product" LIMIT 10');
        expect(r.ok).toBe(true);
    });

    it('SELECT با CTE و JOIN و GROUP BY را می‌پذیرد', () => {
        const sql = `
            WITH st AS (
                SELECT "warehouseId", COUNT(*) AS n
                FROM "Carton" WHERE status = 'IN_STOCK'
                GROUP BY "warehouseId"
            )
            SELECT w.name, st.n FROM st JOIN "Warehouse" w ON w.id = st."warehouseId"
        `;
        expect(validateReadOnlySql(sql).ok).toBe(true);
    });

    it('INSERT را رد می‌کند', () => {
        const r = validateReadOnlySql(`INSERT INTO "Product" (name) VALUES ('x')`);
        expect(r.ok).toBe(false);
        if (!r.ok) expect(r.error).toContain('SELECT');
    });

    it('UPDATE را رد می‌کند', () => {
        expect(validateReadOnlySql(`UPDATE "Product" SET name = 'x'`).ok).toBe(false);
    });

    it('DELETE را رد می‌کند', () => {
        expect(validateReadOnlySql(`DELETE FROM "Product"`).ok).toBe(false);
    });

    it('DROP/CREATE/TRUNCATE را رد می‌کند', () => {
        expect(validateReadOnlySql('DROP TABLE "Product"').ok).toBe(false);
        expect(validateReadOnlySql('CREATE TABLE x (id int)').ok).toBe(false);
        expect(validateReadOnlySql('TRUNCATE "Product"').ok).toBe(false);
    });

    it('کوئری چندعبارتی را رد می‌کند', () => {
        const r = validateReadOnlySql('SELECT 1; SELECT 2');
        expect(r.ok).toBe(false);
        if (!r.ok) expect(r.error).toContain('یک عبارت');
    });

    it('SELECT INTO را رد می‌کند', () => {
        const r = validateReadOnlySql('SELECT id INTO new_table FROM "Product"');
        expect(r.ok).toBe(false);
    });

    it('SQL نامعتبر را رد می‌کند', () => {
        expect(validateReadOnlySql('SELECT FROM WHERE').ok).toBe(false);
        expect(validateReadOnlySql('DROP').ok).toBe(false);
        expect(validateReadOnlySql('').ok).toBe(false);
        expect(validateReadOnlySql(';').ok).toBe(false);
    });

    it('SQL بیش از حد طولانی را رد می‌کند', () => {
        expect(validateReadOnlySql('SELECT ' + '1, '.repeat(5000)).ok).toBe(false);
    });
});

describe('maskSensitiveColumns', () => {
    it('ستون‌های حساس را حذف و مقادیر بلند را کوتاه می‌کند', () => {
        const out = maskSensitiveColumns([
            {
                id: '1',
                hmac: 'secret-hmac',
                qrPayload: 'MA|SN|...',
                name: 'x'.repeat(600),
                ok: 'keep',
            },
        ]);
        expect(out[0]).not.toHaveProperty('hmac');
        expect(out[0]).not.toHaveProperty('qrPayload');
        expect(out[0].ok).toBe('keep');
        expect(String(out[0].name)).toHaveLength(501);
    });

    it('حساسیت به حروف بزرگ ندارد', () => {
        const out = maskSensitiveColumns([{ HMAC: 'x', QrPayload: 'y', name: 'z' }]);
        expect(out[0]).toEqual({ name: 'z' });
    });
});