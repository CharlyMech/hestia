import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_update_launcher.dart';
import 'package:hestia/domain/entities/app_version.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';

/// Warns the user that a newer build is available on TestFlight and offers to
/// open it. For required updates the dismiss action is hidden.
Future<void> showAppUpdateDialog(
  BuildContext context,
  AppVersion latest,
) async {
  final l10n = AppLocalizations.of(context);
  final notes = latest.releaseNotes?.trim();

  await showCupertinoDialog<void>(
    context: context,
    barrierDismissible: !latest.isRequired,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text(l10n.update_title),
      content: Text(
        notes == null || notes.isEmpty
            ? l10n.update_message(latest.version)
            : '${l10n.update_message(latest.version)}\n\n$notes',
      ),
      actions: [
        if (!latest.isRequired)
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.update_later),
          ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () async {
            if (!latest.isRequired) Navigator.of(ctx).pop();
            await AppUpdateLauncher.open(latest);
          },
          child: Text(l10n.update_action),
        ),
      ],
    ),
  );
}
