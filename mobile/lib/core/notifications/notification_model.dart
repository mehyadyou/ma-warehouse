class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final Map<String, dynamic>? data;
  final String? role;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type = 'general',
    DateTime? createdAt,
    this.data,
    this.role,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'info',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      data: json['data'] is Map<String, dynamic> ? Map<String, dynamic>.from(json['data'] as Map) : null,
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
