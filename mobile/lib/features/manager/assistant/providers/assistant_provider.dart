import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../warehouse_keeper/providers/warehouse_keeper_provider.dart';
import '../assistant_voice_service.dart';
import '../data/assistant_api_service.dart';
import '../models/assistant_message.dart';

final assistantApiServiceProvider = Provider<AssistantApiService>(
  (ref) => AssistantApiService(socket: ref.read(socketServiceProvider)),
);

final assistantVoiceServiceProvider = Provider(
  (ref) => AssistantVoiceService(),
);

/// وضعیت چت دستیار
class AssistantState {
  const AssistantState({
    this.messages = const [],
    this.isStreaming = false,
    this.streamedText = '',
    this.status = '',
    this.error,
  });

  final List<AssistantMessage> messages;
  final bool isStreaming;

  /// متن زنده‌ای که در حال دریافت است (حباب در حال تایپ)
  final String streamedText;

  /// وضعیت زندهٔ «فکر کردن» (reasoning مدل) — قبل از شروع پاسخ نمایش داده می‌شود
  final String status;
  final String? error;

  AssistantState copyWith({
    List<AssistantMessage>? messages,
    bool? isStreaming,
    String? streamedText,
    String? status,
    String? error,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      streamedText: streamedText ?? this.streamedText,
      status: status ?? this.status,
      error: error,
    );
  }
}

class AssistantNotifier extends Notifier<AssistantState> {
  @override
  AssistantState build() => const AssistantState();

  /// شروع چت جدید — گفتگو از اول پاک می‌شود
  void newChat() {
    state = const AssistantState();
  }

  Future<void> send(String rawText) async {
    final message = rawText.trim();
    if (message.isEmpty || state.isStreaming) return;

    // تاریخچه = ۱۲ پیام آخر پیش از پیام جاری؛ هر پیام کوتاه می‌شود تا context سبک بماند
    const maxHistoryChars = 1500;
    final previous = state.messages;
    final history = previous
        .where((m) => m.content.trim().isNotEmpty)
        .map(
          (m) => (
            role: m.role,
            content: m.content.length > maxHistoryChars
                ? '${m.content.substring(0, maxHistoryChars)}…'
                : m.content,
          ),
        )
        .toList()
        .reversed
        .take(12)
        .toList()
        .reversed
        .toList();

    state = state.copyWith(
      messages: [
        ...state.messages,
        AssistantMessage(
          role: 'user',
          content: message,
          createdAt: DateTime.now(),
        ),
      ],
      isStreaming: true,
      streamedText: '',
      status: '',
      error: null,
    );

    final api = ref.read(assistantApiServiceProvider);
    try {
      await api.ask(
        message: message,
        history: history,
        onToken: (text) {
          state = state.copyWith(streamedText: state.streamedText + text);
        },
        onStatus: (status) {
          state = state.copyWith(status: status);
        },
        onDone: (full) {
          state = state.copyWith(
            messages: [
              ...state.messages,
              AssistantMessage(
                role: 'assistant',
                content: full,
                createdAt: DateTime.now(),
              ),
            ],
            isStreaming: false,
            streamedText: '',
            status: '',
          );
        },
        onError: (error) {
          state = state.copyWith(
            isStreaming: false,
            streamedText: '',
            status: '',
            error: error,
          );
        },
      );
    } catch (e) {
      debugPrint('assistant send error: $e');
      state = state.copyWith(
        isStreaming: false,
        streamedText: '',
        status: '',
        error: 'خطا در ارتباط با دستیار',
      );
    }
  }
}

final assistantChatProvider =
    NotifierProvider<AssistantNotifier, AssistantState>(AssistantNotifier.new);
