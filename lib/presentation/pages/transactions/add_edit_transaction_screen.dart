import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/transactions/transaction_form.dart';

/// Full-screen wrapper for editing a transaction. The "+" entry on the
/// dashboard uses [TransactionForm] inside a bottom sheet instead.
class AddEditTransactionScreen extends StatelessWidget {
  final Transaction transaction;

  const AddEditTransactionScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);

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

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
