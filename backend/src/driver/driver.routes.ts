import { Router } from 'express';
import { authenticate, authorize } from '../middleware/auth';
import { profileController } from './profile/profile.controller';
import { ordersController } from './orders/orders.controller';
import { deliveryController } from './delivery/delivery.controller';
import { loadingPlanController } from './loadingplan/loadingplan.controller';

const router = Router();

router.use(authenticate);
// فقط نقش راننده — سایر نقش‌ها (مدیر/انباردار) نمی‌توانند تحویل ثبت کنند یا تاریخچه ببینند
router.use(authorize('DRIVER'));

// ── Profile ──
router.get('/me', profileController.me);

// ── Orders ──
router.get('/orders', ordersController.getReadyOrders);

// ── Delivery ──
router.post('/deliver/:orderId', deliveryController.deliverOrder);
router.get('/deliveries', deliveryController.getMyDeliveries);

// ── Loading Plan ──
router.get('/loading-plan', loadingPlanController.getLoadingPlan);

export default router;