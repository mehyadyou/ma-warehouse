import 'package:flutter/material.dart';

import '../../core/network/api_constants.dart';
import '../../core/storage/secure_storage.dart';

/// Image.network با هدر Authorization — فایل‌های /uploads روی سرور
/// محافظت‌شده‌اند و بدون توکن 401 می‌دهند.
///
/// توکن یک بار در initState خوانده می‌شود؛ اگر درخواست 401 داد،
/// یک بار با رفرش سایلنت دوباره تلاش می‌کند.
class AuthNetworkImage extends StatefulWidget {
  const AuthNetworkImage({
    super.key,
    required this.path,
    this.fit,
    this.errorBuilder,
    this.loadingBuilder,
  });

  /// مسیر نسبی مثل /uploads/receipts/x.jpg یا آدرس کامل
  final String path;
  final BoxFit? fit;
  final WidgetBuilder? errorBuilder;
  final ImageLoadingBuilder? loadingBuilder;

  @override
  State<AuthNetworkImage> createState() => _AuthNetworkImageState();
}

class _AuthNetworkImageState extends State<AuthNetworkImage> {
  String? _token;
  bool _retried = false;
  late String _url;

  @override
  void initState() {
    super.initState();
    _url = ApiConstants.fullUrl(widget.path);
    _loadToken();
  }

  @override
  void didUpdateWidget(covariant AuthNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _url = ApiConstants.fullUrl(widget.path);
      _retried = false;
      _loadToken();
    }
  }

  Future<void> _loadToken() async {
    final token = await SecureStorage.getAccessToken();
    if (mounted && token != _token) {
      setState(() => _token = token);
    }
  }

  /// 401 → احتمالاً توکن منقضی؛ رفرش سایلنت و یک تلاش مجدد
  Future<void> _onUnauthorized() async {
    if (_retried) return;
    _retried = true;
    final refreshed = await SecureStorage.getAccessToken();
    if (mounted && refreshed != null && refreshed != _token) {
      setState(() => _token = refreshed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = _token;
    if (token == null) {
      // توکن هنوز نخوانده شده — placeholder تا setState رفرش شود
      return widget.errorBuilder?.call(context) ??
          const SizedBox.shrink();
    }
    return Image.network(
      _url,
      fit: widget.fit,
      headers: {'Authorization': 'Bearer $token'},
      loadingBuilder: widget.loadingBuilder,
      errorBuilder: (_, error, stack) {
        if (error is NetworkImageLoadException &&
            error.statusCode == 401) {
          _onUnauthorized();
        }
        return widget.errorBuilder?.call(context) ??
            const Icon(Icons.broken_image_outlined);
      },
    );
  }
}
