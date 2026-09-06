import 'package:flutter/material.dart';

import '../../shared/utils/numbers.dart';
import 'update_service.dart';

const _bg = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _border = Color(0xFF2A2D33);

/// پاپ‌آپ بروزرسانی — بالای همهٔ صفحات نمایش داده می‌شود.
/// isForce → دکمهٔ «بعداً» ندارد و dismiss هم غیرفعال است.
Future<void> showUpdatePopup(
  BuildContext context,
  AppUpdateInfo info,
) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: !info.isForce,
    barrierColor: Colors.black87,
    builder: (_) => _UpdateDialog(info: info),
  );
}

class _UpdateDialog extends StatefulWidget {
  const _UpdateDialog({required this.info});

  final AppUpdateInfo info;

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  final _service = UpdateService.instance;

  /// idle → downloading → installing → done | failed
  String _phase = 'idle';
  DownloadProgress? _progress;

  bool get _downloading => _phase == 'downloading';

  Future<void> _startDownload() async {
    setState(() => _phase = 'downloading');
    final path = await _service.downloadApk(
      widget.info,
      onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      },
    );
    if (!mounted) return;
    if (path == null) {
      setState(() => _phase = 'failed');
      return;
    }
    setState(() => _phase = 'installing');
    await _service.installApk(path);
    if (!mounted) return;
    // OpenFilex صفحهٔ نصب سیستم را باز کرده؛ اپ منتظر می‌ماند
    setState(() => _phase = 'done');
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    return PopScope(
      canPop: !info.isForce,
      child: Dialog(
        backgroundColor: _bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── هدر ───
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.system_update_rounded,
                          color: _green, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('بروزرسانی جدید',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(
                            'نسخهٔ ${faDigits(info.versionName)} آماده است',
                            style: TextStyle(
                                color: _green,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ─── توضیحات نسخه ───
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                  ),
                  child: Text(
                    info.changelog,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12.5,
                        height: 1.7),
                  ),
                ),
                const SizedBox(height: 6),
                if (info.apkSizeBytes > 0)
                  Text(
                    'حجم دانلود: ${faDigits((info.apkSizeBytes / (1024 * 1024)).toStringAsFixed(0))} مگابایت',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11),
                  ),
                const SizedBox(height: 16),

                // ─── ناحیهٔ پیشرفت / خطا ───
                if (_downloading) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progress?.fraction,
                      minHeight: 6,
                      backgroundColor: _surfaceAlt,
                      valueColor: const AlwaysStoppedAnimation(_green),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _progress != null && _progress!.total > 0
                        ? '${faDigits(((_progress!.received / (1024 * 1024)).toStringAsFixed(1)))} از ${faDigits(((_progress!.total / (1024 * 1024)).toStringAsFixed(1)))} مگابایت'
                        : 'در حال آماده‌سازی...',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                ] else if (_phase == 'failed') ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'دانلود ناموفق بود؛ اتصال اینترنت را بررسی کنید و دوباره تلاش کنید',
                      style: TextStyle(color: Colors.redAccent, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 14),
                ] else if (_phase == 'installing') ...[
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _green)),
                      SizedBox(width: 10),
                      Text('در حال باز کردن نصب...',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 14),
                ] else if (_phase == 'done') ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'صفحهٔ نصب باز شد؛ «نصب» را بزنید و بعد اپ را باز کنید',
                      style: TextStyle(color: _green, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // ─── دکمه‌ها ───
                Row(
                  children: [
                    if (!info.isForce && !_downloading)
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            _phase == 'done' ? 'بستن' : 'بعداً',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6)),
                          ),
                        ),
                      ),
                    Expanded(
                      flex: _phase == 'idle' || _phase == 'failed' ? 2 : 1,
                      child: ElevatedButton.icon(
                        onPressed: (_downloading || _phase == 'installing')
                            ? null
                            : _startDownload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: Icon(
                          _phase == 'failed'
                              ? Icons.refresh_rounded
                              : Icons.download_rounded,
                          size: 18,
                        ),
                        label: Text(
                          _phase == 'failed'
                              ? 'تلاش مجدد'
                              : _phase == 'idle'
                                  ? 'نصب بروزرسانی'
                                  : '...',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
                if (info.isForce) ...[
                  const SizedBox(height: 8),
                  Text(
                    'این نسخه اجباری است و تا نصب، اپ قابل استفاده نیست',
                    style: TextStyle(
                        color: Colors.orange.withValues(alpha: 0.8),
                        fontSize: 10.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
