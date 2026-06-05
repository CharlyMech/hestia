import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/car.dart';
import 'package:hestia/domain/entities/fuel_entry.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/fuel/fuel_bloc.dart';
import 'package:hestia/presentation/widgets/common/sliver_pushed_route_shell.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:skeletonizer/skeletonizer.dart';

class CarDetailScreen extends StatefulWidget {
  final String carId;
  const CarDetailScreen({super.key, required this.carId});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  Car? _car;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final (c, _) =
        await AppDependencies.instance.carRepository.getCar(widget.carId);
    if (!mounted) return;
    setState(() {
      _car = c;
      _loading = false;
    });
  }

  void _confirmDelete(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx);
    showCupertinoDialog(
      context: ctx,
      builder: (_) => CupertinoAlertDialog(
        title: Text(l10n.cars_deleteCarTitle),
        content: Text(l10n.cars_deleteCarConfirm(_car!.name)),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              await AppDependencies.instance.carRepository
                  .deleteCar(widget.carId);
              if (ctx.mounted) ctx.pop();
            },
            child: Text(l10n.common_delete),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.common_cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FuelBloc(AppDependencies.instance.fuelEntryRepository,
          AppDependencies.instance.carRepository)
        ..add(FuelLoad(widget.carId)),
      child: Builder(builder: (context) {
        final l10n = AppLocalizations.of(context);
        final theme = context.myTheme;
        final surface = hexToColor(theme.surfaceColor);
        final border = hexToColor(theme.borderColor);
        final fg = hexToColor(theme.onBackgroundColor);
        final muted = hexToColor(theme.onInactiveColor);
        final accent = hexToColor(theme.primaryColor);

        final car = _car;

        if (!_loading && car == null) {
          return SliverPushedRouteShell(
            title: l10n.cars_carTitle,
            content: Center(
              heightFactor: 1,
              child: Text(l10n.cars_notFound,
                  style: AppFonts.body(fontSize: 13, color: muted)),
            ),
          );
        }

        return SliverPushedRouteShell(
          title: car?.name ?? '',
          header: car != null ? _CarHeader(car: car, accent: accent) : null,
          onRefresh: _load,
          actions: car == null
              ? null
              : [
                  AppMenuAction(
                    icon: iconoir.EditPencil(
                        width: 18, height: 18, color: accent),
                    label: l10n.common_edit,
                    onTap: () => context
                        .push(AppRoutes.editCar, extra: car.id)
                        .then((_) => _load()),
                  ),
                  AppMenuAction(
                    icon: car.isActive
                        ? iconoir.EyeClosed(width: 18, height: 18, color: fg)
                        : iconoir.Eye(width: 18, height: 18, color: accent),
                    label: car.isActive
                        ? l10n.pets_setInactive
                        : l10n.pets_setActive,
                    onTap: () async {
                      await AppDependencies.instance.carRepository
                          .updateCar(car.copyWith(isActive: !car.isActive));
                      await _load();
                    },
                  ),
                  AppMenuAction(
                    icon: iconoir.Trash(
                        width: 18,
                        height: 18,
                        color: CupertinoColors.destructiveRed),
                    label: l10n.common_delete,
                    isDestructive: true,
                    onTap: () => _confirmDelete(context),
                  ),
                ],
          content: Skeletonizer(
            enabled: _loading,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              child: _loading
                  ? _CarSkeleton(surface: surface)
                  : _CarBody(
                      l10n: l10n,
                      car: car!,
                      surface: surface,
                      border: border,
                      fg: fg,
                      muted: muted,
                      accent: accent,
                      onAddEntry: () =>
                          context.push(AppRoutes.addCarEntry, extra: car.id),
                      onAnalytics: () =>
                          context.push(AppRoutes.carAnalytics, extra: car.id),
                      onEditEntry: (e) =>
                          context.push(AppRoutes.editCarEntry, extra: e),
                    ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _CarSkeleton extends StatelessWidget {
  final Color surface;
  const _CarSkeleton({required this.surface});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header card shape
        Container(
          height: 116,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
        ),
        const SizedBox(height: 14),
        // CTA button shape
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
        ),
        const SizedBox(height: 18),
        // Section label
        Container(
          height: 14,
          width: 120,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 10),
        // Entry rows
        Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
          child: Column(
            children: List.generate(
              3,
              (i) => Container(
                height: 52,
                margin: EdgeInsets.only(bottom: i < 2 ? 1 : 0),
                color: surface.withValues(alpha: 0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _CarBody extends StatelessWidget {
  final AppLocalizations l10n;
  final Car car;
  final Color surface, border, fg, muted, accent;
  final VoidCallback onAddEntry;
  final VoidCallback onAnalytics;
  final void Function(FuelEntry) onEditEntry;

  const _CarBody({
    required this.l10n,
    required this.car,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.onAddEntry,
    required this.onAnalytics,
    required this.onEditEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
            l10n: l10n,
            car: car,
            surface: surface,
            fg: fg,
            muted: muted,
            accent: accent),
        const SizedBox(height: 14),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onAddEntry,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
            child: Text(l10n.cars_addFillUp,
                style: AppFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white)),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(l10n.cars_recentFillUps,
                  style: AppFonts.sectionLabel(color: muted)),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAnalytics,
              child: Text(l10n.cars_seeAnalytics,
                  style: AppFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accent)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<FuelBloc, FuelState>(
          builder: (ctx, state) {
            if (state is FuelLoading || state is FuelInitial) {
              return Skeletonizer(
                enabled: true,
                child: Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                  ),
                  child: Column(
                    children: List.generate(
                      3,
                      (i) => Container(height: 52, color: surface),
                    ),
                  ),
                ),
              );
            }
            if (state is FuelError) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text(state.message,
                    style: AppFonts.body(fontSize: 13, color: muted)),
              );
            }
            final entries =
                (state as FuelLoaded).entries.take(10).toList();
            if (entries.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(l10n.cars_noFillUpsYet,
                      style: AppFonts.body(fontSize: 13, color: muted)),
                ),
              );
            }
            return Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(AppRadii.xl),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < entries.length; i++)
                    _EntryRow(
                      l10n: l10n,
                      entry: entries[i],
                      border: border,
                      fg: fg,
                      muted: muted,
                      isLast: i == entries.length - 1,
                      onTap: () => onEditEntry(entries[i]),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Header card ───────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final AppLocalizations l10n;
  final Car car;
  final Color surface, fg, muted, accent;
  const _Header({
    required this.l10n,
    required this.car,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.accent,
  });

  bool get _isRemote =>
      car.imageUrl != null &&
      (car.imageUrl!.startsWith('http://') ||
          car.imageUrl!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final hasImage = car.imageUrl != null && car.imageUrl!.isNotEmpty;
    final initial = car.name.isNotEmpty ? car.name[0].toUpperCase() : '?';
    final statusLabel =
        car.isActive ? l10n.cars_statusActive : l10n.cars_statusInactive;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 84,
              height: 84,
              child: hasImage
                  ? (_isRemote
                      ? CachedNetworkImage(
                          imageUrl: car.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: accent),
                          errorWidget: (_, __, ___) => _initialBox(initial),
                        )
                      : Image.file(File(car.imageUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _initialBox(initial)))
                  : _initialBox(initial),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(car.name,
                    style: AppFonts.body(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: fg)),
                if (car.licensePlate != null) ...[
                  const SizedBox(height: 4),
                  Text(car.licensePlate!,
                      style: AppFonts.numeric(fontSize: 12, color: muted)),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(statusLabel.toUpperCase(),
                          style: AppFonts.label(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: accent)),
                    ),
                    if (car.currentOdometerKm != null) ...[
                      const SizedBox(width: 8),
                      Text(
                          l10n.cars_odometerKm(
                            car.currentOdometerKm!.toStringAsFixed(0),
                          ),
                          style:
                              AppFonts.numeric(fontSize: 12, color: muted)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialBox(String initial) => Container(
        color: accent,
        alignment: Alignment.center,
        child: Text(initial,
            style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700)),
      );
}

// ── Full-bleed sliver header ──────────────────────────────────────────────────

class _CarHeader extends StatelessWidget {
  final Car car;
  final Color accent;
  const _CarHeader({required this.car, required this.accent});

  bool get _hasImage => car.imageUrl != null && car.imageUrl!.isNotEmpty;
  bool get _isRemote =>
      _hasImage &&
      (car.imageUrl!.startsWith('http://') ||
          car.imageUrl!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final initial = car.name.isNotEmpty ? car.name[0].toUpperCase() : '?';
    if (_hasImage) {
      return _isRemote
          ? CachedNetworkImage(
              imageUrl: car.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, __) => ColoredBox(color: accent),
              errorWidget: (_, __, ___) => _fallback(initial),
            )
          : Image.file(File(car.imageUrl!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => _fallback(initial));
    }
    return _fallback(initial);
  }

  Widget _fallback(String initial) => Container(
        color: accent,
        alignment: Alignment.center,
        child: Text(initial,
            style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 80,
                fontWeight: FontWeight.w700)),
      );
}

// ── Entry row ─────────────────────────────────────────────────────────────────

class _EntryRow extends StatelessWidget {
  final AppLocalizations l10n;
  final FuelEntry entry;
  final Color border, fg, muted;
  final bool isLast;
  final VoidCallback onTap;
  const _EntryRow({
    required this.l10n,
    required this.entry,
    required this.border,
    required this.fg,
    required this.muted,
    required this.isLast,
    required this.onTap,
  });

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: border, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cars_fillUpLine(
                      entry.liters.toStringAsFixed(1),
                      entry.pricePerLiter.toStringAsFixed(2),
                      entry.isFullTank ? l10n.cars_fillUpFullSuffix : '',
                    ),
                    style: AppFonts.body(
                        fontSize: 13, fontWeight: FontWeight.w500, color: fg),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.cars_fillUpMeta(
                      _fmtDate(entry.filledAt),
                      entry.odometerKm.toStringAsFixed(0),
                    ),
                    style: AppFonts.body(fontSize: 11, color: muted),
                  ),
                ],
              ),
            ),
            Text(l10n.cars_amountEuro(entry.totalAmount.toStringAsFixed(2)),
                style: AppFonts.numeric(
                    fontSize: 14, fontWeight: FontWeight.w700, color: fg)),
          ],
        ),
      ),
    );
  }
}
