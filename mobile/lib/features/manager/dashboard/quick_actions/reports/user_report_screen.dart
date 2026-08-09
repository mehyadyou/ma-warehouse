import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/manager_api_service.dart';
import '../../../providers/manager_api_provider.dart';
import '../../../models/user_report_model.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceLight = Color(0xFF22262C);
const _green = Color(0xFF4ADE80);
const _blue = Color(0xFF60A5FA);
const _amber = Color(0xFFFBBF24);
const _purple = Color(0xFFA78BFA);
const _textGrey = Color(0xFF94A3B8);

class UserReportScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const UserReportScreen({super.key, required this.userId, required this.userName});

  @override
  ConsumerState<UserReportScreen> createState() => _UserReportScreenState();
}

class _UserReportScreenState extends ConsumerState<UserReportScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);
  UserReportModel? _report;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final report = await _api.getUserReport(widget.userId);
      if (!mounted) return;
      setState(() {
        _report = report;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'خطا در دریافت گزارش';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text('گزارش کاربر', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: _textGrey)))
              : _buildBody(_report!),
    );
  }

  Widget _buildBody(UserReportModel report) {
    final user = report.user;
    final stats = report.stats;
    final lastActivity = report.lastActivity;
    final activities = report.recentActivities;

    final (roleLabel, roleColor) = _roleInfo(user.role ?? '');
    final warehouseName = user.warehouseName;
    final responsibility = switch (user.role ?? '') {
      'MANAGER' => 'مدیریت کل سیستم',
      'WAREHOUSE_KEEPER' => warehouseName != null ? 'مسئول انبار $warehouseName' : 'مسئول انبار',
      'DRIVER' => 'مسئول تحویل سفارش‌ها',
      _ => '—',
    };

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ─── پروفایل ───
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [roleColor.withValues(alpha: 0.12), _surface], begin: Alignment.topRight, end: Alignment.bottomLeft),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: roleColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: Text(
                  (user.name ?? '?').isEmpty ? '?' : (user.name ?? '?').characters.first,
                  style: TextStyle(color: roleColor, fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name ?? '—', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(user.phone ?? '', style: TextStyle(color: _textGrey.withValues(alpha: 0.9), fontSize: 13)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _chip(roleLabel, roleColor),
                        _chip('تاریخ عضویت: ${_formatDate(user.createdAt)}', _textGrey),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ─── مسئولیت ───
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: _surfaceLight, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              const Icon(Icons.assignment_ind_rounded, color: _blue, size: 20),
              const SizedBox(width: 10),
              const Text('مسئولیت:', style: TextStyle(color: _textGrey, fontSize: 13)),
              const SizedBox(width: 6),
              Expanded(child: Text(responsibility, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ─── آمار ───
        _statsGrid(stats),
        const SizedBox(height: 16),

        // ─── آخرین فعالیت ───
        _sectionTitle('آخرین فعالیت'),
        const SizedBox(height: 10),
        if (lastActivity == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: _surfaceLight, borderRadius: BorderRadius.circular(14)),
            child: Text('فعالیتی ثبت نشده', textAlign: TextAlign.center, style: TextStyle(color: _textGrey.withValues(alpha: 0.8), fontSize: 13)),
          )
        else
          _activityCard(
            type: lastActivity.type ?? '',
            label: lastActivity.label ?? '',
            createdAt: lastActivity.createdAt,
            highlighted: true,
          ),
        const SizedBox(height: 16),

        // ─── فعالیت‌های اخیر ───
        _sectionTitle('فعالیت‌های اخیر'),
        const SizedBox(height: 10),
        if (activities.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: _surfaceLight, borderRadius: BorderRadius.circular(14)),
            child: Text('فعالیتی ثبت نشده', textAlign: TextAlign.center, style: TextStyle(color: _textGrey.withValues(alpha: 0.8), fontSize: 13)),
          )
        else
          ...activities.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _activityCard(
                  type: a.type ?? '',
                  label: a.label ?? '',
                  createdAt: a.createdAt,
                ),
              )),
      ],
    );
  }

  Widget _statsGrid(UserReportStatsModel stats) {
    final isKeeper = _report?.user.role == 'WAREHOUSE_KEEPER';
    final isDriver = _report?.user.role == 'DRIVER';
    final isManager = _report?.user.role == 'MANAGER';

    final items = <(String, String, Color)>[
      ('ورود کالا', '${stats.totalCheckins.toInt()}', _green),
      ('تعداد واحد', '${stats.totalUnits.toInt()}', _blue),
      ('مرجوعی', '${stats.totalReturns.toInt()}', _amber),
    ];
    if (isManager || isDriver) {
      items.add(('سفارش‌ها', '${stats.totalOrders.toInt()}', _purple));
      items.add(('تحویل‌ها', '${stats.totalDeliveries.toInt()}', _green));
    } else if (isKeeper) {
      items.add(('سفارش‌ها', '${stats.totalOrders.toInt()}', _purple));
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: items.map((item) => _statCard(item.$1, item.$2, item.$3)).toList(),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: _surfaceLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.25))),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700)),
              Text(label, style: TextStyle(color: _textGrey.withValues(alpha: 0.9), fontSize: 11.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activityCard({required String type, required String label, required dynamic createdAt, bool highlighted = false}) {
    final (icon, color) = switch (type) {
      'CHECKIN' => (Icons.inventory_2_rounded, _green),
      'RETURN' => (Icons.assignment_return_rounded, _amber),
      'ORDER' => (Icons.receipt_long_rounded, _purple),
      'DELIVERY' => (Icons.delivery_dining_rounded, _blue),
      _ => (Icons.event_note_rounded, _textGrey),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlighted ? color.withValues(alpha: 0.08) : _surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlighted ? color.withValues(alpha: 0.35) : Colors.transparent),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
                const SizedBox(height: 3),
                Text(_formatDate(createdAt), style: TextStyle(color: _textGrey.withValues(alpha: 0.7), fontSize: 11)),
              ],
            ),
          ),
          if (highlighted)
            _chip('آخرین', _green)
          else
            Icon(Icons.chevron_left_rounded, size: 18, color: Colors.white.withValues(alpha: 0.2)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700));
  }

  (String, Color) _roleInfo(String role) {
    return switch (role) {
      'MANAGER' => ('مدیر سیستم', _purple),
      'WAREHOUSE_KEEPER' => ('انباردار', _green),
      'DRIVER' => ('راننده', _blue),
      _ => (role, _textGrey),
    };
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.35))),
      child: Text(text, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w600)),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return '—';
    final date = DateTime.parse(value.toString()).toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}/${two(date.month)}/${two(date.day)} - ${two(date.hour)}:${two(date.minute)}';
  }
}
