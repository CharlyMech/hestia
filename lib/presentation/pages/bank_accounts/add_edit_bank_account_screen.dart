import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/constants/known_banks.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/bank_accounts/wallet_card.dart';
import 'package:hestia/presentation/widgets/common/app_toast.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/primary_button.dart';
import 'package:uuid/uuid.dart';

class AddEditBankAccountScreen extends StatefulWidget {
  /// Pass existing account to edit, null to create new.
  final BankAccount? existing;

  const AddEditBankAccountScreen({super.key, this.existing});

  @override
  State<AddEditBankAccountScreen> createState() =>
      _AddEditBankAccountScreenState();
}

class _AddEditBankAccountScreenState extends State<AddEditBankAccountScreen> {
  static const _uuid = Uuid();

  late final TextEditingController _name;
  late final TextEditingController _balance;
  late final TextEditingController _iban;

  KnownBank? _selectedBank;
  int _typeIdx = 0;
  int _ownerIdx = 0;
  String? _currency;
  String? _customColor; // hex, overrides brand color

  bool _saving = false;

  static const _types = [
    AccountType.checking,
    AccountType.savings,
    AccountType.credit,
    AccountType.cash,
    AccountType.investment,
  ];

  static const _typeLabels = [
    'Checking',
    'Savings',
    'Credit',
    'Cash',
    'Investment',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _balance = TextEditingController(
        text: e != null ? e.initialBalance.toStringAsFixed(2) : '');
    _iban = TextEditingController(text: e?.iban ?? '');
    _currency = e?.currency;
    if (e != null) {
      _typeIdx = _types.indexWhere((t) => t == e.accountType);
      if (_typeIdx < 0) _typeIdx = 0;
      _ownerIdx = e.ownerType == OwnerType.shared ? 1 : 0;
      _customColor = e.color;
      // Try to match known bank by institution slug
      if (e.institution != null) {
        final slug = bankSlug(e.institution!);
        _selectedBank = kKnownBanks.cast<KnownBank?>().firstWhere(
              (b) => b?.slug == slug,
              orElse: () => null,
            );
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    _iban.dispose();
    super.dispose();
  }

  String get _effectiveColor =>
      _customColor ?? _selectedBank?.brandColor ?? '#0077B6';

  /// Preview account built from current form state.
  BankAccount get _previewAccount {
    return BankAccount(
      id: widget.existing?.id ?? 'preview',
      householdId: '',
      ownerType: _ownerIdx == 1 ? OwnerType.shared : OwnerType.personal,
      name: _name.text.isEmpty
          ? (_selectedBank?.displayName ?? 'Account')
          : _name.text,
      institution: _selectedBank?.displayName,
      iban: _iban.text.trim().isEmpty ? null : _iban.text.trim(),
      accountType: _types[_typeIdx],
      currency: _currency ?? 'EUR',
      initialBalance: double.tryParse(_balance.text.replaceAll(',', '.')) ?? 0,
      currentBalance: double.tryParse(_balance.text.replaceAll(',', '.')) ?? 0,
      color: _effectiveColor,
      isActive: true,
      isPrimary: widget.existing?.isPrimary ?? false,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      lastUpdate: DateTime.now(),
    );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      context.showToast(const AppToastConfig(
          type: ToastType.error, title: 'Enter an account name'));
      return;
    }
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;

    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(auth.profile.id);
    if (household == null || !mounted) return;

    setState(() => _saving = true);
    final balance = double.tryParse(_balance.text.replaceAll(',', '.')) ?? 0.0;
    final now = DateTime.now();

    final account = BankAccount(
      id: widget.existing?.id ?? _uuid.v4(),
      householdId: household.id,
      ownerType: _ownerIdx == 1 ? OwnerType.shared : OwnerType.personal,
      ownerId: _ownerIdx == 0 ? auth.profile.id : null,
      name: _name.text.trim(),
      institution: _selectedBank?.displayName,
      iban: _iban.text.trim().isEmpty ? null : _iban.text.trim(),
      accountType: _types[_typeIdx],
      currency: _currency ?? auth.profile.preferredCurrency,
      initialBalance: balance,
      currentBalance: balance,
      color: _effectiveColor,
      isActive: true,
      isPrimary: widget.existing?.isPrimary ?? false,
      createdAt: widget.existing?.createdAt ?? now,
      lastUpdate: now,
    );

    final repo = AppDependencies.instance.bankAccountRepository;
    Failure? failure;
    if (widget.existing == null) {
      final (_, f) = await repo.createBankAccount(account);
      failure = f;
    } else {
      failure = await repo.updateBankAccount(account);
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (failure != null) {
      context.showToast(AppToastConfig(
          type: ToastType.error,
          title: 'Could not save',
          description: failure.message));
      return;
    }

    context.showToast(AppToastConfig(
      type: ToastType.success,
      title: widget.existing == null ? 'Account created' : 'Account updated',
    ));
    Navigator.of(context).pop(true);
  }

  void _openBankPicker() {
    showAppBottomSheet<void>(
      context: context,
      title: 'Select bank',
      heightFactor: 0.85,
      expand: true,
      child: _BankPickerSheet(
        selected: _selectedBank,
        onPicked: (bank) {
          setState(() {
            _selectedBank = bank;
            _customColor = null; // reset custom color → use brand color
            if (_name.text.isEmpty && bank != null) {
              _name.text = bank.displayName;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.foregroundColor);
    final muted = hexToColor(theme.mutedColor);
    final accent = hexToColor(theme.primaryColor);
    final preferredCurrency =
        (context.watch<AuthBloc>().state is AuthAuthenticated)
            ? (context.watch<AuthBloc>().state as AuthAuthenticated)
                .profile
                .preferredCurrency
            : 'EUR';

    _currency ??= preferredCurrency;

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: widget.existing == null ? 'New account' : 'Edit account',
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, 40 + MediaQuery.viewInsetsOf(context).bottom),
          children: [
            // Live WalletCard preview
            ListenableBuilder(
              listenable: Listenable.merge([_name, _balance]),
              builder: (_, __) => WalletCard(source: _previewAccount),
            ),
            const SizedBox(height: 28),

            _sectionLabel('BANK', muted),
            const SizedBox(height: 8),
            _PickerTile(
              label: _selectedBank?.displayName ?? 'Select bank',
              isPlaceholder: _selectedBank == null,
              surface: surface,
              border: border,
              fg: fg,
              muted: muted,
              onTap: _openBankPicker,
            ),
            const SizedBox(height: 20),

            _sectionLabel('ACCOUNT NAME', muted),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _name,
              placeholder: 'e.g. Main Checking',
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              style: AppFonts.body(fontSize: 15, color: fg),
              placeholderStyle: AppFonts.body(fontSize: 15, color: muted),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: 0.8),
              ),
            ),
            const SizedBox(height: 20),

            _sectionLabel('IBAN (OPTIONAL)', muted),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _iban,
              placeholder: 'ES00 0000 0000 0000 0000 0000',
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
              ],
              style: AppFonts.numeric(fontSize: 14, color: fg),
              placeholderStyle: AppFonts.numeric(fontSize: 14, color: muted),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: 0.8),
              ),
            ),
            const SizedBox(height: 20),

            _sectionLabel('TYPE', muted),
            const SizedBox(height: 8),
            _SegmentedRow(
              labels: _typeLabels,
              selected: _typeIdx,
              onChanged: (i) => setState(() => _typeIdx = i),
              surface: surface,
              border: border,
              fg: fg,
              muted: muted,
              accent: accent,
            ),
            const SizedBox(height: 20),

            _sectionLabel('OWNERSHIP', muted),
            const SizedBox(height: 8),
            _SegmentedRow(
              labels: const ['Personal', 'Shared'],
              selected: _ownerIdx,
              onChanged: (i) => setState(() => _ownerIdx = i),
              surface: surface,
              border: border,
              fg: fg,
              muted: muted,
              accent: accent,
            ),
            const SizedBox(height: 20),

            _sectionLabel('INITIAL BALANCE', muted),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _balance,
              placeholder: '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              suffix: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  _currency ?? preferredCurrency,
                  style: AppFonts.body(fontSize: 13, color: muted),
                ),
              ),
              style: AppFonts.numeric(fontSize: 15, color: fg),
              placeholderStyle: AppFonts.numeric(fontSize: 15, color: muted),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: 0.8),
              ),
            ),
            const SizedBox(height: 32),

            PrimaryButton(
              label:
                  widget.existing == null ? 'Create account' : 'Save changes',
              onPressed: _saving ? null : _save,
              loading: _saving,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, Color muted) => Text(
        text,
        style: AppFonts.body(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: muted,
            letterSpacing: 0.8),
      );
}

// ── Bank picker sheet ──────────────────────────────────────────────────────

class _BankPickerSheet extends StatefulWidget {
  final KnownBank? selected;
  final void Function(KnownBank? bank) onPicked;

  const _BankPickerSheet({required this.selected, required this.onPicked});

  @override
  State<_BankPickerSheet> createState() => _BankPickerSheetState();
}

class _BankPickerSheetState extends State<_BankPickerSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<KnownBank> get _filtered {
    if (_query.isEmpty) return kKnownBanks;
    final q = _query.toLowerCase();
    return kKnownBanks
        .where((b) =>
            b.displayName.toLowerCase().contains(q) ||
            b.country.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final surface =
        Color(int.parse(theme.surfaceColor.replaceFirst('#', '0xff')));
    final border =
        Color(int.parse(theme.outlineColor.replaceFirst('#', '0xff')));
    final fg =
        Color(int.parse(theme.foregroundColor.replaceFirst('#', '0xff')));
    final muted = Color(int.parse(theme.mutedColor.replaceFirst('#', '0xff')));
    final accent =
        Color(int.parse(theme.primaryColor.replaceFirst('#', '0xff')));

    final filtered = _filtered;
    final maxListHeight = MediaQuery.of(context).size.height * 0.5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: CupertinoSearchTextField(
            controller: _search,
            placeholder: 'Search bank…',
            style: AppFonts.body(fontSize: 15, color: fg),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        // List
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxListHeight),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => Container(
              height: 0.5,
              color: border,
              margin: const EdgeInsets.only(left: 58),
            ),
            itemBuilder: (_, i) {
              final bank = filtered[i];
              final isSelected = widget.selected?.slug == bank.slug;
              final brandColor =
                  Color(int.parse(bank.brandColor.replaceFirst('#', '0xff')));

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.onPicked(bank);
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    spacing: 12,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: brandColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          bank.displayName.substring(0, 1).toUpperCase(),
                          style: AppFonts.heading(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: brandColor),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 1,
                          children: [
                            Text(
                              bank.displayName,
                              style: AppFonts.body(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: fg,
                              ),
                            ),
                            if (bank.country.isNotEmpty)
                              Text(
                                bank.country,
                                style:
                                    AppFonts.body(fontSize: 11, color: muted),
                              ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(CupertinoIcons.checkmark, size: 16, color: accent),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // None / other option
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.onPicked(null);
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: 0.8),
              ),
              child: Text(
                'None / enter manually',
                style: AppFonts.body(fontSize: 14, color: muted),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _PickerTile extends StatelessWidget {
  final String label;
  final bool isPlaceholder;
  final Color surface, border, fg, muted;
  final VoidCallback onTap;

  const _PickerTile({
    required this.label,
    required this.isPlaceholder,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 0.8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppFonts.body(
                  fontSize: 15,
                  color: isPlaceholder ? muted : fg,
                ),
              ),
            ),
            Icon(CupertinoIcons.chevron_up_chevron_down,
                size: 14, color: muted),
          ],
        ),
      ),
    );
  }
}

class _SegmentedRow extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  final Color surface, border, fg, muted, accent;

  const _SegmentedRow({
    required this.labels,
    required this.selected,
    required this.onChanged,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.8),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selected == i ? accent : const Color(0x00000000),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight:
                          selected == i ? FontWeight.w600 : FontWeight.w400,
                      color: selected == i ? CupertinoColors.white : muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
