import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'invoice_repository.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepository();
});