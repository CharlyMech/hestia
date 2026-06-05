import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/fuel_entry.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/fuel/fuel_bloc.dart';
import 'package:hestia/domain/entities/transaction_source.dart';
import 'package:hestia/presentation/widgets/common/app_toast.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';

class AddEditFuelEntryScreen extends StatelessWidget {
  /// Either existing entry (edit) or carId (create).
  final FuelEntry? entry;
  final String? carId;
  const AddEditFuelEntryScreen({super.key, this.entry, this.carId})
      : assert(entry != null || carId != null);

  @override
  Widget build(BuildContext context) {
    final id = entry?.carId ?? carId!;
    return BlocProvider(
      create: (_) => FuelBloc(AppDependencies.instance.fuelEntryRepository,
          AppDependencies.instance.carRepository)
        ..add(FuelLoad(id)),
      child: _AddEditFuelView(entry: entry, carId: id),
    );
  }
}

class _AddEditFuelView extends StatefulWidget {
  final FuelEntry? entry;
  final String carId;
  const _AddEditFuelView({this.entry, required this.carId});
  @override
  State<_AddEditFuelView> createState() => _AddEditFuelViewState();
}

class _AddEditFuelViewState extends State<_AddEditFuelView> {
  late DateTime _filledAt;
  final _odo = TextEditingController();
  final _liters = TextEditingController();
  final _ppl = TextEditingController();
  final _total = TextEditingController();
  final _notes = TextEditingController();
  bool _isFullTank = true;
  bool _createTransaction = false;
  TransactionSource? _station;
  List<TransactionSource> _stations = [];
  bool _totalDirty = false;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _filledAt = e?.filledAt ?? DateTime.now();
    if (e != null) {
      _odo.text = e.odometerKm.toString();
      _liters.text = e.liters.toString();
      _ppl.text = e.pricePerLiter.toString();
      _total.text = e.totalAmount.toString();
      _notes.text = e.notes ?? '';
      _isFullTank = e.isFullTank;
    }
    _liters.addListener(_recompute);
    _ppl.addListener(_recompute);
    _total.addListener(() => _totalDirty = true);
    _loadStations();
  }

  Future<void> _loadStations() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(auth.profile.id);
    if (household == null || !mounted) return;
    final (sources, _) = await AppDependencies
        .instance.transactionSourceRepository
        .getAll(householdId: household.id);
    if (!mounted) return;
    // Only show merchant-kind sources as stations
    final merchants = sources
        .where((s) =>
            s.kind == TransactionSourceKind.merchant ||
            s.kind == TransactionSourceKind.other)
        .toList();
    setState(() {
      _stations = merchants;
      // Pre-select station from existing entry
      if (widget.entry?.stationSourceId != null) {
        _station = merchants.cast<TransactionSource?>().firstWhere(
              (s) => s?.id == widget.entry!.stationSourceId,
              orElse: () => null,
            );
      }
    });
  }

  void _openStationPicker(
      Color surface, Color border, Color fg, Color muted, Color accent) {
    if (_stations.isEmpty) return;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        color: surface,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() => _station = null);
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(children: [
                    Text('None',
                        style: AppFonts.body(fontSize: 15, color: muted)),
                  ]),
                ),
              ),
              Container(height: 0.5, color: border),
              for (final src in _stations) ...[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() => _station = src);
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          src.name,
                          style: AppFonts.body(
                            fontSize: 15,
                            color: _station?.id == src.id ? accent : fg,
                            fontWeight: _station?.id == src.id
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (_station?.id == src.id)
                        Icon(CupertinoIcons.checkmark, size: 16, color: accent),
                    ]),
                  ),
                ),
                Container(height: 0.5, color: border),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _recompute() {
    if (_totalDirty) return;
    final l = double.tryParse(_liters.text.replaceAll(',', '.'));
    final p = double.tryParse(_ppl.text.replaceAll(',', '.'));
    if (l != null && p != null) {
      _total.text = (l * p).toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _odo.dispose();
    _liters.dispose();
    _ppl.dispose();
    _total.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final theme = context.myTheme;
    final surface = hexToColor(theme.surfaceColor);
    DateTime tmp = _filledAt;
    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: surface,
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: CupertinoDatePicker(
                initialDateTime: _filledAt,
                mode: CupertinoDatePickerMode.dateAndTime,
                onDateTimeChanged: (d) => tmp = d,
              ),
            ),
            CupertinoButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
    if (mounted) setState(() => _filledAt = tmp);
  }

  Future<void> _save() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final odo = double.tryParse(_odo.text.replaceAll(',', '.'));
    final liters = double.tryParse(_liters.text.replaceAll(',', '.'));
    final ppl = double.tryParse(_ppl.text.replaceAll(',', '.'));
    if (odo == null || liters == null || ppl == null) return;
    final total =
        double.tryParse(_total.text.replaceAll(',', '.')) ?? liters * ppl;

    final now = DateTime.now();
    final entry = FuelEntry(
      id: widget.entry?.id ?? '',
      carId: widget.carId,
      odometerKm: odo,
      liters: liters,
      pricePerLiter: ppl,
      totalAmount: total,
      isFullTank: _isFullTank,
      stationSourceId: _station?.id,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      filledAt: _filledAt,
      createdBy: widget.entry?.createdBy ?? auth.profile.id,
      createdAt: widget.entry?.createdAt ?? now,
    );

    if (widget.entry == null) {
      context
          .read<FuelBloc>()
          .add(FuelCreate(entry, createTransaction: _createTransaction));
      if (mounted) {
        context.showToast(const AppToastConfig(
            type: ToastType.success, title: 'Fuel entry added'));
      }
    } else {
      context.read<FuelBloc>().add(FuelUpdate(entry));
      if (mounted) {
        context.showToast(const AppToastConfig(
            type: ToastType.success, title: 'Fuel entry updated'));
      }
    }
    if (mounted) context.pop();
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final isEdit = widget.entry != null;

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: isEdit ? 'Edit fill-up' : 'Add fill-up',
      trailing: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _save,
          child: Text('Save',
              style: AppFonts.body(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: accent,
              )),
        ),
      ),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _pickDate,
            child: _ReadOnlyField(
              label: 'Filled at',
              value: _fmtDate(_filledAt),
              surface: surface,
              fg: fg,
              muted: muted,
            ),
          ),
          const SizedBox(height: 12),
          _Field(
              label: 'Odometer (km)',
              controller: _odo,
              keyboard: const TextInputType.numberWithOptions(decimal: true),
              surface: surface,
              fg: fg,
              muted: muted),
          const SizedBox(height: 12),
          _Field(
              label: 'Liters',
              controller: _liters,
              keyboard: const TextInputType.numberWithOptions(decimal: true),
              surface: surface,
              fg: fg,
              muted: muted),
          const SizedBox(height: 12),
          _Field(
              label: 'Price per liter (€)',
              controller: _ppl,
              keyboard: const TextInputType.numberWithOptions(decimal: true),
              surface: surface,
              fg: fg,
              muted: muted),
          const SizedBox(height: 12),
          _Field(
              label: 'Total (€)',
              controller: _total,
              keyboard: const TextInputType.numberWithOptions(decimal: true),
              surface: surface,
              fg: fg,
              muted: muted),
          const SizedBox(height: 12),
          if (_stations.isNotEmpty)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  _openStationPicker(surface, border, fg, muted, accent),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border, width: 0.8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text('STATION',
                              style: AppFonts.body(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: muted,
                                  letterSpacing: 0.5)),
                          Text(
                            _station?.name ?? 'None',
                            style: AppFonts.body(
                              fontSize: 14,
                              color: _station != null ? fg : muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(CupertinoIcons.chevron_up_chevron_down,
                        size: 14, color: muted),
                  ],
                ),
              ),
            ),
          if (_stations.isNotEmpty) const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text('Full tank',
                      style: AppFonts.body(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: fg)),
                ),
                FSwitch(
                  value: _isFullTank,
                  onChange: (v) => setState(() => _isFullTank = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Also create transaction',
                          style: AppFonts.body(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: fg)),
                      const SizedBox(height: 2),
                      Text('Coming soon',
                          style: AppFonts.body(fontSize: 11, color: muted)),
                    ],
                  ),
                ),
                FSwitch(
                  value: _createTransaction,
                  onChange: (v) => setState(() => _createTransaction = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('NOTES', style: AppFonts.sectionLabel(color: muted)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
            child: CupertinoTextField(
              controller: _notes,
              maxLines: 3,
              decoration: const BoxDecoration(),
              placeholder: 'Optional notes',
              style: AppFonts.body(fontSize: 13, color: fg),
            ),
          ),
        ],
      ),
    );
  }
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
            decoration: const BoxDecoration(),
            style: AppFonts.body(
                fontSize: 14, fontWeight: FontWeight.w500, color: fg),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final Color surface;
  final Color fg;
  final Color muted;
  const _ReadOnlyField({
    required this.label,
    required this.value,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value,
              style: AppFonts.body(
                  fontSize: 14, fontWeight: FontWeight.w500, color: fg)),
        ),
      ],
    );
  }
}
