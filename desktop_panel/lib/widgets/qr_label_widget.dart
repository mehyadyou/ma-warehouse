import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/label_data.dart';
import 'app_widgets.dart';

/// ابعاد پیش‌نمایش لیبل روی صفحه — متناسب با لیبل فیزیکی ۱۰×۸ سانتی‌متر (نسبت ۵:۴)
const double kLabelPreviewWidth = 260;
const double kLabelPreviewHeight = 208;

class QRLabelWidget extends StatelessWidget {
  const QRLabelWidget({
    super.key,
    required this.data,
    this.width = kLabelPreviewWidth,
    this.height = kLabelPreviewHeight,
    this.marginMm,
    this.labelWidthMm = 100,
    this.labelHeightMm = 80,
    this.scalePercent = 100,
    this.offsetXmm = 0,
    this.offsetYmm = 0,
  });

  final LabelData data;

  /// ابعاد پیش‌نمایش روی صفحه (پیکسل منطقی) — پیش‌فرض متناسب با ۱۰×۸ سانتی‌متر
  final double width;
  final double height;

  /// حاشیه‌ی داخلی (میلی‌متر) برای پیش‌نمایش واقعی از تنظیمات چاپ
  final double? marginMm;

  /// ابعاد فیزیکی لیبل (برای تبدیل میلی‌متر به پیکسل پیش‌نمایش)
  final double labelWidthMm;
  final double labelHeightMm;

  /// درصد مقیاس محتوا (۱۰۰ = اندازه‌ی اصلی) — دقیقاً مثل خروجی چاپ
  final double scalePercent;

  /// جابه‌جایی محتوا (میلی‌متر) — مثبتِ Y یعنی بالا، هماهنگ با خروجی PDF
  final double offsetXmm;
  final double offsetYmm;

  @override
  Widget build(BuildContext context) {
    final pad = marginMm == null
        ? 10.0
        : (marginMm! * kLabelPreviewWidth / 100).clamp(2, 40).toDouble();
    final s = scalePercent / 100;
    final pxPerMmX = width / labelWidthMm;
    final pxPerMmY = height / labelHeightMm;
    // در PDF محور y رو به بالاست؛ در پیش‌نمایش فلاپر رو به پایین — برای هماهنگی معکوس می‌کنیم
    final ox = offsetXmm * pxPerMmX;
    final oy = -offsetYmm * pxPerMmY;
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: ClipRect(
        child: Transform.translate(
          offset: Offset(ox, oy),
          child: Transform.scale(
            scale: s,
            alignment: Alignment.center,
            child: Column(
        children: [
          // سربرگ: PGG + زیرنویس ریز (FittedBox تا در هر فونتی جا شود)
          const SizedBox(
            height: 34,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PGG',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'Pro Global Groups',
                    style: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontSize: 6,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            color: Colors.black,
            height: 1,
            thickness: 1.5,
          ),
          const SizedBox(height: 6),
          // بدنه: QR سمت چپ، اطلاعات سمت راست (چیدمان افقی ۱۰×۱۰)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // اطلاعات
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _InfoRow(label: 'محصول', value: data.productName),
                      _InfoRow(label: 'مدل', value: data.modelDisplay),
                      _InfoRow(label: 'تعداد', value: data.qtyText),
                      _InfoRow(label: 'سریال', value: data.serial),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // QR
                Expanded(
                  flex: 2,
                  child: Center(
                    child: QrImageView(
                      data: data.qrPayload,
                      version: QrVersions.auto,
                      size: (height * 0.38).clamp(40, 130).toDouble(),
                      backgroundColor: Colors.white,
                      // «color» الزامی است؛ بدون آن qr_flutter هنگام paint خطای Null check می‌دهد
                      // و کل لیبل (شامل متن) رندر نمی‌شود
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const DashedDivider(),
          const SizedBox(height: 2),
          SizedBox(
            height: 22,
            child: Center(
              child: Text(
                '*${data.barcode}*',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontFamily: 'Courier New',
                ),
              ),
            ),
          ),
          SizedBox(
            height: 14,
            child: Center(
              child: Text(
                data.tracking,
                style: const TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontSize: 7,
                  letterSpacing: 1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
              ),
            ),
          ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Text(
              '▸ $label',
              style: const TextStyle(color: Colors.black, fontSize: 9),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),              ),
            ),
          ],
        ),
    );
  }
}
