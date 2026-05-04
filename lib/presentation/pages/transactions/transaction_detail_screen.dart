import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/transactions/transaction_form.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show EditPencil, Trash;

/// Read-only transaction detail. FButton at the bottom opens [TransactionForm]
/// in a bottom sheet for edits; trash icon confirms delete via Cupertino dialog.
class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;
  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late Transaction _tx;

  @override
  void initState() {
    super.initState();
    _tx = widget.transaction;
  }

  Future<void> _openEditSheet() async {
    await showAppBottomSheet<void>(
      context: context,
      title: 'Edit transaction',
      heightFactor: 0.92,
      expand: true,
      child: TransactionForm(
        householdId: _tx.householdId,
        userId: _tx.userId,
        initialTransaction: _tx,
      ),
    );
    // Refetch to reflect any changes.
    final (txs, _) =
        await AppDependencies.instance.transactionRepository.getTransactions(
      householdId: _tx.householdId,
      viewMode: ViewMode.household,
      userId: _tx.userId,
      limit: 200,
    );
    final updated = txs.where((t) => t.id == _tx.id).firstOrNull;
    if (!mounted || updated == null) return;
    setState(() => _tx = updated);
  }

  Future<void> _confirmDelete() async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete transaction'),
        content: const Text('This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await AppDependencies.instance.transactionRepository
        .deleteTransaction(_tx.id);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final income = _c(theme.colorGreen);
    final expense = _c(theme.colorRed);

    final isIncome = _tx.type == TransactionType.income;
    final tintColor = isIncome ? income : expense;
    final sign = isIncome ? '+' : '−';

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      borderColor: border,
      foregroundColor: fg,
      titleText: 'Transaction',
      trailing: IconBtn(
        icon: Trash(width: 16, height: 16, color: expense),
        surface: surface,
        border: border,
        onTap: _confirmDelete,
        size: 36,
        radius: AppRadii.lg,
      ),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
                  // Amount headline
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surface,
                      border: Border.all(color: border, width: 1),
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                    ),
                    child: Column(
                      spacing: 6,
                      children: [
                        Text(
                          isIncome ? 'Income' : 'Expense',
                          style: AppFonts.body(fontSize: 12, color: muted),
                        ),
                        Text(
                          '$sign${_tx.amount.abs().toStringAsFixed(2)}',
                          style: AppFonts.numeric(
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            color: tintColor,
                          ),
                        ),
                        Text(
                          _tx.note ?? _tx.categoryName ?? 'Transaction',
                          style: AppFonts.body(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: fg,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Field rows
                  _DetailCard(
                    surface: surface,
                    border: border,
                    rows: [
                      _Row('Category', _tx.categoryName ?? '—'),
                      _Row('Account', _tx.bankAccountName ?? '—'),
                      if (_tx.transactionSourceName != null)
                        _Row('Source', _tx.transactionSourceName!),
                      _Row('Date', _fmtDate(_tx.date)),
                      if (_tx.userName != null) _Row('By', _tx.userName!),
                      if (_tx.isRecurring) const _Row('Recurring', 'Yes'),
                      if (_tx.note != null && _tx.note!.isNotEmpty)
                        _Row('Note', _tx.note!),
                    ],
                    fg: fg,
                    muted: muted,
                  ),

                  const SizedBox(height: 24),
                  FButton(
                    onPress: _openEditSheet,
                    prefix: EditPencil(
                      width: 16,
                      height: 16,
                      color: CupertinoColors.white,
                    ),
                    label: const Text('Edit transaction'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Updated ${_fmtDate(_tx.lastUpdate)}',
                    textAlign: TextAlign.center,
                    style: AppFonts.body(fontSize: 11, color: muted),
                  ),
                ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Row {
  final String label;
  final String value;
  const _Row(this.label, this.value);
}

class _DetailCard extends StatelessWidget {
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final List<_Row> rows;

  const _DetailCard({
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: i < rows.length - 1
                    ? Border(bottom: BorderSide(color: border, width: 1))
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rows[i].label,
                      style: AppFonts.body(fontSize: 13, color: muted),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      rows[i].value,
                      textAlign: TextAlign.right,
                      style: AppFonts.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: fg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
