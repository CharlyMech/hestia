import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/pet_health_record.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';

/// Opens the add/edit health-record form in an app bottom sheet (bug #7).
Future<void> showHealthRecordSheet(
  BuildContext context, {
  String? petId,
  PetHealthRecord? existing,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<void>(
    context: context,
    title: existing == null ? l10n.healthRecord_addRecord : l10n.healthRecord_editRecord,
    heightFactor: 0.92,
    expand: true,
    child: _AddEditHealthRecordView(
      petId: petId,
      existing: existing,
      asSheet: true,
    ),
  );
}

class AddEditHealthRecordScreen extends StatelessWidget {
  /// petId is set when creating a new record.
  final String? petId;

  /// existing is set when editing.
  final PetHealthRecord? existing;

  const AddEditHealthRecordScreen({super.key, this.petId, this.existing})
      : assert(petId != null || existing != null);

  @override
  Widget build(BuildContext context) {
    return _AddEditHealthRecordView(petId: petId, existing: existing);
  }
}

class _AddEditHealthRecordView extends StatefulWidget {
  final String? petId;
  final PetHealthRecord? existing;
  final bool asSheet;
  const _AddEditHealthRecordView({
    this.petId,
    this.existing,
    this.asSheet = false,
  });
  @override
  State<_AddEditHealthRecordView> createState() =>
      _AddEditHealthRecordViewState();
}

class _AddEditHealthRecordViewState extends State<_AddEditHealthRecordView> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _vet = TextEditingController();
  final _cost = TextEditingController();

  HealthRecordType _type = HealthRecordType.vet;
  DateTime _recordedAt = DateTime.now();
  DateTime? _nextDueAt;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _title.text = e.title;
      _notes.text = e.notes ?? '';
      _vet.text = e.vetName ?? '';
      _cost.text = e.cost?.toString() ?? '';
      _type = e.type;
      _recordedAt = e.recordedAt;
      _nextDueAt = e.nextDueAt;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _vet.dispose();
    _cost.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final title = _title.text.trim();
    if (title.isEmpty) return;

    final resolvedPetId = widget.existing?.petId ?? widget.petId!;
    final now = DateTime.now();
    final record = PetHealthRecord(
      id: widget.existing?.id ?? '',
      petId: resolvedPetId,
      type: _type,
      title: title,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      recordedAt: _recordedAt,
      nextDueAt: _nextDueAt,
      cost: double.tryParse(_cost.text.replaceAll(',', '.')),
      vetName: _vet.text.trim().isEmpty ? null : _vet.text.trim(),
      createdBy: widget.existing?.createdBy ?? auth.profile.id,
      createdAt: widget.existing?.createdAt ?? now,
    );

    if (!mounted) return;
    final repo = AppDependencies.instance.petRepository;
    if (widget.existing == null) {
      final (_, failure) = await repo.createHealthRecord(record);
      if (!mounted) return;
      if (failure != null) {
        final l10n = AppLocalizations.of(context);
        showCupertinoDialog<void>(
          context: context,
          builder: (c) => CupertinoAlertDialog(
            title: Text(l10n.healthRecord_couldNotSave),
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
    } else {
      final failure = await repo.updateHealthRecord(record);
      if (!mounted) return;
      if (failure != null) {
        final l10n = AppLocalizations.of(context);
        showCupertinoDialog<void>(
          context: context,
          builder: (c) => CupertinoAlertDialog(
            title: Text(l10n.healthRecord_couldNotSave),
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
    }
    if (!mounted) return;
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
    final form = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(l10n.healthRecord_type, fg),
            _typePicker(surface, border, fg, muted),
            const SizedBox(height: 12),
            _label(l10n.healthRecord_title, fg),
            _field(_title, l10n.healthRecord_titlePlaceholder, fg, surface, border),
            const SizedBox(height: 12),
            _label(l10n.healthRecord_vetClinic, fg),
            _field(_vet, l10n.healthRecord_optional, fg, surface, border),
            const SizedBox(height: 12),
            _label(l10n.healthRecord_date, fg),
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
            const SizedBox(height: 12),
            _label(l10n.healthRecord_nextDueDate, fg),
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
            const SizedBox(height: 12),
            _label(l10n.healthRecord_costEuro, fg),
            _field(_cost, '0.00', fg, surface, border, numeric: true),
            const SizedBox(height: 12),
            _label(l10n.healthRecord_notes, fg),
            _field(_notes, l10n.healthRecord_notesPlaceholder, fg, surface, border, maxLines: 3),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: AnimatedButton(
                onTap: _save,
                child: Text(
                  widget.existing == null ? l10n.healthRecord_addRecord : l10n.healthRecord_saveChanges,
                  style: AppFonts.body(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white),
                ),
              ),
            ),
          ],
        );

    // Sheet variant: just the padded, scrollable form (host provides chrome).
    if (widget.asSheet) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        child: form,
      );
    }

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: widget.existing == null ? l10n.healthRecord_addRecord : l10n.healthRecord_editRecord,
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

  Widget _label(String text, Color fg) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: AppFonts.body(
                fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
      );

  Widget _field(
    TextEditingController ctrl,
    String placeholder,
    Color fg,
    Color surface,
    Color border, {
    bool numeric = false,
    int maxLines = 1,
  }) =>
      FTextField(
        controller: ctrl,
        hint: placeholder,
        maxLines: maxLines,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        textCapitalization:
            numeric ? TextCapitalization.none : TextCapitalization.sentences,
      );

  Widget _typePicker(Color surface, Color border, Color fg, Color muted) =>
      Builder(builder: (context) {
        final l10n = AppLocalizations.of(context);
        return Container(
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
      });

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
    final options = HealthRecordType.values;
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  String _typeLabel(HealthRecordType t, AppLocalizations l10n) => switch (t) {
        HealthRecordType.vaccine => l10n.pets_healthTypeVaccine,
        HealthRecordType.vet => l10n.pets_healthTypeVet,
        HealthRecordType.medication => l10n.pets_healthTypeMedication,
        HealthRecordType.grooming => l10n.pets_healthTypeGrooming,
        HealthRecordType.deworming => l10n.pets_healthTypeDeworming,
        HealthRecordType.other => l10n.pets_healthTypeOther,
      };
}
