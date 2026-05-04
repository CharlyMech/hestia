import 'package:flutter/cupertino.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';

/// Create / edit shopping list form for a bottom sheet or pushed route.
class ShoppingListFormContent extends StatefulWidget {
  final String householdId;
  final String userId;
  final ShoppingList? existing;
  final VoidCallback onSuccess;

  const ShoppingListFormContent({
    super.key,
    required this.householdId,
    required this.userId,
    this.existing,
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
  List<BankAccount> _accounts = const [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _scope = e?.scope ?? ShoppingListScope.shared;
    _bankAccountId = e?.bankAccountId;
    _loadAccounts();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    final (accounts, _) = await AppDependencies.instance.bankAccountRepository
        .getBankAccounts(
      householdId: widget.householdId,
      viewMode: ViewMode.household,
      userId: widget.userId,
    );
    if (!mounted) return;
    setState(() => _accounts = accounts);
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
        bankAccountId: _bankAccountId,
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
    final surface = _c(theme.surfaceColor);
    final fg = _c(theme.onBackgroundColor);
    final accent = _c(theme.primaryColor);
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

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);

    final selectedAccount =
        _accounts.where((a) => a.id == _bankAccountId).firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('NAME', style: AppFonts.sectionLabel(color: muted)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: surface,
              border: Border.all(color: border, width: 1),
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: CupertinoTextField(
              controller: _name,
              placeholder: 'e.g. Weekly groceries',
              decoration: const BoxDecoration(),
              padding: const EdgeInsets.symmetric(vertical: 14),
              style: AppFonts.body(fontSize: 14, color: fg),
            ),
          ),
          const SizedBox(height: 14),
          Text('SCOPE', style: AppFonts.sectionLabel(color: muted)),
          const SizedBox(height: 6),
          SegmentedControl(
            options: const ['Personal', 'Household'],
            active: _scope == ShoppingListScope.personal ? 0 : 1,
            onChanged: (i) => setState(() => _scope = i == 0
                ? ShoppingListScope.personal
                : ShoppingListScope.shared),
            surface: surface,
            border: border,
            fg: fg,
            muted: muted,
            activeColor: accent,
            activeFg: CupertinoColors.white,
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
                border: Border.all(color: border, width: 1),
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
                      widget.existing != null ? 'Save changes' : 'Create list',
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
