import 'package:flutter/foundation.dart';

import 'invoice_file_store_io.dart' if (dart.library.html) 'invoice_file_store_web.dart' as impl;

/// پل ذخیره فایل‌های خروجی فاکتور؛ روی موبایل فایل‌سیستمی و روی وب دانلود مرورگری
class InvoiceFileStore {
  /// خواندن بایت‌های دارایی فاکتور (لوگو/امضا)
  /// موبایل: از فایل؛ وب: از حافظه (بعد از رفرش در دسترس نیست)
  static Future<Uint8List?> loadBytes(String path) => impl.loadBytes(path);

  /// ذخیره PDF و برگرداندن مسیر؛ روی وب فایل دانلود می‌شود
  static Future<String> savePdf(Uint8List bytes, String invoiceNumber) =>
      impl.savePdf(bytes, invoiceNumber);

  /// ذخیره PNG و برگرداندن مسیر؛ روی وب فایل دانلود می‌شود
  static Future<String> savePng(Uint8List bytes, String invoiceNumber) =>
      impl.savePng(bytes, invoiceNumber);

  /// ذخیره لوگوی فاکتور
  static Future<String> saveLogo(Uint8List bytes) => impl.saveLogo(bytes);

  /// ذخیره امضای فاکتور
  static Future<String> saveSignature(Uint8List bytes) =>
      impl.saveSignature(bytes);

  /// دانلود مستقیم بایت‌ها (روی موبایل عملیات ندارد؛ اشتراک/چاپ جایگزین است)
  static Future<void> downloadBytes(Uint8List bytes, String fileName) =>
      impl.downloadBytes(bytes, fileName);

  /// آیا روی وب اجرا می‌شود؟
  static bool get isWeb => kIsWeb;
}