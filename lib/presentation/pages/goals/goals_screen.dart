import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/widgets/common/animated_progress_bar.dart';
import 'package:hestia/presentation/widgets/common/member_avatar.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:hestia/presentation/widgets/dashboard/progress_ring.dart';
import 'package:hestia/presentation/widgets/dashboard/scope_pill.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Plus, Calendar;

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  int _filter = 0; // 0=All 1=Shared 2=Personal

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final surface2 = _c(theme.surface2Color);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final tints = theme.categoryTints.map(_c).toList();
    final income = _c(theme.colorGreen);

    final goals = <_Goal>[
      _Goal(
        title: 'Summer trip · Sicily',
        v: 0.62,
        cur: 1860,
        tgt: 3000,
        color: accent,
        scope: ScopeKind.shared,
        deadline: 'Aug 2026',
        members: [
          (name: 'Ana', color: tints[0]),
          (name: 'Luis', color: tints[2]),
        ],
      ),
      _Goal(
        title: 'Emergency fund',
        v: 0.34,
        cur: 3400,
        tgt: 10000,
        color: tints[0],
        scope: ScopeKind.shared,
        deadline: 'No deadline',
        members: [
          (name: 'Ana', color: tints[0]),
          (name: 'Luis', color: tints[2]),
        ],
      ),
      _Goal(
        title: 'New laptop',
        v: 0.78,
        cur: 1560,
        tgt: 2000,
        color: income,
        scope: ScopeKind.personal,
        deadline: 'Jun 2026',
        members: const [],
      ),
      _Goal(
        title: 'Photography course',
        v: 0.15,
        cur: 90,
        tgt: 600,
        color: tints[1],
        scope: ScopeKind.personal,
        deadline: 'Sep 2026',
        members: const [],
      ),
    ];

    final filtered = switch (_filter) {
      1 => goals.where((g) => g.scope == ScopeKind.shared).toList(),
      2 => goals.where((g) => g.scope == ScopeKind.personal).toList(),
      _ => goals,
    };

    Widget pill(String label, int idx) {
      final active = _filter == idx;
      return GestureDetector(
        onTap: () => setState(() => _filter = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: active ? surface2 : const Color(0x00000000),
            border: Border.all(
              color: active ? muted.withValues(alpha: 0.4) : border,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppFonts.body(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: active ? fg : muted,
            ),
          ),
        ),
      );
    }

    Widget goalCard(_Goal g) => GestureDetector(
          onTap: () => context.push(AppRoutes.goalDetail, extra: g.title),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              border: Border.all(color: border, width: 1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    ProgressRing(
                      value: g.v,
                      size: 54,
                      stroke: 5,
                      color: g.color,
                      trackColor: border,
                      child: Text(
                        '${(g.v * 100).round()}%',
                        style: AppFonts.numeric(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  g.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.body(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: fg,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              ScopePill(kind: g.scope),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${_fmt(g.cur)}€',
                                style: AppFonts.numeric(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: fg,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '/ ${_fmt(g.tgt)}€',
                                style: AppFonts.body(
                                  fontSize: 12,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Calendar(
                                width: 11,
                                height: 11,
                                color: muted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                g.deadline,
                                style: AppFonts.body(
                                  fontSize: 11,
                                  color: muted,
                                ),
                              ),
                              if (g.members.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                AvatarStack(
                                  members: g.members,
                                  size: 14,
                                  ringColor: surface,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedProgressBar(
                  value: g.v,
                  trackColor: border,
                  fillColor: g.color,
                ),
              ],
            ),
          ),
        );

    return ScreenShell(
      bg: bg,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Goals',
                        style: AppFonts.heading(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '4 active · saving 52% on track',
                        style: AppFonts.body(fontSize: 13, color: muted),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.addGoal),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Plus(
                        width: 18,
                        height: 18,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Summary card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surface,
                border: Border.all(color: border, width: 1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  ProgressRing(
                    value: 0.52,
                    size: 68,
                    stroke: 6,
                    color: accent,
                    trackColor: border,
                    child: Text(
                      '52%',
                      style: AppFonts.numeric(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall progress',
                          style: AppFonts.body(fontSize: 12, color: muted),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '6,910€',
                              style: AppFonts.numeric(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: fg,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/ 15,600€',
                              style: AppFonts.body(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+420€ contributed this month',
                          style: AppFonts.body(fontSize: 11, color: muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 18)),

        // Filter pills
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                pill('All', 0),
                const SizedBox(width: 6),
                pill('Shared', 1),
                const SizedBox(width: 6),
                pill('Personal', 2),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // Goal cards
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: filtered.length,
            itemBuilder: (_, i) => goalCard(filtered[i]),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
          ),
        ),
      ],
    );
  }

  String _fmt(num n) => n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Goal {
  final String title;
  final double v;
  final num cur;
  final num tgt;
  final Color color;
  final ScopeKind scope;
  final String deadline;
  final List<({String name, Color color})> members;

  const _Goal({
    required this.title,
    required this.v,
    required this.cur,
    required this.tgt,
    required this.color,
    required this.scope,
    required this.deadline,
    required this.members,
  });
}
