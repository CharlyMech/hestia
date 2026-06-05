import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/utils/app_info.dart';
import 'package:hestia/domain/entities/app_version.dart';
import 'package:hestia/domain/repositories/app_version_repository.dart';

enum AppUpdateStatus {
  initial,
  checking,
  upToDate,
  updateAvailable,
  error,
}

class AppUpdateState extends Equatable {
  final AppUpdateStatus status;
  final AppVersion? latest;
  final String? message;
  final bool dialogShown;

  const AppUpdateState({
    this.status = AppUpdateStatus.initial,
    this.latest,
    this.message,
    this.dialogShown = false,
  });

  bool get hasUpdate => status == AppUpdateStatus.updateAvailable;

  AppUpdateState copyWith({
    AppUpdateStatus? status,
    AppVersion? latest,
    String? message,
    bool? dialogShown,
  }) {
    return AppUpdateState(
      status: status ?? this.status,
      latest: latest ?? this.latest,
      message: message ?? this.message,
      dialogShown: dialogShown ?? this.dialogShown,
    );
  }

  @override
  List<Object?> get props => [status, latest, message, dialogShown];
}

class AppUpdateCubit extends Cubit<AppUpdateState> {
  final AppVersionRepository _repository;

  AppUpdateCubit(this._repository) : super(const AppUpdateState());

  Future<void> checkForUpdates() async {
    if (state.status == AppUpdateStatus.checking) return;
    emit(const AppUpdateState(status: AppUpdateStatus.checking));

    final (latest, failure) =
        await _repository.getLatestVersion(platform: 'ios');
    if (failure != null) {
      emit(AppUpdateState(
        status: AppUpdateStatus.error,
        message: failure.message,
      ));
      return;
    }
    if (latest == null || !_isNewerThanCurrent(latest)) {
      emit(const AppUpdateState(status: AppUpdateStatus.upToDate));
      return;
    }

    emit(AppUpdateState(
      status: AppUpdateStatus.updateAvailable,
      latest: latest,
    ));
  }

  void markDialogShown() {
    if (!state.hasUpdate || state.dialogShown) return;
    emit(state.copyWith(dialogShown: true));
  }

  bool _isNewerThanCurrent(AppVersion latest) {
    final currentVersion = AppInfo.version;
    if (currentVersion.isEmpty) return false;

    final semverCompare = _compareSemver(latest.version, currentVersion);
    if (semverCompare > 0) return true;
    if (semverCompare < 0) return false;

    final currentBuild = int.tryParse(AppInfo.buildNumber) ?? 0;
    return latest.buildNumber > currentBuild;
  }

  int _compareSemver(String left, String right) {
    final a = _parseSemver(left);
    final b = _parseSemver(right);
    for (var i = 0; i < 3; i++) {
      if (a[i] != b[i]) return a[i].compareTo(b[i]);
    }
    return 0;
  }

  List<int> _parseSemver(String value) {
    final core = value.split('+').first;
    final parts = core.split('.');
    return List<int>.generate(3, (index) {
      if (index >= parts.length) return 0;
      return int.tryParse(parts[index]) ?? 0;
    });
  }
}
