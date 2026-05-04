import 'package:hestia/core/config/flavor.dart';

/// Short delay on mock read paths so loading skeletons are visible in dev.
Future<void> mockReadLatency() async {
  if (!FlavorConfig.isMock) return;
  await Future<void>.delayed(const Duration(milliseconds: 420));
}
