import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/warehouse_keeper_provider.dart';
import '../models/keeper_carrier_model.dart';
import '../../../core/network/api_error.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);
const _red = Color(0xFFF87171);
const _border = Color(0xFF2A2D33);

/// منوی «باربری» پنل انباردار — افزودن/ویرایش/حذف باربری.
///
/// ترتیب لیست = صف بارگیری راننده: بالا دورترین (اولین بار — ته وانت)،
/// پایین نزدیک‌ترین (آخرین بار — کنار در). انباردار دورترین باربری را بالای صف
/// می‌گذارد تا اول بارگیری شود. جابه‌جایی با دستگیرهٔ درگ انجام می‌شود و سمت سرور
/// اولویت‌ها بازچینی می‌شوند.
class CarriersScreen extends ConsumerStatefulWidget {
  const CarriersScreen({super.key});

  @override
  ConsumerState<CarriersScreen> createState() => _CarriersScreenState();
}

class _CarriersScreenState extends ConsumerState<CarriersScreen> {
  /// شناسهٔ باربری‌های در حال ویرایش/حذف — جلوگیری از عملیات دوباره
  final Set<String> _pendingIds = {};

  /// ترتیب محلی بعد از درگ — تا رسیدن پاسخ سرور نمایش داده می‌شود؛
  /// در خطا پاک می‌شود تا لیست به ترتیب واقعی برگردد
  List<KeeperCarrierModel>? _localCarriers;
  bool _reorderBusy = false;

  /// آیا کاربر با موس کار می‌کند؟ با موس درگ بلافاصله شروع می‌شود (بدون
  /// نگه‌داشتن)؛ با لمس برای حفظ اسکرول، درگ با نگه‌داشتن کوتاه شروع می‌شود.
  bool _mouseMode = false;

  Future<void> _openForm([KeeperCarrierModel? carrier]) async {
    final saved = await showModalBottomSheet<KeeperCarrierModel>(
      context: context,
      backgroundColor: _bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CarrierFormSheet(carrier: carrier),
    );
    if (saved == null || !mounted) return;

    final isEdit = carrier != null;
    setState(() => _pendingIds.add(saved.id.isEmpty ? '_new' : saved.id));
    try {
      await ref
          .read(
            carrierSaveProvider(
              (
                id: isEdit ? carrier.id : null,
                name: saved.name,
                priority: saved.priority,
                phone: saved.phone,
                address: saved.address,
              ),
            ).future,
          );
      if (mounted) {
        // سایهٔ ترتیبِ حاصل از درگ را کنار بگذار تا لیست تازهٔ سرور (با
        // باربری جدید/ویرایش‌شده) بدون پوشاندن نمایش داده شود
        setState(() => _localCarriers = null);
        // باربری جدید به انتهای صف اضافه می‌شود؛ با درگ به جایگاه دلخواه برده می‌شود
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'باربری ویرایش شد'
                  : 'باربری افزوده شد — با گرفتن و کشیدن آن را در صف جای دهید',
            ),
            backgroundColor: _green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) _showError(friendlyError(e));
    } finally {
      if (mounted) setState(() => _pendingIds.remove(carrier?.id ?? '_new'));
    }
  }

  Future<void> _confirmDelete(KeeperCarrierModel carrier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف باربری', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(
          '«${carrier.name}» حذف می‌شود و دیگر در لیست انتخاب باربریِ ثبت سفارش نیست.\nسفارش‌های قبلی نام باربری را نگه داشته‌اند.',
          style: const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: _red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _pendingIds.add(carrier.id));
    try {
      await ref.read(carrierDeleteProvider(carrier.id).future);
      if (mounted) {
        // سایهٔ ترتیبِ حاصل از درگ را کنار بگذار تا حذف در لیست تازهٔ سرور دیده شود
        setState(() => _localCarriers = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('باربری حذف شد'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) _showError(friendlyError(e));
    } finally {
      if (mounted) setState(() => _pendingIds.remove(carrier.id));
    }
  }

  /// درگ‌انددراپ صف — ترتیب محلی بلافاصله اعمال، سپس روی سرور ذخیره می‌شود؛
  /// در خطا لیست به ترتیب سرور برمی‌گردد
  Future<void> _onReorder(int oldIndex, int newIndex) async {
    if (_reorderBusy) return;
    final source = _localCarriers ??
        ref.read(carriersProvider).value ??
        const <KeeperCarrierModel>[];
    if (source.isEmpty) return;
    if (newIndex > oldIndex) newIndex -= 1;

    final reordered = List.of(source);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);

    setState(() {
      _reorderBusy = true;
      _localCarriers = reordered;
    });
    try {
      final saved = await ref
          .read(carrierReorderProvider(reordered.map((c) => c.id).toList()).future);
      if (!mounted) return;
      setState(() {
        // ترتیب تازهٔ سرور (با اولویت‌های بازچینی‌شده) — بدون invalidate، بدون فلش
        _localCarriers = saved;
        _reorderBusy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localCarriers = null;
        _reorderBusy = false;
      });
      _showError(friendlyError(e));
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carriersAsync = ref.watch(carriersProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text(
          'باربری‌ها',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _green),
            onPressed: () => ref.invalidate(carriersProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pendingIds.contains('_new') ? null : () => _openForm(),
        backgroundColor: _green,
        icon: _pendingIds.contains('_new')
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('باربری جدید', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: carriersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _green)),
        error: (err, _) => _buildError(context, ref),
        data: (carriers) {
          final list = _localCarriers ?? carriers;
          return list.isEmpty
              ? _buildEmpty()
              : Column(
                  children: [
                    _buildQueueHint(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () {
                          // رفرش دستی هم سایهٔ درگ را کنار می‌گذارد تا لیست سرور دیده شود
                          _localCarriers = null;
                          return ref.refresh(carriersProvider.future);
                        },
                        color: _green,
                        backgroundColor: _surface,
                        child: MouseRegion(
                          // حرکت موس روی لیست (بدون کلیک) → حالت درگ فوری فعال می‌شود
                          onHover: (_) {
                            if (!_mouseMode) setState(() => _mouseMode = true);
                          },
                          child: Listener(
                            // موس/ترک‌پد → درگ فوری؛ لمس واقعی → درگ با نگه‌داشتن (اسکرول سالم بماند)
                            onPointerDown: (event) {
                              final isMouse =
                                  event.kind == PointerDeviceKind.mouse ||
                                      event.kind == PointerDeviceKind.trackpad;
                              if (isMouse && !_mouseMode) {
                                setState(() => _mouseMode = true);
                              } else if (!isMouse && _mouseMode) {
                                setState(() => _mouseMode = false);
                              }
                            },
                            child: ReorderableListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                              buildDefaultDragHandles: false,
                              itemCount: list.length,
                              onReorder: _onReorder,
                              itemBuilder: (context, index) {
                                final carrier = list[index];
                                // با موس: درگ فوری؛ با لمس: نگه‌داشتن کوتاه
                                final listener = _mouseMode
                                    ? ReorderableDragStartListener(
                                        key: ValueKey(carrier.id),
                                        index: index,
                                        child: _CarrierCard(
                                          carrier: carrier,
                                          position: index + 1,
                                          pending: _pendingIds.contains(
                                              carrier.id),
                                          onEdit: () => _openForm(carrier),
                                          onDelete: () => _confirmDelete(
                                              carrier),
                                        ),
                                      )
                                    : ReorderableDelayedDragStartListener(
                                        key: ValueKey(carrier.id),
                                        index: index,
                                        child: _CarrierCard(
                                          carrier: carrier,
                                          position: index + 1,
                                          pending: _pendingIds.contains(
                                              carrier.id),
                                          onEdit: () => _openForm(carrier),
                                          onDelete: () => _confirmDelete(
                                              carrier),
                                        ),
                                      );
                                return listener;
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  /// راهنمای صف بارگیری — بالا دورترین (اولین بار)، پایین نزدیک‌ترین (آخرین بار)
  Widget _buildQueueHint() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _orange.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.swap_vert_rounded, size: 18, color: _orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'ترتیب صف بارگیری: بالا = دورترین (اولین بار)، پایین = نزدیک‌ترین (آخرین بار)\nکارت هر باربری را بگیرید و بکشید — با موس فوری، با لمس کمی نگه دارید',
              style: TextStyle(
                color: _orange.withValues(alpha: 0.9),
                fontSize: 11.5,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fire_truck_outlined, color: Colors.white.withValues(alpha: 0.25), size: 44),
          const SizedBox(height: 12),
          Text(
            'باربری‌ای ثبت نشده است',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13.5),
          ),
          const SizedBox(height: 4),
          Text(
            'با «باربری جدید» اولین شرکت حمل را اضافه کنید\n— مدیر هنگام ثبت سفارش همین لیست را می‌بیند',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 11.5,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, color: Colors.white.withValues(alpha: 0.3), size: 40),
          const SizedBox(height: 12),
          Text('خطا در دریافت اطلاعات', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => ref.invalidate(carriersProvider),
            style: OutlinedButton.styleFrom(
              foregroundColor: _green,
              side: BorderSide(color: _green.withValues(alpha: 0.4)),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('تلاش دوباره'),
          ),
        ],
      ),
    );
  }
}

class _CarrierCard extends StatelessWidget {
  const _CarrierCard({
    super.key,
    required this.carrier,
    required this.position,
    required this.pending,
    required this.onEdit,
    required this.onDelete,
  });

  final KeeperCarrierModel carrier;
  final int position;
  final bool pending;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final hasDetails =
        (carrier.phone?.isNotEmpty ?? false) || (carrier.address?.isNotEmpty ?? false);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          // جایگاه در صف بارگیری — بالای صف = اولین بار (دورترین)، پایین = آخرین بار (نزدیک‌ترین)
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$position',
              style: const TextStyle(color: _orange, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  carrier.name,
                  style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w600),
                ),
                if (hasDetails) ...[
                  const SizedBox(height: 3),
                  Text(
                    [
                      if (carrier.phone?.isNotEmpty ?? false) carrier.phone!,
                      if (carrier.address?.isNotEmpty ?? false) carrier.address!,
                    ].join(' — '),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (pending)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: _green),
            )
          else ...[
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, color: Colors.white.withValues(alpha: 0.55), size: 20),
              tooltip: 'ویرایش',
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, color: _red, size: 20),
              tooltip: 'حذف',
            ),
          ],
          const SizedBox(width: 2),
          // دستگیرهٔ درگ (نماد) — کارت با نگه‌داشتن بلند جابه‌جا می‌شود
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 20),
            child: Icon(
              Icons.drag_handle_rounded,
              color: Colors.white38,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

/// فرم افزودن/ویرایش باربری — نتیجه در [Navigator.pop] برمی‌گردد.
/// ترتیب در صف با درگ‌انددراپ تعیین می‌شود؛ باربری جدید به انتهای صف اضافه می‌شود.
class _CarrierFormSheet extends StatefulWidget {
  const _CarrierFormSheet({this.carrier});

  final KeeperCarrierModel? carrier;

  @override
  State<_CarrierFormSheet> createState() => _CarrierFormSheetState();
}

class _CarrierFormSheetState extends State<_CarrierFormSheet> {
  late final TextEditingController _nameCtrl =
      TextEditingController(text: widget.carrier?.name ?? '');
  late final TextEditingController _phoneCtrl =
      TextEditingController(text: widget.carrier?.phone ?? '');
  late final TextEditingController _addressCtrl =
      TextEditingController(text: widget.carrier?.address ?? '');

  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_saving) return;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('نام باربری الزامی است'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final phone = _phoneCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    Navigator.pop(
      context,
      KeeperCarrierModel(
        id: widget.carrier?.id ?? '',
        name: name,
        priority: widget.carrier?.priority ?? 0,
        phone: phone.isEmpty ? null : phone,
        address: address.isEmpty ? null : address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.carrier != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isEdit ? 'ویرایش باربری' : 'باربری جدید',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'این باربری در ثبت سفارش مدیر (بخش انتخاب باربری) نمایش داده می‌شود\nجایگاه آن در صف بارگیری را با گرفتن و کشیدن کارتش در لیست اصلی تعیین کنید',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11.5, height: 1.6),
          ),
          const SizedBox(height: 14),
          _field(_nameCtrl, 'نام باربری *', hint: 'مثلاً باربری فارس'),
          const SizedBox(height: 10),
          _field(_phoneCtrl, 'تلفن', hint: 'مثلاً 071-12345678', keyboardType: TextInputType.phone),
          const SizedBox(height: 10),
          _field(_addressCtrl, 'آدرس/شهر', hint: 'مثلاً شیراز'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isEdit ? 'ذخیرهٔ تغییرات' : 'افزودن باربری',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 12,
        ),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
        filled: true,
        fillColor: _surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _green),
        ),
        isDense: true,
      ),
    );
  }
}