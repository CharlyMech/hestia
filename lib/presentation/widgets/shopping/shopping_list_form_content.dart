import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/transaction_source.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';

/// Create / edit shopping list form for a bottom sheet or pushed route.
class ShoppingListFormContent extends StatefulWidget {
  final String householdId;
  final String userId;
  final ShoppingList? existing;

  /// When true, creates a reusable template instead of a live session.
  final bool asTemplate;
  final VoidCallback onSuccess;

  const ShoppingListFormContent({
    super.key,
    required this.householdId,
    required this.userId,
    this.existing,
    this.asTemplate = false,
    required this.onSuccess,
  });

  @override
  State<ShoppingListFormContent> createState() =>
      ShoppingListFormContentState();
}

class ShoppingListFormContentState extends State<ShoppingListFormContent> {
  late final TextEditingController _name;
  late ShoppingListScope _scope;
  String? _bankAccountId;
  String? _transactionSourceId;
  List<BankAccount> _accounts = const [];
  List<TransactionSource> _sources = const [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _scope = e?.scope ?? ShoppingListScope.shared;
    _bankAccountId = e?.bankAccountId;
    _transactionSourceId = e?.transactionSourceId;
    _loadAccounts();
    _loadSources();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    final (accounts, _) =
        await AppDependencies.instance.bankAccountRepository.getBankAccounts(
      householdId: widget.householdId,
      viewMode: ViewMode.household,
      userId: widget.userId,
    );
    if (!mounted) return;
    setState(() => _accounts = accounts);
  }

  Future<void> _loadSources() async {
    final (sources, _) =
        await AppDependencies.instance.transactionSourceRepository.getAll(
      householdId: widget.householdId,
    );
    if (!mounted) return;
    setState(() => _sources = sources);
  }

  Future<void> submit() async {
    final trimmed = _name.text.trim();
    if (trimmed.isEmpty || _saving) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final existing = widget.existing;
    if (existing != null) {
      final err = await AppDependencies.instance.shoppingRepository.updateList(
        existing.copyWith(
          name: trimmed,
          scope: _scope,
          bankAccountId: _bankAccountId,
          transactionSourceId: _transactionSourceId,
          lastUpdate: now,
        ),
      );
      if (!mounted) return;
      setState(() => _saving = false);
      if (err != null) return;
      widget.onSuccess();
      return;
    }
    await AppDependencies.instance.shoppingRepository.createList(
      ShoppingList(
        id: '',
        householdId: widget.householdId,
        ownerId: widget.userId,
        scope: _scope,
        name: trimmed,
        kind: widget.asTemplate
            ? ShoppingListKind.template
            : ShoppingListKind.session,
        sessionStartedAt: widget.asTemplate ? null : now,
        bankAccountId: _bankAccountId,
        transactionSourceId: _transactionSourceId,
        createdAt: now,
        lastUpdate: now,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    widget.onSuccess();
  }

  Future<void> _pickBankAccount() async {
    final theme = context.myTheme;
    final surface = hexToColor(theme.surfaceColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final accent = hexToColor(theme.primaryColor);
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
              CupertinoButton(
                onPressed: () {
                  setState(() => _bankAccountId = null);
                  Navigator.of(context).pop();
                },
                child: Text(
                  'None',
                  style: AppFonts.body(fontSize: 15, color: fg),
                ),
              ),
              for (final a in _accounts)
                CupertinoButton(
                  onPressed: () {
                    setState(() => _bankAccountId = a.id);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    a.name,
                    style: AppFonts.body(
                      fontSize: 15,
                      fontWeight: a.id == _bankAccountId
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: a.id == _bankAccountId ? accent : fg,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickSource() async {
    final theme = context.myTheme;
    final surface = hexToColor(theme.surfaceColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final accent = hexToColor(theme.primaryColor);
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
              CupertinoButton(
                onPressed: () {
                  setState(() => _transactionSourceId = null);
                  Navigator.of(context).pop();
                },
                child: Text(
                  'None',
                  style: AppFonts.body(fontSize: 15, color: fg),
                ),
              ),
              for (final s in _sources)
                CupertinoButton(
                  onPressed: () {
                    setState(() => _transactionSourceId = s.id);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    s.name,
                    style: AppFonts.body(
                      fontSize: 15,
                      fontWeight: s.id == _transactionSourceId
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: s.id == _transactionSourceId ? accent : fg,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);

    final selectedAccount =
        _accounts.where((a) => a.id == _bankAccountId).firstOrNull;
    final selectedSource =
        _sources.where((s) => s.id == _transactionSourceId).firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('NAME', style: AppFonts.sectionLabel(color: muted)),
          const SizedBox(height: 6),
          FTextField(
            controller: _name,
            hint: widget.asTemplate
                ? 'e.g. Mercadona staples'
                : 'e.g. Weekly groceries',
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 14),
          Text('SCOPE', style: AppFonts.sectionLabel(color: muted)),
          const SizedBox(height: 6),
          SegmentedControl(
            options: const ['Personal', 'Household'],
            active: _scope == ShoppingListScope.personal ? 0 : 1,
            onChanged: (i) => setState(() => _scope =
                i == 0 ? ShoppingListScope.personal : ShoppingListScope.shared),
            surface: surface,
            border: border,
            fg: fg,
            muted: muted,
            activeColor: accent,
            activeFg: CupertinoColors.white,
          ),
          const SizedBox(height: 14),
          Text(
            'DEFAULT SOURCE (OPTIONAL)',
            style: AppFonts.sectionLabel(color: muted),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickSource,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          const SizedBox(height: 14),
          Text(
            'LINKED ACCOUNT (OPTIONAL)',
            style: AppFonts.sectionLabel(color: muted),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickBankAccount,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Text(
                selectedAccount?.name ?? 'None',
                style: AppFonts.body(fontSize: 14, color: fg),
              ),
            ),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: _saving ? null : submit,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(AppRadii.xl),
              ),
              alignment: Alignment.center,
              child: _saving
                  ? const CupertinoActivityIndicator(
                      color: CupertinoColors.white,
                    )
                  : Text(
                      widget.existing != null
                          ? 'Save changes'
                          : (widget.asTemplate
                              ? 'Create template'
                              : 'Create session'),
                      style: AppFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
