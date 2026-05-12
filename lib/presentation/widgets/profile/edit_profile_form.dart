import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/data/services/image_upload_service.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_events.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/image_picker_field.dart';

/// Edit-profile bottom sheet body. Lets the user change avatar, display name,
/// birth date, preferred currency and calendar color.
class EditProfileForm extends StatefulWidget {
  final Profile profile;
  final List<Color> tints;

  const EditProfileForm({
    super.key,
    required this.profile,
    required this.tints,
  });

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  late final TextEditingController _name;
  late String? _avatarUrl;
  late DateTime? _birthDate;
  late String _currency;
  late String? _calendarColor;
  bool _saving = false;

  static const _currencies = ['EUR', 'USD', 'GBP', 'JPY', 'CHF', 'CAD'];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.displayName ?? '');
    _avatarUrl = widget.profile.avatarUrl;
    _birthDate = widget.profile.birthDate;
    _currency = widget.profile.preferredCurrency;
    _calendarColor = widget.profile.calendarColor;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String get _initials {
    final n =
        _name.text.trim().isEmpty ? widget.profile.email : _name.text.trim();
    final parts = n.split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
  }

  Future<void> _pickBirthDate() async {
    final theme = context.myTheme;
    final fg = _c(theme.onBackgroundColor);
    DateTime tmp = _birthDate ?? DateTime(2000, 1, 1);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        color: _c(theme.surfaceColor),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('Cancel',
                        style: AppFonts.body(fontSize: 14, color: fg)),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    onPressed: () {
                      setState(() => _birthDate = tmp);
                      Navigator.of(ctx).pop();
                    },
                    child: Text('Done',
                        style: AppFonts.body(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: fg)),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tmp,
                  maximumDate: DateTime.now(),
                  minimumYear: 1900,
                  onDateTimeChanged: (d) => tmp = d,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickCurrency() async {
    final theme = context.myTheme;
    final fg = _c(theme.onBackgroundColor);
    final accent = _c(theme.primaryColor);
    final picked = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => Container(
        color: _c(theme.surfaceColor),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final c in _currencies)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(ctx).pop(c),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            c,
                            style: AppFonts.body(
                              fontSize: 15,
                              fontWeight: c == _currency
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: c == _currency ? accent : fg,
                            ),
                          ),
                        ),
                        if (c == _currency)
                          Icon(CupertinoIcons.check_mark,
                              size: 16, color: accent),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _currency = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final updated = widget.profile.copyWith(
      displayName: _name.text.trim().isEmpty ? null : _name.text.trim(),
      avatarUrl: _avatarUrl,
      clearAvatar: _avatarUrl == null,
      birthDate: _birthDate,
      clearBirthDate: _birthDate == null,
      preferredCurrency: _currency,
      calendarColor: _calendarColor,
      lastUpdate: DateTime.now(),
    );
    if (!mounted) return;
    context.read<AuthBloc>().add(AuthUpdateProfile(updated));
    Navigator.of(context).maybePop();
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final surface = _c(theme.surfaceColor);
    final bg = _c(theme.backgroundColor);
    final accent = _c(theme.primaryColor);
    final onPrimary = _c(theme.onPrimaryColor);

    final swatches = <Color>[
      accent,
      ...widget.tints,
      const Color(0xFF22C55E),
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
    ];
    int selectedSwatch() {
      if (_calendarColor == null) return 0;
      final hex = _calendarColor!.toLowerCase();
      for (var i = 0; i < swatches.length; i++) {
        final cand =
            '#${swatches[i].toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
        if (cand.toLowerCase() == hex) return i;
      }
      return 0;
    }

    BoxDecoration field() => BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ImagePickerField(
              bucket: ImageBuckets.avatars,
              path: '${widget.profile.id}/avatar.jpg',
              value: _avatarUrl,
              onChanged: (v) => setState(() => _avatarUrl = v),
              size: 110,
              circle: true,
              fallbackColor: accent,
              fallbackText: _initials,
            ),
          ),
          const SizedBox(height: 24),
          _label('Display name', muted),
          const SizedBox(height: 6),
          CupertinoTextField(
            controller: _name,
            placeholder: 'Your name',
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            style: AppFonts.body(fontSize: 15, color: fg),
            placeholderStyle: AppFonts.body(fontSize: 15, color: muted),
            decoration: field(),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          _label('Birth date', muted),
          const SizedBox(height: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _pickBirthDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: field(),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _birthDate == null ? 'Not set' : _formatDate(_birthDate!),
                      style: AppFonts.body(
                        fontSize: 15,
                        color: _birthDate == null ? muted : fg,
                      ),
                    ),
                  ),
                  if (_birthDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _birthDate = null),
                      child: Icon(CupertinoIcons.xmark_circle_fill,
                          size: 18, color: muted),
                    )
                  else
                    Icon(CupertinoIcons.calendar, size: 16, color: muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _label('Preferred currency', muted),
          const SizedBox(height: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _pickCurrency,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: field(),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _currency,
                      style: AppFonts.body(fontSize: 15, color: fg),
                    ),
                  ),
                  Icon(CupertinoIcons.chevron_down, size: 14, color: muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _label('Calendar color', muted),
          const SizedBox(height: 8),
          ColorSwatchRow(
            colors: swatches,
            selected: selectedSwatch(),
            onSelected: (i) {
              final hex =
                  '#${swatches[i].toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
              setState(() => _calendarColor = hex);
            },
            bg: bg,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: CupertinoButton(
              color: accent,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              padding: EdgeInsets.zero,
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const CupertinoActivityIndicator()
                  : Text(
                      'Save',
                      style: AppFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t, Color c) => Text(
        t.toUpperCase(),
        style: AppFonts.body(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: c,
          letterSpacing: 1.0,
        ),
      );

  String _formatDate(DateTime d) {
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
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
