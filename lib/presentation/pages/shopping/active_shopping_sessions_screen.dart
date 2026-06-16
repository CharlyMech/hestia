import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/shopping/shopping_sessions_bloc.dart';
import 'package:hestia/presentation/widgets/layout/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/shopping/active_shopping_session_card.dart';
import 'package:hestia/presentation/widgets/shopping/finish_session_flow.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show CartAlt;

/// Lists every active shopping session as a swipeable card.
/// Receives the [ShoppingSessionsBloc] from the pushing screen (provided via
/// the route as `BlocProvider.value`).
class ActiveShoppingSessionsScreen extends StatefulWidget {
  const ActiveShoppingSessionsScreen({super.key});

  @override
  State<ActiveShoppingSessionsScreen> createState() =>
      _ActiveShoppingSessionsScreenState();
}

class _ActiveShoppingSessionsScreenState
    extends State<ActiveShoppingSessionsScreen> {
  bool _refreshing = false;

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    try {
      final bloc = context.read<ShoppingSessionsBloc>();
      final start = bloc.state;
      final startRev = start is ShoppingSessionsLoaded ? start.revision : -1;
      bloc.add(ShoppingSessionsRefresh());
      await bloc.stream.firstWhere((s) {
        if (s is ShoppingSessionsLoaded) return s.revision > startRev;
        if (s is ShoppingSessionsError) return true;
        return false;
      });
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final green = hexToColor(theme.colorGreen);
    final red = hexToColor(theme.colorRed);

    return BlocBuilder<ShoppingSessionsBloc, ShoppingSessionsState>(
      builder: (context, state) {
        final sessions =
            state is ShoppingSessionsLoaded ? state.active : const [];

        return CupertinoPushedRouteShell(
          backgroundColor: bg,
          navBackground: surface,
          borderColor: border,
          foregroundColor: fg,
          titleText: l10n.shopping_activeSessions,
          isLoading: _refreshing,
          childIsScrollable: true,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              CupertinoSliverRefreshControl(onRefresh: _onRefresh),
              if (sessions.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 12,
                      children: [
                        CartAlt(width: 44, height: 44, color: muted),
                        Text(
                          l10n.shopping_noActiveSessions,
                          style: AppFonts.body(fontSize: 13, color: muted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  sliver: SliverList.separated(
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final session = sessions[i];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                        child: ActiveShoppingSessionCard(
                          session: session,
                          surface: surface,
                          border: border,
                          fg: fg,
                          muted: muted,
                          accent: accent,
                          green: green,
                          red: red,
                          onOpen: () => context.push(
                            AppRoutes.shoppingListDetail,
                            extra: session,
                          ),
                          onFinish: () async {
                            final bloc = context.read<ShoppingSessionsBloc>();
                            final done = await FinishSessionFlow.finish(context,
                                session: session);
                            if (done) bloc.add(ShoppingSessionsRefresh());
                          },
                          onDelete: () async {
                            final bloc = context.read<ShoppingSessionsBloc>();
                            final done = await FinishSessionFlow.delete(context,
                                session: session);
                            if (done) bloc.add(ShoppingSessionsRefresh());
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
