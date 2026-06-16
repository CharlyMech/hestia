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

/// Bottom-sheet body: confirm name, scope, optional source, and which household
/// members to share with, then start a shopping session (optionally seeded from
/// [template]).
class StartShoppingSessionSheet extends StatefulWidget {
  final String householdId;
  final String userId;
  final ShoppingList? template;
  final void Function({
    required String name,
    required ShoppingListScope scope,
    String? bankAccountId,
    String? transactionSourceId,
    String? templateListId,
    List<String> sharedWithUserIds,
  }) onStart;

  const StartShoppingSessionSheet({
    super.key,
    required this.householdId,
    required this.userId,
    this.template,
    required this.onStart,
  });

  @override
  State<StartShoppingSessionSheet> createState() =>
      _StartShoppingSessionSheetState();
}

class _StartShoppingSessionSheetState
    extends State<StartShoppingSessionSheet> {
  late final TextEditingController _name;
  late final FRadioSelectGroupController<String?> _sourceCtrl;
  late ShoppingListScope _scope;
  String? _sourceId;
  final Set<String> _shareWith = {};
  bool _shareAll = true;
  List<TransactionSource> _sources = const [];
  List<Profile> _members = const [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    _name = TextEditingController(text: t?.name ?? '');
    _scope = t?.scope ?? ShoppingListScope.shared;
    _sourceId = t?.transactionSourceId;
    _sourceCtrl = FRadioSelectGroupController<String?>(value: _sourceId);
    _sourceCtrl.addListener(_onSourceChanged);
    _load();
  }

  void _onSourceChanged() {
    final value = _sourceCtrl.values.firstOrNull;
    if (value != _sourceId) setState(() => _sourceId = value);
  }

  @override
  void dispose() {
    _name.dispose();
    _sourceCtrl.removeListener(_onSourceChanged);
    _sourceCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final deps = AppDependencies.instance;
    final (sources, _) = await deps.transactionSourceRepository.getAll(
      householdId: widget.householdId,
    );
    final (members, _) = await deps.householdRepository.getMemberProfiles(
      widget.householdId,
    );
    if (!mounted) return;
    setState(() {
      _sources = sources;
      // Exclude the current user — they own the session.
      _members = members.where((m) => m.id != widget.userId).toList();
    });
  }

  void _submit() {
    final n = _name.text.trim();
    if (n.isEmpty || _busy) return;
    setState(() => _busy = true);
    // Empty list => whole household ("All"). Only meaningful for shared scope.
    final members = _scope == ShoppingListScope.shared && !_shareAll
        ? _shareWith.toList()
        : const <String>[];
    widget.onStart(
      name: n,
      scope: _scope,
      transactionSourceId: _sourceId,
      templateListId: widget.template?.id,
      sharedWithUserIds: members,
    );
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
    final isShared = _scope == ShoppingListScope.shared;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          _Label(text: l10n.shopping_sessionName, color: muted),
          FTextField(
            controller: _name,
            hint: l10n.shopping_sessionNamePlaceholder,
            textCapitalization: TextCapitalization.sentences,
          ),
          _Label(text: l10n.shopping_scope, color: muted),
          AnimatedPillTabs(
            labels: [l10n.shopping_scopePersonal, l10n.shopping_scopeHousehold],
            selectedIndex: _scope == ShoppingListScope.personal ? 0 : 1,
            onChanged: (i) => setState(() {
              _scope = i == 0
                  ? ShoppingListScope.personal
                  : ShoppingListScope.shared;
              if (_scope == ShoppingListScope.personal) _shareWith.clear();
            }),
            surface: surface,
            border: border,
            fg: fg,
            muted: muted,
            pillColor: accent,
          ),
          _Label(text: l10n.shopping_source, color: muted),
          FSelectMenuTile<String?>(
            groupController: _sourceCtrl,
            autoHide: true,
            title: Text(
              _sources.where((s) => s.id == _sourceId).firstOrNull?.name ??
                  l10n.shopping_sourcePlaceholder,
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
              title: l10n.shopping_shareWithUsers,
              members: _members,
              selected: _shareWith,
              shareAll: _shareAll,
              onShareAllChanged: (v) => setState(() {
                _shareAll = v;
                if (v) _shareWith.clear();
              }),
              onMemberChanged: (id, v) => setState(() {
                if (v) {
                  _shareWith.add(id);
                } else {
                  _shareWith.remove(id);
                }
              }),
            ),
          AnimatedButton(
            backgroundColor: accent,
            borderRadius: AppRadii.xl,
            padding: const EdgeInsets.symmetric(vertical: 14),
            onTap: _busy ? null : _submit,
            child: Center(
              child: _busy
                  ? const CupertinoActivityIndicator(
                      color: CupertinoColors.white)
                  : Text(
                      l10n.shopping_startSessionAction,
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

class _Label extends StatelessWidget {
  final String text;
  final Color color;
  const _Label({required this.text, required this.color});

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: AppFonts.sectionLabel(color: color));
}
