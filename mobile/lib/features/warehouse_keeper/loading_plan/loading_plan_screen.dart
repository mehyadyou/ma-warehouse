import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../providers/warehouse_keeper_provider.dart';
import '../models/keeper_product_model.dart';
import '../models/loading_plan_item_model.dart';
import '../../../core/network/api_error.dart';

const _bg         = Color(0xFF0F1114);
const _surface    = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green      = Color(0xFF4ADE80);
const _orange     = Color(0xFFFB923C);
const _border     = Color(0xFF2A2D33);

class _Row {
  String? productId;
  String? modelId;
  int quantity = 1;
  List<KeeperProductVariantModel> models = [];
}

class LoadingPlanScreen extends ConsumerStatefulWidget {
  const LoadingPlanScreen({super.key});
  @override
  ConsumerState<LoadingPlanScreen> createState() => _LoadingPlanScreenState();
}

class _LoadingPlanScreenState extends ConsumerState<LoadingPlanScreen> {
  List<KeeperProductModel> _products = [];
  bool _loading    = true;
  bool _generating = false;
  String _strategy = 'FIFO';

  final List<_Row> _rows = [];
  List<LoadingPlanItemModel>? _plan;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final p = await ref.read(wkApiProvider).getProducts();
      setState(() { _products = p; _loading = false; });
      if (p.isNotEmpty) _addRow();
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _addRow() {
    setState(() => _rows.add(_Row()));
  }

  Future<void> _generate() async {
    for (int i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      if (r.productId == null) { _snack('ردیف ${i+1}: محصول انتخاب نشده'); return; }
      if (r.modelId   == null) { _snack('ردیف ${i+1}: مدل انتخاب نشده');   return; }
    }
    setState(() => _generating = true);
    try {
      final items = _rows.map((r) => {
        'productId': r.productId,
        'modelId':   r.modelId,
        'quantity':  r.quantity,
      }).toList();
      final result = await ref.read(wkApiProvider).getLoadingPlan(items, _strategy);
      setState(() => _plan = result);
    } on DioException catch (e) {
      _snack(friendlyError(e));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text('برنامه بارگیری',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : _plan != null ? _buildPlanView() : _buildConfigView(),
    );
  }

  Widget _buildConfigView() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(children: [
          const Text('روش:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          _StrategyChip(label: 'FIFO', subtitle: 'قدیمی‌ترها اول', selected: _strategy == 'FIFO',
              onTap: () => setState(() => _strategy = 'FIFO')),
          const SizedBox(width: 8),
          _StrategyChip(label: 'LIFO', subtitle: 'جدیدترها اول', selected: _strategy == 'LIFO',
              onTap: () => setState(() => _strategy = 'LIFO')),
        ]),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _rows.length + 1,
          itemBuilder: (_, i) {
            if (i == _rows.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: OutlinedButton.icon(
                  onPressed: _addRow,
                  icon: const Icon(Icons.add_rounded, color: _green),
                  label: const Text('افزودن محصول', style: TextStyle(color: _green)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _green),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              );
            }
            return _buildRow(i);
          },
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: BoxDecoration(color: _surface, border: Border(top: BorderSide(color: _border))),
        child: ElevatedButton(
          onPressed: _generating ? null : _generate,
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _generating
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('تولید برنامه $_strategy', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    ]);
  }

  Widget _buildRow(int i) {
    final row = _rows[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
      child: Column(children: [
        Row(children: [
          Text('${i+1}', style: const TextStyle(color: _green, fontWeight: FontWeight.w700)),
          const Spacer(),
          if (_rows.length > 1)
            GestureDetector(
              onTap: () => setState(() => _rows.removeAt(i)),
              child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.3), size: 18),
            ),
        ]),
        const SizedBox(height: 8),
        _Dropdown(
          value: row.productId,
          hint: 'انتخاب محصول',
          items: _products.map((p) => DropdownMenuItem<String>(
            value: p.id,
            child: Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
          )).toList(),
          onChanged: (v) {
            setState(() {
              row.productId = v;
              row.modelId   = null;
              final p = _products.firstWhere((p) => p.id == v, orElse: () => KeeperProductModel());
              row.models = p.models;
            });
          },
        ),
        const SizedBox(height: 8),
        _Dropdown(
          value: row.modelId,
          hint: 'انتخاب مدل',
          items: row.models.map((m) {
            final cap = m.unitsPerBox;
            final unit = _products.firstWhere((p) => p.id == row.productId, orElse: () => KeeperProductModel()).unit ?? 'عدد';
            final pkg = m.packageType ?? 'کارتن';
            return DropdownMenuItem<String>(
              value: m.id,
              child: Text(cap != null ? '${m.name} ($cap $unit/$pkg)' : m.name,
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            );
          }).toList(),
          onChanged: row.productId == null ? null : (v) => setState(() => row.modelId = v),
        ),
        const SizedBox(height: 8),
        Row(children: [
          const Text('تعداد:', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const Spacer(),
          _Counter(
            value: row.quantity,
            onDec: row.quantity > 1 ? () => setState(() => row.quantity--) : null,
            onInc: () => setState(() => row.quantity++),
          ),
        ]),
      ]),
    );
  }

  Widget _buildPlanView() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _green.withOpacity(0.3)),
            ),
            child: Text('$_strategy — ${_plan!.length} آیتم',
                style: const TextStyle(color: _green, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => setState(() => _plan = null),
            icon: const Icon(Icons.refresh_rounded, color: _green, size: 18),
            label: const Text('تغییر', style: TextStyle(color: _green, fontSize: 13)),
          ),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _plan!.length,
          itemBuilder: (_, i) {
            final item = _plan![i];
            final isInd = item.isIndividualUnit ?? false;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isInd ? _orange.withOpacity(0.3) : _border),
              ),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: _green.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text('${item.sequence}',
                      style: const TextStyle(color: _green, fontWeight: FontWeight.w700, fontSize: 13))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.productName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(item.modelName,
                      style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isInd ? _orange.withOpacity(0.15) : _green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isInd ? 'تکی' : '${item.capacityPerBox} ${item.unit ?? 'عدد'}',
                    style: TextStyle(color: isInd ? _orange : _green, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
            );
          },
        ),
      ),
    ]);
  }
}

class _StrategyChip extends StatelessWidget {
  final String label, subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _StrategyChip({required this.label, required this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _green.withOpacity(0.12) : _surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? _green : _border),
        ),
        child: Column(children: [
          Text(label, style: TextStyle(color: selected ? _green : Colors.white70, fontWeight: FontWeight.w700, fontSize: 13)),
          Text(subtitle, style: TextStyle(color: selected ? _green.withOpacity(0.7) : Colors.white38, fontSize: 10)),
        ]),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String? value, hint;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?)? onChanged;
  const _Dropdown({required this.value, required this.hint, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: _surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint!, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
        isExpanded: true, dropdownColor: _surfaceAlt,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.4)),
        items: items, onChanged: onChanged,
      ),
    ),
  );
}

class _Counter extends StatelessWidget {
  final int value;
  final VoidCallback? onDec;
  final VoidCallback onInc;
  const _Counter({required this.value, required this.onDec, required this.onInc});

  @override
  Widget build(BuildContext context) => Row(children: [
    _Btn(icon: Icons.remove_rounded, enabled: onDec != null, onTap: onDec),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text('$value', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
    _Btn(icon: Icons.add_rounded, enabled: true, onTap: onInc),
  ]);
}

class _Btn extends StatelessWidget {
  final IconData icon; final bool enabled; final VoidCallback? onTap;
  const _Btn({required this.icon, required this.enabled, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        color: enabled ? _green.withOpacity(0.12) : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: enabled ? _green : Colors.white.withOpacity(0.2), size: 16),
    ),
  );
}
