import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// پیاده‌سازی وب: دانلود با مرورگر + نگهداری دارایی‌ها در حافظه

/// دارایی‌های فاکتور (لوگو/امضا) تا زمان رفرش صفحه
final Map<String, Uint8List> _memoryAssets = {};

/// نام فایل امن از روی شماره فاکتور
String _safeName(String invoiceNumber) {
  final cleaned = invoiceNumber
      .replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '-')
      .replaceAll(RegExp(r'-+'), '-');
  return cleaned.isEmpty ? 'factor' : cleaned;
}

/// دانلود مستقیم بایت‌ها با لینک مرورگر
Future<void> downloadBytes(Uint8List bytes, String fileName) async {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/octet-stream'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;
  anchor.click();
  web.URL.revokeObjectURL(url);
}

Future<String> savePdf(Uint8List bytes, String invoiceNumber) async {
  await downloadBytes(bytes, 'factor-${_safeName(invoiceNumber)}.pdf');
  return 'web://${_safeName(invoiceNumber)}.pdf';
}

Future<String> savePng(Uint8List bytes, String invoiceNumber) async {
  await downloadBytes(bytes, 'factor-${_safeName(invoiceNumber)}.png');
  return 'web://${_safeName(invoiceNumber)}.png';
}

/// ذخیره لوگوی فاکتور (در حافظه؛ تا رفرش صفحه)
Future<String> saveLogo(Uint8List bytes) => _saveAsset('logo.png', bytes);

/// ذخیره امضای فاکتور (در حافظه؛ تا رفرش صفحه)
Future<String> saveSignature(Uint8List bytes) =>
    _saveAsset('signature.png', bytes);

Future<String> _saveAsset(String key, Uint8List bytes) async {
  final path = 'web://$key';
  _memoryAssets[path] = bytes;
  return path;
}

Future<Uint8List?> loadBytes(String path) async => _memoryAssets[path];