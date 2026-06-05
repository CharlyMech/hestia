import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/app_version.dart';

abstract class AppVersionRepository {
  Future<(AppVersion?, Failure?)> getLatestVersion({
    String platform = 'ios',
  });
}
