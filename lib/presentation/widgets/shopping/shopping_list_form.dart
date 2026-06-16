import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/common/animated_pill_tabs.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/transaction_source.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/widgets/shopping/member_share_accordion.dart';

/// Create / edit shopping list / template form for a bottom sheet or pushed route.
class ShoppingListForm extends StatefulWidget {
  final String householdId;
  final String userId;
  final ShoppingList? existing;

  /// When true, creates a reusable template instead of a live session.
  final bool asTemplate;
  final VoidCallback onSuccess;

  const ShoppingListForm({
    super.key,
    required this.householdId,
    required this.userId,
    this.existing,
    this.asTemplate = false,
    required this.onSuccess,
  });

  @override
  State<ShoppingListForm> createState() => ShoppingListFormState();
}

class ShoppingListFormState extends State<ShoppingListForm> {
  late final TextEditingController _name;
  late final FRadioSelectGroupController<String?> _sourceCtrl;
  late ShoppingListScope _scope;
  String? _transactionSourceId;
  final Set<String> _sharedWith = {};
  List<TransactionSource> _sources = const [];
  List<Profile> _members = const [];
  bool _saving = false;

  /// True = share with the whole household (no explicit member rows).
  bool _shareAll = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _scope = e?.scope ?? ShoppingListScope.shared;
    _transactionSourceId = e?.transactionSourceId;
    _sourceCtrl = FRadioSelectGroupController<String?>(value: _transactionSourceId);
    _sourceCtrl.addListener(_onSourceChanged);
    _loadSources();
    _loadMembers();
  }

  void _onSourceChanged() {
    final value = _sourceCtrl.values.firstOrNull;
    if (value != _transactionSourceId) {
      setState(() => _transactionSourceId = value);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _sourceCtrl.removeListener(_onSourceChanged);
    _sourceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSources() async {
    final (sources, _) =
        await AppDependencies.instance.transactionSourceRepository.getAll(
      householdId: widget.householdId,
    );
    if (!mounted) return;
    setState(() => _sources = sources);
  }

  Future<void> _loadMembers() async {
    final (members, _) =
        await AppDependencies.instance.householdRepository.getMemberProfiles(
      widget.householdId,
    );
    final existing = widget.existing;
    List<String> shared = const [];
    if (existing != null && existing.scope == ShoppingListScope.shared) {
      final (m, _) = await AppDependencies.instance.shoppingRepository
          .getListMembers(existing.id);
      shared = m;
    }
    if (!mounted) return;
    setState(() {
      _members = members.where((m) => m.id != widget.userId).toList();
      _sharedWith
        ..clear()
        ..addAll(shared);
      _shareAll = shared.isEmpty;
    });
  }

  Future<void> submit() async {
    final trimmed = _name.text.trim();
    if (trimmed.isEmpty || _saving) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final existing = widget.existing;
    // Members only matter for shared scope; "All" => empty list.
    final memberIds = _scope == ShoppingListScope.shared && !_shareAll
        ? _sharedWith.toList()
        : const <String>[];
    if (existing != null) {
      final repo = AppDependencies.instance.shoppingRepository;
      final err = await repo.updateList(
        existing.copyWith(
          name: trimmed,
          scope: _scope,
          transactionSourceId: _transactionSourceId,
          lastUpdate: now,
        ),
      );
      if (err == null) {
        await repo.setListMembers(listId: existing.id, userIds: memberIds);
      }
      if (!mounted) return;
      setState(() => _saving = false);
      if (err != null) return;
      widget.onSuccess();
      return;
    }
    final (created, _) =
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
        transactionSourceId: _transactionSourceId,
        createdAt: now,
        lastUpdate: now,
      ),
    );
    if (created != null && memberIds.isNotEmpty) {
      await AppDependencies.instance.shoppingRepository
          .setListMembers(listId: created.id, userIds: memberIds);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.myTheme;
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final onPrimary = hexToColor(theme.onPrimaryColor);

    final selectedSource =
        _sources.where((s) => s.id == _transactionSourceId).firstOrNull;
    final isShared = _scope == ShoppingListScope.shared;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text(
            l10n.shopping_templateName.toUpperCase(),
            style: AppFonts.sectionLabel(color: muted),
          ),
          FTextField(
            controller: _name,
            hint: widget.asTemplate
                ? l10n.shopping_templateNamePlaceholder
                : l10n.shopping_sessionNamePlaceholder,
            textCapitalization: TextCapitalization.sentences,
          ),
          Text(
            l10n.shopping_scope.toUpperCase(),
            style: AppFonts.sectionLabel(color: muted),
          ),
          AnimatedPillTabs(
            labels: [l10n.shopping_scopePersonal, l10n.shopping_scopeHousehold],
            selectedIndex: _scope == ShoppingListScope.personal ? 0 : 1,
            onChanged: (i) => setState(() {
              _scope = i == 0
                  ? ShoppingListScope.personal
                  : ShoppingListScope.shared;
              if (_scope == ShoppingListScope.personal) _sharedWith.clear();
            }),
            surface: surface,
            border: border,
            fg: fg,
            muted: muted,
            pillColor: accent,
          ),
          Text(
            l10n.shopping_source.toUpperCase(),
            style: AppFonts.sectionLabel(color: muted),
          ),
          FSelectMenuTile<String?>(
            groupController: _sourceCtrl,
            autoHide: true,
            title: Text(
              selectedSource?.name ?? l10n.shopping_sourcePlaceholder,
              style: AppFonts.body(fontSize: 14, color: fg),
            ),
            menu: [
              FSelectTile<String?>(
                title: Text(l10n.common_none),
                value: null,
              ),
              for (final s in _sources)
                FSelectTile<String?>(title: Text(s.name), value: s.id),
            ],
          ),
          if (isShared && _members.isNotEmpty)
            MemberShareAccordion(
              title: l10n.shopping_shareTemplate,
              members: _members,
              selected: _sharedWith,
              shareAll: _shareAll,
              onShareAllChanged: (v) => setState(() {
                _shareAll = v;
                if (v) _sharedWith.clear();
              }),
              onMemberChanged: (id, v) => setState(() {
                if (v) {
                  _sharedWith.add(id);
                } else {
                  _sharedWith.remove(id);
                }
              }),
            ),
          AnimatedButton(
            backgroundColor: accent,
            borderRadius: AppRadii.xl,
            padding: const EdgeInsets.symmetric(vertical: 14),
            onTap: _saving ? null : submit,
            child: Center(
              child: _saving
                  ? const CupertinoActivityIndicator(
                      color: CupertinoColors.white,
                    )
                  : Text(
                      widget.existing != null
                          ? l10n.shopping_saveChanges
                          : (widget.asTemplate
                              ? l10n.shopping_createTemplate
                              : l10n.shopping_startSessionAction),
                      style: AppFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
