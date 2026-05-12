import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/member_avatar.dart';
import 'package:hestia/presentation/widgets/dashboard/progress_ring.dart';
import 'package:hestia/presentation/widgets/dashboard/scope_pill.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show MoreVert, Sparks, PiggyBank, Plus;

class GoalDetailScreen extends StatelessWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final tints = theme.categoryTints.map(_c).toList();
    final income = _c(theme.colorGreen);

    final contribs = <_Contrib>[
      _Contrib('Ana', tints[0], 'Apr 15', 200),
      _Contrib('Luis', tints[2], 'Apr 10', 250),
      _Contrib('Ana', tints[0], 'Apr 1', 200),
      _Contrib('Luis', tints[2], 'Mar 28', 250),
    ];

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: 'Goal',
      trailing: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size(44, 36),
          onPressed: () {},
          child: MoreVert(width: 20, height: 20, color: fg),
        ),
      ),
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 140),
            children: [
              // Hero
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CatTile(
                          icon: Sparks(width: 16, height: 16, color: accent),
                          color: accent,
                          size: 28,
                          radius: 8,
                        ),
                        const SizedBox(width: 8),
                        const ScopePill(kind: ScopeKind.shared),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Summer trip · Sicily',
                      textAlign: TextAlign.center,
                      style: AppFonts.heading(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reach target · by August 2026',
                      style: AppFonts.body(fontSize: 12, color: muted),
                    ),
                    const SizedBox(height: 22),
                    ProgressRing(
                      value: 0.62,
                      size: 148,
                      stroke: 10,
                      color: accent,
                      trackColor: border,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SAVED',
                            style: AppFonts.sectionLabel(color: muted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '1,860€',
                            style: AppFonts.numeric(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: fg,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'of 3,000€',
                            style: AppFonts.numeric(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Stat row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _StatCell(
                      label: 'Remaining',
                      value: '1,140€',
                      surface: surface,
                      border: border,
                      fg: fg,
                      muted: muted,
                    ),
                    const SizedBox(width: 10),
                    _StatCell(
                      label: 'Monthly need',
                      value: '285€',
                      surface: surface,
                      border: border,
                      fg: fg,
                      muted: muted,
                    ),
                    const SizedBox(width: 10),
                    _StatCell(
                      label: 'Days left',
                      value: '120',
                      surface: surface,
                      border: border,
                      fg: fg,
                      muted: muted,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Linked source
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionLabel('Linked source', color: muted),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                  ),
                  child: Row(
                    children: [
                      CatTile(
                        icon: PiggyBank(
                          width: 18,
                          height: 18,
                          color: tints[3],
                        ),
                        color: tints[3],
                        size: 36,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Household Savings',
                              style: AppFonts.body(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: fg,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'BBVA · 12,400€',
                              style: AppFonts.body(fontSize: 12, color: muted),
                            ),
                          ],
                        ),
                      ),
                      ChevronIcon(color: muted),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Contributions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionLabel(
                  'Contributions',
                  action: 'Add',
                  color: muted,
                  actionColor: accent,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < contribs.length; i++)
                        _ContribRow(
                          c: contribs[i],
                          divider: i < contribs.length - 1,
                          border: border,
                          fg: fg,
                          muted: muted,
                          income: income,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom CTA with gradient mask
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 26),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    bg.withValues(alpha: 0),
                    bg.withValues(alpha: 0.95),
                    bg,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton(
                    color: accent,
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Plus(
                          width: 16,
                          height: 16,
                          color: CupertinoColors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Add contribution',
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;

  const _StatCell({
    required this.label,
    required this.value,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: AppFonts.sectionLabel(color: muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppFonts.numeric(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Contrib {
  final String who;
  final Color color;
  final String date;
  final double amt;
  const _Contrib(this.who, this.color, this.date, this.amt);
}

class _ContribRow extends StatelessWidget {
  final _Contrib c;
  final bool divider;
  final Color border;
  final Color fg;
  final Color muted;
  final Color income;

  const _ContribRow({
    required this.c,
    required this.divider,
    required this.border,
    required this.fg,
    required this.muted,
    required this.income,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        border: divider
            ? Border(bottom: BorderSide(color: border, width: 1))
            : null,
      ),
      child: Row(
        children: [
          MemberAvatar(name: c.who, color: c.color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.who,
                  style: AppFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  c.date,
                  style: AppFonts.body(fontSize: 11, color: muted),
                ),
              ],
            ),
          ),
          Text(
            '+${c.amt.toStringAsFixed(2)}€',
            style: AppFonts.numeric(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: income,
            ),
          ),
        ],
      ),
    );
  }
}
