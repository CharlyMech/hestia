import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/car_maintenance_record.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/cars/car_maintenance_bloc.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/layout/cupertino_pushed_route_shell.dart';
import 'package:hestia/core/config/dependencies.dart';

class AddEditMaintenanceRecordScreen extends StatelessWidget {
  /// carId is required when creating a new record.
  final String? carId;

  /// existing is set when editing.
  final CarMaintenanceRecord? existing;

  const AddEditMaintenanceRecordScreen({super.key, this.carId, this.existing})
      : assert(carId != null || existing != null);

  @override
  Widget build(BuildContext context) {
    return _AddEditMaintenanceRecordView(carId: carId, existing: existing);
  }
}

class _AddEditMaintenanceRecordView extends StatefulWidget {
  final String? carId;
  final CarMaintenanceRecord? existing;

  const _AddEditMaintenanceRecordView({this.carId, this.existing});

  @override
  State<_AddEditMaintenanceRecordView> createState() =>
      _AddEditMaintenanceRecordViewState();
}

class _AddEditMaintenanceRecordViewState
    extends State<_AddEditMaintenanceRecordView> {
  final _title = TextEditingController();
  final _workshop = TextEditingController();
  final _odometer = TextEditingController();
  final _cost = TextEditingController();
  final _notes = TextEditingController();

  MaintenanceType _type = MaintenanceType.mechanic;
  DateTime _recordedAt = DateTime.now();
  DateTime? _nextDueAt;
  bool _createExpense = false;

  List<BankAccount> _bankAccounts = const [];
  BankAccount? _selectedAccount;
  bool _loadingAccounts = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _title.text = e.title;
      _workshop.text = e.workshop ?? '';
      _odometer.text = e.odometerKm?.toString() ?? '';
      _cost.text = e.cost?.toString() ?? '';
      _notes.text = e.notes ?? '';
      _type = e.type;
      _recordedAt = e.recordedAt;
      _nextDueAt = e.nextDueAt;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _workshop.dispose();
    _odometer.dispose();
    _cost.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _loadBankAccounts() async {
    if (_bankAccounts.isNotEmpty || _loadingAccounts) return;
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    setState(() => _loadingAccounts = true);
    final deps = AppDependencies.instance;
    final (household, _) =
        await deps.householdRepository.getCurrentHousehold(auth.profile.id);
    if (!mounted) return;
    final householdId = household?.id ?? '';
    final (accounts, _) = await deps.bankAccountRepository.getBankAccounts(
      householdId: householdId,
      viewMode: ViewMode.household,
    );
    if (mounted) {
      setState(() {
        _bankAccounts = accounts;
        _loadingAccounts = false;
        if (_selectedAccount == null && accounts.isNotEmpty) {
          _selectedAccount = accounts.first;
        }
      });
    }
  }

  Future<void> _save() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final title = _title.text.trim();
    if (title.isEmpty) return;

    final resolvedCarId = widget.existing?.carId ?? widget.carId!;
    final now = DateTime.now();

    final record = CarMaintenanceRecord(
      id: widget.existing?.id ?? '',
      carId: resolvedCarId,
      type: _type,
      title: title,
      workshop:
          _workshop.text.trim().isEmpty ? null : _workshop.text.trim(),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      recordedAt: _recordedAt,
      nextDueAt: _nextDueAt,
      odometerKm: int.tryParse(_odometer.text.replaceAll(',', '.')),
      cost: double.tryParse(_cost.text.replaceAll(',', '.')),
      transactionId: widget.existing?.transactionId,
      appointmentId: widget.existing?.appointmentId,
      createdBy: widget.existing?.createdBy ?? auth.profile.id,
      createdAt: widget.existing?.createdAt ?? now,
    );

    Map<String, dynamic>? transactionPayload;
    if (_createExpense && _selectedAccount != null && record.cost != null) {
      transactionPayload = {
        'bank_account_id': _selectedAccount!.id,
        'amount': record.cost,
        'type': 'expense',
        'title': title,
        'recorded_at': _recordedAt.millisecondsSinceEpoch ~/ 1000,
      };
    }

    if (!mounted) return;

    CarMaintenanceBloc? bloc;
    try {
      bloc = context.read<CarMaintenanceBloc>();
    } catch (_) {}

    if (bloc != null) {
      if (widget.existing == null) {
        bloc.add(CarMaintenanceCreate(record, transaction: transactionPayload));
      } else {
        bloc.add(CarMaintenanceUpdate(record));
      }
      return;
    }

    // Fallback: call repo directly when no bloc in tree
    final repo = AppDependencies.instance.carRepository;
    final failure = widget.existing == null
        ? await repo.createMaintenanceRecord(record,
            transaction: transactionPayload)
        : await repo.updateMaintenanceRecord(record);

    if (!mounted) return;
    if (failure != null) {
      final l10n = AppLocalizations.of(context);
      showCupertinoDialog<void>(
        context: context,
        builder: (c) => CupertinoAlertDialog(
          title: Text(l10n.maintenance_couldNotSave),
          content: Text(failure.message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(c),
              child: Text(l10n.common_ok),
            ),
          ],
        ),
      );
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final l10n = AppLocalizations.of(context);

    // BLoC listener — only active when CarMaintenanceBloc is in the tree
    Widget form = _buildForm(l10n, surface, border, fg, muted, accent);

    CarMaintenanceBloc? bloc;
    try {
      bloc = context.read<CarMaintenanceBloc>();
    } catch (_) {}

    if (bloc != null) {
      form = BlocListener<CarMaintenanceBloc, CarMaintenanceState>(
        listener: (context, state) {
          if (state is CarMaintenanceSaved) {
            context.pop();
          } else if (state is CarMaintenanceError) {
            showCupertinoDialog<void>(
              context: context,
              builder: (c) => CupertinoAlertDialog(
                title: Text(l10n.maintenance_couldNotSave),
                content: Text(state.message),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.pop(c),
                    child: Text(l10n.common_ok),
                  ),
                ],
              ),
            );
          }
        },
        child: form,
      );
    }

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: widget.existing == null
          ? l10n.maintenance_addRecord
          : l10n.maintenance_editRecord,
      trailing: GestureDetector(
        onTap: _save,
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            l10n.common_save,
            style: AppFonts.body(
                fontSize: 15, fontWeight: FontWeight.w600, color: accent),
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: form,
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n, Color surface, Color border,
      Color fg, Color muted, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        _label(l10n.maintenance_type, fg),
        _typePicker(surface, border, fg, muted, l10n),
        _label(l10n.maintenance_title, fg),
        FTextField(
          controller: _title,
          hint: l10n.maintenance_titlePlaceholder,
          textCapitalization: TextCapitalization.sentences,
        ),
        _label(l10n.maintenance_workshop, fg),
        FTextField(
          controller: _workshop,
          hint: l10n.maintenance_workshopPlaceholder,
          textCapitalization: TextCapitalization.words,
        ),
        _label(l10n.maintenance_date, fg),
        _datePicker(
          value: _recordedAt,
          onChanged: (d) => setState(() => _recordedAt = d),
          surface: surface,
          border: border,
          fg: fg,
          muted: muted,
          accent: accent,
          allowClear: false,
          l10n: l10n,
        ),
        _label(l10n.maintenance_nextDueDate, fg),
        _datePicker(
          value: _nextDueAt,
          onChanged: (d) => setState(() => _nextDueAt = d),
          surface: surface,
          border: border,
          fg: fg,
          muted: muted,
          accent: accent,
          allowClear: true,
          l10n: l10n,
        ),
        _label(l10n.maintenance_odometerKm, fg),
        FTextField(
          controller: _odometer,
          hint: '0',
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          textCapitalization: TextCapitalization.none,
        ),
        _label(l10n.maintenance_cost, fg),
        FTextField(
          controller: _cost,
          hint: '0.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textCapitalization: TextCapitalization.none,
        ),
        // Create expense toggle
        Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: border),
          ),
          child: AnimatedButton(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            onTap: () {
              setState(() => _createExpense = !_createExpense);
              if (!_createExpense) _loadBankAccounts();
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.maintenance_createExpense,
                    style: AppFonts.body(fontSize: 14, color: fg),
                  ),
                ),
                CupertinoSwitch(
                  value: _createExpense,
                  activeTrackColor: hexToColor(
                      context.myTheme.primaryColor),
                  onChanged: (v) {
                    setState(() => _createExpense = v);
                    if (v) _loadBankAccounts();
                  },
                ),
              ],
            ),
          ),
        ),
        if (_createExpense) ...[
          _label(l10n.maintenance_bankAccount, hexToColor(context.myTheme.onBackgroundColor)),
          _bankAccountPicker(surface, border, fg, muted, l10n),
        ],
        _label(l10n.maintenance_notes, fg),
        FTextField(
          controller: _notes,
          hint: l10n.maintenance_notesPlaceholder,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: AnimatedButton(
            onTap: _save,
            child: Text(
              widget.existing == null
                  ? l10n.maintenance_addRecord
                  : l10n.maintenance_saveChanges,
              style: AppFonts.body(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text, Color fg) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: AppFonts.body(
                fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
      );

  Widget _typePicker(Color surface, Color border, Color fg, Color muted,
          AppLocalizations l10n) =>
      Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: border),
        ),
        child: AnimatedButton(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          onTap: () => _pickType(fg, surface, l10n),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _typeLabel(_type, l10n),
                  style: AppFonts.body(fontSize: 14, color: fg),
                ),
              ),
              Icon(CupertinoIcons.chevron_down, size: 14, color: muted),
            ],
          ),
        ),
      );

  Widget _bankAccountPicker(Color surface, Color border, Color fg, Color muted,
          AppLocalizations l10n) =>
      Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: border),
        ),
        child: AnimatedButton(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          onTap: () => _pickBankAccount(fg, surface, l10n),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _loadingAccounts
                      ? '…'
                      : (_selectedAccount?.name ??
                          l10n.maintenance_bankAccount),
                  style: AppFonts.body(fontSize: 14, color: fg),
                ),
              ),
              Icon(CupertinoIcons.chevron_down, size: 14, color: muted),
            ],
          ),
        ),
      );

  Widget _datePicker({
    required DateTime? value,
    required ValueChanged<DateTime> onChanged,
    required Color surface,
    required Color border,
    required Color fg,
    required Color muted,
    required Color accent,
    required bool allowClear,
    required AppLocalizations l10n,
  }) {
    final hasValue = value != null;
    final label = hasValue
        ? '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'
        : l10n.common_notSet;

    return GestureDetector(
      onTap: () => _pickDate(
        initial: value ?? DateTime.now(),
        onChanged: onChanged,
        onClear: allowClear ? () => setState(() => _nextDueAt = null) : null,
        fg: fg,
        surface: surface,
        accent: accent,
        l10n: l10n,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppFonts.body(
                    fontSize: 14,
                    color: hasValue ? fg : fg.withValues(alpha: 0.35)),
              ),
            ),
            Icon(CupertinoIcons.calendar, size: 16, color: muted),
          ],
        ),
      ),
    );
  }

  void _pickType(Color fg, Color surface, AppLocalizations l10n) {
    final options = MaintenanceType.values;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: surface,
        child: CupertinoPicker(
          itemExtent: 40,
          scrollController: FixedExtentScrollController(
            initialItem: options.indexOf(_type),
          ),
          onSelectedItemChanged: (i) => setState(() => _type = options[i]),
          children: options
              .map((t) => Center(
                    child: Text(_typeLabel(t, l10n),
                        style: AppFonts.body(fontSize: 16, color: fg)),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _pickBankAccount(Color fg, Color surface, AppLocalizations l10n) {
    if (_bankAccounts.isEmpty) return;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: surface,
        child: CupertinoPicker(
          itemExtent: 40,
          scrollController: FixedExtentScrollController(
            initialItem: _selectedAccount != null
                ? _bankAccounts.indexOf(_selectedAccount!)
                : 0,
          ),
          onSelectedItemChanged: (i) =>
              setState(() => _selectedAccount = _bankAccounts[i]),
          children: _bankAccounts
              .map((a) => Center(
                    child: Text(a.name,
                        style: AppFonts.body(fontSize: 16, color: fg)),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onChanged,
    required VoidCallback? onClear,
    required Color fg,
    required Color surface,
    required Color accent,
    required AppLocalizations l10n,
  }) {
    DateTime temp = initial;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: surface,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onClear != null)
                    AnimatedButton(
                      padding: EdgeInsets.zero,
                      onTap: () {
                        onClear();
                        Navigator.pop(context);
                      },
                      child: Text(l10n.common_cancel,
                          style: AppFonts.body(fontSize: 15, color: fg)),
                    )
                  else
                    const SizedBox(width: 60),
                  AnimatedButton(
                    padding: EdgeInsets.zero,
                    onTap: () {
                      setState(() => onChanged(temp));
                      Navigator.pop(context);
                    },
                    child: Text(l10n.common_done,
                        style: AppFonts.body(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: accent)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initial,
                onDateTimeChanged: (d) => temp = d,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(MaintenanceType t, AppLocalizations l10n) => switch (t) {
        MaintenanceType.mechanic => l10n.maintenance_mechanic,
        MaintenanceType.itv => l10n.maintenance_itv,
        MaintenanceType.tires => l10n.maintenance_tires,
        MaintenanceType.oil => l10n.maintenance_oil,
        MaintenanceType.insurance => l10n.maintenance_insurance,
        MaintenanceType.other => l10n.maintenance_other,
      };
}
