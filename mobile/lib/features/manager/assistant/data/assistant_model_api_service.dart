import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

/// پیکربندی فعلی مدل دستیار — نمای عمومی (کلید کامل هرگز برنمی‌گردد)
class AssistantModelConfig {
  final String? name;
  final String baseUrl;
  final String model;
  final int maxTokens;
  final bool thinking;
  final bool fromDb;
  final bool hasApiKey;
  final String? apiKeyTail;

  const AssistantModelConfig({
    this.name,
    required this.baseUrl,
    required this.model,
    required this.maxTokens,
    required this.thinking,
    required this.fromDb,
    required this.hasApiKey,
    this.apiKeyTail,
  });

  factory AssistantModelConfig.fromJson(Map<String, dynamic> json) {
    return AssistantModelConfig(
      name: json['name'] as String?,
      baseUrl: (json['baseUrl'] as String?) ?? '',
      model: (json['model'] as String?) ?? '',
      maxTokens: ((json['maxTokens'] as num?) ?? 8000).toInt(),
      thinking: (json['thinking'] as bool?) ?? true,
      fromDb: (json['fromDb'] as bool?) ?? false,
      hasApiKey: (json['hasApiKey'] as bool?) ?? false,
      apiKeyTail: json['apiKeyTail'] as String?,
    );
  }

  Map<String, dynamic> toPayload({
    String? apiKey,
    bool includeApiKey = false,
  }) {
    return {
      if (name != null && name!.trim().isNotEmpty) 'name': name!.trim(),
      'baseUrl': baseUrl.trim(),
      'model': model.trim(),
      'maxTokens': maxTokens,
      'thinking': thinking,
      if (includeApiKey && apiKey != null && apiKey.trim().isNotEmpty)
        'apiKey': apiKey.trim(),
    };
  }
}

/// ارتباط با پیکربندی مدل دستیار (فقط مدیر) — /manager/assistant/config
class AssistantModelApiService {
  final Dio _dio = DioClient().dio;

  Future<AssistantModelConfig> getConfig() async {
    final response = await _dio.get('/manager/assistant/config');
    return AssistantModelConfig.fromJson(
      Map<String, dynamic>.from(response.data['config'] as Map),
    );
  }

  Future<AssistantModelConfig> saveConfig({
    required AssistantModelConfig config,
    String? apiKey,
  }) async {
    final response = await _dio.put(
      '/manager/assistant/config',
      data: config.toPayload(apiKey: apiKey, includeApiKey: true),
    );
    return AssistantModelConfig.fromJson(
      Map<String, dynamic>.from(response.data['config'] as Map),
    );
  }

  /// حذف ردیف اختصاصی → بازگشت به env/پیش‌فرض
  Future<AssistantModelConfig> resetConfig() async {
    final response = await _dio.delete('/manager/assistant/config');
    return AssistantModelConfig.fromJson(
      Map<String, dynamic>.from(response.data['config'] as Map),
    );
  }

  /// تست اتصال به مدل با مقادیر فعلی فرم (بدون ذخیره)
  Future<({bool ok, String model, int latencyMs})> testConfig({
    required AssistantModelConfig config,
    String? apiKey,
  }) async {
    final response = await _dio.post(
      '/manager/assistant/config/test',
      data: config.toPayload(apiKey: apiKey, includeApiKey: true),
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    return (
      ok: (data['ok'] as bool?) ?? false,
      model: (data['model'] as String?) ?? config.model,
      latencyMs: ((data['latencyMs'] as num?) ?? 0).toInt(),
    );
  }
}
