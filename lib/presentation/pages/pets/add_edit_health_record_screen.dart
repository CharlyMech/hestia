import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/pet_health_record.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';

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
  const _AddEditHealthRecordView({this.petId, this.existing});
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
        showCupertinoDialog<void>(
          context: context,
          builder: (c) => CupertinoAlertDialog(
            title: const Text('Could not save'),
            content: Text(failure.message),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(c),
                child: const Text('OK'),
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
        showCupertinoDialog<void>(
          context: context,
          builder: (c) => CupertinoAlertDialog(
            title: const Text('Could not save'),
            content: Text(failure.message),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(c),
                child: const Text('OK'),
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
      titleText: widget.existing == null ? 'Add Record' : 'Edit Record',
      trailing: GestureDetector(
        onTap: _save,
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            'Save',
            style: AppFonts.body(
                fontSize: 15, fontWeight: FontWeight.w600, color: accent),
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Type', fg),
            _typePicker(surface, border, fg, muted),
            const SizedBox(height: 12),
            _label('Title', fg),
            _field(_title, 'e.g. Annual vaccination', fg, surface, border),
            const SizedBox(height: 12),
            _label('Vet / Clinic', fg),
            _field(_vet, 'Optional', fg, surface, border),
            const SizedBox(height: 12),
            _label('Date', fg),
            _datePicker(
              value: _recordedAt,
              onChanged: (d) => setState(() => _recordedAt = d),
              surface: surface,
              border: border,
              fg: fg,
              muted: muted,
              accent: accent,
              allowClear: false,
            ),
            const SizedBox(height: 12),
            _label('Next due date', fg),
            _datePicker(
              value: _nextDueAt,
              onChanged: (d) => setState(() => _nextDueAt = d),
              surface: surface,
              border: border,
              fg: fg,
              muted: muted,
              accent: accent,
              allowClear: true,
            ),
            const SizedBox(height: 12),
            _label('Cost (€)', fg),
            _field(_cost, '0.00', fg, surface, border, numeric: true),
            const SizedBox(height: 12),
            _label('Notes', fg),
            _field(_notes, 'Optional notes…', fg, surface, border, maxLines: 3),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: accent,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                onPressed: _save,
                child: Text(
                  widget.existing == null ? 'Add Record' : 'Save Changes',
                  style: AppFonts.body(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white),
                ),
              ),
            ),
          ],
        ),
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
      Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: border),
        ),
        child: CupertinoTextField(
          controller: ctrl,
          placeholder: placeholder,
          style: AppFonts.body(fontSize: 14, color: fg),
          placeholderStyle:
              AppFonts.body(fontSize: 14, color: fg.withValues(alpha: 0.35)),
          decoration: null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          maxLines: maxLines,
        ),
      );

  Widget _typePicker(Color surface, Color border, Color fg, Color muted) =>
      Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: border),
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          onPressed: () => _pickType(fg, surface),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _typeLabel(_type),
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
  }) {
    final hasValue = value != null;
    final label = hasValue
        ? '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'
        : 'Not set';

    return GestureDetector(
      onTap: () => _pickDate(
        initial: value ?? DateTime.now(),
        onChanged: onChanged,
        onClear: allowClear ? () => setState(() => _nextDueAt = null) : null,
        fg: fg,
        surface: surface,
        accent: accent,
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

  void _pickType(Color fg, Color surface) {
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
                    child: Text(_typeLabel(t),
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
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        onClear();
                        Navigator.pop(context);
                      },
                      child: Text('Clear',
                          style: AppFonts.body(fontSize: 15, color: fg)),
                    )
                  else
                    const SizedBox(width: 60),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() => onChanged(temp));
                      Navigator.pop(context);
                    },
                    child: Text('Done',
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

  String _typeLabel(HealthRecordType t) => switch (t) {
        HealthRecordType.vaccine => 'Vaccine',
        HealthRecordType.vet => 'Vet visit',
        HealthRecordType.medication => 'Medication',
        HealthRecordType.grooming => 'Grooming',
        HealthRecordType.deworming => 'Deworming',
        HealthRecordType.other => 'Other',
      };

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
