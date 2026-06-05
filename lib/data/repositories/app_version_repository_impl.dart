import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/services/app_version_service.dart';
import 'package:hestia/domain/entities/app_version.dart';
import 'package:hestia/domain/repositories/app_version_repository.dart';

class AppVersionRepositoryImpl implements AppVersionRepository {
  final AppVersionService _service;

  AppVersionRepositoryImpl(this._service);

  @override
  Future<(AppVersion?, Failure?)> getLatestVersion({
    String platform = 'ios',
  }) async {
    try {
      final data = await _service.getLatestVersion(platform: platform);
      if (data == null) return (null, null);

      final createdRaw = data['created_at'];
      final createdAt = createdRaw == null
          ? null
          : parseSupabaseTimestamp(createdRaw, orElse: DateTime.now());

      return (
        AppVersion(
          platform: (data['platform'] as String?) ?? platform,
          version: data['version'] as String,
          buildNumber: (data['build_number'] as num).toInt(),
          releaseTag: data['release_tag'] as String?,
          releaseNotes: data['release_notes'] as String?,
          testflightUrl: data['testflight_url'] as String?,
          isRequired: (data['is_required'] as bool?) ?? false,
          createdAt: createdAt,
        ),
        null,
      );
    } catch (e) {
      return (null, mapExceptionToFailure(e));
    }
  }
}
