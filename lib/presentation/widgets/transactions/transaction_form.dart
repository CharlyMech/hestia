import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/known_banks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/category.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/domain/entities/transaction_source.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/transaction_form/transaction_form_bloc.dart';
import 'package:hestia/presentation/blocs/transaction_form/transaction_form_event.dart';
import 'package:hestia/presentation/blocs/transaction_form/transaction_form_state.dart';
import 'package:hestia/presentation/blocs/transaction_sources/transaction_sources_bloc.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/common/app_toast.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/animated_pill_tabs.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/toggle_switch.dart';
import 'package:hestia/presentation/widgets/transaction_sources/transaction_source_form.dart';
import 'package:hestia/presentation/widgets/transactions/pickers/bank_account_picker.dart';
import 'package:hestia/presentation/widgets/transactions/pickers/category_picker.dart';
import 'package:hestia/presentation/widgets/transactions/pickers/date_picker.dart';
import 'package:hestia/domain/entities/payment_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Cart, CreditCard, Calendar, Refresh, EditPencil, Trash, Shop, Plus;
import 'package:intl/intl.dart';

class TransactionForm extends StatefulWidget {
  final String householdId;
  final String userId;
  final Transaction? initialTransaction;
  final VoidCallback? onClose;
  final void Function(Transaction transaction)? onSubmitted;

  const TransactionForm({
    super.key,
    required this.householdId,
    required this.userId,
    this.initialTransaction,
    this.onClose,
    this.onSubmitted,
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
  List<PaymentCard> _cards = const [];
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

  Future<void> _loadCardsForAccount(String accountId) async {
    final (cards, _) = await AppDependencies.instance.cardRepository
        .getCardsByAccount(accountId: accountId);
    if (!mounted) return;
    setState(() => _cards = cards);
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
        locationService: AppDependencies.instance.locationService,
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
        cards: _cards,
        loadingLookups: _loadingLookups,
        isEditing: widget.initialTransaction != null &&
            widget.initialTransaction!.id.isNotEmpty,
        onClose: widget.onClose,
        onSubmitted: widget.onSubmitted,
        householdId: widget.householdId,
        userId: widget.userId,
        onReloadTransactionSources: _reloadTransactionSources,
        onAccountSelected: _loadCardsForAccount,
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
  final List<PaymentCard> cards;
  final bool loadingLookups;
  final bool isEditing;
  final VoidCallback? onClose;
  final void Function(Transaction transaction)? onSubmitted;
  final String householdId;
  final String userId;
  final Future<void> Function() onReloadTransactionSources;
  final Future<void> Function(String accountId) onAccountSelected;

  const _FormBody({
    required this.amountCtrl,
    required this.noteCtrl,
    required this.categories,
    required this.bankAccounts,
    required this.txSources,
    required this.cards,
    required this.loadingLookups,
    required this.isEditing,
    required this.onClose,
    this.onSubmitted,
    required this.householdId,
    required this.userId,
    required this.onReloadTransactionSources,
    required this.onAccountSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final onPrimary = hexToColor(theme.onPrimaryColor);
    final expense = hexToColor(theme.colorRed);
    final income = hexToColor(theme.colorGreen);
    final tints = theme.categoryTints.map(hexToColor).toList();

    return BlocConsumer<TransactionFormBloc, TransactionFormState>(
      listener: (context, state) {
        if (state.status == TransactionFormStatus.success) {
          final t = state.submittedTransaction;
          if (t != null) {
            onSubmitted?.call(t);
            context.showToast(AppToastConfig(
              type: ToastType.success,
              title: t.isExpense ? 'Expense saved' : 'Income saved',
              description: t.note ?? t.categoryName,
              position: ToastPosition.bottom,
            ));
          } else {
            context.showToast(const AppToastConfig(
              type: ToastType.neutral,
              title: 'Transaction deleted',
              position: ToastPosition.bottom,
            ));
          }
          onClose?.call();
          Navigator.of(context).maybePop();
        } else if (state.status == TransactionFormStatus.error) {
          context.showToast(AppToastConfig(
            type: ToastType.error,
            title: 'Something went wrong',
            description: state.failure?.message,
            position: ToastPosition.bottom,
          ));
        }
      },
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        final bloc = context.read<TransactionFormBloc>();
        final isTransfer = state.kind == TransactionKind.transfer;
        final amountColor =
            state.kind == TransactionKind.income ? income : expense;
        final selectedCategory =
            categories.where((c) => c.id == state.categoryId).firstOrNull;
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
              AnimatedPillTabs(
                labels: const ['Expense', 'Income', 'Transfer'],
                selectedIndex: state.kind.index,
                onChanged: (i) => bloc.add(
                  TransactionFormKindChanged(TransactionKind.values[i]),
                ),
                surface: surface,
                border: border,
                fg: fg,
                muted: muted,
                pillColor: accent,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _openCurrencyPicker(context, bloc, state),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Text('AMOUNT · ${state.currency}',
                        style: AppFonts.sectionLabel(color: muted)),
                    Icon(CupertinoIcons.chevron_down, size: 11, color: muted),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: amountCtrl,
                placeholder: '0.00',
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: false),
                inputFormatters: [
                  // Accept both '.' and ',' as the decimal separator, then
                  // normalise ',' → '.' so locales that show a comma key work.
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  TextInputFormatter.withFunction((oldV, newV) {
                    var t = newV.text.replaceAll(',', '.');
                    final firstDot = t.indexOf('.');
                    if (firstDot != -1) {
                      // keep only the first dot, max 2 decimals
                      final intPart = t.substring(0, firstDot);
                      var dec = t
                          .substring(firstDot + 1)
                          .replaceAll('.', '');
                      if (dec.length > 2) dec = dec.substring(0, 2);
                      t = '$intPart.$dec';
                    }
                    return TextEditingValue(
                      text: t,
                      selection: TextSelection.collapsed(offset: t.length),
                    );
                  }),
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
                  icon: selectedAccount?.institution != null
                      ? _BankLogo(
                          institution: selectedAccount!.institution!,
                          fallbackColor: tints[2])
                      : CreditCard(width: 18, height: 18, color: tints[2]),
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
                  onTap: () =>
                      _openBankAccountPicker(context, bloc, state, false),
                ),
                // Card picker — shown when account has cards and not a transfer
                if (!isTransfer && cards.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _PickerTile(
                    icon: CreditCard(
                        width: 18,
                        height: 18,
                        color: tints[6 % tints.length]),
                    iconColor: tints[6 % tints.length],
                    label: 'Card',
                    value: () {
                      final c = cards
                          .where((c) => c.id == state.paymentCardId)
                          .firstOrNull;
                      return c != null ? '•••• ${c.last4}' : 'Optional';
                    }(),
                    sub: cards
                        .where((c) => c.id == state.paymentCardId)
                        .firstOrNull
                        ?.cardholderName,
                    errorColor: expense,
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                    onTap: () => _openCardPicker(context, bloc, state),
                  ),
                ],
                if (isTransfer) ...[
                  const SizedBox(height: 8),
                  _PickerTile(
                    icon: selectedTo?.institution != null
                        ? _BankLogo(
                            institution: selectedTo!.institution!,
                            fallbackColor: tints[3])
                        : CreditCard(width: 18, height: 18, color: tints[3]),
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
                        child: EditPencil(width: 16, height: 16, color: muted),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CupertinoTextField(
                          controller: noteCtrl,
                          placeholder: 'Add a note…',
                          textCapitalization: TextCapitalization.sentences,
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
                if (!isTransfer) ...[
                  const SizedBox(height: 8),
                  _ToggleTile(
                    icon: Plus(width: 18, height: 18, color: tints[3]),
                    iconColor: tints[3],
                    label: 'Attach location',
                    value: state.attachLocation ? 'On' : 'Off',
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                    accent: accent,
                    switchOn: state.attachLocation,
                    onChanged: (v) =>
                        bloc.add(TransactionFormLocationToggled(v)),
                  ),
                  if (state.attachLocation) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedButton(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            onTap: state.locationLoading
                                ? null
                                : () => bloc.add(
                                      const TransactionFormLocationFetchRequested(),
                                    ),
                            child: state.locationLoading
                                ? const CupertinoActivityIndicator()
                                : Text(
                                    'Use GPS',
                                    style: AppFonts.body(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: accent),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AnimatedButton(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            onTap: state.locationLoading
                                ? null
                                : () => _openLocationMap(context, bloc, state),
                            child: Text(
                              'Map',
                              style: AppFonts.body(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: accent),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (state.latitude != null && state.longitude != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${state.latitude!.toStringAsFixed(5)}, ${state.longitude!.toStringAsFixed(5)}',
                          style: AppFonts.body(fontSize: 12, color: muted),
                        ),
                      ),
                  ],
                ],
              ],
              if (state.errors['location'] != null) ...[
                _ErrorLine(text: state.errors['location']!, color: expense),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedButton(
                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                    onTap: () => AppDependencies.instance.locationService
                        .openSystemAppSettings(),
                    child: Text(
                      l10n.settings_locationOpenSettings,
                      style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ),
                ),
              ],
              if (state.failure != null)
                _ErrorLine(text: state.failure!.message, color: expense),
              // ── Actor "Related to" picker ──────────────────────────────
              _ActorPicker(
                petId: state.petId,
                carId: state.carId,
                homeId: state.homeId,
                householdId: householdId,
                surface: surface,
                border: border,
                fg: fg,
                muted: muted,
                accent: accent,
                onChanged: (petId, carId, homeId) => bloc.add(
                  TransactionFormActorChanged(
                      petId: petId, carId: carId, homeId: homeId),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (isEditing)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: AnimatedButton(
                          padding: EdgeInsets.zero,
                          onTap: state.status ==
                                  TransactionFormStatus.submitting
                              ? null
                              : () => bloc.add(const TransactionFormDelete()),
                          child: Trash(width: 18, height: 18, color: expense),
                        ),
                      ),
                    ),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: AnimatedButton(
                        padding: EdgeInsets.zero,
                        onTap:
                            state.status == TransactionFormStatus.submitting
                                ? null
                                : () => bloc.add(const TransactionFormSubmit()),
                        child: state.status == TransactionFormStatus.submitting
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

  Future<void> _openLocationMap(
    BuildContext context,
    TransactionFormBloc bloc,
    TransactionFormState state,
  ) async {
    final initialLat = state.latitude ?? 40.4168;
    final initialLng = state.longitude ?? -3.7038;
    final result = await context.push<(double, double)>(
      AppRoutes.transactionMapPicker,
      extra: (initialLat, initialLng),
    );
    if (!context.mounted || result == null) return;
    bloc.add(TransactionFormLocationSet(
      latitude: result.$1,
      longitude: result.$2,
    ));
  }

  void _openCategoryPicker(BuildContext context, TransactionFormBloc bloc,
      TransactionFormState state) {
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
        onSelected: (s) {
          bloc.add(
            isTo
                ? TransactionFormToBankAccountChanged(s.id)
                : TransactionFormSourceChanged(s.id),
          );
          if (!isTo) {
            bloc.add(TransactionFormCurrencyChanged(s.currency));
            // Clear card selection and reload cards for the new account.
            bloc.add(const TransactionFormCardChanged(null));
            onAccountSelected(s.id);
          }
        },
      ),
    );
  }

  void _openCardPicker(BuildContext context, TransactionFormBloc bloc,
      TransactionFormState state) {
    showAppBottomSheet<void>(
      context: context,
      title: 'Select card',
      heightFactor: 0.5,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _CardPickerRow(
            label: 'None',
            sub: 'No card',
            selected: state.paymentCardId == null,
            onTap: () {
              bloc.add(const TransactionFormCardChanged(null));
              Navigator.of(context).maybePop();
            },
          ),
          ...cards.map((c) => _CardPickerRow(
                label: '•••• ${c.last4}',
                sub: c.cardholderName,
                selected: c.id == state.paymentCardId,
                onTap: () {
                  bloc.add(TransactionFormCardChanged(c.id));
                  Navigator.of(context).maybePop();
                },
              )),
        ],
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

  void _openCurrencyPicker(BuildContext context, TransactionFormBloc bloc,
      TransactionFormState state) {
    const currencies = ['EUR', 'USD', 'GBP', 'CHF', 'JPY', 'CAD', 'AUD'];
    final theme = context.myTheme;
    final fg = hexToColor(theme.onBackgroundColor);
    final accent = hexToColor(theme.primaryColor);
    showAppBottomSheet<void>(
      context: context,
      title: 'Currency',
      heightFactor: 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final c in currencies)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                bloc.add(TransactionFormCurrencyChanged(c));
                Navigator.of(context).pop();
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(c,
                          style: AppFonts.body(
                              fontSize: 15,
                              color: c == state.currency ? accent : fg,
                              fontWeight: c == state.currency
                                  ? FontWeight.w700
                                  : FontWeight.w400)),
                    ),
                    if (c == state.currency)
                      Icon(CupertinoIcons.checkmark, size: 16, color: accent),
                  ],
                ),
              ),
            ),
        ],
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
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final border = hexToColor(theme.borderColor);

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
              return AnimatedButton(
                onTap: () => onSelected(null),
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
            return AnimatedButton(
              padding: const EdgeInsets.symmetric(vertical: 10),
              onTap: () => onSelected(s.id),
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
                  AnimatedButton(
                    padding: EdgeInsets.zero,
                    onTap: () => _openEditor(context, existing: s),
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
}

/// Small bank logo for the account picker. Renders the bundled PNG when an
/// asset exists for the institution slug, else a brand-colored letter badge.
class _BankLogo extends StatelessWidget {
  final String institution;
  final Color fallbackColor;

  const _BankLogo({required this.institution, required this.fallbackColor});

  @override
  Widget build(BuildContext context) {
    final slug = bankSlug(institution);
    final known = kKnownBanks.cast<KnownBank?>().firstWhere(
          (b) => b?.slug == slug,
          orElse: () => null,
        );
    final brand = known != null
        ? hexToColor(known.brandColor)
        : fallbackColor;
    final letter =
        institution.isNotEmpty ? institution[0].toUpperCase() : '?';

    return SizedBox(
      width: 18,
      height: 18,
      child: Image.asset(
        'assets/banks/$slug.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          decoration: BoxDecoration(
            color: brand.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            letter,
            style: AppFonts.heading(
                fontSize: 10, fontWeight: FontWeight.w700, color: brand),
          ),
        ),
      ),
    );
  }
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
              color: error != null ? errorColor : const Color(0x00000000),
              width: 1),
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
                        style: AppFonts.body(fontSize: 11, color: errorColor)),
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
                        fontSize: 14, fontWeight: FontWeight.w500, color: fg)),
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

// ── Actor "Related to" picker ─────────────────────────────────────────────────

class _ActorPicker extends StatefulWidget {
  final String? petId;
  final String? carId;
  final String? homeId;
  final String householdId;
  final Color surface, border, fg, muted, accent;
  final void Function(String? petId, String? carId, String? homeId) onChanged;

  const _ActorPicker({
    required this.householdId,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.onChanged,
    this.petId,
    this.carId,
    this.homeId,
  });

  @override
  State<_ActorPicker> createState() => _ActorPickerState();
}

class _ActorPickerState extends State<_ActorPicker> {
  List<({String id, String name, String icon})> _pets = [];
  List<({String id, String name, String icon})> _cars = [];
  List<({String id, String name, String icon})> _homes = [];

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final deps = AppDependencies.instance;
    final (pets, _) =
        await deps.petRepository.getPets(householdId: widget.householdId);
    final (cars, _) =
        await deps.carRepository.getCars(householdId: widget.householdId);
    final (homes, _) = await deps.homeRepository.getHomes(widget.householdId);
    if (!mounted) return;
    setState(() {
      _pets = pets.map((p) => (id: p.id, name: p.name, icon: '🐾')).toList();
      _cars = cars.map((c) => (id: c.id, name: c.name, icon: '🚗')).toList();
      _homes = homes.map((h) => (id: h.id, name: h.name, icon: '🏠')).toList();
    });
  }

  String? get _activeLabel {
    if (widget.petId != null) {
      final pet = _pets.where((p) => p.id == widget.petId).firstOrNull;
      return pet != null ? '${pet.icon} ${pet.name}' : null;
    }
    if (widget.carId != null) {
      final car = _cars.where((c) => c.id == widget.carId).firstOrNull;
      return car != null ? '${car.icon} ${car.name}' : null;
    }
    if (widget.homeId != null) {
      final home = _homes.where((h) => h.id == widget.homeId).firstOrNull;
      return home != null ? '${home.icon} ${home.name}' : null;
    }
    return null;
  }

  void _openPicker() async {
    if (_pets.isEmpty && _cars.isEmpty && _homes.isEmpty) return;

    await showAppBottomSheet<void>(
      context: context,
      title: 'Related to',
      heightFactor: 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _row(
            label: 'None',
            selected:
                widget.petId == null && widget.carId == null && widget.homeId == null,
            onTap: () {
              widget.onChanged(null, null, null);
              Navigator.of(context).pop();
            },
          ),
          if (_pets.isNotEmpty)
            _section('Pets', _pets, (id) => widget.petId == id, (id) {
              widget.onChanged(id, null, null);
              Navigator.of(context).pop();
            }),
          if (_cars.isNotEmpty)
            _section('Cars', _cars, (id) => widget.carId == id, (id) {
              widget.onChanged(null, id, null);
              Navigator.of(context).pop();
            }),
          if (_homes.isNotEmpty)
            _section('Homes', _homes, (id) => widget.homeId == id, (id) {
              widget.onChanged(null, null, id);
              Navigator.of(context).pop();
            }),
        ],
      ),
    );
  }

  Widget _section(
    String title,
    List<({String id, String name, String icon})> items,
    bool Function(String id) isSelected,
    void Function(String id) onPick,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
          child: Text(
            title.toUpperCase(),
            style: AppFonts.label(
                fontSize: 11, color: widget.muted, letterSpacing: 0.6),
          ),
        ),
        for (final it in items)
          _row(
            label: '${it.icon} ${it.name}',
            selected: isSelected(it.id),
            onTap: () => onPick(it.id),
          ),
      ],
    );
  }

  Widget _row({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppFonts.body(
                  fontSize: 15,
                  color: selected ? widget.accent : widget.fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              Icon(CupertinoIcons.checkmark, size: 16, color: widget.accent),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActor =
        widget.petId != null || widget.carId != null || widget.homeId != null;
    final label = _activeLabel;

    if (_pets.isEmpty && _cars.isEmpty && _homes.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _openPicker,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: widget.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.border, width: 0.8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text('Related to',
                      style: AppFonts.body(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.muted,
                          letterSpacing: 0.5)),
                  Text(
                    label ?? 'None',
                    style: AppFonts.body(
                      fontSize: 14,
                      color: hasActor ? widget.fg : widget.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (hasActor)
              GestureDetector(
                onTap: () => widget.onChanged(null, null, null),
                child: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  size: 18,
                  color: widget.muted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CardPickerRow extends StatelessWidget {
  final String label;
  final String? sub;
  final bool selected;
  final VoidCallback onTap;

  const _CardPickerRow({
    required this.label,
    this.sub,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.12) : surface,
          border: Border.all(color: selected ? accent : border),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Row(
          spacing: 12,
          children: [
            Icon(
              selected
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
              size: 20,
              color: selected ? accent : muted,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppFonts.body(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: fg)),
                  if (sub != null)
                    Text(sub!,
                        style: AppFonts.body(fontSize: 12, color: muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
