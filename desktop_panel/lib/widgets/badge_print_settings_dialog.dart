import 'package:flutter/material.dart';

import '../core/badge_print_settings.dart';
import '../core/label_data.dart';
import '../core/palette.dart';
import 'app_widgets.dart';
import 'badge_sheet_widget.dart';

/// نمونه برای پیش‌نمایشِ واقعی بیجک — همان ساختار محتوای چاپ‌شده
final BadgeData _sampleBadge = BadgeData(
  sequence: 1,
  total: 2,
  count: 2,
  modelName: 'مدل آ',
  packageType: 'کیسه',
  unitsPerBox: 10,
  senderName: 'انبار مرکزی',
  senderPhone: '02111111111',
  senderNationalId: '0012345678',
  receiverName: 'گیرنده نمونه',
  receiverCity: 'تهران',
  receiverPostalCode: '1234567890',
  receiverAddress: 'خیابان اصلی، پلاک ۱۲',
  receiverPhone: '09120000000',
  shippingMethod: 'تیپاکس',
  carrier: 'تیپاکس',
  orderRef: 'MA-ABCD1234',
  createdAt: '۱۴۰۴/۰۵/۰۱',
);

/// ابعاد برگه‌ها (میلی‌متر)
const double _badgePageWidthMm = 210; // A5 افقی (حالت دوتایی)
const double _badgePageHeightMm = 148;
const double _badgeSingleWidthMm = 105; // A6 عمودی (حالت تکی)

Future<void> showBadgePrintSettingsDialog(BuildContext context) async {
  // قبل از باز شدن مطمئن می‌شویم آخرین تنظیمات بارگذاری شده
  await BadgePrintSettingsHolder.instance.load();
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const BadgePrintSettingsDialog(),
  );
}

class BadgePrintSettingsDialog extends StatefulWidget {
  const BadgePrintSettingsDialog({super.key});

  @override
  State<BadgePrintSettingsDialog> createState() =>
      _BadgePrintSettingsDialogState();
}

class _BadgePrintSettingsDialogState extends State<BadgePrintSettingsDialog> {
  late final ValueNotifier<BadgePrintSettings> _draft;

  @override
  void initState() {
    super.initState();
    _draft = ValueNotifier<BadgePrintSettings>(
      BadgePrintSettingsHolder.instance.current,
    );
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  /// اعمالِ تنظیماتِ حالتِ فعلی بدون بستن دیالوگ — تا کاربر بتواند
  /// حالت دیگر را هم تنظیم و ذخیره کند
  Future<void> _apply() async {
    final dual = _draft.value.dualMode;
    await BadgePrintSettingsHolder.instance.save(_draft.value);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          dual
              ? 'تنظیمات حالت دوتایی ذخیره شد — حالا حالت تکی را هم تنظیم کنید.'
              : 'تنظیمات حالت تکی ذخیره شد — حالا حالت دوتایی را هم تنظیم کنید.',
        ),
        backgroundColor: Palette.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveAndClose() async {
    await BadgePrintSettingsHolder.instance.save(_draft.value);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Palette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ValueListenableBuilder<BadgePrintSettings>(
            valueListenable: _draft,
            builder: (context, s, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // پیش‌نمایش زنده (سمت راست در RTL)
                        Expanded(
                          flex: 5,
                          child: _BadgePreviewPane(
                            dualMode: s.dualMode,
                            scalePercent: s.scalePercent,
                            offsetXmm: s.offsetXmm,
                            offsetYmm: s.offsetYmm,
                            onDrag: (dxMm, dyMm) =>
                                _draft.value = _applyOffset(dxMm, dyMm),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // کنترل‌ها (سمت چپ)
                        Expanded(
                          flex: 4,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _modeCard(s),
                                const SizedBox(height: 14),
                                _pageInfoCard(s),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Text(
                                      'مقیاس محتوا',
                                      style: TextStyle(
                                        color: Palette.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${s.scalePercent.round()}%',
                                      style: const TextStyle(
                                        color: Palette.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: s.scalePercent.clamp(80, 120),
                                  min: 80,
                                  max: 120,
                                  divisions: 40,
                                  activeColor: Palette.primary,
                                  inactiveColor: Palette.border,
                                  onChanged: (v) =>
                                      _draft.value = _applyScale(v),
                                ),
                                Row(
                                  children: [
                                    const Flexible(
                                      child: Text(
                                        'موقعیت محتوا: در پیش‌نمایش، بیجک را با موس بکشید',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Palette.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () =>
                                          _draft.value = _resetPosition(),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Palette.primary,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      child: const Text(
                                        'وسط‌چین (ریست)',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  s.dualMode
                                      ? 'تنظیمات فعلی فقط برای حالت دوتایی ذخیره می‌شود؛ برای تنظیم حالت تکی، تیک را بردارید.'
                                      : 'تنظیمات فعلی فقط برای حالت تکی ذخیره می‌شود؛ برای تنظیم حالت دوتایی، تیک را بزنید.',
                                  style: const TextStyle(
                                    color: Palette.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _footer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  BadgePrintSettings _applyOffset(double dxMm, double dyMm) {
    final s = _draft.value;
    double clamp(double v) => v.clamp(-20, 20).toDouble();
    return s.dualMode
        ? s.copyWith(
            dualOffsetXmm: clamp(s.dualOffsetXmm + dxMm),
            dualOffsetYmm: clamp(s.dualOffsetYmm + dyMm),
          )
        : s.copyWith(
            singleOffsetXmm: clamp(s.singleOffsetXmm + dxMm),
            singleOffsetYmm: clamp(s.singleOffsetYmm + dyMm),
          );
  }

  BadgePrintSettings _applyScale(double v) {
    final s = _draft.value;
    final value = v.roundToDouble();
    return s.dualMode
        ? s.copyWith(dualScalePercent: value)
        : s.copyWith(singleScalePercent: value);
  }

  BadgePrintSettings _resetPosition() {
    final s = _draft.value;
    return s.dualMode
        ? s.copyWith(dualOffsetXmm: 0, dualOffsetYmm: 0)
        : s.copyWith(singleOffsetXmm: 0, singleOffsetYmm: 0);
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.badge_outlined, color: Palette.primary, size: 26),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تنظیمات چاپ بیجک',
                style: TextStyle(
                  color: Palette.text,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'چیدمان بیجک روی کاغذ را تنظیم کنید؛ تنظیمات حالت دوتایی و تکی جداگانه ذخیره می‌شوند.',
                style: TextStyle(color: Palette.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'بستن',
          icon: const Icon(Icons.close, color: Palette.textMuted),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _modeCard(BadgePrintSettings s) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Palette.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Palette.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'حالت دوتایی (دو بیجک در هر برگه)',
                  style: TextStyle(
                    color: Palette.text,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.dualMode
                      ? 'روشن: دو بیجک کنار هم روی برگهٔ A5 — با برش وسط جدا می‌شوند.'
                      : 'خاموش: هر بیجک روی یک برگهٔ A6 جداگانه.',
                  style: const TextStyle(color: Palette.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: s.dualMode,
            onChanged: (v) =>
                _draft.value = _draft.value.copyWith(dualMode: v),
            activeThumbColor: Palette.primary,
            activeTrackColor: Palette.primary.withValues(alpha: 0.3),
            inactiveThumbColor: Palette.textMuted,
            inactiveTrackColor: Palette.border,
          ),
        ],
      ),
    );
  }

  Widget _pageInfoCard(BadgePrintSettings s) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Palette.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Palette.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.straighten_outlined,
              color: Palette.textMuted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.dualMode ? 'برگهٔ A5 افقی (۲۱۰×۱۴۸mm)' : 'برگهٔ A6 عمودی (۱۰۵×۱۴۸mm)',
                  style: const TextStyle(
                    color: Palette.text,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.dualMode
                      ? 'دو بیجک کنار هم؛ مقیاس و جابه‌جایی برای هر دو یکسان اعمال می‌شود.'
                      : 'هر بیجک روی یک برگهٔ جداگانه چاپ می‌شود.',
                  style: TextStyle(color: Palette.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppButton(
          label: 'اعمال تنظیمات',
          onPressed: _apply,
        ),
        const SizedBox(width: 10),
        AppButton(
          label: 'ذخیره و بستن',
          variant: AppButtonVariant.secondary,
          onPressed: _saveAndClose,
        ),
        const SizedBox(width: 10),
        AppButton(
          label: 'بستن بدون ذخیره',
          variant: AppButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// پنل پیش‌نمایش زنده — حالت دوتایی: برگهٔ A5 با دو بیجک | حالت تکی: برگهٔ A6
class _BadgePreviewPane extends StatelessWidget {
  const _BadgePreviewPane({
    required this.dualMode,
    required this.scalePercent,
    required this.offsetXmm,
    required this.offsetYmm,
    required this.onDrag,
  });

  final bool dualMode;
  final double scalePercent;
  final double offsetXmm;
  final double offsetYmm;

  /// با کشیدن موس روی پیش‌نمایش، تغییر آفست به میلی‌متر برمی‌گرداند (X مثبت = راست، Y مثبت = بالا)
  final void Function(double dxMm, double dyMm) onDrag;

  @override
  Widget build(BuildContext context) {
    final w = dualMode ? _badgePageWidthMm : _badgeSingleWidthMm;
    final h = _badgePageHeightMm;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF23262C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.border),
      ),
      // اندازه‌ی کاغذ بر اساس فضای واقعی پنل محاسبه می‌شود تا محتوا از پنل بیرون
      // نزند؛ اگر محتوا جا نشود، اسکرولِ پنل فقط به‌عنوان پشتیبان عمل می‌کند و
      // در حالت عادی (بدون سرریز) با موس قابل کشیدن است.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxH = constraints.maxHeight;
          // ارتفاع ثابت متن‌های اطراف کاغذ (هدر + متن اندازه + فواصل + راهنما)
          const chromeH = 88.0;
          final paperAreaH = (maxH - chromeH).clamp(60.0, double.infinity);
          final paperAreaW = constraints.maxWidth;
          final scale =
              ((paperAreaW / w).clamp(0.1, 10) < (paperAreaH / h).clamp(0.1, 10))
                  ? (paperAreaW / w)
                  : (paperAreaH / h);
          final pw = w * scale;
          final ph = h * scale;
          final mmPerPxX = w / pw;
          final mmPerPxY = h / ph;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.visibility_outlined,
                        color: Palette.textMuted, size: 18),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'پیش‌نمایش دقیق — دقیقاً همین در کاغذ چاپ می‌شود',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Palette.textMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${dualMode ? 'برگهٔ A5 (۲۱۰×۱۴۸)' : 'برگهٔ A6 (۱۰۵×۱۴۸)'}'
                  '  ·  موقعیت: X ${_signed(offsetXmm)}mm  Y ${_signed(offsetYmm)}mm'
                  '  ·  مقیاس: ${scalePercent.round()}%',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Palette.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 12),
                // ناحیه‌ی کاغذ: ارتفاع ثابت تا همیشه در پنل جا شود
                SizedBox(
                  height: paperAreaH,
                  width: double.infinity,
                  child: Center(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.move,
                      child: GestureDetector(
                        key: const ValueKey('badgePreviewDrag'),
                        onPanUpdate: (details) {
                          // کشیدن به راست = X+ ; کشیدن به پایین = Y- (چون Y مثبت یعنی بالا)
                          onDrag(
                            details.delta.dx * mmPerPxX,
                            -details.delta.dy * mmPerPxY,
                          );
                        },
                        child: _paper(pw, ph, mmPerPxX, mmPerPxY),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Palette.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'برای جابه‌جایی بیجک، آن را با موس بکشید؛ با «اعمال» برای همین حالت و با «ذخیره و بستن» برای همه ذخیره می‌شود',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Palette.textMuted, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// برگهٔ کاغذ با بیجک‌ها — دقیقاً شبیه خروجی چاپ
  Widget _paper(double pw, double ph, double mmPerPxX, double mmPerPxY) {
    return Container(
      width: pw,
      height: ph,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF8B9099)),
      ),
      child: dualMode
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _badge(mmPerPxX, mmPerPxY),
                ),
                // راهنمای برش وسط
                Container(width: 1.5, color: const Color(0xFFB0B0B0)),
                Expanded(
                  child: _badge(mmPerPxX, mmPerPxY),
                ),
              ],
            )
          : _badge(mmPerPxX, mmPerPxY),
    );
  }

  Widget _badge(double mmPerPxX, double mmPerPxY) {
    final s = scalePercent / 100;
    final ox = offsetXmm * mmPerPxX;
    final oy = -offsetYmm * mmPerPxY;
    return ClipRect(
      child: Transform.translate(
        offset: Offset(ox, oy),
        child: Transform.scale(
          scale: s,
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.contain,
            child: BadgeSheetWidget(data: _sampleBadge),
          ),
        ),
      ),
    );
  }

  String _signed(double v) {
    if (v == 0) return '۰';
    final s = v.toStringAsFixed(1);
    return v > 0 ? '+$s' : s;
  }
}
