import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/transactions/transaction_form.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Xmark;

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

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  IconBtn(
                    icon: Xmark(width: 16, height: 16, color: fg),
                    surface: surface,
                    border: border,
                    onTap: () => context.pop(),
                    size: 36,
                    radius: 10,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Edit transaction',
                        style: AppFonts.body(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            Expanded(
              child: TransactionForm(
                householdId: transaction.householdId,
                userId: transaction.userId,
                initialTransaction: transaction,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
