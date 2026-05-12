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
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:skeletonizer/skeletonizer.dart';

class FuelScreen extends StatelessWidget {
  const FuelScreen({super.key});

  @override
  Widget build(BuildContext context) => const _FuelView();
}

class _FuelView extends StatefulWidget {
  const _FuelView();

  @override
  State<_FuelView> createState() => _FuelViewState();
}

class _FuelViewState extends State<_FuelView> {
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
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final tints = theme.categoryTints.map(_c).toList();

    return ColoredBox(
      color: bg,
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<CarsBloc, CarsState>(
          builder: (context, state) {
            return Skeletonizer(
              enabled: _refreshing,
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
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
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
                          IconBtn(
                            icon:
                                iconoir.Plus(width: 16, height: 16, color: fg),
                            surface: surface,
                            border: border,
                            onTap: () async {
                              await context.push(AppRoutes.addCar);
                              if (context.mounted) {
                                context
                                    .read<CarsBloc>()
                                    .add(const CarsRefresh());
                              }
                            },
                            size: 36,
                            radius: AppRadii.lg,
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
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CupertinoActivityIndicator()),
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
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconoir.Car(width: 48, height: 48, color: muted),
              const SizedBox(height: 12),
              Text('No vehicles yet',
                  style: AppFonts.body(
                      fontSize: 15, fontWeight: FontWeight.w600, color: fg)),
              const SizedBox(height: 6),
              Text('Tap + to add one',
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

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
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
                      _StatusBadge(status: car.status, accent: accent),
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
                      '${car.currentOdometerKm!.toStringAsFixed(0)} km',
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
  final CarStatus status;
  final Color accent;
  const _StatusBadge({required this.status, required this.accent});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      CarStatus.active => 'Active',
      CarStatus.sold => 'Sold',
      CarStatus.scrap => 'Scrap',
    };
    final mutedHex = context.myTheme.onInactiveColor;
    final muted = Color(int.parse(mutedHex.replaceFirst('#', '0xff')));
    final color = status == CarStatus.active ? accent : muted;
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
