import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';

/// Reusable "share with household members" accordion used by both the start-
/// session sheet and the template form.
///
/// Includes an **All** checkbox: when checked, [selected] is empty meaning the
/// whole household. Unchecking it reveals the per-member checkboxes.
class MemberShareAccordion extends StatelessWidget {
  final String title;
  final List<Profile> members;

  /// Explicitly selected member ids (empty when [shareAll] is true).
  final Set<String> selected;
  final bool shareAll;

  /// Toggle the "All" checkbox. true → clear [selected].
  final ValueChanged<bool> onShareAllChanged;

  /// Toggle a single member.
  final void Function(String userId, bool value) onMemberChanged;

  const MemberShareAccordion({
    super.key,
    required this.title,
    required this.members,
    required this.selected,
    required this.shareAll,
    required this.onShareAllChanged,
    required this.onMemberChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.myTheme;
    final fg = hexToColor(theme.onBackgroundColor);

    return FAccordion(
      items: [
        FAccordionItem(
          title: Text(
            title,
            style: AppFonts.body(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              _Row(
                label: l10n.shopping_shareAll,
                value: shareAll,
                onChanged: onShareAllChanged,
                fg: fg,
              ),
              if (!shareAll)
                for (final m in members)
                  _Row(
                    label: m.displayName ?? m.email,
                    value: selected.contains(m.id),
                    onChanged: (v) => onMemberChanged(m.id, v),
                    fg: fg,
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color fg;

  const _Row({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Row(
        spacing: 12,
        children: [
          FCheckbox(value: value, onChange: onChanged),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.body(fontSize: 14, color: fg),
            ),
          ),
        ],
      ),
    );
  }
}
