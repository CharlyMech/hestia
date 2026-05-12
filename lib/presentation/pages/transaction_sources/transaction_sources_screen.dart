import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
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
  final bool embedded;

  const TransactionSourcesScreen({super.key, this.embedded = false});

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
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    if (auth is! AuthAuthenticated || _resolving || _householdId == null) {
      final body = auth is! AuthAuthenticated
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
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                        ),
                      ),
                    ),
                ],
              ),
            );
      if (widget.embedded) return body;
      return CupertinoPushedRouteShell(
        backgroundColor: bg,
        navBackground: surface,
        borderColor: border,
        foregroundColor: fg,
        titleText: 'Transaction sources',
        child: body,
      );
    }
    return BlocProvider(
      create: (_) => TransactionSourcesBloc(
        AppDependencies.instance.transactionSourceRepository,
      )..add(TransactionSourcesLoad(householdId: _householdId!)),
      child: _Body(
        householdId: _householdId!,
        userId: auth.profile.id,
        embedded: widget.embedded,
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Body extends StatelessWidget {
  final String householdId;
  final String userId;
  final bool embedded;
  const _Body({
    required this.householdId,
    required this.userId,
    this.embedded = false,
  });

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

    final addButton = IconBtn(
      icon: Plus(width: 16, height: 16, color: fg),
      surface: surface,
      border: border,
      onTap: () => _openSheet(context),
      size: 36,
      radius: AppRadii.lg,
    );

    final content = BlocBuilder<TransactionSourcesBloc, TransactionSourcesState>(
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
                        borderRadius: BorderRadius.circular(AppRadii.xl),
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
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            if (embedded)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${loaded.sources.length} sources',
                          style: AppFonts.body(fontSize: 13, color: muted),
                        ),
                      ),
                      addButton,
                    ],
                  ),
                ),
              ),
            if (loaded.sources.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No sources yet — tap + to add one',
                    style: AppFonts.body(fontSize: 13, color: muted),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList.separated(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                        ),
                        child: Row(
                          spacing: 12,
                          children: [
                            _SourceIcon(
                              imageUrl: s.imageUrl,
                              name: s.name,
                              color: color,
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
                ),
              ),
          ],
        );
      },
    );

    if (embedded) return content;
    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: 'Transaction sources',
      trailing: addButton,
      child: content,
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _SourceIcon extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final Color color;

  const _SourceIcon({
    required this.imageUrl,
    required this.name,
    required this.color,
  });

  bool get _isRemote =>
      imageUrl != null &&
      (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final fallback = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: AppFonts.body(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );

    if (!hasImage) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: SizedBox(
        width: 32,
        height: 32,
        child: _isRemote
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              )
            : Image.file(
                File(imageUrl!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}
