import 'package:equatable/equatable.dart';

class AppVersion extends Equatable {
  final String platform;
  final String version;
  final int buildNumber;
  final String? releaseTag;
  final String? releaseNotes;
  final String? testflightUrl;
  final bool isRequired;
  final DateTime? createdAt;

  const AppVersion({
    required this.platform,
    required this.version,
    required this.buildNumber,
    this.releaseTag,
    this.releaseNotes,
    this.testflightUrl,
    this.isRequired = false,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        platform,
        version,
        buildNumber,
        releaseTag,
        releaseNotes,
        testflightUrl,
        isRequired,
        createdAt,
      ];
}
