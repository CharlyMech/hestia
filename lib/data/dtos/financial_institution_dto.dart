class FinancialInstitutionDto {
  final String id;
  final String name;
  final String slug;
  final String country;
  final String brandColor;
  final String? logoAsset;
  final String institutionType;
  final bool isCustom;
  final int createdAt;
  final int lastUpdate;

  const FinancialInstitutionDto({
    required this.id,
    required this.name,
    required this.slug,
    this.country = '',
    required this.brandColor,
    this.logoAsset,
    this.institutionType = 'bank',
    this.isCustom = false,
    required this.createdAt,
    required this.lastUpdate,
  });

  factory FinancialInstitutionDto.fromJson(Map<String, dynamic> json) {
    return FinancialInstitutionDto(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      country: json['country'] as String? ?? '',
      brandColor: json['brand_color'] as String,
      logoAsset: json['logo_asset'] as String?,
      institutionType: json['institution_type'] as String? ?? 'bank',
      isCustom: json['is_custom'] as bool? ?? false,
      createdAt: json['created_at'] as int,
      lastUpdate: json['last_update'] as int,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'name': name,
        'slug': slug,
        'country': country,
        'brand_color': brandColor,
        'logo_asset': logoAsset,
        'institution_type': institutionType,
        'is_custom': isCustom,
        'created_at': createdAt,
        'last_update': lastUpdate,
      };

  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'country': country,
        'brand_color': brandColor,
        'logo_asset': logoAsset,
        'institution_type': institutionType,
        'last_update': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };
}
