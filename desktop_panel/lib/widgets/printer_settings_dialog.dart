import 'package:flutter/material.dart';

import '../core/label_data.dart';
import '../core/palette.dart';
import '../core/printer_settings.dart';
import 'app_widgets.dart';
import 'qr_label_widget.dart';

/// نمونه برای پیش‌نمایشِ واقعی لیبل — همان ساختار محتوای چاپ‌شده
final LabelData _sampleLabel = LabelData(
  productName: 'اسپیکر هوشمند',
  modelDisplay: 'مدل آ',
  qtyText: '۱۰ عدد / کارتن',
  serial: 'MA-1405-0001',
  barcode: 'MA-1405-0001',
  tracking: 'MA-1405-0001',
  date: '1404-05-01',
  qrPayload: 'MA|SN|MA-1405-0001|c1|hmac',
);

/// اندازه‌های رایج لیبل به میلی‌متر (عرض × ارتفاع)
const List<(String name, double w, double h)> _presets = [
  ('لیبل ۱۰×۸ سانتی (پیش‌فرض)', 100, 80),
  ('لیبل ۱۰×۱۰ سانتی', 100, 100),
  ('برچسب ۴×۲.۵ سانتی', 40, 25),
  ('برچسب ۲×۲ سانتی', 20, 20),
];

Future<void> showPrinterSettingsDialog(BuildContext context) async {
  // قبل از باز شدن مطمئن می‌شویم آخرین تنظیمات بارگذاری شده
  await PrinterSettingsHolder.instance.load();
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PrinterSettingsDialog(),
  );
}

class PrinterSettingsDialog extends StatefulWidget {
  const PrinterSettingsDialog({super.key});

  @override
  State<PrinterSettingsDialog> createState() => _PrinterSettingsDialogState();
}

class _PrinterSettingsDialogState extends State<PrinterSettingsDialog> {
  late final ValueNotifier<PrinterSettings> _draft;
  late TextEditingController _widthCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _marginCtrl;

  @override
  void initState() {
    super.initState();
    final current = PrinterSettingsHolder.instance.current;
    _draft = ValueNotifier<PrinterSettings>(current);
    _widthCtrl = TextEditingController(text: _num(current.labelWidthMm));
    _heightCtrl = TextEditingController(text: _num(current.labelHeightMm));
    _marginCtrl = TextEditingController(text: _num(current.labelMarginMm));
    _widthCtrl.addListener(_syncFromFields);
    _heightCtrl.addListener(_syncFromFields);
    _marginCtrl.addListener(_syncFromFields);
  }

  String _num(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toString();

  void _syncFromFields() {
    _draft.value = _draft.value.copyWith(
      labelWidthMm: double.tryParse(_widthCtrl.text) ??
          PrinterSettings.defaults.labelWidthMm,
      labelHeightMm: double.tryParse(_heightCtrl.text) ??
          PrinterSettings.defaults.labelHeightMm,
      labelMarginMm: double.tryParse(_marginCtrl.text) ??
          PrinterSettings.defaults.labelMarginMm,
    );
  }

  void _applyPreset(double w, double h) {
    _widthCtrl.text = _num(w);
    _heightCtrl.text = _num(h);
    // متن‌فیلدها را دوباره به متن فارسی/نقطه حساس به‌روز کن
    _draft.value = _draft.value.copyWith(labelWidthMm: w, labelHeightMm: h);
  }

  @override
  void dispose() {
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    _marginCtrl.dispose();
    _draft.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await PrinterSettingsHolder.instance.save(_draft.value);
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
          child: ValueListenableBuilder<PrinterSettings>(
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
                        child: _PreviewPane(
                          settings: s,
                          onDrag: (dxMm, dyMm) => _draft.value =
                              _draft.value.copyWith(
                            offsetXmm:
                                (_draft.value.offsetXmm + dxMm).clamp(-20, 20),
                            offsetYmm:
                                (_draft.value.offsetYmm + dyMm).clamp(-20, 20),
                          ),
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
                              _printerInfoCard(s),
                              const SizedBox(height: 14),
                              _sectionTitle('ابعاد لیبل فیزیکی'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _field('عرض (mm)', _widthCtrl, '۱۰۰'),
                                  const SizedBox(width: 10),
                                  _field('ارتفاع (mm)', _heightCtrl, '۸۰'),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _presetsRow(s),
                              const SizedBox(height: 16),
                              _sectionTitle('حاشیه و مقیاس'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _field('حاشیه (mm)', _marginCtrl, '۶'),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'حاشیه‌ی داخلی = فاصله‌ی محتوا از لبه‌ی برش کاغذ',
                                style: TextStyle(
                                  color: Palette.textMuted,
                                  fontSize: 11,
                                ),
                              ),
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
                                onChanged: (v) => _draft.value =
                                    _draft.value
                                        .copyWith(scalePercent: v.roundToDouble()),
                              ),
                              Row(
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'موقعیت محتوا: در پیش‌نمایش، محتوا را با موس بکشید',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Palette.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => _draft.value =
                                        _draft.value.copyWith(
                                      offsetXmm: 0,
                                      offsetYmm: 0,
                                    ),
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

  Widget _header(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.print_rounded, color: Palette.primary, size: 26),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تنظیمات چاپگر',
                style: TextStyle(
                  color: Palette.text,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'چیدمان دقیق را پیش‌نمایش ببینید، ذخیره کنید؛ همه‌ی چاپ‌ها با همین تنظیمات انجام می‌شود.',
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

  Widget _sectionTitle(String t) => Text(
        t,
        style: const TextStyle(
          color: Palette.text,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _printerInfoCard(PrinterSettings s) {
    final isDefault = s.printerName.isEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Palette.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Palette.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.print_outlined, color: Palette.textMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDefault ? 'چاپگر پیش‌فرض ویندوز' : s.printerName,
                  style: const TextStyle(
                    color: Palette.text,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'خروجی به چاپگر پیش‌فرض ویندوز ارسال می‌شود؛ در پنجره‌ی چاپ، نام چاپگر را ببینید/تأیید کنید.',
                  style: TextStyle(color: Palette.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetsRow(PrinterSettings s) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final p in _presets)
          ActionChip(
            backgroundColor: s.labelWidthMm == p.$2 && s.labelHeightMm == p.$3
                ? Palette.primary
                : Palette.surfaceHover,
            side: BorderSide(
              color: s.labelWidthMm == p.$2 && s.labelHeightMm == p.$3
                  ? Palette.primary
                  : Palette.border,
            ),
            label: Text(
              p.$1,
              style: TextStyle(
                color: s.labelWidthMm == p.$2 && s.labelHeightMm == p.$3
                    ? Colors.black
                    : Palette.textMuted,
                fontSize: 11,
              ),
            ),
            onPressed: () => _applyPreset(p.$2, p.$3),
          ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Palette.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: ctrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Palette.text, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Palette.surfaceAlt,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Palette.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Palette.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Palette.primary),
              ),
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
          label: 'ذخیره تنظیمات',
          onPressed: _save,
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

/// پنل پیش‌نمایش زنده — مقیاس‌گذاری بر اساس ابعاد میلی‌متری انتخاب‌شده
class _PreviewPane extends StatelessWidget {
  const _PreviewPane({required this.settings, required this.onDrag});

  final PrinterSettings settings;

  /// با کشیدن موس روی پیش‌نمایش، تغییر آفست به میلی‌متر برمی‌گرداند (X مثبت = راست، Y مثبت = بالا)
  final void Function(double dxMm, double dyMm) onDrag;

  @override
  Widget build(BuildContext context) {
    final w = settings.labelWidthMm;
    final h = settings.labelHeightMm;
    // جعبه‌ی در دسترس برای پیش‌نمایش
    const boxW = 380.0;
    const boxH = 300.0;
    final scale = ((boxW / w).clamp(0.2, 10) < (boxH / h).clamp(0.2, 10))
        ? (boxW / w)
        : (boxH / h);
    final pw = w * scale;
    final ph = h * scale;
    final mmPerPxX = w / pw;
    final mmPerPxY = h / ph;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF23262C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.border),
      ),
      child: SingleChildScrollView(
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
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Palette.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // نوار اندازه‌ی عرض + آفست فعلی
          Text(
            'عرض: ${_mm(w)} | ارتفاع: ${_mm(h)}  (${_cm(w)} × ${_cm(h)})  ·  موقعیت: X ${_signed(settings.offsetXmm)}mm  Y ${_signed(settings.offsetYmm)}mm',
            style: const TextStyle(color: Palette.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 12),
          // پیش‌نمایش با قابلیت کشیدن محتوا با موس
          MouseRegion(
            cursor: SystemMouseCursors.move,
            child: GestureDetector(
              onPanUpdate: (details) {
                // کشیدن به راست = X+ ; کشیدن به پایین = Y- (چون Y مثبت یعنی بالا)
                onDrag(
                  details.delta.dx * mmPerPxX,
                  -details.delta.dy * mmPerPxY,
                );
              },
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1114),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Palette.border),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: QRLabelWidget(
                    data: _sampleLabel,
                    width: pw,
                    height: ph,
                    marginMm: settings.labelMarginMm,
                    labelWidthMm: w,
                    labelHeightMm: h,
                    scalePercent: settings.scalePercent,
                    offsetXmm: settings.offsetXmm,
                    offsetYmm: settings.offsetYmm,
                  ),
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
                  'برای جابه‌جایی محتوا، آن را با موس بکشید؛ با ذخیره، همه‌ی چاپ‌ها با همین تنظیمات انجام می‌شود',
                  style: TextStyle(color: Palette.textMuted, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  String _signed(double v) {
    if (v == 0) return '۰';
    final s = v.toStringAsFixed(1);
    return v > 0 ? '+$s' : s;
  }

  String _mm(double v) =>
      v == v.roundToDouble() ? '${v.round()}mm' : '${v.toStringAsFixed(1)}mm';
  String _cm(double v) => v == v.roundToDouble()
      ? '${v.round() / 10} سانت'
      : '${(v / 10).toStringAsFixed(1)} سانت';
}