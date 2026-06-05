import 'package:equatable/equatable.dart';
import 'package:hestia/core/constants/enums.dart';

class FinancialInstitution extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String country;
  final String brandColor;
  final String? logoAsset;
  final InstitutionType institutionType;
  final bool isCustom;

  const FinancialInstitution({
    required this.id,
    required this.name,
    required this.slug,
    this.country = '',
    required this.brandColor,
    this.logoAsset,
    this.institutionType = InstitutionType.bank,
    this.isCustom = false,
  });

  @override
  List<Object?> get props => [id, slug];
}
