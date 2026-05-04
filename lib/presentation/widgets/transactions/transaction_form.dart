import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/category.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/domain/entities/transaction_source.dart';
import 'package:hestia/presentation/blocs/transaction_form/transaction_form_bloc.dart';
import 'package:hestia/presentation/blocs/transaction_form/transaction_form_event.dart';
import 'package:hestia/presentation/blocs/transaction_form/transaction_form_state.dart';
import 'package:hestia/presentation/blocs/transaction_sources/transaction_sources_bloc.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/toggle_switch.dart';
import 'package:hestia/presentation/widgets/transaction_sources/transaction_source_form.dart';
import 'package:hestia/presentation/widgets/transactions/pickers/bank_account_picker.dart';
import 'package:hestia/presentation/widgets/transactions/pickers/category_picker.dart';
import 'package:hestia/presentation/widgets/transactions/pickers/date_picker.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Cart, CreditCard, Calendar, Refresh, EditPencil, Trash, Shop, Plus;
import 'package:intl/intl.dart';

class TransactionForm extends StatefulWidget {
  final String householdId;
  final String userId;
  final Transaction? initialTransaction;
  final VoidCallback? onClose;

  const TransactionForm({
    super.key,
    required this.householdId,
    required this.userId,
    this.initialTransaction,
    this.onClose,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;

  List<Category> _categories = const [];
  List<BankAccount> _bankAccounts = const [];
  List<TransactionSource> _txSources = const [];
  bool _loadingLookups = true;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTransaction;
    _amountCtrl = TextEditingController(
      text: t != null ? t.amount.toStringAsFixed(2) : '',
    );
    _noteCtrl = TextEditingController(text: t?.note ?? '');
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    final deps = AppDependencies.instance;
    final (cats, _) = await deps.categoryRepository.getCategories(
      householdId: widget.householdId,
    );
    final (accounts, _) = await deps.bankAccountRepository.getBankAccounts(
      householdId: widget.householdId,
      viewMode: ViewMode.personal,
      userId: widget.userId,
    );
    final (txSrcs, _) = await deps.transactionSourceRepository.getAll(
      householdId: widget.householdId,
    );
    if (!mounted) return;
    setState(() {
      _categories = cats;
      _bankAccounts = accounts;
      _txSources = txSrcs;
      _loadingLookups = false;
    });
  }

  Future<void> _reloadTransactionSources() async {
    final (txSrcs, _) =
        await AppDependencies.instance.transactionSourceRepository.getAll(
      householdId: widget.householdId,
    );
    if (!mounted) return;
    setState(() => _txSources = txSrcs);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionFormBloc(
        transactionRepository: AppDependencies.instance.transactionRepository,
        householdId: widget.householdId,
        userId: widget.userId,
        initialTransaction: widget.initialTransaction,
      ),
      child: _FormBody(
        amountCtrl: _amountCtrl,
        noteCtrl: _noteCtrl,
        categories: _categories,
        bankAccounts: _bankAccounts,
        txSources: _txSources,
        loadingLookups: _loadingLookups,
        isEditing: widget.initialTransaction != null,
        onClose: widget.onClose,
        householdId: widget.householdId,
        userId: widget.userId,
        onReloadTransactionSources: _reloadTransactionSources,
      ),
    );
  }
}

class _FormBody extends StatelessWidget {
  final TextEditingController amountCtrl;
  final TextEditingController noteCtrl;
  final List<Category> categories;
  final List<BankAccount> bankAccounts;
  final List<TransactionSource> txSources;
  final bool loadingLookups;
  final bool isEditing;
  final VoidCallback? onClose;
  final String householdId;
  final String userId;
  final Future<void> Function() onReloadTransactionSources;

  const _FormBody({
    required this.amountCtrl,
    required this.noteCtrl,
    required this.categories,
    required this.bankAccounts,
    required this.txSources,
    required this.loadingLookups,
    required this.isEditing,
    required this.onClose,
    required this.householdId,
    required this.userId,
    required this.onReloadTransactionSources,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final surface = _c(theme.surfaceColor);
    final surface2 = _c(theme.surface2Color);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final onPrimary = _c(theme.onPrimaryColor);
    final expense = _c(theme.colorRed);
    final income = _c(theme.colorGreen);
    final tints = theme.categoryTints.map(_c).toList();

    return BlocConsumer<TransactionFormBloc, TransactionFormState>(
      listener: (context, state) {
        if (state.status == TransactionFormStatus.success) {
          onClose?.call();
          Navigator.of(context).maybePop();
        }
      },
      builder: (context, state) {
        final bloc = context.read<TransactionFormBloc>();
        final isTransfer = state.kind == TransactionKind.transfer;
        final amountColor =
            state.kind == TransactionKind.income ? income : expense;
        final selectedCategory = categories
            .where((c) => c.id == state.categoryId)
            .firstOrNull;
        final selectedAccount =
            bankAccounts.where((s) => s.id == state.bankAccountId).firstOrNull;
        final selectedTo = bankAccounts
            .where((s) => s.id == state.toBankAccountId)
            .firstOrNull;
        final dateLabel = _formatDate(state.date);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedControl(
                options: const ['Expense', 'Income', 'Transfer'],
                active: state.kind.index,
                onChanged: (i) => bloc.add(
                  TransactionFormKindChanged(TransactionKind.values[i]),
                ),
                surface: surface,
                border: border,
                fg: fg,
                muted: muted,
                activeColor: surface2,
              ),
              const SizedBox(height: 24),
              Text('AMOUNT · EUR',
                  style: AppFonts.sectionLabel(color: muted)),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: amountCtrl,
                placeholder: '0.00',
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: false),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                textAlign: TextAlign.center,
                style: AppFonts.numeric(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
                placeholderStyle: AppFonts.numeric(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: amountColor.withValues(alpha: 0.35),
                ),
                decoration: const BoxDecoration(),
                onChanged: (v) => bloc.add(TransactionFormAmountChanged(v)),
              ),
              if (state.errors['amount'] != null)
                _ErrorLine(text: state.errors['amount']!, color: expense),
              const SizedBox(height: 12),
              if (loadingLookups)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CupertinoActivityIndicator(),
                )
              else ...[
                if (!isTransfer)
                  _PickerTile(
                    icon: Cart(width: 18, height: 18, color: tints[0]),
                    iconColor: tints[0],
                    label: 'Category',
                    value: selectedCategory?.name ?? 'Select',
                    sub: selectedCategory?.type.name,
                    error: state.errors['category'],
                    errorColor: expense,
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                    onTap: () => _openCategoryPicker(context, bloc, state),
                  ),
                if (!isTransfer) const SizedBox(height: 8),
                _PickerTile(
                  icon:
                      CreditCard(width: 18, height: 18, color: tints[2]),
                  iconColor: tints[2],
                  label: isTransfer ? 'From account' : 'Bank account',
                  value: selectedAccount?.name ?? 'Select',
                  sub: selectedAccount == null
                      ? null
                      : 'Balance ${selectedAccount.currentBalance.toStringAsFixed(2)} ${selectedAccount.currency}',
                  error: state.errors[isTransfer ? 'from' : 'bankAccount'],
                  errorColor: expense,
                  surface: surface,
                  border: border,
                  fg: fg,
                  muted: muted,
                  onTap: () => _openBankAccountPicker(context, bloc, state, false),
                ),
                if (isTransfer) ...[
                  const SizedBox(height: 8),
                  _PickerTile(
                    icon: CreditCard(
                        width: 18, height: 18, color: tints[3]),
                    iconColor: tints[3],
                    label: 'To account',
                    value: selectedTo?.name ?? 'Select',
                    sub: selectedTo == null
                        ? null
                        : 'Balance ${selectedTo.currentBalance.toStringAsFixed(2)} ${selectedTo.currency}',
                    error: state.errors['to'],
                    errorColor: expense,
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                    onTap: () =>
                        _openBankAccountPicker(context, bloc, state, true),
                  ),
                ],
                if (!isTransfer) ...[
                  const SizedBox(height: 8),
                  _PickerTile(
                    icon: Shop(width: 18, height: 18, color: tints[5]),
                    iconColor: tints[5],
                    label: 'Source',
                    value: txSources
                            .where((s) => s.id == state.transactionSourceId)
                            .firstOrNull
                            ?.name ??
                        'Optional',
                    sub: state.transactionSourceId == null
                        ? 'Merchant, employer, service'
                        : null,
                    errorColor: expense,
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                    onTap: () => _openTransactionSourcePicker(
                      context,
                      bloc,
                      state,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _PickerTile(
                  icon: Calendar(width: 18, height: 18, color: tints[1]),
                  iconColor: tints[1],
                  label: 'Date',
                  value: dateLabel,
                  errorColor: expense,
                  surface: surface,
                  border: border,
                  fg: fg,
                  muted: muted,
                  onTap: () => _openDatePicker(context, bloc, state),
                ),
                if (!isTransfer) ...[
                  const SizedBox(height: 8),
                  _ToggleTile(
                    icon: Refresh(width: 18, height: 18, color: tints[4]),
                    iconColor: tints[4],
                    label: 'Repeat',
                    value: state.isRecurring ? 'Recurring' : 'One-time',
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                    accent: accent,
                    switchOn: state.isRecurring,
                    onChanged: (v) =>
                        bloc.add(TransactionFormRecurringToggled(v)),
                  ),
                ],
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border.all(color: border, width: 1),
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: EditPencil(
                            width: 16, height: 16, color: muted),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CupertinoTextField(
                          controller: noteCtrl,
                          placeholder: 'Add a note…',
                          maxLines: 3,
                          minLines: 1,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          style: AppFonts.body(fontSize: 13, color: fg),
                          placeholderStyle:
                              AppFonts.body(fontSize: 13, color: muted),
                          decoration: const BoxDecoration(),
                          onChanged: (v) =>
                              bloc.add(TransactionFormNoteChanged(v)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (state.failure != null)
                _ErrorLine(text: state.failure!.message, color: expense),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (isEditing)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: CupertinoButton(
                          color: surface,
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                          onPressed: state.status ==
                                  TransactionFormStatus.submitting
                              ? null
                              : () => bloc.add(const TransactionFormDelete()),
                          child:
                              Trash(width: 18, height: 18, color: expense),
                        ),
                      ),
                    ),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: CupertinoButton(
                        color: accent,
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                        padding: EdgeInsets.zero,
                        onPressed: state.status ==
                                TransactionFormStatus.submitting
                            ? null
                            : () => bloc.add(const TransactionFormSubmit()),
                        child: state.status ==
                                TransactionFormStatus.submitting
                            ? const CupertinoActivityIndicator()
                            : Text(
                                isEditing ? 'Update' : 'Save transaction',
                                style: AppFonts.body(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: onPrimary,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _openCategoryPicker(BuildContext context,
      TransactionFormBloc bloc, TransactionFormState state) {
    final type = state.kind == TransactionKind.income
        ? TransactionType.income
        : TransactionType.expense;
    final filtered = categories.where((c) => c.type == type).toList();
    showAppBottomSheet<void>(
      context: context,
      title: 'Select category',
      heightFactor: 0.6,
      child: CategoryPicker(
        categories: filtered,
        selectedId: state.categoryId,
        onSelected: (c) => bloc.add(TransactionFormCategoryChanged(c.id)),
      ),
    );
  }

  void _openBankAccountPicker(BuildContext context, TransactionFormBloc bloc,
      TransactionFormState state, bool isTo) {
    final title = isTo
        ? 'Select destination account'
        : (state.kind == TransactionKind.transfer
            ? 'Select from account'
            : 'Select bank account');
    showAppBottomSheet<void>(
      context: context,
      title: title,
      heightFactor: 0.6,
      child: BankAccountPicker(
        accounts: bankAccounts,
        selectedId: isTo ? state.toBankAccountId : state.bankAccountId,
        excludeId: isTo ? state.bankAccountId : null,
        onSelected: (s) => bloc.add(
          isTo
              ? TransactionFormToBankAccountChanged(s.id)
              : TransactionFormSourceChanged(s.id),
        ),
      ),
    );
  }

  Future<void> _openTransactionSourcePicker(BuildContext context,
      TransactionFormBloc bloc, TransactionFormState state) async {
    await showAppBottomSheet<void>(
      context: context,
      title: 'Counterparty source',
      heightFactor: 0.72,
      expand: true,
      child: _TransactionSourcePickerSheet(
        sources: txSources,
        selectedId: state.transactionSourceId,
        householdId: householdId,
        userId: userId,
        onReload: onReloadTransactionSources,
        onSelected: (id) {
          bloc.add(TransactionFormTransactionSourceChanged(id));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _openDatePicker(BuildContext context, TransactionFormBloc bloc,
      TransactionFormState state) {
    showAppBottomSheet<void>(
      context: context,
      title: 'Select date',
      heightFactor: 0.55,
      child: TransactionDatePicker(
        initialDate: state.date,
        onConfirm: (d) => bloc.add(TransactionFormDateChanged(d)),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final today = DateTime.now();
    if (d.year == today.year && d.month == today.month && d.day == today.day) {
      return 'Today';
    }
    return DateFormat('dd MMM yyyy').format(d);
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

/// Bottom-sheet body: create/edit + shrink-wrapped list (no nested viewport).
class _TransactionSourcePickerSheet extends StatelessWidget {
  final List<TransactionSource> sources;
  final String? selectedId;
  final String householdId;
  final String userId;
  final Future<void> Function() onReload;
  final ValueChanged<String?> onSelected;

  const _TransactionSourcePickerSheet({
    required this.sources,
    required this.selectedId,
    required this.householdId,
    required this.userId,
    required this.onReload,
    required this.onSelected,
  });

  Future<void> _openEditor(
    BuildContext context, {
    TransactionSource? existing,
  }) async {
    await showAppBottomSheet<void>(
      context: context,
      expand: true,
      title: existing == null ? 'New source' : 'Edit source',
      heightFactor: 0.85,
      child: BlocProvider(
        create: (_) => TransactionSourcesBloc(
          AppDependencies.instance.transactionSourceRepository,
        )..add(TransactionSourcesLoad(householdId: householdId)),
        child: TransactionSourceForm(
          existing: existing,
          householdId: householdId,
          userId: userId,
        ),
      ),
    );
    await onReload();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final border = _c(theme.borderColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(vertical: 12),
            onPressed: () => _openEditor(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                Plus(width: 18, height: 18, color: CupertinoColors.white),
                Text(
                  'Create new source',
                  style: AppFonts.body(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: sources.length + 1,
          separatorBuilder: (_, __) => Container(height: 1, color: border),
          itemBuilder: (_, i) {
            if (i == 0) {
              final selected = selectedId == null;
              return CupertinoButton(
                onPressed: () => onSelected(null),
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'None',
                      style: AppFonts.body(
                        fontSize: 15,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w400,
                        color: selected ? accent : muted,
                      ),
                    ),
                  ],
                ),
              );
            }
            final s = sources[i - 1];
            final selected = s.id == selectedId;
            return CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 10),
              onPressed: () => onSelected(s.id),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      s.name,
                      style: AppFonts.body(
                        fontSize: 15,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w400,
                        color: selected ? accent : fg,
                      ),
                    ),
                  ),
                  Text(
                    s.kind.name,
                    style: AppFonts.body(fontSize: 11, color: muted),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(36, 36),
                    onPressed: () => _openEditor(context, existing: s),
                    child: EditPencil(width: 16, height: 16, color: muted),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _PickerTile extends StatelessWidget {
  final Widget icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? sub;
  final String? error;
  final Color errorColor;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.errorColor,
    required this.onTap,
    this.sub,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(
              color: error != null ? errorColor : border, width: 1),
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Row(
          children: [
            CatTile(icon: icon, color: iconColor, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(),
                      style: AppFonts.label(
                          fontSize: 11, color: muted, letterSpacing: 0.55)),
                  const SizedBox(height: 1),
                  Text(value,
                      style: AppFonts.body(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: fg)),
                  if (sub != null) ...[
                    const SizedBox(height: 1),
                    Text(sub!,
                        style: AppFonts.body(
                            fontSize: 11,
                            color: muted.withValues(alpha: 0.55))),
                  ],
                  if (error != null) ...[
                    const SizedBox(height: 3),
                    Text(error!,
                        style:
                            AppFonts.body(fontSize: 11, color: errorColor)),
                  ],
                ],
              ),
            ),
            ChevronIcon(color: muted),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final Widget icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;
  final bool switchOn;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.switchOn,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Row(
        children: [
          CatTile(icon: icon, color: iconColor, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: AppFonts.label(
                        fontSize: 11, color: muted, letterSpacing: 0.55)),
                const SizedBox(height: 1),
                Text(value,
                    style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: fg)),
              ],
            ),
          ),
          ToggleSwitch(
            value: switchOn,
            onChanged: onChanged,
            activeColor: accent,
            inactiveColor: border,
            width: 34,
            height: 20,
          ),
        ],
      ),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  final String text;
  final Color color;
  const _ErrorLine({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppFonts.body(fontSize: 12, color: color),
      ),
    );
  }
}
