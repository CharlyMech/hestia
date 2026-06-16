import 'package:flutter/cupertino.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/domain/entities/shopping_list_item.dart';
import 'package:hestia/domain/entities/shopping_session.dart';
import 'package:hestia/domain/entities/shopping_session_item.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';

/// When a session was started from a template and its items diverged from the
/// template (added/removed/renamed/qty/order — ignoring checked state), offer
/// to update the template to match the session.
abstract final class TemplateSyncFlow {
  static Future<void> maybeSyncTemplate(
    BuildContext context, {
    required ShoppingSession session,
  }) async {
    final templateId = session.templateId;
    if (templateId == null) return;

    final listRepo = AppDependencies.instance.shoppingRepository;
    final sessionRepo = AppDependencies.instance.shoppingSessionRepository;
    final (sessionItems, _) =
        await sessionRepo.getItems(sessionId: session.id, scope: session.scope);
    final (templateItems, _) = await listRepo.getItems(templateId);

    if (!_differs(sessionItems, templateItems)) return;
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);
    final update = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.shopping_updateTemplateTitle),
        content: Text(l10n.shopping_updateTemplateBody),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.shopping_updateTemplateNo),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.shopping_updateTemplateYes),
          ),
        ],
      ),
    );
    if (update != true) return;

    // Overwrite the template's items to mirror the session (name, qty, order).
    for (final t in templateItems) {
      await listRepo.deleteItem(t.id);
    }
    final now = DateTime.now();
    var order = 0;
    for (final s in sessionItems) {
      await listRepo.createItem(ShoppingListItem(
        id: '',
        listId: templateId,
        name: s.name,
        qty: s.qty,
        sortOrder: order++,
        createdAt: now,
        lastUpdate: now,
      ));
    }
  }

  /// Compares item sets by name + qty + order, ignoring checked state.
  static bool _differs(
    List<ShoppingSessionItem> session,
    List<ShoppingListItem> template,
  ) {
    if (session.length != template.length) return true;
    final s = [...session]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final t = [...template]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    for (var i = 0; i < s.length; i++) {
      if (s[i].name.trim().toLowerCase() != t[i].name.trim().toLowerCase() ||
          s[i].qty != t[i].qty) {
        return true;
      }
    }
    return false;
  }
}
