import 'package:speech_to_text/speech_to_text.dart';

/// تبدیل صدا به متن با سرویس گفتار دستگاه (اندروید/iOS — Web Speech API روی وب).
/// جداسازی در یک کلاس تا در تست‌های widget قابل فیک شدن باشد.
class AssistantVoiceService {
  final SpeechToText _stt = SpeechToText();
  bool _initialized = false;
  bool _starting = false;
  bool _listening = false;
  String? _faLocaleId;
  void Function(String text)? _onResult;
  void Function(String? error)? _onError;

  bool get isAvailable => _initialized;

  /// آیا همین حالا در حال شنیدن است (حتی وقتی UI از قلم افتاده باشد)
  bool get isListening => _listening || _stt.isListening;

  AssistantVoiceService();

  /// آماده‌سازی سرویس — اگر دستگاه پشتیبانی نکند false برمی‌گرداند
  Future<bool> initialize({void Function(String? error)? onError}) async {
    _onError = onError;
    if (_initialized) return true;
    _starting = true;
    try {
      _initialized = await _stt.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
      );
    } catch (_) {
      _initialized = false;
    }
    _starting = false;
    return _initialized;
  }

  /// شروع ضبط — نتایج جزئی و نهایی از طریق onResult می‌آیند
  Future<void> start({
    required void Function(String text) onResult,
    required void Function(String? error) onError,
  }) async {
    if (_starting) return; // دبل‌تپ/دبل‌لانگ‌پرس → دوبار listen نشود
    _onResult = onResult;
    _onError = onError;
    try {
      if (isListening) await _stt.cancel();
      await _stt.listen(
        onResult: (result) {
          final text = result.recognizedWords.trim();
          if (text.isNotEmpty) _onResult?.call(text);
        },
        listenOptions: SpeechListenOptions(
          // خطای دائمی → خودکار لغو شود تا session معلق نماند
          cancelOnError: true,
          partialResults: true,
          // دیکتهٔ جمله‌های کامل — مناسب پرسش از دستیار
          listenMode: ListenMode.dictation,
          // بدون سقف مکث دستی؛ کاربر با رهاکردن دکمه پایان می‌دهد
          // (اندروید هنوز ممکن است سقف سیستمی کوتاهی اعمال کند)
          pauseFor: null,
          listenFor: null,
          localeId: _faLocaleId ?? await _resolvePersianLocale(),
        ),
      );
      _listening = true;
    } on Exception {
      _listening = false;
      onError('سرویس گفتار در دسترس نیست');
    }
  }

  /// پایان ضبط و گرفتن نتیجهٔ نهایی
  Future<void> stop() async {
    if (!isListening) return;
    try {
      await _stt.stop(); // نتیجهٔ نهایی ارسال می‌شود
    } catch (_) {}
    _listening = false;
  }

  /// لغو فوری بدون گرفتن نتیجه — برای dispose
  Future<void> cancel() async {
    try {
      await _stt.cancel();
    } catch (_) {}
    _listening = false;
  }

  /// اولین زبان فارسی موجود در فهرست زبان‌های recognizer دستگاه
  Future<String?> _resolvePersianLocale() async {
    if (_faLocaleId != null) return _faLocaleId;
    try {
      final locales = await _stt.locales();
      for (final ln in locales) {
        final id = ln.localeId.toLowerCase();
        if (id == 'fa_ir' || id == 'fa' || id.startsWith('fa')) {
          _faLocaleId = ln.localeId;
          break;
        }
      }
      // فارسی نصب نیست → هیچ (زبان پیش‌فرض سیستم استفاده می‌شود)
    } catch (_) {}
    return _faLocaleId;
  }

  void _handleStatus(String status) {
    // «done»/«notListening» یعنی موتور خودش ضبط را بسته است
    // (سقف زمانی سیستم، خطا، یا پایان گفتار) — UI باید باخبر شود.
    if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      _listening = false;
      // اگر موتور خودش بسته (سقف زمانی/سکوت/خطا) و هنوز نتیجهٔ نهایی
      // به UI نرفته، آخرین متن شناخته‌شده را اعلام کن. در stop عادی
      // نتیجهٔ نهایی قبلاً رسیده و متن تکراری همان متن قبلی را set می‌کند.
      final text = _stt.lastRecognizedWords.trim();
      if (text.isNotEmpty) _onResult?.call(text);
    }
  }

  void _handleError(dynamic err) {
    _listening = false;
    final code = err?.errorMsg as String? ?? '';
    final msg = _friendlyError(code);
    _onError?.call(msg);
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'error_permission':
        return 'اجازهٔ میکروفون داده نشده است؛ از تنظیمات برنامه فعالش کنید';
      case 'error_audio_error':
        return 'خطای میکروفون؛ دستگاه را ری‌استارت کنید یا هدست را جدا کنید';
      case 'error_network':
      case 'error_network_timeout':
        return 'تشخیص گفتار به اینترنت نیاز دارد؛ اتصال شبکه را بررسی کنید';
      case 'error_no_match':
      case 'error_speech_timeout':
        return 'صدایی شنیده نشد؛ نزدیک‌تر به میکروفون صحبت کنید';
      case 'error_busy':
        return 'سرویس گفتار مشغول است؛ چند لحظه بعد تلاش کنید';
      case 'error_server':
      case 'error_server_disconnected':
      case 'error_too_many_requests':
        return 'سرویس گفتار در دسترس نیست؛ کمی بعد دوباره تلاش کنید';
      case 'error_language_not_supported':
      case 'error_language_unavailable':
        return 'زبان فارسی روی این دستگاه نصب نیست؛ از تنظیمات سیستم زبان فارسی را برای تشخیص گفتار اضافه کنید';
      default:
        return 'تشخیص گفتار ناموفق بود؛ دوباره تلاش کنید';
    }
  }
}
