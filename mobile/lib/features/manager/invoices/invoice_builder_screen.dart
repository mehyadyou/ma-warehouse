import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../shared/utils/numbers.dart';
import 'invoice_amount_words.dart';
import 'invoice_asset_image.dart';
import 'invoice_models.dart';
import 'invoice_preview_screen.dart';
import 'invoice_repository_provider.dart';
import 'invoice_file_store.dart';
import 'invoices_history_screen.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _red = Color(0xFFF87171);
const _border = Color(0xFF2A2D33);
const _textDim = Color(0xFF8A8F98);

const _paymentMethods = ['نقدی', 'کارت', 'چک', 'حواله'];
const _units = ['عدد', 'کیلوگرم', 'متر', 'کارتن', 'بسته', 'جفت', 'دستگاه', 'سرویس'];

/// فاکتورساز مدیر — فرم ساخت/ویرایش فاکتور
class InvoiceBuilderScreen extends ConsumerStatefulWidget {
  /// پیش‌نویس اولیه (مثلاً خروجی تبدیل سفارش صندوق به فاکتور)
  final InvoiceDraftModel? initialDraft;

  const InvoiceBuilderScreen({super.key, this.initialDraft});

  @override
  ConsumerState<InvoiceBuilderScreen> createState() =>
      _InvoiceBuilderScreenState();
}

class _InvoiceBuilderScreenState extends ConsumerState<InvoiceBuilderScreen> {
  late final _repo = ref.read(invoiceRepositoryProvider);

  final _numberCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  late String _paymentMethod;
  late InvoiceType _type;

  final _sellerName = TextEditingController();
  final _sellerPhone = TextEditingController();
  final _sellerAddress = TextEditingController();
  final _sellerEconomic = TextEditingController();
  final _sellerRegister = TextEditingController();

  final _buyerName = TextEditingController();
  final _buyerPhone = TextEditingController();
  final _buyerAddress = TextEditingController();
  final _buyerEconomic = TextEditingController();
  final _buyerRegister = TextEditingController();

  late final List<_ItemRow> _items;
  late bool _includeTax;
  final _taxPercent = TextEditingController(text: '9');
  final _shippingCost = TextEditingController();

  final _notesCtrl = TextEditingController();

  String? _logoPath;
  String? _signaturePath;

  @override
  void initState() {
    super.initState();
    final now = Jalali.fromDateTime(DateTime.now());
    _dateCtrl.text = '${now.year}/${now.month}/${now.day}';
    _paymentMethod = _paymentMethods.first;
    _type = InvoiceType.simple;
    _items = [_ItemRow(unit: _units.first, onChange: _onDerivedChanged)];
    _includeTax = false;

    // پیش‌پر کردن اطلاعات فروشنده از پروفایل ذخیره‌شده
    final seller = _repo.loadSellerProfile();
    _sellerName.text = seller.name;
    _sellerPhone.text = seller.phone;
    _sellerAddress.text = seller.address;
    _sellerEconomic.text = seller.economicCode;
    _sellerRegister.text = seller.registerNumber;

    // بازیابی پیش‌نویس قبلی؛ در صورت داشتن پیش‌نویس اولیه (مثلاً از صندوق)،
    // همان باز می‌شود تا پیش‌نویس قبلی جای آن را نگیرد
    final draft = widget.initialDraft ?? _repo.loadDraft();
    if (draft != null) _restoreDraft(draft);

    _numberCtrl.addListener(_onDerivedChanged);
    _taxPercent.addListener(_onDerivedChanged);
    _shippingCost.addListener(_onDerivedChanged);
  }

  @override
  void dispose() {
    _persistDraft();
    _numberCtrl.dispose();
    _dateCtrl.dispose();
    _sellerName.dispose();
    _sellerPhone.dispose();
    _sellerAddress.dispose();
    _sellerEconomic.dispose();
    _sellerRegister.dispose();
    _buyerName.dispose();
    _buyerPhone.dispose();
    _buyerAddress.dispose();
    _buyerEconomic.dispose();
    _buyerRegister.dispose();
    _taxPercent.dispose();
    _shippingCost.dispose();
    _notesCtrl.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _restoreDraft(InvoiceDraftModel draft) {
    _type = draft.type;
    _paymentMethod = draft.paymentMethod;
    _includeTax = draft.includeTax;
    _logoPath = draft.logoPath;
    _signaturePath = draft.signaturePath;

    _numberCtrl.text = draft.number;
    if (draft.dateLabel.isNotEmpty) _dateCtrl.text = draft.dateLabel;
    _sellerName.text = draft.seller.name;
    _sellerPhone.text = draft.seller.phone;
    _sellerAddress.text = draft.seller.address;
    _sellerEconomic.text = draft.seller.economicCode;
    _sellerRegister.text = draft.seller.registerNumber;
    _buyerName.text = draft.buyer.name;
    _buyerPhone.text = draft.buyer.phone;
    _buyerAddress.text = draft.buyer.address;
    _buyerEconomic.text = draft.buyer.economicCode;
    _buyerRegister.text = draft.buyer.registerNumber;
    _taxPercent.text = formatNumber(draft.taxPercent);
    _shippingCost.text = draft.shippingCost > 0 ? formatNumber(draft.shippingCost) : '';
    _notesCtrl.text = draft.notes;

    _items
      ..clear()
      ..addAll(
        draft.items.isEmpty
            ? [_ItemRow(unit: _units.first, onChange: _onDerivedChanged)]
            : draft.items
                .map((item) => _ItemRow.from(item, onChange: _onDerivedChanged)),
      );
  }

  void _onDerivedChanged() => setState(() {});

  void _persistDraft() {
    final draft = _buildDraft();
    if (!draft.isEmpty) _repo.saveDraft(draft);
  }

  InvoiceDraftModel _buildDraft() {
    return InvoiceDraftModel(
      number: _numberCtrl.text.trim(),
      dateLabel: _dateCtrl.text.trim(),
      type: _type,
      paymentMethod: _paymentMethod,
      seller: InvoicePartyModel(
        name: _sellerName.text.trim(),
        phone: _sellerPhone.text.trim(),
        address: _sellerAddress.text.trim(),
        economicCode: _sellerEconomic.text.trim(),
        registerNumber: _sellerRegister.text.trim(),
      ),
      buyer: InvoicePartyModel(
        name: _buyerName.text.trim(),
        phone: _buyerPhone.text.trim(),
        address: _buyerAddress.text.trim(),
        economicCode: _buyerEconomic.text.trim(),
        registerNumber: _buyerRegister.text.trim(),
      ),
      items: _items.map((item) => item.toModel()).toList(),
      includeTax: _includeTax,
      taxPercent: _parseNum(_taxPercent),
      shippingCost: _parseNum(_shippingCost),
      notes: _notesCtrl.text.trim(),
      logoPath: _logoPath,
      signaturePath: _signaturePath,
      sourceOrderId: widget.initialDraft?.sourceOrderId,
    );
  }

  String? _validate() {
    if (_sellerName.text.trim().isEmpty) return 'نام فروشنده را وارد کنید';
    if (_buyerName.text.trim().isEmpty) return 'نام خریدار را وارد کنید';
    if (_items.isEmpty) return 'حداقل یک قلم به فاکتور اضافه کنید';
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.description.text.trim().isEmpty) {
        return 'شرح قلم ${i + 1} خالی است';
      }
      if (_parseNum(item.quantity) <= 0) {
        return 'تعداد قلم ${i + 1} نامعتبر است';
      }
      if (_parseNum(item.unitPrice) < 0) {
        return 'قیمت قلم ${i + 1} نامعتبر است';
      }
    }
    return null;
  }

  Future<void> _openPreview() async {
    final error = _validate();
    if (error != null) {
      _showSnack(error);
      return;
    }

    var draft = _buildDraft();
    if (draft.number.isEmpty) {
      draft = draft.copyWith(
        number: '${_repo.loadHistory().length + 1}',
      );
    }
    if (draft.dateLabel.isEmpty) {
      final now = Jalali.fromDateTime(DateTime.now());
      draft = draft.copyWith(dateLabel: '${now.year}/${now.month}/${now.day}');
    }

    // ذخیره پروفایل فروشنده + پیش‌نویس برای ادامه کار
    await _repo.saveSellerProfile(draft.seller);
    await _repo.saveDraft(draft);

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        // فاکتور ساخته‌شدهٔ قبلی (از صندوق/تاریخچه) همان id را نگه می‌دارد تا
        // نسخهٔ ویرایش‌شده جایگزین شود و دوبار در تاریخچه نیفتد
        builder: (_) => InvoicePreviewScreen(
          draft: draft,
          isNew: widget.initialDraft?.id.isEmpty ?? true,
        ),
      ),
    );
  }

  Future<void> _pickImage({required bool isLogo}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: _surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: _green),
              title: const Text('انتخاب از گالری', style: TextStyle(color: Colors.white, fontSize: 14)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: _green),
              title: const Text('دوربین', style: TextStyle(color: Colors.white, fontSize: 14)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      final path = isLogo
          ? await InvoiceFileStore.saveLogo(bytes)
          : await InvoiceFileStore.saveSignature(bytes);
      setState(() {
        if (isLogo) {
          _logoPath = path;
        } else {
          _signaturePath = path;
        }
      });
    } catch (_) {
      if (mounted) _showSnack('بارگذاری عکس ناموفق بود');
    }
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

  static num _parseNum(TextEditingController c) =>
      double.tryParse(normalizeDigits(c.text)) ?? 0;

  @override
  Widget build(BuildContext context) {
    final draft = _buildDraft();
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
          'فاکتورساز',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'فاکتورهای قبلی',
            icon: const Icon(Icons.history_rounded, color: _green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InvoicesHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _section(
                    icon: Icons.receipt_long_rounded,
                    title: 'مشخصات فاکتور',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _choiceChip('فاکتور ساده', _type == InvoiceType.simple, onTap: () => setState(() => _type = InvoiceType.simple)),
                            const SizedBox(width: 8),
                            _choiceChip('فاکتور رسمی', _type == InvoiceType.formal, onTap: () => setState(() => _type = InvoiceType.formal)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _textField(_numberCtrl, 'شماره فاکتور')),
                            const SizedBox(width: 10),
                            Expanded(child: _textField(_dateCtrl, 'تاریخ (شمسی)', keyboardType: TextInputType.text)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: DropdownButton<String>(
                            value: _paymentMethod,
                            dropdownColor: _surfaceAlt,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            underline: Container(height: 1, color: _border),
                            items: _paymentMethods
                                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                .toList(),
                            onChanged: (v) => setState(() => _paymentMethod = v ?? _paymentMethod),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _section(
                    icon: Icons.storefront_rounded,
                    title: 'فروشنده',
                    child: _partyFields(
                      name: _sellerName,
                      phone: _sellerPhone,
                      address: _sellerAddress,
                      economic: _sellerEconomic,
                      register: _sellerRegister,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _section(
                    icon: Icons.person_rounded,
                    title: 'خریدار',
                    child: _partyFields(
                      name: _buyerName,
                      phone: _buyerPhone,
                      address: _buyerAddress,
                      economic: _buyerEconomic,
                      register: _buyerRegister,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _section(
                    icon: Icons.inventory_2_rounded,
                    title: 'اقلام فاکتور',
                    child: Column(
                      children: [
                        for (var i = 0; i < _items.length; i++) _itemCard(_items[i], i),
                        const SizedBox(height: 10),
                        _outlinedButton(
                          icon: Icons.add_rounded,
                          label: 'افزودن ردیف',
                          onTap: () => setState(() => _items.add(_ItemRow(unit: _units.first, onChange: _onDerivedChanged))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _section(
                    icon: Icons.calculate_rounded,
                    title: 'جمع‌ها',
                    child: Column(
                      children: [
                        if (_type == InvoiceType.formal)
                          Row(
                            children: [
                              _checkbox('ارزش افزوده', _includeTax, (v) => setState(() => _includeTax = v)),
                              const SizedBox(width: 10),
                              if (_includeTax)
                                Expanded(
                                  child: _textField(
                                    _taxPercent,
                                    'درصد مالیات',
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  ),
                                ),
                            ],
                          ),
                        if (_type == InvoiceType.formal) const SizedBox(height: 10),
                        _textField(
                          _shippingCost,
                          'هزینه ارسال (تومان)',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _totalLine('جمع اقلام', formatNumber(draft.subtotal)),
                              if (draft.taxAmount > 0)
                                _totalLine('ارزش افزوده', formatNumber(draft.taxAmount)),
                              if (draft.shippingCost > 0)
                                _totalLine('هزینه ارسال', formatNumber(draft.shippingCost)),
                              const Divider(color: _border, height: 16),
                              _totalLine('مبلغ نهایی', formatNumber(draft.grandTotal), bold: true, color: _green),
                              const SizedBox(height: 6),
                              Text(
                                'به حروف: ${amountInWords(draft.grandTotal)}',
                                style: const TextStyle(color: _textDim, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _section(
                    icon: Icons.notes_rounded,
                    title: 'توضیحات',
                    child: _textField(_notesCtrl, 'توضیحات / شرایط پرداخت', maxLines: 3),
                  ),
                  const SizedBox(height: 12),
                  _section(
                    icon: Icons.badge_rounded,
                    title: 'لوگو و امضا',
                    child: Row(
                      children: [
                        Expanded(child: _imageTile(isLogo: true, path: _logoPath)),
                        const SizedBox(width: 10),
                        Expanded(child: _imageTile(isLogo: false, path: _signaturePath)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ─── دکمه ساخت ───
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: BoxDecoration(
              color: _surface,
              border: Border(top: BorderSide(color: _border)),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _openPreview,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('پیش‌نمایش و ساخت فاکتور', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _partyFields({
    required TextEditingController name,
    required TextEditingController phone,
    required TextEditingController address,
    required TextEditingController economic,
    required TextEditingController register,
  }) {
    return Column(
      children: [
        _textField(name, 'نام *'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _textField(phone, 'تلفن', keyboardType: TextInputType.phone)),
            const SizedBox(width: 10),
            Expanded(child: _textField(address, 'آدرس')),
          ],
        ),
        if (_type == InvoiceType.formal) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _textField(economic, 'کد اقتصادی')),
              const SizedBox(width: 10),
              Expanded(child: _textField(register, 'شماره ثبت')),
            ],
          ),
        ],
      ],
    );
  }

  Widget _itemCard(_ItemRow row, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _textField(row.description, 'شرح کالا/خدمات *'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: _red, size: 20),
                onPressed: () {
                  setState(() {
                    row.dispose();
                    _items.removeAt(index);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _textField(
                  row.quantity,
                  'تعداد',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: row.unit,
                      isExpanded: true,
                      dropdownColor: _surfaceAlt,
                      style: const TextStyle(color: Colors.white, fontSize: 12.5),
                      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => row.unit = v);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _textField(
                  row.unitPrice,
                  'قیمت واحد',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _textField(
                  row.discount,
                  'تخفیف',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageTile({required bool isLogo, required String? path}) {
    final label = isLogo ? 'لوگو' : 'امضا';
    final hasImage = path != null && path.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          if (hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: InvoiceAssetImage(
                path: path,
                height: 64,
                placeholder: const Icon(Icons.image_outlined, color: _textDim, size: 44),
              ),
            )
          else
            Container(
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border),
              ),
              child: Icon(isLogo ? Icons.business_rounded : Icons.draw_rounded, color: _textDim, size: 30),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => _pickImage(isLogo: isLogo),
                icon: const Icon(Icons.add_photo_alternate_rounded, color: _green, size: 18),
                label: Text(hasImage ? 'تغییر $label' : 'افزودن $label', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              if (hasImage)
                IconButton(
                  onPressed: () => setState(() {
                    if (isLogo) {
                      _logoPath = null;
                    } else {
                      _signaturePath = null;
                    }
                  }),
                  icon: const Icon(Icons.close_rounded, color: _red, size: 18),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: _green, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _choiceChip(String label, bool selected, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _green.withValues(alpha: 0.15) : _surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? _green : _border, width: 1.4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _green : _textDim,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _checkbox(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? _green : _surfaceAlt,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: value ? _green : _border),
            ),
            child: value ? const Icon(Icons.check_rounded, color: Colors.black, size: 15) : null,
          ),
        ),
        const SizedBox(width: 8),
        const Text('ارزش افزوده', style: TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }

  Widget _totalLine(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: bold ? Colors.white : _textDim, fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
          Text(value, style: TextStyle(color: color ?? Colors.white, fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.start,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlign: textAlign,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
        filled: true,
        fillColor: _surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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

  Widget _outlinedButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _green.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _green, size: 18),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

/// یک ردیف قلم با کنترلرهای خود
class _ItemRow {
  final description = TextEditingController();
  final quantity = TextEditingController();
  final unitPrice = TextEditingController();
  final discount = TextEditingController();
  String unit;

  _ItemRow({required this.unit, VoidCallback? onChange}) {
    _attach(onChange);
  }

  _ItemRow.from(InvoiceItemModel item, {VoidCallback? onChange})
      : unit = item.unit {
    description.text = item.description;
    quantity.text = item.quantity > 0 ? formatNumber(item.quantity) : '';
    unitPrice.text = item.unitPrice > 0 ? formatNumber(item.unitPrice) : '';
    discount.text = item.discount > 0 ? formatNumber(item.discount) : '';
    _attach(onChange);
  }

  /// هر تغییر در فیلدهای ردیف، جمع فاکتور را به‌روز می‌کند
  void _attach(VoidCallback? onChange) {
    if (onChange == null) return;
    for (final controller in [description, quantity, unitPrice, discount]) {
      controller.addListener(onChange);
    }
  }

  num get _qty => double.tryParse(normalizeDigits(quantity.text)) ?? 0;
  num get _price => double.tryParse(normalizeDigits(unitPrice.text)) ?? 0;
  num get _discount => double.tryParse(normalizeDigits(discount.text)) ?? 0;

  InvoiceItemModel toModel() => InvoiceItemModel(
        description: description.text.trim(),
        quantity: _qty,
        unit: unit,
        unitPrice: _price,
        discount: _discount,
      );

  void dispose() {
    description.dispose();
    quantity.dispose();
    unitPrice.dispose();
    discount.dispose();
  }
}