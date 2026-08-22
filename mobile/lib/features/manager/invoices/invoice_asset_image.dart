import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'invoice_file_store.dart';

/// تصویر دارایی فاکتور (لوگو/امضا)؛ موبایل از فایل و وب از حافظه خوانده می‌شود
class InvoiceAssetImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const InvoiceAssetImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: InvoiceFileStore.loadBytes(path),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return placeholder ?? const SizedBox.shrink();
        }
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => placeholder ?? const SizedBox.shrink(),
        );
      },
    );
  }
}