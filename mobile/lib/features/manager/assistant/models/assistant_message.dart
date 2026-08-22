import 'package:freezed_annotation/freezed_annotation.dart';

part 'assistant_message.freezed.dart';

@freezed
abstract class AssistantMessage with _$AssistantMessage {
  const factory AssistantMessage({
    /// 'user' | 'assistant'
    required String role,
    required String content,
    required DateTime createdAt,
  }) = _AssistantMessage;
}
