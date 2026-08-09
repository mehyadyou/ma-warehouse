import { Router } from 'express';
import { notificationController } from './notification.controller';
import { authenticate } from '../middleware/auth';

const router = Router();
router.use(authenticate);

router.get('/',             notificationController.list);
router.get('/unread-count', notificationController.unreadCount);
router.patch('/mark-read',  notificationController.markRead);
router.delete('/',           notificationController.clearAll);
router.get('/settings',     notificationController.getSettings);
router.put('/settings',     notificationController.updateSettings);

export const notificationRoutes = router;
