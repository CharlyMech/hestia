import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/car.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/cars/cars_bloc.dart';
import 'package:hestia/presentation/blocs/user_prefs/user_prefs_bloc.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';

import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:skeletonizer/skeletonizer.dart';

class CarScreen extends StatelessWidget {
  const CarScreen({super.key});

  @override
  Widget build(BuildContext context) => const _CarView();
}

class _CarView extends StatefulWidget {
  const _CarView();

  @override
  State<_CarView> createState() => _CarViewState();
}

class _CarViewState extends State<_CarView> {
  bool _refreshing = false;

  Future<void> _onPullRefresh(BuildContext context) async {
    setState(() => _refreshing = true);
    try {
      final bloc = context.read<CarsBloc>();
      final start = bloc.state;
      final startRev = start is CarsLoaded ? start.revision : -1;
      bloc.add(const CarsRefresh());
      await bloc.stream.firstWhere((s) {
        if (s is CarsLoaded) return s.revision > startRev;
        if (s is CarsError) return true;
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
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final tints = theme.categoryTints.map(hexToColor).toList();
    final showFuelModule = context.watch<UserPrefsBloc>().state.showFuelModule;

    final topInset = MediaQuery.viewPaddingOf(context).top;
    return ColoredBox(
      color: bg,
      child: BlocBuilder<CarsBloc, CarsState>(
        builder: (context, state) {
          final isLoading =
              _refreshing || state is CarsLoading || state is CarsInitial;
          return Skeletonizer(
            enabled: isLoading,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () => _onPullRefresh(context),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.cars_title,
                            style: AppFonts.heading(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: fg,
                            ),
                          ),
                        ),
                        if (showFuelModule)
                          AnimatedButton(
                            size: 32,
                            padding: const EdgeInsets.all(4),
                            onTap: () async {
                              await context.push(AppRoutes.addCar);
                              if (context.mounted) {
                                context
                                    .read<CarsBloc>()
                                    .add(const CarsRefresh());
                              }
                            },
                            child:
                                iconoir.Plus(width: 22, height: 22, color: fg),
                          ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                _buildBody(state, surface, fg, muted, accent, tints, context),
                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    CarsState state,
    Color surface,
    Color fg,
    Color muted,
    Color accent,
    List<Color> tints,
    BuildContext context,
  ) {
    if (state is CarsLoading || state is CarsInitial) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        sliver: SliverList.separated(
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => Container(
            height: 88,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
          ),
        ),
      );
    }
    if (state is CarsError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(state.message,
              style: AppFonts.body(fontSize: 13, color: muted)),
        ),
      );
    }
    final cars = (state as CarsLoaded).cars;
    if (cars.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconoir.Car(width: 48, height: 48, color: muted),
              const SizedBox(height: 12),
              Text(l10n.cars_noVehiclesYet,
                  style: AppFonts.body(
                      fontSize: 15, fontWeight: FontWeight.w600, color: fg)),
              const SizedBox(height: 6),
              Text(l10n.cars_tapToAdd,
                  style: AppFonts.body(fontSize: 12, color: muted)),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      sliver: SliverList.separated(
        itemCount: cars.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _CarCard(
          car: cars[i],
          surface: surface,
          fg: fg,
          muted: muted,
          accent: accent,
          tint: tints[i % tints.length],
          onTap: () async {
            await context.push(AppRoutes.carDetail, extra: cars[i].id);
            if (context.mounted) {
              context.read<CarsBloc>().add(const CarsRefresh());
            }
          },
        ),
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  final Car car;
  final Color surface;
  final Color fg;
  final Color muted;
  final Color accent;
  final Color tint;
  final VoidCallback onTap;

  const _CarCard({
    required this.car,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.tint,
    required this.onTap,
  });

  bool get _isRemote =>
      car.imageUrl != null &&
      (car.imageUrl!.startsWith('http://') ||
          car.imageUrl!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final hasImage = car.imageUrl != null && car.imageUrl!.isNotEmpty;
    final initial = car.name.isNotEmpty ? car.name[0].toUpperCase() : '?';

    final thumb = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64,
        height: 64,
        child: hasImage
            ? (_isRemote
                ? CachedNetworkImage(
                    imageUrl: car.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: tint),
                    errorWidget: (_, __, ___) => _initialBox(initial),
                  )
                : Image.file(
                    File(car.imageUrl!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _initialBox(initial),
                  ))
            : _initialBox(initial),
      ),
    );

    final subline = [
      if (car.make != null) car.make!,
      if (car.model != null) car.model!,
      if (car.year != null) '${car.year}',
    ].join(' · ');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Row(
          children: [
            thumb,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          car.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: fg,
                          ),
                        ),
                      ),
                      _StatusBadge(isActive: car.isActive, accent: accent),
                    ],
                  ),
                  if (subline.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subline,
                        style: AppFonts.body(fontSize: 12, color: muted)),
                  ],
                  if (car.currentOdometerKm != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).cars_odometerKm(
                        car.currentOdometerKm!.toStringAsFixed(0),
                      ),
                      style: AppFonts.numeric(fontSize: 12, color: muted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initialBox(String initial) => Container(
        color: tint,
        alignment: Alignment.center,
        child: Text(
          initial,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  final Color accent;
  const _StatusBadge({required this.isActive, required this.accent});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = isActive ? l10n.cars_statusActive : 'Inactive';
    final mutedHex = context.myTheme.onInactiveColor;
    final muted = hexToColor(mutedHex);
    final color = isActive ? accent : muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppFonts.label(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
