import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';

/// New / edit shopping list. Reaches the index bloc through the parent route
/// so saving updates the lists screen automatically. Editing not yet wired —
/// the screen treats `existing` as a future hook.
class AddEditShoppingListScreen extends StatefulWidget {
  final String householdId;
  final String userId;
  final ShoppingList? existing;

  const AddEditShoppingListScreen({
    super.key,
    required this.householdId,
    required this.userId,
    this.existing,
  });

  @override
  State<AddEditShoppingListScreen> createState() =>
      _AddEditShoppingListScreenState();
}

class _AddEditShoppingListScreenState
    extends State<AddEditShoppingListScreen> {
  late final TextEditingController _name;
  late ShoppingListScope _scope;
  String? _bankAccountId;
  List<BankAccount> _accounts = const [];

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

  Future<void> _pickBankAccount(BuildContext context) async {
    final theme = context.myTheme;
    final surface =
        Color(int.parse(theme.surfaceColor.replaceFirst('#', '0xff')));
    final fg = Color(int.parse(theme.onBackgroundColor.replaceFirst('#', '0xff')));
    final accent =
        Color(int.parse(theme.primaryColor.replaceFirst('#', '0xff')));
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

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final now = DateTime.now();
    final list = ShoppingList(
      id: '',
      householdId: widget.householdId,
      ownerId: widget.userId,
      scope: _scope,
      name: name,
      bankAccountId: _bankAccountId,
      createdAt: now,
      lastUpdate: now,
    );
    await AppDependencies.instance.shoppingRepository.createList(list);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);

    final selectedAccount =
        _accounts.where((a) => a.id == _bankAccountId).firstOrNull;

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      borderColor: border,
      foregroundColor: fg,
      titleText: widget.existing != null
          ? 'Edit shopping list'
          : 'New shopping list',
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _save,
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            widget.existing != null ? 'Save' : 'Create',
            style: AppFonts.body(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
                  Text('NAME',
                      style: AppFonts.sectionLabel(color: muted)),
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
                  Text('SCOPE',
                      style: AppFonts.sectionLabel(color: muted)),
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
                  Text('LINKED ACCOUNT (OPTIONAL)',
                      style: AppFonts.sectionLabel(color: muted)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _pickBankAccount(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
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
                ],
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
