import 'package:flutter/cupertino.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/data/mappers/transaction_mapper.dart';
import 'package:hestia/domain/entities/category.dart';
import 'package:hestia/domain/entities/shopping_session.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/shopping/template_sync_flow.dart';
import 'package:hestia/presentation/widgets/transactions/transaction_form.dart';

/// Shared finish/cancel flows for an active shopping session, reused by the
/// detail screen and the active-sessions cards.
///
/// On finish, in order: (1) maybe-update-template (from-template sessions),
/// (2) maybe-save-as-template (scratch sessions), (3) ask whether to record a
/// payment, then finish via `ShoppingSessionRepository.finishSession` (personal
/// → push-local-session; shared → finish-shopping-session). The caller refreshes
/// its bloc on a `true` return.
abstract final class FinishSessionFlow {
  static Future<bool> finish(
    BuildContext context, {
    required ShoppingSession session,
  }) async {
    final l10n = AppLocalizations.of(context);
    final userId = AppDependencies.instance.authRepository.currentUserId;
    if (userId == null) return false;

    // 1. From-template session diverged → offer to update the template.
    await TemplateSyncFlow.maybeSyncTemplate(context, session: session);
    if (!context.mounted) return false;

    // 2. Scratch session → offer to save it as a reusable template.
    if (session.templateId == null) {
      final save = await showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(l10n.shopping_saveAsTemplateTitle),
          content: Text(l10n.shopping_saveAsTemplateBody),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.shopping_saveAsTemplateNo),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.shopping_saveAsTemplateYes),
            ),
          ],
        ),
      );
      if (save == true) {
        await AppDependencies.instance.shoppingSessionRepository
            .saveAsTemplate(session: session, name: session.name);
      }
      if (!context.mounted) return false;
    }

    // 3. Ask whether to record a payment.
    final wantsTx = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.shopping_addTransactionTitle),
        content: Text(l10n.shopping_addTransactionBody),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.shopping_addTransactionNo),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.shopping_addTransactionYes),
          ),
        ],
      ),
    );
    if (wantsTx == null || !context.mounted) return false;

    if (!wantsTx) {
      await AppDependencies.instance.shoppingSessionRepository
          .finishSession(session: session, userId: userId);
      return true;
    }

    return _openTransactionSheet(context, session: session, userId: userId);
  }

  static Future<bool> _openTransactionSheet(
    BuildContext context, {
    required ShoppingSession session,
    required String userId,
  }) async {
    final deps = AppDependencies.instance;

    final (cats, _) = await deps.categoryRepository.getCategories(
      householdId: session.householdId,
    );
    Category? expenseCat;
    for (final c in cats) {
      if (c.type == TransactionType.expense) {
        expenseCat = c;
        break;
      }
    }
    expenseCat ??= cats.isNotEmpty ? cats.first : null;
    if (expenseCat == null || !context.mounted) return false;

    final (accounts, _) = await deps.bankAccountRepository.getBankAccounts(
      householdId: session.householdId,
      viewMode: ViewMode.personal,
      userId: userId,
    );
    final bankId = session.bankAccountId ??
        (accounts.isNotEmpty ? accounts.first.id : '');

    final now = DateTime.now();
    final initial = Transaction(
      id: '',
      householdId: session.householdId,
      userId: userId,
      categoryId: expenseCat.id,
      bankAccountId: bankId,
      transactionSourceId: session.transactionSourceId,
      amount: 0,
      type: TransactionType.expense,
      date: now,
      createdAt: now,
      lastUpdate: now,
    );

    if (!context.mounted) return false;
    var finished = false;
    await showAppBottomSheet<void>(
      context: context,
      title: AppLocalizations.of(context).shopping_finishSession,
      child: TransactionForm(
        householdId: session.householdId,
        userId: userId,
        initialTransaction: initial,
        onSubmitted: (tx) async {
          finished = true;
          final txJson = TransactionMapper.toDto(tx).toInsertJson();
          await AppDependencies.instance.shoppingSessionRepository.finishSession(
            session: session,
            userId: userId,
            transactionJson: txJson,
          );
        },
      ),
    );
    return finished;
  }

  /// Native confirm → cancel/delete the session.
  static Future<bool> delete(
    BuildContext context, {
    required ShoppingSession session,
  }) async {
    final l10n = AppLocalizations.of(context);
    final userId = AppDependencies.instance.authRepository.currentUserId;
    if (userId == null) return false;
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.shopping_deleteSessionTitle),
        content: Text(l10n.shopping_deleteSessionBody),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.common_cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );
    if (ok != true) return false;
    await AppDependencies.instance.shoppingSessionRepository
        .cancelSession(session: session, userId: userId);
    return true;
  }
}
