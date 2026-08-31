import { Router } from 'express';
import { badgeController } from './badge.controller';
import { authenticate } from '../middleware/auth';

const router = Router();
router.use(authenticate);

router.get('/',               badgeController.list);
router.get('/orders/:orderId', badgeController.listByOrder);
router.post('/printed',        badgeController.markPrinted);

export const badgeRoutes = router;
