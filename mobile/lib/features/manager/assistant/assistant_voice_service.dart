import 'package:speech_to_text/speech_to_text.dart';

/// تبدیل صدا به متن با سرویس گفتار دستگاه (اندروید/وب — Web Speech API).
/// جداسازی در یک کلاس تا در تست‌های widget قابل فیک شدن باشد.
class AssistantVoiceService {
  final SpeechToText _stt = SpeechToText();
  bool _initialized = false;
  void Function(String? error)? _onError;

  bool get isAvailable => _initialized;

  /// آماده‌سازی سرویس — اگر دستگاه پشتیبانی نکند false برمی‌گرداند
  Future<bool> initialize({void Function(String? error)? onError}) async {
    if (_initialized) return true;
    try {
      _initialized = await _stt.initialize(
        onError: (error) => _onError?.call(error.errorMsg),
      );
    } catch (_) {
      _initialized = false;
    }
    return _initialized;
  }

  /// شروع ضبط — نتایج جزئی و نهایی از طریق onResult می‌آیند
  Future<void> start({
    required void Function(String text) onResult,
    required void Function(String? error) onError,
  }) async {
    _onError = onError;
    try {
      await _stt.listen(
        onResult: (result) {
          final text = result.recognizedWords.trim();
          if (text.isNotEmpty) onResult(text);
        },
      );
    } catch (_) {
      onError('سرویس گفتار در دسترس نیست');
    }
  }

  Future<void> stop() async {
    try {
      await _stt.stop();
    } catch (_) {}
  }

  Future<void> cancel() async {
    try {
      await _stt.cancel();
    } catch (_) {}
  }
}
