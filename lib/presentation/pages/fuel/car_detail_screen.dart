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
import 'package:hestia/presentation/blocs/fuel/fuel_bloc.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FuelBloc(AppDependencies.instance.fuelEntryRepository)
        ..add(FuelLoad(widget.carId)),
      child: Builder(builder: (context) {
        final theme = context.myTheme;
        final bg = _c(theme.backgroundColor);
        final surface = _c(theme.surfaceColor);
        final border = _c(theme.borderColor);
        final fg = _c(theme.onBackgroundColor);
        final muted = _c(theme.onInactiveColor);
        final accent = _c(theme.primaryColor);

        return CupertinoPushedRouteShell(
          backgroundColor: bg,
          navBackground: surface,
          borderColor: border,
          foregroundColor: fg,
          titleText: _car?.name ?? 'Car',
          trailing: _car == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context
                        .push(AppRoutes.editCar, extra: _car!.id)
                        .then((_) => _load()),
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      child: iconoir.EditPencil(
                          width: 18, height: 18, color: accent),
                    ),
                  ),
                ),
          child: ScreenShell(
            bg: bg,
            bottomPadding: 32,
            slivers: [
              if (_loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CupertinoActivityIndicator()),
                  ),
                )
              else if (_car == null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text('Car not found',
                          style: AppFonts.body(fontSize: 13, color: muted)),
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: _Header(
                    car: _car!,
                    surface: surface,
                    fg: fg,
                    muted: muted,
                    accent: accent,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          context.push(AppRoutes.addCarEntry, extra: _car!.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                        ),
                        child: Text(
                          'Add fill-up',
                          style: AppFonts.body(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 18)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('RECENT FILL-UPS',
                              style: AppFonts.sectionLabel(color: muted)),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => context.push(AppRoutes.carAnalytics,
                              extra: _car!.id),
                          child: Text(
                            'See analytics',
                            style: AppFonts.body(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverToBoxAdapter(
                  child: BlocBuilder<FuelBloc, FuelState>(
                    builder: (ctx, state) {
                      if (state is FuelLoading || state is FuelInitial) {
                        return const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CupertinoActivityIndicator()),
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
                            child: Text('No fill-ups yet',
                                style:
                                    AppFonts.body(fontSize: 13, color: muted)),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(AppRadii.xl),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              for (var i = 0; i < entries.length; i++)
                                _EntryRow(
                                  entry: entries[i],
                                  border: border,
                                  fg: fg,
                                  muted: muted,
                                  isLast: i == entries.length - 1,
                                  onTap: () => context.push(AppRoutes.editCarEntry,
                                      extra: entries[i]),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Header extends StatelessWidget {
  final Car car;
  final Color surface;
  final Color fg;
  final Color muted;
  final Color accent;
  const _Header({
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
    final statusLabel = switch (car.status) {
      CarStatus.active => 'Active',
      CarStatus.sold => 'Sold',
      CarStatus.scrap => 'Scrap',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
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
                        color: fg,
                      )),
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
                              color: accent,
                            )),
                      ),
                      if (car.currentOdometerKm != null) ...[
                        const SizedBox(width: 8),
                        Text('${car.currentOdometerKm!.toStringAsFixed(0)} km',
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
              fontWeight: FontWeight.w700,
            )),
      );
}

class _EntryRow extends StatelessWidget {
  final FuelEntry entry;
  final Color border;
  final Color fg;
  final Color muted;
  final bool isLast;
  final VoidCallback onTap;
  const _EntryRow({
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
                    '${entry.liters.toStringAsFixed(1)} L · ${entry.pricePerLiter.toStringAsFixed(2)} €/L${entry.isFullTank ? ' · full' : ''}',
                    style: AppFonts.body(
                        fontSize: 13, fontWeight: FontWeight.w500, color: fg),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_fmtDate(entry.filledAt)} · ${entry.odometerKm.toStringAsFixed(0)} km',
                    style: AppFonts.body(fontSize: 11, color: muted),
                  ),
                ],
              ),
            ),
            Text(
              '${entry.totalAmount.toStringAsFixed(2)} €',
              style: AppFonts.numeric(
                  fontSize: 14, fontWeight: FontWeight.w700, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
