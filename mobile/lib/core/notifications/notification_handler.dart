import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

void handleNotification(BuildContext context, String role, String type, String? orderId) {
  switch (role) {
    case 'MANAGER':
      // TODO: Navigate to manager's order detail
      break;
    case 'WAREHOUSE_KEEPER':
      if (type == 'new_order') {
        context.push('/warehouse/orders');
      }
      break;
    case 'DRIVER':
      // TODO: Navigate to driver's delivery page
      break;
  }
}