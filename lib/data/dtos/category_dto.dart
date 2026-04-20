class CategoryDto {
  final String id;
  final String householdId;
  final String name;
  final String type;
  final String? color;
  final String? icon;
  final bool isActive;
  final int sortOrder;
  final int createdAt;
  final int lastUpdate;

  const CategoryDto({
    required this.id,
    required this.householdId,
    required this.name,
    required this.type,
    this.color,
    this.icon,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    required this.lastUpdate,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] as int,
      lastUpdate: json['last_update'] as int,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'household_id': householdId,
        'name': name,
        'type': type,
        'color': color,
        'icon': icon,
        'is_active': isActive,
        'sort_order': sortOrder,
      };

  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'type': type,
        'color': color,
        'icon': icon,
        'is_active': isActive,
        'sort_order': sortOrder,
        'last_update': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };
}
