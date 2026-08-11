import { prisma } from '../src/utils/prisma';

(async () => {
    try {
        const rows = await prisma.$queryRawUnsafe('SELECT 1 as ok');
        console.log('DB-OK', JSON.stringify(rows));
    } catch (e: any) {
        console.error('DB-FAIL', e?.message ?? e);
        process.exitCode = 1;
    } finally {
        await prisma.$disconnect();
    }
})();
