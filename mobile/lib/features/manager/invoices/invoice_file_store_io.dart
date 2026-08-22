import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// پیاده‌سازی موبایل/دسکتاپ: ذخیره در پوشه اسناد برنامه
Future<Directory> _invoicesDir() async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}${Platform.pathSeparator}invoices');
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}

/// نام فایل امن از روی شماره فاکتور
String _safeName(String invoiceNumber) {
  final cleaned = invoiceNumber
      .replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '-')
      .replaceAll(RegExp(r'-+'), '-');
  return cleaned.isEmpty ? 'factor' : cleaned;
}

Future<String> savePdf(Uint8List bytes, String invoiceNumber) async {
  final dir = await _invoicesDir();
  final file =
      File('${dir.path}${Platform.pathSeparator}${_safeName(invoiceNumber)}.pdf');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

Future<String> savePng(Uint8List bytes, String invoiceNumber) async {
  final dir = await _invoicesDir();
  final file =
      File('${dir.path}${Platform.pathSeparator}${_safeName(invoiceNumber)}.png');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

/// ذخیره لوگوی فاکتور (در پوشه دارایی‌های فاکتور)
Future<String> saveLogo(Uint8List bytes) => _saveAsset('logo.png', bytes);

/// ذخیره امضای فاکتور (در پوشه دارایی‌های فاکتور)
Future<String> saveSignature(Uint8List bytes) =>
    _saveAsset('signature.png', bytes);

Future<String> _saveAsset(String fileName, Uint8List bytes) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}${Platform.pathSeparator}invoice_assets');
  if (!await dir.exists()) await dir.create(recursive: true);
  final file = File('${dir.path}${Platform.pathSeparator}$fileName');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

Future<Uint8List?> loadBytes(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  return file.readAsBytes();
}

Future<void> downloadBytes(Uint8List bytes, String fileName) async {
  // روی موبایل دانلود مرورگری وجود ندارد؛ ذخیره + اشتراک/چاپ انجام می‌شود
}