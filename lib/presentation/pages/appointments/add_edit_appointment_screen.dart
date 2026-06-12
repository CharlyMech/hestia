import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/appointment_form/appointment_form_bloc.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/appointments/appointment_related_picker.dart';

class AddEditAppointmentScreen extends StatelessWidget {
  final Appointment? existing;
  final DateTime? defaultDate;
  const AddEditAppointmentScreen({
    super.key,
    this.existing,
    this.defaultDate,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const _NoAuth();
    }
    final profile = auth.profile;

    return BlocProvider(
      create: (_) => AppointmentFormBloc(
        repository: AppDependencies.instance.appointmentRepository,
        userId: profile.id,
        existing: existing,
        defaultDate: defaultDate,
      ),
      child: const _Form(),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form();

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final expense = hexToColor(theme.colorRed);
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<AppointmentFormBloc, AppointmentFormState>(
      listenWhen: (p, n) => p.saved != n.saved || p.deleted != n.deleted,
      listener: (context, state) {
        if (state.saved || state.deleted) context.pop();
      },
      builder: (context, state) {
        return CupertinoPushedRouteShell(
          backgroundColor: bg,
          navBackground: surface,
          borderColor: border,
          foregroundColor: fg,
          titleText: state.isEdit
              ? l10n.calendar_appointment
              : l10n.calendar_newAppointment,
          trailing: state.submitting
              ? const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: CupertinoActivityIndicator(),
                )
              : GestureDetector(
                  onTap: state.titleValid
                      ? () => context
                          .read<AppointmentFormBloc>()
                          .add(const FormSubmit())
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      l10n.common_save,
                      style: AppFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: state.titleValid ? accent : muted,
                      ),
                    ),
                  ),
                ),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, 40 + MediaQuery.viewInsetsOf(context).bottom),
            children: [
              // All day toggle
              Row(
                children: [
                  FCheckbox(
                    value: state.isAllDay,
                    onChange: (v) {
                      context
                          .read<AppointmentFormBloc>()
                          .add(FormAllDayChanged(v));
                      if (v) {
                        final d = state.startsAt;
                        final midnight = DateTime(d.year, d.month, d.day);
                        context
                            .read<AppointmentFormBloc>()
                            .add(FormStartChanged(midnight));
                        context
                            .read<AppointmentFormBloc>()
                            .add(const FormDurationChanged(Duration(hours: 24)));
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  Text(l10n.appointments_allDay,
                      style: AppFonts.body(fontSize: 14, color: fg)),
                ],
              ),
              const SizedBox(height: 12),
              // Share with household
              Row(
                children: [
                  FCheckbox(
                    value: state.isShared,
                    onChange: (v) => context
                        .read<AppointmentFormBloc>()
                        .add(FormSharedChanged(v)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(l10n.appointments_shareHousehold,
                        style: AppFonts.body(fontSize: 14, color: fg)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _LabeledField(
                label: l10n.appointments_title,
                muted: muted,
                child: _Input(
                  initial: state.title,
                  placeholder: l10n.appointments_titlePlaceholder,
                  surface: surface,
                  border: border,
                  fg: fg,
                  muted: muted,
                  onChanged: (v) => context
                      .read<AppointmentFormBloc>()
                      .add(FormTitleChanged(v)),
                ),
              ),
              const SizedBox(height: 16),
              _LabeledField(
                label: l10n.appointments_location,
                muted: muted,
                child: _Input(
                  initial: state.location,
                  placeholder: l10n.common_none,
                  surface: surface,
                  border: border,
                  fg: fg,
                  muted: muted,
                  onChanged: (v) => context
                      .read<AppointmentFormBloc>()
                      .add(FormLocationChanged(v)),
                ),
              ),
              const SizedBox(height: 10),
              // Map coordinates (bug #12): reuse the fixed-pin picker.
              _MapField(
                latitude: state.latitude,
                longitude: state.longitude,
                surface: surface,
                border: border,
                fg: fg,
                muted: muted,
                accent: accent,
                onPick: () async {
                  final result = await context.push<(double, double)>(
                    AppRoutes.transactionMapPicker,
                    extra: (state.latitude ?? 40.4168, state.longitude ?? -3.7038),
                  );
                  if (result != null && context.mounted) {
                    context
                        .read<AppointmentFormBloc>()
                        .add(FormLocationCoordsChanged(result.$1, result.$2));
                  }
                },
                onClear: () => context
                    .read<AppointmentFormBloc>()
                    .add(const FormLocationCoordsChanged(null, null)),
              ),
              const SizedBox(height: 16),
              // Related pet / car (bug #10).
              AppointmentRelatedPicker(
                householdId: state.householdId,
                petIds: state.petIds,
                carId: state.carId,
                surface: surface,
                border: border,
                fg: fg,
                muted: muted,
                accent: accent,
                onPetsChanged: (ids) => context
                    .read<AppointmentFormBloc>()
                    .add(FormPetsChanged(ids)),
                onCarChanged: (id) => context
                    .read<AppointmentFormBloc>()
                    .add(FormCarChanged(id)),
              ),
              const SizedBox(height: 16),
              _LabeledField(
                label: l10n.appointments_notes,
                muted: muted,
                child: _Input(
                  initial: state.notes,
                  placeholder: l10n.common_none,
                  surface: surface,
                  border: border,
                  fg: fg,
                  muted: muted,
                  minLines: 3,
                  maxLines: 6,
                  onChanged: (v) => context
                      .read<AppointmentFormBloc>()
                      .add(FormNotesChanged(v)),
                ),
              ),
              const SizedBox(height: 16),
              // Starts at (hide time pickers when all-day)
              _LabeledField(
                label: l10n.appointments_date,
                muted: muted,
                child: _DateRow(
                  value: state.startsAt,
                  showTime: !state.isAllDay,
                  surface: surface,
                  border: border,
                  fg: fg,
                  muted: muted,
                  onPick: () async {
                    final picked =
                        await _pickDateTime(context, state.startsAt, state.isAllDay);
                    if (picked != null && context.mounted) {
                      context
                          .read<AppointmentFormBloc>()
                          .add(FormStartChanged(picked));
                    }
                  },
                ),
              ),
              if (!state.isAllDay) ...[
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'Duration',
                  muted: muted,
                  child: _DurationPicker(
                    value: state.duration,
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                    accent: accent,
                    onChanged: (d) => context
                        .read<AppointmentFormBloc>()
                        .add(FormDurationChanged(d)),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _LabeledField(
                label: l10n.appointments_category,
                muted: muted,
                child: _CategoryPicker(
                  value: state.category,
                  surface: surface,
                  border: border,
                  fg: fg,
                  muted: muted,
                  accent: accent,
                  onChanged: (c) => context
                      .read<AppointmentFormBloc>()
                      .add(FormCategoryChanged(c)),
                ),
              ),
              const SizedBox(height: 16),
              _LabeledField(
                label: l10n.appointments_color,
                muted: muted,
                child: _ColorPicker(
                  selected: state.color,
                  onChanged: (hex) => context
                      .read<AppointmentFormBloc>()
                      .add(FormColorChanged(hex)),
                ),
              ),
              const SizedBox(height: 16),
              _LabeledField(
                label: l10n.appointments_reminders,
                muted: muted,
                child: _Reminders(
                  selected: state.reminderOffsets,
                  surface: surface,
                  border: border,
                  fg: fg,
                  muted: muted,
                  accent: accent,
                  onToggle: (d) => context
                      .read<AppointmentFormBloc>()
                      .add(FormToggleReminder(d)),
                ),
              ),
              if (state.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  state.error!,
                  style: AppFonts.body(fontSize: 13, color: expense),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<DateTime?> _pickDateTime(
      BuildContext context, DateTime initial, bool dateOnly) async {
    DateTime selected = initial;
    final l10n = AppLocalizations.of(context);
    final picked = await showAppBottomSheet<DateTime>(
      context: context,
      title: dateOnly ? l10n.appointments_date : null,
      heightFactor: 0.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.common_cancel),
              ),
              CupertinoButton(
                onPressed: () => Navigator.of(context).pop(selected),
                child: Text(l10n.common_done),
              ),
            ],
          ),
          SizedBox(
            height: 216,
            child: CupertinoDatePicker(
              mode: dateOnly
                  ? CupertinoDatePickerMode.date
                  : CupertinoDatePickerMode.dateAndTime,
              initialDateTime: initial,
              minuteInterval: 5,
              use24hFormat: true,
              onDateTimeChanged: (d) => selected = d,
            ),
          ),
        ],
      ),
    );
    return picked;
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final Color muted;
  const _LabeledField({
    required this.label,
    required this.child,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppFonts.sectionLabel(color: muted)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _Input extends StatefulWidget {
  final String initial;
  final String placeholder;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final ValueChanged<String> onChanged;
  final int minLines;
  final int? maxLines;

  const _Input({
    required this.initial,
    required this.placeholder,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.onChanged,
    this.minLines = 1,
    this.maxLines,
  });

  @override
  State<_Input> createState() => _InputState();
}

class _InputState extends State<_Input> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FTextField(
      controller: _controller,
      hint: widget.placeholder,
      textCapitalization: TextCapitalization.sentences,
      minLines: widget.minLines,
      maxLines: widget.maxLines ?? widget.minLines,
      onChange: widget.onChanged,
    );
  }
}

class _DateRow extends StatelessWidget {
  final DateTime value;
  final bool showTime;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final VoidCallback onPick;

  const _DateRow({
    required this.value,
    required this.showTime,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _fmt(value, showTime),
                style: AppFonts.body(fontSize: 14, color: fg),
              ),
            ),
            ChevronIcon(color: muted),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d, bool withTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final base = '${months[d.month - 1]} ${d.day}, ${d.year}';
    if (!withTime) return base;
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$base · $hh:$mm';
  }
}

class _DurationPicker extends StatelessWidget {
  final Duration value;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;
  final ValueChanged<Duration> onChanged;

  const _DurationPicker({
    required this.value,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.onChanged,
  });

  static const _options = [
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(minutes: 45),
    Duration(hours: 1),
    Duration(hours: 2),
    Duration(hours: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final d in _options)
          GestureDetector(
            onTap: () => onChanged(d),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: d == value ? accent.withValues(alpha: 0.14) : surface,
                border: Border.all(
                  color: d == value ? accent : const Color(0x00000000),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _fmt(d),
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: d == value ? accent : muted,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _fmt(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes} min';
    if (d.inMinutes % 60 == 0) return '${d.inHours}h';
    return '${d.inHours}h ${d.inMinutes % 60}m';
  }
}

class _CategoryPicker extends StatelessWidget {
  final AppointmentCategory value;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;
  final ValueChanged<AppointmentCategory> onChanged;

  const _CategoryPicker({
    required this.value,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in AppointmentCategory.values)
          GestureDetector(
            onTap: () => onChanged(c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: c == value ? accent.withValues(alpha: 0.14) : surface,
                border: Border.all(
                  color: c == value ? accent : const Color(0x00000000),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _label(c),
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c == value ? accent : muted,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _label(AppointmentCategory c) => switch (c) {
        AppointmentCategory.health => 'Health',
        AppointmentCategory.vehicle => 'Vehicle',
        AppointmentCategory.beauty => 'Beauty',
        AppointmentCategory.work => 'Work',
        AppointmentCategory.personal => 'Personal',
        AppointmentCategory.other => 'Other',
      };
}

class _ColorPicker extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _ColorPicker({required this.selected, required this.onChanged});

  static Color _parse(String hex) =>
      hexToColor(hex);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final hex in AppointmentColors.palette)
          GestureDetector(
            onTap: () => onChanged(selected == hex ? null : hex),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _parse(hex),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected == hex
                      ? _parse(hex)
                      : const Color(0x00000000),
                  width: 3,
                ),
                boxShadow: selected == hex
                    ? [
                        BoxShadow(
                          color: _parse(hex).withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: selected == hex
                  ? const Icon(CupertinoIcons.checkmark,
                      size: 14, color: CupertinoColors.white)
                  : null,
            ),
          ),
      ],
    );
  }
}

class _Reminders extends StatelessWidget {
  final List<Duration> selected;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;
  final ValueChanged<Duration> onToggle;

  const _Reminders({
    required this.selected,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.onToggle,
  });

  static const _options = [
    Duration(minutes: 15),
    Duration(hours: 1),
    Duration(hours: 8),
    Duration(hours: 24),
    Duration(days: 7),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final d in _options)
          () {
            final isOn = selected.any((s) => s.inMinutes == d.inMinutes);
            return GestureDetector(
              onTap: () => onToggle(d),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isOn ? accent.withValues(alpha: 0.14) : surface,
                  border: Border.all(
                    color: isOn ? accent : const Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _fmt(d),
                  style: AppFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isOn ? accent : muted,
                  ),
                ),
              ),
            );
          }(),
      ],
    );
  }

  String _fmt(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes} min';
    if (d.inHours < 24) return '${d.inHours}h';
    final days = d.inDays;
    return days == 1 ? '1 day' : '$days days';
  }
}

class _MapField extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _MapField({
    required this.latitude,
    required this.longitude,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasCoords = latitude != null && longitude != null;
    return GestureDetector(
      onTap: onPick,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 0.8),
        ),
        child: Row(
          spacing: 10,
          children: [
            Icon(CupertinoIcons.map_pin_ellipse, size: 18, color: accent),
            Expanded(
              child: Text(
                hasCoords
                    ? '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}'
                    : 'Pin location on map',
                style: AppFonts.body(
                    fontSize: 14, color: hasCoords ? fg : muted),
              ),
            ),
            if (hasCoords)
              GestureDetector(
                onTap: onClear,
                child: Icon(CupertinoIcons.xmark_circle_fill,
                    size: 18, color: muted),
              ),
          ],
        ),
      ),
    );
  }
}

class _NoAuth extends StatelessWidget {
  const _NoAuth();
  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(child: Text('Sign in required')),
    );
  }
}
