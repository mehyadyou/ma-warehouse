import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/network/api_error.dart';

const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _card = Color(0xFF1E2128);
const _green = Color(0xFF4ADE80);
const _border = Color(0xFF262A33);

/// بارگذاری یک صفحهٔ محصولات از سرور (جستجو + صفحه)
typedef PickerPageLoader<T> =
    Future<({List<T> items, int total})> Function(String query, int page);

/// پیکر جستجوشوندهٔ سرور-محور — جایگزین امن Dropdown با لیست کامل.
/// هر صفحه ۵۰ آیتم؛ با اسکرول صفحهٔ بعد می‌آید و جستجو debounce دارد.
/// خروجی: آیتم انتخابی یا null (انصراف).
Future<T?> showSearchPicker<T>({
  required BuildContext context,
  required String title,
  required PickerPageLoader<T> loader,
  required String Function(T) labelOf,
  String? Function(T)? subtitleOf,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SearchPickerSheet<T>(
      title: title,
      loader: loader,
      labelOf: labelOf,
      subtitleOf: subtitleOf,
    ),
  );
}

class _SearchPickerSheet<T> extends StatefulWidget {
  final String title;
  final PickerPageLoader<T> loader;
  final String Function(T) labelOf;
  final String? Function(T)? subtitleOf;

  const _SearchPickerSheet({
    required this.title,
    required this.loader,
    required this.labelOf,
    this.subtitleOf,
  });

  @override
  State<_SearchPickerSheet<T>> createState() => _SearchPickerSheetState<T>();
}

class _SearchPickerSheetState<T> extends State<_SearchPickerSheet<T>> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _debounce;

  List<T> _items = [];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      _load(reset: false);
    }
  }

  void _onQueryChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _load(reset: true);
    });
  }

  Future<void> _load({required bool reset}) async {
    final seq = ++_seq;
    final nextPage = reset ? 1 : _page + 1;
    if (!reset && (_loadingMore || !_hasMore)) return;

    setState(() {
      if (reset) {
        _loading = true;
        _error = null;
        _items = [];
        _hasMore = true;
      } else {
        _loadingMore = true;
      }
    });
    try {
      final result = await widget.loader(_searchCtrl.text.trim(), nextPage);
      if (!mounted || seq != _seq) return;
      setState(() {
        _items = reset ? result.items : [..._items, ...result.items];
        _page = nextPage;
        _hasMore = _items.length < result.total;
        _loading = false;
        _loadingMore = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted || seq != _seq) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = friendlyError(e);
      });
    }
  }

  void _retry() => _load(reset: true);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: _surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onQueryChanged,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'جستجوی محصول...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _green));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _retry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _green,
                  side: const BorderSide(color: _green),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Text(
          _searchCtrl.text.trim().isEmpty
              ? 'محصولی یافت نشد'
              : 'نتیجه‌ای برای جستجوی شما پیدا نشد',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 13,
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: _loadingMore
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _green,
                      ),
                    )
                  : Text(
                      'برای نمایش بیشتر اسکرول کنید',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 11,
                      ),
                    ),
            ),
          );
        }
        final item = _items[index];
        final label = widget.labelOf(item);
        final subtitle = widget.subtitleOf?.call(item);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: _card,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.pop(context, item),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        color: _green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (subtitle != null && subtitle.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
