import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/manager/dashboard/activity/activity_model.dart';
import 'package:ma_app/features/manager/dashboard/activity/activity_tile.dart';

void main() {
  testWidgets('تایل فعالیت، تاریخ و ساعت دقیق را نشان میدهد', (tester) async {
    final item = ActivityItem(
      id: 'x',
      title: 'ثبت محصول',
      subtitle: 'سینک ظرفشویی • مدیر',
      status: 'ثبت',
      statusColor: Colors.green,
      icon: Icons.add,
      iconBg: Colors.green,
      createdAt: '2026-08-08T06:00:00.000Z',
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ActivityTile(item: item))),
    );

    expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    expect(find.textContaining('۱۴۰۵/۰۵/۱۶'), findsOneWidget);
    expect(find.textContaining(':'), findsWidgets);
  });

  testWidgets('تایل بدون createdAt، خط زمان نشان نمیدهد', (tester) async {
    final item = ActivityItem(
      id: 'x',
      title: 'ثبت محصول',
      subtitle: 'سینک ظرفشویی • مدیر',
      status: 'ثبت',
      statusColor: Colors.green,
      icon: Icons.add,
      iconBg: Colors.green,
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ActivityTile(item: item))),
    );

    expect(find.byIcon(Icons.schedule_rounded), findsNothing);
  });
}
