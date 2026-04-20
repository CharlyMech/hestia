class NotificationDto {
  final String id;
  final String userId;
  final String householdId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic>? payload;
  final bool isRead;
  final int createdAt;

  const NotificationDto({
    required this.id,
    required this.userId,
    required this.householdId,
    required this.title,
    required this.body,
    required this.type,
    this.payload,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      householdId: json['household_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      payload: json['payload'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as int,
    );
  }
}
