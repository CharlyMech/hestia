import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/presentation/blocs/appointment_form/appointment_form_bloc.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';

class AppointmentFormContent extends StatefulWidget {
  final DateTime defaultDate;
  final String userId;
  final String? householdId;
  final bool use24h;
  final int startDayOfWeek;
  final void Function(String appointmentId, bool isAllDay) onSaved;

  const AppointmentFormContent({
    super.key,
    required this.defaultDate,
    required this.userId,
    this.householdId,
    this.use24h = true,
    this.startDayOfWeek = DateTime.monday,
    required this.onSaved,
  });

  @override
  State<AppointmentFormContent> createState() => _AppointmentFormContentState();
}

class _AppointmentFormContentState extends State<AppointmentFormContent> {
  bool _allDay = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final errorColor = _c(theme.colorRed);

    return BlocProvider(
      create: (_) => AppointmentFormBloc(
        repository: AppDependencies.instance.appointmentRepository,
        userId: widget.userId,
        householdId: widget.householdId,
        defaultDate: widget.defaultDate,
      ),
      child: BlocConsumer<AppointmentFormBloc, AppointmentFormState>(
        listenWhen: (p, n) => !p.saved && n.saved,
        listener: (context, state) {
          Navigator.of(context).pop();
          widget.onSaved(state.id ?? '', _allDay);
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            children: [
              // Title
              _LabeledField(
                label: 'Title',
                muted: muted,
                child: _Input(
                  initial: state.title,
                  placeholder: 'Dentist · Gym · Meeting…',
                  surface: surface,
                  border: border,
                  fg: fg,
                  muted: muted,
                  onChanged: (v) => context
                      .read<AppointmentFormBloc>()
                      .add(FormTitleChanged(v)),
                ),
              ),
              const SizedBox(height: 14),
              // All day
              Row(
                children: [
                  FCheckbox(
                    value: _allDay,
                    onChange: (v) {
                      setState(() => _allDay = v);
                      if (_allDay) {
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
                  Text(
                    'All day',
                    style: AppFonts.body(fontSize: 14, color: fg),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Date
              _LabeledField(
                label: 'Date',
                muted: muted,
                child: _TappableRow(
                  value: _fmtDate(state.startsAt),
                  surface: surface,
                  border: border,
                  fg: fg,
                  muted: muted,
                  onTap: () => _pickDate(context, state.startsAt),
                ),
              ),
              const SizedBox(height: 14),
              // Start time
              Opacity(
                opacity: _allDay ? 0.38 : 1.0,
                child: _LabeledField(
                  label: 'Start time',
                  muted: muted,
                  child: _TappableRow(
                    value: _fmtTime(state.startsAt),
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                    onTap: _allDay
                        ? null
                        : () => _pickTime(context, state.startsAt,
                            onPicked: (t) {
                              context
                                  .read<AppointmentFormBloc>()
                                  .add(FormStartChanged(t));
                            }),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // End time
              Opacity(
                opacity: _allDay ? 0.38 : 1.0,
                child: _LabeledField(
                  label: 'End time',
                  muted: muted,
                  child: _TappableRow(
                    value: _fmtTime(state.startsAt.add(state.duration)),
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                    onTap: _allDay
                        ? null
                        : () => _pickTime(
                              context,
                              state.startsAt.add(state.duration),
                              onPicked: (t) {
                                var dur = t.difference(state.startsAt);
                                if (dur.inMinutes < 15) {
                                  dur = const Duration(minutes: 15);
                                }
                                context
                                    .read<AppointmentFormBloc>()
                                    .add(FormDurationChanged(dur));
                              },
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Category
              _LabeledField(
                label: 'Category',
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
              const SizedBox(height: 14),
              // Reminders
              _LabeledField(
                label: 'Reminders',
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
                const SizedBox(height: 12),
                Text(
                  state.error!,
                  style: AppFonts.body(fontSize: 13, color: errorColor),
                ),
              ],
              const SizedBox(height: 20),
              // Save button
              GestureDetector(
                onTap: (state.titleValid && !state.submitting)
                    ? () => context
                        .read<AppointmentFormBloc>()
                        .add(const FormSubmit())
                    : null,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: state.titleValid
                        ? accent
                        : accent.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                  ),
                  child: Center(
                    child: state.submitting
                        ? const CupertinoActivityIndicator()
                        : Text(
                            'Save',
                            style: AppFonts.body(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime current) async {
    DateTime selected = current;
    final theme = context.myTheme;
    final surface = _c(theme.surfaceColor);
    final fg = _c(theme.onBackgroundColor);
    final accent = _c(theme.primaryColor);

    final calStyle = FCalendarStyle.inherit(
      colorScheme: context.theme.colorScheme,
      typography: context.theme.typography,
      style: context.theme.style,
    ).copyWith(
      dayPickerStyle: FCalendarDayPickerStyle.inherit(
        colorScheme: context.theme.colorScheme,
        typography: context.theme.typography,
      ).copyWith(startDayOfWeek: widget.startDayOfWeek),
    );

    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (ctx) {
        final ctrl = FCalendarController.date(
          initialSelection: DateTime.utc(
              current.year, current.month, current.day),
        );
        return Container(
          height: 420,
          color: surface,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Cancel',
                          style: AppFonts.body(fontSize: 15, color: fg)),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.of(ctx).pop(selected),
                      child: Text('Done',
                          style: AppFonts.body(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: accent)),
                    ),
                  ],
                ),
                Expanded(
                  child: FCalendar(
                    controller: ctrl,
                    style: calStyle,
                    start: DateTime.utc(2020),
                    end: DateTime.utc(2035),
                    today: DateTime.utc(DateTime.now().year,
                        DateTime.now().month, DateTime.now().day),
                    onPress: (d) {
                      selected = DateTime(
                        d.year, d.month, d.day,
                        current.hour, current.minute,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null && context.mounted) {
      context.read<AppointmentFormBloc>().add(FormStartChanged(picked));
    }
  }

  Future<void> _pickTime(
    BuildContext context,
    DateTime current, {
    required ValueChanged<DateTime> onPicked,
  }) async {
    DateTime selected = current;
    final theme = context.myTheme;
    final surface = _c(theme.surfaceColor);
    final fg = _c(theme.onBackgroundColor);
    final accent = _c(theme.primaryColor);

    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (ctx) {
        return Container(
          height: 320,
          color: surface,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Cancel',
                          style: AppFonts.body(fontSize: 15, color: fg)),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.of(ctx).pop(selected),
                      child: Text('Done',
                          style: AppFonts.body(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: accent)),
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: current,
                    minuteInterval: 5,
                    use24hFormat: true,
                    onDateTimeChanged: (d) => selected = d,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null && context.mounted) {
      onPicked(picked);
    }
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _fmtTime(DateTime d) {
    final mm = d.minute.toString().padLeft(2, '0');
    if (widget.use24h) {
      return '${d.hour.toString().padLeft(2, '0')}:$mm';
    }
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final period = d.hour < 12 ? 'AM' : 'PM';
    return '$h:$mm $period';
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final Color muted;
  const _LabeledField(
      {required this.label, required this.child, required this.muted});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(label.toUpperCase(), style: AppFonts.sectionLabel(color: muted)),
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

  const _Input({
    required this.initial,
    required this.placeholder,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.onChanged,
  });

  @override
  State<_Input> createState() => _InputState();
}

class _InputState extends State<_Input> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: _ctrl,
      placeholder: widget.placeholder,
      placeholderStyle: AppFonts.body(fontSize: 14, color: widget.muted),
      style: AppFonts.body(fontSize: 14, color: widget.fg),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: widget.surface,
        border: Border.all(color: widget.border),
        borderRadius: BorderRadius.circular(12),
      ),
      onChanged: widget.onChanged,
    );
  }
}

class _TappableRow extends StatelessWidget {
  final String value;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final VoidCallback? onTap;

  const _TappableRow({
    required this.value,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(value,
                  style: AppFonts.body(fontSize: 14, color: fg)),
            ),
            ChevronIcon(color: muted),
          ],
        ),
      ),
    );
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: c == value ? accent.withValues(alpha: 0.14) : surface,
                border: Border.all(
                    color: c == value ? accent : border),
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
                  border: Border.all(color: isOn ? accent : border),
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
