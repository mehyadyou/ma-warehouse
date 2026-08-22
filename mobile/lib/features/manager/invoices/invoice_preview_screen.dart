import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'invoice_file_store.dart';
import 'invoice_models.dart';
import 'invoice_pdf_generator.dart';
import 'invoice_png_exporter.dart';
import 'invoice_repository_provider.dart';
import 'invoice_widget.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _border = Color(0xFF2A2D33);

/// پیش‌نمایش تمام‌صفحه فاکتور + ساخت PDF / PNG
class InvoicePreviewScreen extends ConsumerStatefulWidget {
  final InvoiceDraftModel draft;
  final bool isNew;

  const InvoicePreviewScreen({
    super.key,
    required this.draft,
    this.isNew = false,
  });

  @override
  ConsumerState<InvoicePreviewScreen> createState() =>
      _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends ConsumerState<InvoicePreviewScreen> {
  final _boundaryKey = GlobalKey();
  late InvoiceDraftModel _draft;
  bool _buildingPdf = false;
  bool _buildingPng = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.isNew
        ? widget.draft.copyWith(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            createdAt: DateTime.now().toIso8601String(),
          )
        : widget.draft;
  }

  Future<void> _buildPdf() async {
    if (_buildingPdf) return;
    setState(() => _buildingPdf = true);
    try {
      final bytes = await InvoicePdfGenerator.generate(_draft);
      final path = await InvoiceFileStore.savePdf(bytes, _draft.number);
      final saved = _draft.copyWith(pdfPath: path);
      await ref.read(invoiceRepositoryProvider).saveToHistory(saved);
      _draft = saved;
      if (!mounted) return;
      final displayName = kIsWeb
          ? 'factor-${_draft.number}.pdf'
          : path.split(Platform.pathSeparator).last;
      await _showPdfSuccess(displayName, bytes);
    } catch (_) {
      if (mounted) _showSnack('ساخت فاکتور ناموفق بود؛ دوباره تلاش کنید');
    } finally {
      if (mounted) setState(() => _buildingPdf = false);
    }
  }

  Future<void> _buildPng() async {
    if (_buildingPng) return;
    final boundary = _boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      _showSnack('پیش‌نمایش آماده نیست');
      return;
    }
    setState(() => _buildingPng = true);
    try {
      final bytes = await InvoicePngExporter.capture(boundary);
      final path = await InvoiceFileStore.savePng(bytes, _draft.number);
      // روی وب دانلود توسط savePng انجام شده است
      if (kIsWeb) return;
      if (!mounted) return;
      await _sharePng(path);
    } catch (_) {
      if (mounted) _showSnack('ساخت تصویر ناموفق بود؛ دوباره تلاش کنید');
    } finally {
      if (mounted) setState(() => _buildingPng = false);
    }
  }

  Future<void> _sharePng(String path) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        text: 'فاکتور ${_draft.number}',
      ),
    );
  }

  Future<void> _showPdfSuccess(String fileName, Uint8List bytes) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0x1A4ADE80),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: _green, size: 30),
              ),
              const SizedBox(height: 14),
              const Text(
                'فاکتور ساخته شد',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                fileName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8A8F98),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              if (kIsWeb)
                _actionButton(
                  icon: Icons.download_rounded,
                  label: 'دانلود دوباره',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await InvoiceFileStore.downloadBytes(
                      bytes,
                      'factor-${_draft.number}.pdf',
                    );
                  },
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        icon: Icons.share_rounded,
                        label: 'اشتراک‌گذاری',
                        onTap: () async {
                          Navigator.pop(ctx);
                          await Printing.sharePdf(
                            bytes: bytes,
                            filename: 'factor-${_draft.number}.pdf',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionButton(
                        icon: Icons.print_rounded,
                        label: 'چاپ',
                        onTap: () async {
                          Navigator.pop(ctx);
                          await Printing.layoutPdf(
                            onLayout: (format) async => bytes,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              _actionButton(
                icon: Icons.check_rounded,
                label: 'پایان',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                filled: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: filled ? _green : _surfaceAlt,
        foregroundColor: filled ? Colors.black : Colors.white,
        minimumSize: const Size.fromHeight(46),
        side: filled ? null : const BorderSide(color: _border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: _surfaceAlt,
          content: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'پیش‌نمایش فاکتور',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: InvoiceView(invoice: _draft),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: BoxDecoration(
              color: _surface,
              border: Border(top: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _buildPdf,
                    child: _buildingPdf
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black87,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.picture_as_pdf_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'ساخت فاکتور',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _surfaceAlt,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: _border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _buildPng,
                    child: _buildingPng
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_rounded, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'خروجی PNG',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}