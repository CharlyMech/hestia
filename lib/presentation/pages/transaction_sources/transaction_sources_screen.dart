import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/transaction_source.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/transaction_sources/transaction_sources_bloc.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/transaction_sources/transaction_source_form.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Plus;
import 'package:skeletonizer/skeletonizer.dart';

/// Household-wide list of [TransactionSource] entries (Netflix, Spotify,
/// employers, merchants, etc.). Tap a row to edit, header "+" to create.
class TransactionSourcesScreen extends StatefulWidget {
  const TransactionSourcesScreen({super.key});

  @override
  State<TransactionSourcesScreen> createState() =>
      _TransactionSourcesScreenState();
}

class _TransactionSourcesScreenState extends State<TransactionSourcesScreen> {
  String? _householdId;
  bool _resolving = true;

  @override
  void initState() {
    super.initState();
    _resolveHousehold();
  }

  Future<void> _resolveHousehold() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      if (mounted) setState(() => _resolving = false);
      return;
    }
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(auth.profile.id);
    if (!mounted) return;
    setState(() {
      _householdId = household?.id;
      _resolving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    if (auth is! AuthAuthenticated || _resolving || _householdId == null) {
      return CupertinoPushedRouteShell(
        backgroundColor: bg,
        borderColor: border,
        foregroundColor: fg,
        titleText: 'Transaction sources',
        child: auth is! AuthAuthenticated
            ? Center(
                child: Text(
                  'Sign in to manage sources',
                  style: AppFonts.body(fontSize: 14, color: muted),
                ),
              )
            : Skeletonizer(
                enabled: true,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    for (var i = 0; i < 5; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: muted.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppRadii.xl),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      );
    }
    return BlocProvider(
      create: (_) => TransactionSourcesBloc(
        AppDependencies.instance.transactionSourceRepository,
      )..add(TransactionSourcesLoad(householdId: _householdId!)),
      child: _Body(householdId: _householdId!, userId: auth.profile.id),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Body extends StatelessWidget {
  final String householdId;
  final String userId;
  const _Body({required this.householdId, required this.userId});

  Future<void> _openSheet(BuildContext context, {TransactionSource? existing}) {
    return showAppBottomSheet<void>(
      context: context,
      title: existing == null ? 'New source' : 'Edit source',
      heightFactor: 0.8,
      child: BlocProvider.value(
        value: context.read<TransactionSourcesBloc>(),
        child: TransactionSourceForm(
          existing: existing,
          householdId: householdId,
          userId: userId,
        ),
      ),
    );
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

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      borderColor: border,
      foregroundColor: fg,
      titleText: 'Transaction sources',
      trailing: IconBtn(
        icon: Plus(width: 16, height: 16, color: fg),
        surface: surface,
        border: border,
        onTap: () => _openSheet(context),
        size: 36,
        radius: AppRadii.lg,
      ),
      child: BlocBuilder<TransactionSourcesBloc, TransactionSourcesState>(
        builder: (context, state) {
          if (state is TransactionSourcesLoading ||
              state is TransactionSourcesInitial) {
            return Skeletonizer(
              enabled: true,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  for (var i = 0; i < 6; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: surface,
                          border: Border.all(color: border),
                          borderRadius:
                              BorderRadius.circular(AppRadii.xl),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
          if (state is TransactionSourcesError) {
            return Center(
              child: Text(
                state.message,
                style: AppFonts.body(fontSize: 13, color: muted),
              ),
            );
          }
          final loaded = state as TransactionSourcesLoaded;
          if (loaded.sources.isEmpty) {
            return Center(
              child: Text(
                'No sources yet — tap + to add one',
                style: AppFonts.body(fontSize: 13, color: muted),
              ),
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            itemCount: loaded.sources.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final s = loaded.sources[i];
              final color = s.color != null
                  ? Color(int.parse(s.color!.replaceFirst('#', '0xff')))
                  : accent;
              return GestureDetector(
                onTap: () => _openSheet(context, existing: s),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border.all(color: border, width: 1),
                    borderRadius:
                        BorderRadius.circular(AppRadii.xl),
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.18),
                          borderRadius:
                              BorderRadius.circular(AppRadii.md),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                          style: AppFonts.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(
                              s.name,
                              style: AppFonts.body(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: fg,
                              ),
                            ),
                            Text(
                              s.kind.name,
                              style: AppFonts.body(
                                fontSize: 11,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
