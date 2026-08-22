import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

/// رندر قالب فاکتور (RepaintBoundary) به PNG با کیفیت چاپ
class InvoicePngExporter {
  /// نسبت مقیاس بر اساس ابعاد، طوری که بلندترین ضلع ≈ ۳۵۰۰ پیکسل باشد
  /// (تقریباً A4 با ۳۰۰DPI و بیشتر برای فاکتورهای بلندتر)
  static double _ratioFor(ui.Size size) {
    final maxDim = max(size.width, size.height);
    final ratio = 3500 / maxDim;
    return ratio.clamp(2.0, 6.0);
  }

  static Future<Uint8List> capture(RenderRepaintBoundary boundary) async {
    final ratio = _ratioFor(boundary.size);
    final image = await boundary.toImage(pixelRatio: ratio);
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('رندر تصویر فاکتور ناموفق بود');
      }
      return byteData.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }
}