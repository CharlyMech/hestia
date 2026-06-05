import 'package:flutter/widgets.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';

enum ScopeKind { shared, personal }

class ScopePill extends StatelessWidget {
  final ScopeKind kind;
  final String? label;

  const ScopePill({super.key, required this.kind, this.label});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.myTheme;
    final shared = kind == ScopeKind.shared;
    final fg = hexToColor(theme.onBackgroundColor);
    final bg = hexToColor(theme.surfaceColor);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label ??
            (shared ? l10n.bankAccounts_shared : l10n.bankAccounts_personal),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}
