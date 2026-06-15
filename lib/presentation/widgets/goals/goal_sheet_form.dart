import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/constants/themes.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/financial_goal.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/presentation/blocs/goals/goals_bloc.dart';
import 'package:hestia/presentation/widgets/common/app_toast.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/primary_button.dart';

/// Reusable goal form. Opens inside `showAppBottomSheet` from goals screen,
/// money source detail, or anywhere else. Handles create/edit/delete via the
/// surrounding [GoalsBloc] (must be provided in context).
class GoalSheetForm extends StatefulWidget {
  final FinancialGoal? existing;
  final String householdId;
  final String userId;
  final String? prefilledBankAccountId;
  final List<BankAccount> bankAccounts;

  const GoalSheetForm({
    super.key,
    this.existing,
    required this.householdId,
    required this.userId,
    this.prefilledBankAccountId,
    required this.bankAccounts,
  });

  @override
  State<GoalSheetForm> createState() => _GoalSheetFormState();
}

class _GoalSheetFormState extends State<GoalSheetForm> {
  late final TextEditingController _name;
  late final TextEditingController _target;
  late final TextEditingController _monthly;
  late GoalScope _scope;
  late GoalType _type;
  late int _colorIdx;
  String? _moneySourceId;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    _name = TextEditingController(text: g?.name ?? '');
    _target = TextEditingController(
      text: g?.targetAmount?.toStringAsFixed(0) ?? '',
    );
    _monthly = TextEditingController(
      text: g?.monthlyTarget?.toStringAsFixed(0) ?? '',
    );
    _scope = g?.scope ?? GoalScope.household;
    _type = g?.goalType ?? GoalType.reachTarget;
    _colorIdx = 0;
    _moneySourceId = g?.bankAccountId ?? widget.prefilledBankAccountId;
    _deadline = g?.endDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _monthly.dispose();
    super.dispose();
  }

  List<Color> _swatches(MyTheme theme) {
    final tints = theme.categoryTints
        .map((h) => hexToColor(h))
        .toList();
    return [
      hexToColor(theme.primaryColor),
      hexToColor(theme.colorGreen),
      ...tints,
      hexToColor(theme.colorRed),
    ];
  }

  Future<void> _pickDeadline(BuildContext context) async {
    final theme = context.myTheme;
    final surface =
        hexToColor(theme.surfaceColor);
    DateTime tmp = _deadline ?? DateTime.now().add(const Duration(days: 90));
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: surface,
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedButton(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: tmp,
                minimumDate: DateTime.now(),
                onDateTimeChanged: (d) => tmp = d,
              ),
            ),
          ],
        ),
      ),
    );
    if (mounted) setState(() => _deadline = tmp);
  }

  Future<void> _pickMoneySource(BuildContext context) async {
    final theme = context.myTheme;
    final surface =
        hexToColor(theme.surfaceColor);
    final fg =
        hexToColor(theme.onBackgroundColor);
    final accent =
        hexToColor(theme.primaryColor);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        color: surface,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final ms in widget.bankAccounts)
                AnimatedButton(
                  onTap: () {
                    setState(() => _moneySourceId = ms.id);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    ms.name,
                    style: AppFonts.body(
                      fontSize: 15,
                      fontWeight: ms.id == _moneySourceId
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: ms.id == _moneySourceId ? accent : fg,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final theme = context.myTheme;
    final swatches = _swatches(theme);
    final hex =
        '#${swatches[_colorIdx].toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    final target = double.tryParse(_target.text.replaceAll(',', '.'));
    final monthly = double.tryParse(_monthly.text.replaceAll(',', '.'));
    final now = DateTime.now();

    if (widget.existing == null) {
      final goal = FinancialGoal(
        id: '',
        householdId: widget.householdId,
        scope: _scope,
        ownerId: _scope == GoalScope.personal ? widget.userId : null,
        bankAccountId: _moneySourceId,
        name: name,
        goalType: _type,
        targetAmount: target,
        monthlyTarget: monthly,
        color: hex,
        startDate: now,
        endDate: _deadline,
        createdAt: now,
        lastUpdate: now,
      );
      context.read<GoalsBloc>().add(GoalsCreate(goal));
      context.showToast(
          const AppToastConfig(type: ToastType.success, title: 'Goal created'));
    } else {
      final g = widget.existing!;
      final updated = g.copyWith(
        name: name,
        scope: _scope,
        goalType: _type,
        bankAccountId: _moneySourceId,
        clearMoneySource: _moneySourceId == null,
        targetAmount: target,
        clearTargetAmount: target == null,
        monthlyTarget: monthly,
        clearMonthlyTarget: monthly == null,
        color: hex,
        endDate: _deadline,
        clearEndDate: _deadline == null,
        lastUpdate: now,
      );
      context.read<GoalsBloc>().add(GoalsUpdate(updated));
      context.showToast(
          const AppToastConfig(type: ToastType.success, title: 'Goal updated'));
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete goal'),
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
    if (ok == true && mounted) {
      context.read<GoalsBloc>().add(GoalsDelete(widget.existing!.id));
      context.showToast(
          const AppToastConfig(type: ToastType.neutral, title: 'Goal deleted'));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final surface =
        hexToColor(theme.surfaceColor);
    final border =
        hexToColor(theme.borderColor);
    final fg =
        hexToColor(theme.onBackgroundColor);
    final muted =
        hexToColor(theme.onInactiveColor);
    final accent =
        hexToColor(theme.primaryColor);
    final swatches = _swatches(theme);

    final selectedSource =
        widget.bankAccounts.where((ms) => ms.id == _moneySourceId).firstOrNull;
    final isEdit = widget.existing != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          _label('Name', muted),
          _input(
            controller: _name,
            placeholder: 'e.g. Summer trip',
            surface: surface,
            border: border,
            fg: fg,
          ),
          _label('Scope', muted),
          SegmentedControl(
            options: const ['Personal', 'Household'],
            active: _scope == GoalScope.personal ? 0 : 1,
            onChanged: (i) => setState(() =>
                _scope = i == 0 ? GoalScope.personal : GoalScope.household),
            surface: surface,
            border: border,
            fg: fg,
            muted: muted,
            activeColor: accent,
            activeFg: CupertinoColors.white,
          ),
          _label('Goal type', muted),
          SegmentedControl(
            options: const ['Reach', 'Save monthly', 'Reduce'],
            active: switch (_type) {
              GoalType.reachTarget => 0,
              GoalType.saveMonthly => 1,
              GoalType.reduceSpending => 2,
              GoalType.custom => 0,
            },
            onChanged: (i) => setState(() {
              _type = switch (i) {
                0 => GoalType.reachTarget,
                1 => GoalType.saveMonthly,
                _ => GoalType.reduceSpending,
              };
            }),
            surface: surface,
            border: border,
            fg: fg,
            muted: muted,
          ),
          if (_type != GoalType.saveMonthly) ...[
            _label('Target amount', muted),
            _input(
              controller: _target,
              placeholder: '0',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              surface: surface,
              border: border,
              fg: fg,
              trailing: 'EUR',
              muted: muted,
            ),
          ],
          if (_type == GoalType.saveMonthly) ...[
            _label('Monthly target', muted),
            _input(
              controller: _monthly,
              placeholder: '0',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              surface: surface,
              border: border,
              fg: fg,
              trailing: 'EUR',
              muted: muted,
            ),
          ],
          _label('Deadline', muted),
          GestureDetector(
            onTap: () => _pickDeadline(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Text(
                _deadline == null
                    ? 'No deadline'
                    : '${_deadline!.day} ${_monthName(_deadline!.month)} ${_deadline!.year}',
                style: AppFonts.body(fontSize: 14, color: fg),
              ),
            ),
          ),
          _label('Linked account', muted),
          GestureDetector(
            onTap: widget.bankAccounts.isEmpty
                ? null
                : () => _pickMoneySource(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Text(
                selectedSource?.name ?? 'None',
                style: AppFonts.body(fontSize: 14, color: fg),
              ),
            ),
          ),
          _label('Color', muted),
          ColorSwatchRow(
            colors: swatches,
            selected: _colorIdx,
            onSelected: (i) => setState(() => _colorIdx = i),
            bg: surface,
          ),
          const SizedBox(height: 4),
          Row(
            spacing: 10,
            children: [
              if (isEdit)
                Expanded(
                  child: AnimatedButton(
                    onTap: _confirmDelete,
                    child: Text(
                      'Delete',
                      style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: hexToColor(
                            theme.colorRed),
                      ),
                    ),
                  ),
                ),
              Expanded(
                flex: isEdit ? 1 : 2,
                child: PrimaryButton(
                  label: isEdit ? 'Save' : 'Create goal',
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String t, Color muted) =>
      Text(t.toUpperCase(), style: AppFonts.sectionLabel(color: muted));

  Widget _input({
    required TextEditingController controller,
    required String placeholder,
    required Color surface,
    required Color border,
    required Color fg,
    Color? muted,
    String? trailing,
    TextInputType? keyboardType,
  }) {
    return FTextField(
      controller: controller,
      hint: placeholder,
      keyboardType: keyboardType,
      textCapitalization:
          (keyboardType == null || keyboardType == TextInputType.text)
              ? TextCapitalization.sentences
              : TextCapitalization.none,
      suffix: (trailing != null && muted != null)
          ? Text(trailing, style: AppFonts.body(fontSize: 12, color: muted))
          : null,
    );
  }

  String _monthName(int m) {
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
    return months[m - 1];
  }
}
