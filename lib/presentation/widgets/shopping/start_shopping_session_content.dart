import 'package:flutter/cupertino.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/transaction_source.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';

/// Bottom-sheet body: confirm name, scope, optional bank/source, then start a
/// shopping session (optionally seeded from [template]).
class StartShoppingSessionContent extends StatefulWidget {
  final String householdId;
  final String userId;
  final ShoppingList? template;
  final void Function({
    required String name,
    required ShoppingListScope scope,
    String? bankAccountId,
    String? transactionSourceId,
    String? templateListId,
  }) onStart;

  const StartShoppingSessionContent({
    super.key,
    required this.householdId,
    required this.userId,
    this.template,
    required this.onStart,
  });

  @override
  State<StartShoppingSessionContent> createState() =>
      _StartShoppingSessionContentState();
}

class _StartShoppingSessionContentState
    extends State<StartShoppingSessionContent> {
  late final TextEditingController _name;
  late ShoppingListScope _scope;
  String? _bankAccountId;
  String? _sourceId;
  List<BankAccount> _accounts = const [];
  List<TransactionSource> _sources = const [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    _name = TextEditingController(text: t?.name ?? '');
    _scope = t?.scope ?? ShoppingListScope.shared;
    _bankAccountId = t?.bankAccountId;
    _sourceId = t?.transactionSourceId;
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final deps = AppDependencies.instance;
    final (accounts, _) = await deps.bankAccountRepository.getBankAccounts(
      householdId: widget.householdId,
      viewMode: ViewMode.household,
      userId: widget.userId,
    );
    final (sources, _) = await deps.transactionSourceRepository.getAll(
      householdId: widget.householdId,
    );
    if (!mounted) return;
    setState(() {
      _accounts = accounts;
      _sources = sources;
    });
  }

  void _submit() {
    final n = _name.text.trim();
    if (n.isEmpty || _busy) return;
    setState(() => _busy = true);
    widget.onStart(
      name: n,
      scope: _scope,
      bankAccountId: _bankAccountId,
      transactionSourceId: _sourceId,
      templateListId: widget.template?.id,
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));

  Future<void> _pickSource() async {
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
                  setState(() => _sourceId = null);
                  Navigator.of(context).pop();
                },
                child:
                    Text('None', style: AppFonts.body(fontSize: 15, color: fg)),
              ),
              for (final s in _sources)
                CupertinoButton(
                  onPressed: () {
                    setState(() => _sourceId = s.id);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    s.name,
                    style: AppFonts.body(
                      fontSize: 15,
                      fontWeight:
                          s.id == _sourceId ? FontWeight.w700 : FontWeight.w400,
                      color: s.id == _sourceId ? accent : fg,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickBank() async {
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
                child:
                    Text('None', style: AppFonts.body(fontSize: 15, color: fg)),
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

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final selectedBank =
        _accounts.where((a) => a.id == _bankAccountId).firstOrNull;
    final selectedSrc = _sources.where((s) => s.id == _sourceId).firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('SESSION NAME', style: AppFonts.sectionLabel(color: muted)),
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
              placeholder: 'e.g. Saturday groceries',
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
          Text('SOURCE (OPTIONAL)', style: AppFonts.sectionLabel(color: muted)),
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
                selectedSrc?.name ?? 'Mercadona, Lidl, …',
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
            onTap: _pickBank,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Text(
                selectedBank?.name ?? 'None',
                style: AppFonts.body(fontSize: 14, color: fg),
              ),
            ),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: _busy ? null : _submit,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(AppRadii.xl),
              ),
              alignment: Alignment.center,
              child: _busy
                  ? const CupertinoActivityIndicator(
                      color: CupertinoColors.white)
                  : Text(
                      'Start session',
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
