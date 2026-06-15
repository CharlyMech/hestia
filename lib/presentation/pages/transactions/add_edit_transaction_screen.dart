import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/presentation/widgets/layout/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/transactions/transaction_form.dart';

/// Full-screen wrapper for editing a transaction. The "+" entry on the
/// dashboard uses [TransactionForm] inside a bottom sheet instead.
class AddEditTransactionScreen extends StatelessWidget {
  final Transaction transaction;

  const AddEditTransactionScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.onBackgroundColor);

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: 'Edit transaction',
      child: TransactionForm(
        householdId: transaction.householdId,
        userId: transaction.userId,
        initialTransaction: transaction,
      ),
    );
  }
}
