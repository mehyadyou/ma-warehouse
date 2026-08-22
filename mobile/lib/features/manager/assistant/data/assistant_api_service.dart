import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/realtime/socket_service.dart';

/// یک قلم تاریخچه برای ارسال به سرور
typedef AssistantHistoryItem = ({String role, String content});

/// ارتباط با دستیار: استریم کامل روی سوکت (reasoning + پاسخ) + fallback SSE روی HTTP
class AssistantApiService {
  AssistantApiService({required SocketService socket}) : _socket = socket;

  final Dio _dio = DioClient().dio;
  final SocketService _socket;

  /// ارسال پیام؛ با رسیدن هر قطعه onToken، با هر به‌روزرسانی وضعیت onStatus،
  /// با پایان پاسخ onDone و با خطا onError صدا زده می‌شود.
  Future<void> ask({
    required String message,
    required List<AssistantHistoryItem> history,
    required void Function(String text) onToken,
    required void Function(String text) onStatus,
    required void Function(String fullText) onDone,
    required void Function(String error) onError,
  }) async {
    if (_socket.isConnected) {
      // شنونده‌های یک‌بارمصرف — بعد از done/error/timeout خودشان را پاک می‌کنند
      late final void Function(dynamic) onTokenEvent;
      late final void Function(dynamic) onStatusEvent;
      late final void Function(dynamic) onDoneEvent;
      late final void Function(dynamic) onErrorEvent;
      Timer? timeout;

      void cleanup() {
        timeout?.cancel();
        _socket.offEvent('assistant:token', onTokenEvent);
        _socket.offEvent('assistant:status', onStatusEvent);
        _socket.offEvent('assistant:done', onDoneEvent);
        _socket.offEvent('assistant:error', onErrorEvent);
      }

      onTokenEvent = (data) {
        final text = (data is Map) ? data['text'] as String? ?? '' : '';
        if (text.isNotEmpty) onToken(text);
      };

      onStatusEvent = (data) {
        final text = (data is Map) ? data['text'] as String? ?? '' : '';
        if (text.isNotEmpty) onStatus(text);
      };

      onDoneEvent = (data) {
        cleanup();
        final full = (data is Map) ? data['fullText'] as String? ?? '' : '';
        if (full.trim().isEmpty) {
          onError('پاسخی از دستیار دریافت نشد');
          return;
        }
        onDone(full);
      };

      onErrorEvent = (data) {
        cleanup();
        final error = (data is Map) ? data['error'] as String? ?? '' : '';
        onError(error.isEmpty ? 'خطای نامشخص از دستیار' : error);
      };

      // اگر سرور جواب ندهد، مکالمه‌اش برای همیشه آویزان نمی‌ماند
      timeout = Timer(const Duration(seconds: 120), () {
        cleanup();
        onError('پاسخ دستیار طول کشید؛ دوباره تلاش کنید');
      });

      try {
        _socket.on('assistant:token', onTokenEvent);
        _socket.on('assistant:status', onStatusEvent);
        _socket.on('assistant:done', onDoneEvent);
        _socket.on('assistant:error', onErrorEvent);
        _socket.emit('assistant:ask', {
          'message': message,
          'history': history
              .map((h) => {'role': h.role, 'content': h.content})
              .toList(),
        });
      } catch (_) {
        cleanup();
        onError('ارتباط با دستیار برقرار نشد؛ دوباره تلاش کنید');
      }
      return;
    }

    // fallback: سوکت وصل نیست → استریم SSE؛ اگر سرور روت استریم نداشت → پاسخ کامل JSON
    await _httpStream(message, history, onToken, onStatus, onDone, onError);
  }

  /// استریم روی HTTP (SSE) — هر رویداد یک خط `data: {json}` است:
  /// {type:'status'} | {type:'token'} | {type:'done'} | {type:'error'}
  Future<void> _httpStream(
    String message,
    List<AssistantHistoryItem> history,
    void Function(String text) onToken,
    void Function(String text) onStatus,
    void Function(String fullText) onDone,
    void Function(String error) onError,
  ) async {
    try {
      final response = await _dio.post<ResponseBody>(
        '/manager/assistant/chat/stream',
        data: {
          'message': message,
          'history': history
              .map((h) => {'role': h.role, 'content': h.content})
              .toList(),
        },
        options: Options(
          responseType: ResponseType.stream,
          // بین هر قطعه ریست می‌شود؛ استدلال طولانی قطع نمی‌شود
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      final stream = response.data?.stream;
      if (stream == null) {
        onError('پاسخی از دستیار دریافت نشد');
        return;
      }

      var doneText = '';
      await for (final line
          in utf8.decoder.bind(stream).transform(const LineSplitter())) {
        if (!line.startsWith('data: ')) continue;
        final payload = line.substring(6).trim();
        if (payload.isEmpty) continue;
        Map<String, dynamic>? evt;
        try {
          final decoded = jsonDecode(payload);
          evt = (decoded is Map) ? Map<String, dynamic>.from(decoded) : null;
        } catch (_) {
          evt = null;
        }
        switch (evt?['type'] as String?) {
          case 'token':
            final t = evt?['text'] as String? ?? '';
            if (t.isNotEmpty) onToken(t);
            break;
          case 'status':
            final s = evt?['text'] as String? ?? '';
            if (s.isNotEmpty) onStatus(s);
            break;
          case 'done':
            doneText = evt?['fullText'] as String? ?? '';
            break;
          case 'error':
            onError(evt?['error'] as String? ?? 'خطای نامشخص از دستیار');
            return;
        }
      }

      if (doneText.trim().isNotEmpty) {
        onDone(doneText);
        return;
      }
      onError('پاسخ دستیار ناقص رسید؛ دوباره تلاش کنید');
    } catch (e) {
      // روت استریم در دسترس نیست (نسخهٔ قدیمی سرور) یا خطای شبکه → پاسخ کامل
      await _httpJson(message, history, onToken, onDone, onError);
    }
  }

  /// پاسخ کامل با JSON — آخرین fallback
  Future<void> _httpJson(
    String message,
    List<AssistantHistoryItem> history,
    void Function(String text) onToken,
    void Function(String fullText) onDone,
    void Function(String error) onError,
  ) async {
    try {
      final response = await _dio.post(
        '/manager/assistant/chat',
        data: {
          'message': message,
          'history': history
              .map((h) => {'role': h.role, 'content': h.content})
              .toList(),
        },
      );
      final answer = response.data?['answer'] as String? ?? '';
      if (answer.isEmpty) {
        onError('پاسخی از دستیار دریافت نشد');
        return;
      }
      onToken(answer);
      onDone(answer);
    } catch (e) {
      onError(friendlyError(e));
    }
  }
}
