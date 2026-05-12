import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/data/services/image_upload_service.dart';
import 'package:hestia/domain/entities/car.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/cars/cars_bloc.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/image_picker_field.dart';
import 'package:hestia/presentation/widgets/common/member_avatar.dart';

class AddEditCarScreen extends StatelessWidget {
  final String? carId;
  const AddEditCarScreen({super.key, this.carId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CarsBloc(AppDependencies.instance.carRepository),
      child: _AddEditCarView(carId: carId),
    );
  }
}

class _AddEditCarView extends StatefulWidget {
  final String? carId;
  const _AddEditCarView({this.carId});
  @override
  State<_AddEditCarView> createState() => _AddEditCarViewState();
}

class _AddEditCarViewState extends State<_AddEditCarView> {
  final _name = TextEditingController();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _plate = TextEditingController();
  final _tank = TextEditingController();
  final _odo = TextEditingController();

  String? _imageUrl;
  FuelType _fuelType = FuelType.gasoline;
  CarStatus _status = CarStatus.active;
  Car? _existing;
  List<Profile> _household = [];
  final Set<String> _selectedMembers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      setState(() => _loading = false);
      return;
    }
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(auth.profile.id);
    if (household != null) {
      final (profiles, _) = await AppDependencies.instance.householdRepository
          .getMemberProfiles(household.id);
      _household = profiles;
    }
    if (widget.carId != null) {
      final (car, _) =
          await AppDependencies.instance.carRepository.getCar(widget.carId!);
      if (car != null) {
        _existing = car;
        _name.text = car.name;
        _make.text = car.make ?? '';
        _model.text = car.model ?? '';
        _year.text = car.year?.toString() ?? '';
        _plate.text = car.licensePlate ?? '';
        _tank.text = car.tankCapacityLiters?.toString() ?? '';
        _odo.text = car.currentOdometerKm?.toString() ?? '';
        _imageUrl = car.imageUrl;
        _fuelType = car.fuelType;
        _status = car.status;
        final (members, _) =
            await AppDependencies.instance.carRepository.getMembers(car.id);
        _selectedMembers.addAll(members.map((m) => m.userId));
      }
    } else {
      _selectedMembers.add(auth.profile.id);
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _make.dispose();
    _model.dispose();
    _year.dispose();
    _plate.dispose();
    _tank.dispose();
    _odo.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(auth.profile.id);
    if (household == null) return;

    final now = DateTime.now();
    final car = Car(
      id: _existing?.id ?? '',
      householdId: household.id,
      name: name,
      imageUrl: _imageUrl,
      make: _make.text.trim().isEmpty ? null : _make.text.trim(),
      model: _model.text.trim().isEmpty ? null : _model.text.trim(),
      year: int.tryParse(_year.text.trim()),
      licensePlate: _plate.text.trim().isEmpty ? null : _plate.text.trim(),
      fuelType: _fuelType,
      tankCapacityLiters: double.tryParse(_tank.text.replaceAll(',', '.')),
      currentOdometerKm: double.tryParse(_odo.text.replaceAll(',', '.')),
      status: _status,
      createdBy: _existing?.createdBy ?? auth.profile.id,
      createdAt: _existing?.createdAt ?? now,
      lastUpdate: now,
    );

    if (!mounted) return;
    if (_existing == null) {
      context.read<CarsBloc>().add(CarsCreate(car, _selectedMembers.toList()));
    } else {
      context.read<CarsBloc>().add(CarsUpdate(car));
    }
    context.pop();
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
    final isEdit = widget.carId != null;

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: isEdit ? 'Edit car' : 'New car',
      trailing: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
          onTap: _save,
          behavior: HitTestBehavior.opaque,
          child: Text(
            'Save',
            style: AppFonts.body(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ),
      ),
      child: _loading
          ? const Center(child: CupertinoActivityIndicator())
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Center(
                  child: ImagePickerField(
                    bucket: ImageBuckets.cars,
                    path: '${_existing?.id ?? 'new'}/cover.jpg',
                    value: _imageUrl,
                    onChanged: (v) => setState(() => _imageUrl = v),
                    size: 120,
                    circle: false,
                    fallbackText: _name.text.isNotEmpty
                        ? _name.text[0].toUpperCase()
                        : '?',
                  ),
                ),
                const SizedBox(height: 20),
                _Field(
                    label: 'Name',
                    controller: _name,
                    surface: surface,
                    fg: fg,
                    muted: muted),
                const SizedBox(height: 12),
                _Field(
                    label: 'Make',
                    controller: _make,
                    surface: surface,
                    fg: fg,
                    muted: muted),
                const SizedBox(height: 12),
                _Field(
                    label: 'Model',
                    controller: _model,
                    surface: surface,
                    fg: fg,
                    muted: muted),
                const SizedBox(height: 12),
                _Field(
                    label: 'Year',
                    controller: _year,
                    keyboard: TextInputType.number,
                    surface: surface,
                    fg: fg,
                    muted: muted),
                const SizedBox(height: 12),
                _Field(
                    label: 'License plate',
                    controller: _plate,
                    surface: surface,
                    fg: fg,
                    muted: muted),
                const SizedBox(height: 12),
                _Segmented<FuelType>(
                  label: l10n.cars_fuelType,
                  options: const [
                    (FuelType.gasoline, 'Gasoline'),
                    (FuelType.diesel, 'Diesel'),
                    (FuelType.electric, 'Electric'),
                    (FuelType.hybrid, 'Hybrid'),
                  ],
                  value: _fuelType,
                  onChanged: (v) => setState(() => _fuelType = v),
                  surface: surface,
                  fg: fg,
                  muted: muted,
                  accent: accent,
                ),
                const SizedBox(height: 12),
                _Field(
                    label: 'Tank capacity (L)',
                    controller: _tank,
                    keyboard:
                        const TextInputType.numberWithOptions(decimal: true),
                    surface: surface,
                    fg: fg,
                    muted: muted),
                const SizedBox(height: 12),
                _Field(
                    label: 'Current odometer (km)',
                    controller: _odo,
                    keyboard:
                        const TextInputType.numberWithOptions(decimal: true),
                    surface: surface,
                    fg: fg,
                    muted: muted),
                const SizedBox(height: 12),
                _Segmented<CarStatus>(
                  label: 'Status',
                  options: const [
                    (CarStatus.active, 'Active'),
                    (CarStatus.sold, 'Sold'),
                    (CarStatus.scrap, 'Scrap'),
                  ],
                  value: _status,
                  onChanged: (v) => setState(() => _status = v),
                  surface: surface,
                  fg: fg,
                  muted: muted,
                  accent: accent,
                ),
                const SizedBox(height: 18),
                Text('DRIVERS', style: AppFonts.sectionLabel(color: muted)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                  ),
                  child: Column(
                    children: [
                      for (final p in _household)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() {
                            if (_selectedMembers.contains(p.id)) {
                              _selectedMembers.remove(p.id);
                            } else {
                              _selectedMembers.add(p.id);
                            }
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 8),
                            child: Row(
                              children: [
                                MemberAvatar(
                                  name: p.displayName ?? p.email,
                                  color: p.calendarColor != null
                                      ? Color(int.parse(p.calendarColor!
                                          .replaceFirst('#', '0xff')))
                                      : accent,
                                  imageUrl: p.avatarUrl,
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    p.displayName ?? p.email,
                                    style: AppFonts.body(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: fg),
                                  ),
                                ),
                                Icon(
                                  _selectedMembers.contains(p.id)
                                      ? CupertinoIcons.checkmark_circle_fill
                                      : CupertinoIcons.circle,
                                  color: _selectedMembers.contains(p.id)
                                      ? accent
                                      : muted,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;
  final Color surface;
  final Color fg;
  final Color muted;
  const _Field({
    required this.label,
    required this.controller,
    this.keyboard,
    required this.surface,
    required this.fg,
    required this.muted,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppFonts.sectionLabel(color: muted)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CupertinoTextField(
            controller: controller,
            keyboardType: keyboard,
            placeholder: '',
            decoration: const BoxDecoration(),
            style: AppFonts.body(
                fontSize: 14, fontWeight: FontWeight.w500, color: fg),
          ),
        ),
      ],
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  final String label;
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;
  final Color surface;
  final Color fg;
  final Color muted;
  final Color accent;
  const _Segmented({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppFonts.sectionLabel(color: muted)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              for (final (v, lbl) in options)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(v),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: value == v ? accent : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lbl,
                        style: AppFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: value == v ? CupertinoColors.white : fg,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
