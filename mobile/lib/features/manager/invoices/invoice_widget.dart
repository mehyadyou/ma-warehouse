import 'package:flutter/material.dart';

import '../../../shared/utils/numbers.dart';
import 'invoice_amount_words.dart';
import 'invoice_asset_image.dart';
import 'invoice_models.dart';

/// رنگ‌های چاپی قالب (روی کاغذ سفید)
const _ink = Color(0xFF1F2937);
const _inkDim = Color(0xFF6B7280);
const _green = Color(0xFF16A34A);
const _greenLight = Color(0xFFF0FDF4);
const _greenBorder = Color(0xFF86EFAC);
const _line = Color(0xFFE5E7EB);
const _stripe = Color(0xFFF9FAFB);

/// قالب فاکتور A4 — بین پیش‌نمایش و خروجی PNG مشترک است
class InvoiceView extends StatelessWidget {
  final InvoiceDraftModel invoice;

  const InvoiceView({super.key, required this.invoice});

  /// عرض منطقی صفحه (نسبت A4)
  static const pageWidth = 420.0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SizedBox(
        width: pageWidth,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _TopBar(),
              const SizedBox(height: 14),
              _Header(invoice: invoice),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _PartyBox(label: 'فروشنده', party: invoice.seller, formal: invoice.type == InvoiceType.formal)),
                  const SizedBox(width: 10),
                  Expanded(child: _PartyBox(label: 'خریدار', party: invoice.buyer, formal: invoice.type == InvoiceType.formal)),
                ],
              ),
              const SizedBox(height: 12),
              _ItemsTable(items: invoice.items),
              const SizedBox(height: 10),
              _Totals(invoice: invoice),
              const SizedBox(height: 10),
              _AmountInWords(invoice: invoice),
              if (invoice.notes.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                _Notes(notes: invoice.notes),
              ],
              const SizedBox(height: 14),
              _Footer(invoice: invoice),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_green, _greenBorder]),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final InvoiceDraftModel invoice;
  const _Header({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final typeLabel = invoice.type == InvoiceType.formal ? 'فاکتور رسمی' : 'فاکتور ساده';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (invoice.logoPath != null && invoice.logoPath!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _invoiceImage(invoice.logoPath!, width: 74, height: 74),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'فاکتور فروش کالا و خدمات',
                style: TextStyle(
                  color: _ink,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Vazirmatn',
                ),
              ),
              const SizedBox(height: 3),
              Text(
                typeLabel,
                style: const TextStyle(
                  color: _green,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Vazirmatn',
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _greenLight,
            border: Border.all(color: _greenBorder),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('شماره فاکتور', invoice.number),
              const SizedBox(height: 3),
              _infoRow('تاریخ', invoice.dateLabel),
              const SizedBox(height: 3),
              _infoRow('نوع پرداخت', invoice.paymentMethod),
            ],
          ),
        ),
      ],
    );
  }
}

class _PartyBox extends StatelessWidget {
  final String label;
  final InvoicePartyModel party;
  final bool formal;

  const _PartyBox({
    required this.label,
    required this.party,
    required this.formal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _green,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'Vazirmatn',
            ),
          ),
          const SizedBox(height: 6),
          _partyLine(party.name, bold: true),
          if (party.phone.trim().isNotEmpty) _partyLine(party.phone),
          if (party.address.trim().isNotEmpty) _partyLine(party.address),
          if (formal && party.economicCode.trim().isNotEmpty)
            _partyLine('کد اقتصادی: ${party.economicCode}'),
          if (formal && party.registerNumber.trim().isNotEmpty)
            _partyLine('شماره ثبت: ${party.registerNumber}'),
        ],
      ),
    );
  }

  Widget _partyLine(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        text,
        style: TextStyle(
          color: bold ? _ink : _inkDim,
          fontSize: 11,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          fontFamily: 'Vazirmatn',
        ),
      ),
    );
  }
}

class _ItemsTable extends StatelessWidget {
  final List<InvoiceItemModel> items;
  const _ItemsTable({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _TableRowHeader(),
          for (var i = 0; i < items.length; i++)
            _TableRowItem(index: i, item: items[i], zebra: i.isOdd),
        ],
      ),
    );
  }
}

class _TableRowHeader extends StatelessWidget {
  const _TableRowHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _green,
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: const Row(
        children: [
          _Cell('ردیف', flex: 1, header: true),
          _Cell('شرح کالا/خدمات', flex: 5, header: true),
          _Cell('تعداد', flex: 2, header: true),
          _Cell('واحد', flex: 2, header: true),
          _Cell('قیمت واحد', flex: 3, header: true),
          _Cell('جمع', flex: 3, header: true),
        ],
      ),
    );
  }
}

class _TableRowItem extends StatelessWidget {
  final int index;
  final InvoiceItemModel item;
  final bool zebra;

  const _TableRowItem({
    required this.index,
    required this.item,
    required this.zebra,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: zebra ? _stripe : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _Cell('${index + 1}', flex: 1),
          _Cell(item.description, flex: 5, alignStart: true),
          _Cell(_num(item.quantity), flex: 2),
          _Cell(item.unit, flex: 2),
          _Cell(_num(item.unitPrice), flex: 3),
          _Cell(_num(item.rowTotal), flex: 3, bold: true),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final int flex;
  final bool header;
  final bool bold;
  final bool alignStart;

  const _Cell(this.text, {required this.flex, this.header = false, this.bold = false, this.alignStart = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignStart ? TextAlign.start : TextAlign.center,
        style: TextStyle(
          color: header ? Colors.white : _ink,
          fontSize: 10,
          fontWeight: (header || bold) ? FontWeight.w700 : FontWeight.w400,
          fontFamily: 'Vazirmatn',
        ),
      ),
    );
  }
}

class _Totals extends StatelessWidget {
  final InvoiceDraftModel invoice;
  const _Totals({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final formal = invoice.type == InvoiceType.formal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _totalRow('جمع کل اقلام', formatNumber(invoice.subtotal)),
        if (formal && invoice.includeTax)
          _totalRow(
            'ارزش افزوده (${_num(invoice.taxPercent)}٪)',
            formatNumber(invoice.taxAmount),
          ),
        if (invoice.shippingCost > 0)
          _totalRow('هزینه ارسال', formatNumber(invoice.shippingCost)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'مبلغ نهایی: ${formatNumber(invoice.grandTotal)} تومان',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Vazirmatn',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _totalRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(top: 2),
    child: Text(
      '$label: $value تومان',
      style: const TextStyle(
        color: _ink,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        fontFamily: 'Vazirmatn',
      ),
    ),
  );
}

class _AmountInWords extends StatelessWidget {
  final InvoiceDraftModel invoice;
  const _AmountInWords({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: _greenLight,
        border: Border.all(color: _greenBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مبلغ به حروف:',
            style: TextStyle(
              color: _green,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'Vazirmatn',
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              amountInWords(invoice.grandTotal),
              style: const TextStyle(
                color: _ink,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'Vazirmatn',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Notes extends StatelessWidget {
  final String notes;
  const _Notes({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'توضیحات',
            style: TextStyle(
              color: _green,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'Vazirmatn',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            notes,
            style: const TextStyle(
              color: _inkDim,
              fontSize: 10,
              fontFamily: 'Vazirmatn',
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final InvoiceDraftModel invoice;
  const _Footer({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'با تشکر از خرید شما',
                style: TextStyle(
                  color: _inkDim.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontFamily: 'Vazirmatn',
                ),
              ),
              if (invoice.seller.phone.trim().isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  'تلفن فروشنده: ${invoice.seller.phone}',
                  style: const TextStyle(
                    color: _inkDim,
                    fontSize: 10,
                    fontFamily: 'Vazirmatn',
                  ),
                ),
              ],
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (invoice.signaturePath != null && invoice.signaturePath!.isNotEmpty)
              _invoiceImage(invoice.signaturePath!, width: 96, height: 56),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: _greenBorder),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Text(
                'امضا و مهر فروشنده',
                style: TextStyle(
                  color: _inkDim,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Vazirmatn',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget _invoiceImage(String path, {required double width, required double height}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: InvoiceAssetImage(path: path, width: width, height: height),
  );
}

Widget _infoRow(String label, String value) {
  return Text(
    '$label: $value',
    style: const TextStyle(
      color: _ink,
      fontSize: 10.5,
      fontWeight: FontWeight.w600,
      fontFamily: 'Vazirmatn',
    ),
  );
}

String _num(num value) => formatNumber(value);