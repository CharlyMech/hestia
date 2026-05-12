import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/presentation/blocs/appointment_form/appointment_form_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';

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
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final expense = _c(theme.colorRed);

    return BlocConsumer<AppointmentFormBloc, AppointmentFormState>(
      listenWhen: (p, n) => p.saved != n.saved || p.deleted != n.deleted,
      listener: (context, state) {
        if (state.saved || state.deleted) {
          context.pop();
        }
      },
      builder: (context, state) {
        return CupertinoPushedRouteShell(
          backgroundColor: bg,
          navBackground: surface,
          borderColor: border,
          foregroundColor: fg,
          titleText: state.isEdit ? 'Edit appointment' : 'New appointment',
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
                      'Save',
                      style: AppFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: state.titleValid ? accent : muted,
                      ),
                    ),
                  ),
                ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              _LabeledField(
                label: 'Title',
                muted: muted,
                child: _Input(
                  initial: state.title,
                  placeholder: 'Dentist · Dr. Marín',
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
                label: 'Location',
                muted: muted,
                child: _Input(
                  initial: state.location,
                  placeholder: 'Optional',
                  surface: surface,
                  border: border,
                  fg: fg,
                  muted: muted,
                  onChanged: (v) => context
                      .read<AppointmentFormBloc>()
                      .add(FormLocationChanged(v)),
                ),
              ),
              const SizedBox(height: 16),
              _LabeledField(
                label: 'Notes',
                muted: muted,
                child: _Input(
                  initial: state.notes,
                  placeholder: 'Optional',
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
              _LabeledField(
                label: 'Starts at',
                muted: muted,
                child: _DateRow(
                  value: state.startsAt,
                  surface: surface,
                  border: border,
                  fg: fg,
                  muted: muted,
                  onPick: () async {
                    final picked = await _pickDateTime(context, state.startsAt);
                    if (picked != null && context.mounted) {
                      context
                          .read<AppointmentFormBloc>()
                          .add(FormStartChanged(picked));
                    }
                  },
                ),
              ),
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                Text(
                  state.error!,
                  style: AppFonts.body(fontSize: 13, color: expense),
                ),
              ],
              if (state.isEdit) ...[
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: state.submitting
                      ? null
                      : () => context
                          .read<AppointmentFormBloc>()
                          .add(const FormDelete()),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: expense.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Delete appointment',
                        style: AppFonts.body(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: expense,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<DateTime?> _pickDateTime(
      BuildContext context, DateTime initial) async {
    DateTime selected = initial;
    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (ctx) {
        return Container(
          height: 320,
          color: CupertinoColors.systemBackground.resolveFrom(ctx),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.of(ctx).pop(selected),
                      child: const Text('Done'),
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: initial,
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
    return picked;
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

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
    return CupertinoTextField(
      controller: _controller,
      placeholder: widget.placeholder,
      placeholderStyle: AppFonts.body(fontSize: 14, color: widget.muted),
      style: AppFonts.body(fontSize: 14, color: widget.fg),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      minLines: widget.minLines,
      maxLines: widget.maxLines ?? widget.minLines,
      decoration: BoxDecoration(
        color: widget.surface,
        border: Border.all(color: widget.border, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      onChanged: widget.onChanged,
    );
  }
}

class _DateRow extends StatelessWidget {
  final DateTime value;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final VoidCallback onPick;

  const _DateRow({
    required this.value,
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
                _fmt(value),
                style: AppFonts.body(fontSize: 14, color: fg),
              ),
            ),
            ChevronIcon(color: muted),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, ${d.year} · $hh:$mm';
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
                  color: d == value ? accent : Color(0x00000000),
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
                  color: c == value ? accent : Color(0x00000000),
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
                    color: isOn ? accent : Color(0x00000000),
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

class _NoAuth extends StatelessWidget {
  const _NoAuth();
  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(child: Text('Sign in required')),
    );
  }
}
