import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/currencies.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/data/services/image_upload_service.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_events.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/image_picker_field.dart';

/// Edit-profile bottom sheet body. Lets the user change avatar, display name,
/// birth date, preferred currency and calendar color.
class ProfileSheetForm extends StatefulWidget {
  final Profile profile;
  final List<Color> tints;

  const ProfileSheetForm({
    super.key,
    required this.profile,
    required this.tints,
  });

  @override
  State<ProfileSheetForm> createState() => _ProfileSheetFormState();
}

class _ProfileSheetFormState extends State<ProfileSheetForm>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _name;
  late final FRadioSelectGroupController<AppCurrency> _currencyCtrl;
  late final FPopoverController _currencyPopover;
  late String? _avatarUrl;
  late DateTime? _birthDate;
  late String? _calendarColor;
  bool _saving = false;

  AppCurrency get _currency =>
      _currencyCtrl.values.firstOrNull ??
      AppCurrencies.fromCode(widget.profile.preferredCurrency) ??
      AppCurrencies.eur;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.displayName ?? '');
    _currencyCtrl = FRadioSelectGroupController<AppCurrency>(
      value: AppCurrencies.fromCode(widget.profile.preferredCurrency) ??
          AppCurrencies.eur,
    );
    _currencyPopover = FPopoverController(vsync: this);
    _avatarUrl = widget.profile.avatarUrl;
    _birthDate = widget.profile.birthDate;
    _calendarColor = widget.profile.calendarColor;
  }

  @override
  void dispose() {
    _name.dispose();
    _currencyCtrl.dispose();
    _currencyPopover.dispose();
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
    final fg = hexToColor(theme.onBackgroundColor);
    final primary = hexToColor(theme.primaryColor);

    DateTime tmp = _birthDate ?? DateTime(2000, 1, 1);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: hexToColor(theme.surfaceColor),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadii.xxl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                children: [
                  AnimatedButton(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Text(AppLocalizations.of(ctx).common_cancel,
                        style: AppFonts.body(fontSize: 14, color: fg)),
                  ),
                  const Spacer(),
                  AnimatedButton(
                    onTap: () {
                      setState(() => _birthDate = tmp);
                      Navigator.of(ctx).pop();
                    },
                    child: Text(AppLocalizations.of(ctx).common_done,
                        style: AppFonts.body(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primary)),
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

  Future<void> _save() async {
    setState(() => _saving = true);
    final updated = widget.profile.copyWith(
      displayName: _name.text.trim().isEmpty ? null : _name.text.trim(),
      avatarUrl: _avatarUrl,
      clearAvatar: _avatarUrl == null,
      birthDate: _birthDate,
      clearBirthDate: _birthDate == null,
      preferredCurrency: _currency.code,
      calendarColor: _calendarColor,
      lastUpdate: DateTime.now(),
    );
    if (!mounted) return;
    final bloc = context.read<AuthBloc>();
    bloc.add(AuthUpdateProfile(updated));
    // Wait for bloc to emit updated AuthAuthenticated state before closing.
    await bloc.stream.firstWhere((s) => s is AuthAuthenticated);
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final surface = hexToColor(theme.surfaceColor);
    final bg = hexToColor(theme.backgroundColor);
    final accent = hexToColor(theme.primaryColor);
    final onPrimary = hexToColor(theme.onPrimaryColor);

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
          borderRadius: BorderRadius.circular(AppRadii.lg),
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
              fallbackColor:
                  _calendarColor != null ? hexToColor(_calendarColor!) : accent,
              fallbackText: _initials,
            ),
          ),
          const SizedBox(height: 24),
          _label(AppLocalizations.of(context).profile_displayName, muted),
          const SizedBox(height: 6),
          FTextField(
            controller: _name,
            hint: AppLocalizations.of(context).profile_displayName,
            textCapitalization: TextCapitalization.words,
            onChange: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          _label(AppLocalizations.of(context).profile_birthDate, muted),
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
                      _birthDate == null
                          ? AppLocalizations.of(context).common_notSet
                          : _formatDate(_birthDate!),
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
          _label(AppLocalizations.of(context).profile_preferredCurrency, muted),
          const SizedBox(height: 6),
          ListenableBuilder(
            listenable: _currencyCtrl,
            builder: (context, _) => FPopover(
              controller: _currencyPopover,
              followerAnchor: Alignment.topCenter,
              targetAnchor: Alignment.bottomCenter,
              followerBuilder: (context, style, _) => DecoratedBox(
                decoration: style.decoration,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 340,
                    maxHeight: 240,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: AppCurrencies.all.length,
                      separatorBuilder: (_, __) => Container(
                        height: 0.8,
                        color: hexToColor(context.myTheme.borderColor)
                            .withValues(alpha: 0.5),
                      ),
                      itemBuilder: (context, i) {
                        final c = AppCurrencies.all[i];
                        final selected = _currencyCtrl.values.contains(c);
                        return AnimatedButton(
                          onTap: () {
                            _currencyCtrl.select(c, true);
                            _currencyPopover.hide();
                          },
                          backgroundColor: surface,
                          borderRadius: AppRadii.none,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 13),
                          child: Row(
                            spacing: 12,
                            children: [
                              if (selected)
                                Icon(CupertinoIcons.check_mark,
                                    size: 14,
                                    color: hexToColor(
                                        context.myTheme.primaryColor))
                              else
                                const SizedBox(width: 14),
                              Text(
                                '${c.code} ${c.symbol}',
                                style: AppFonts.body(
                                  fontSize: 15,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: selected
                                      ? hexToColor(context.myTheme.primaryColor)
                                      : fg,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              target: AnimatedButton(
                onTap: _currencyPopover.toggle,
                backgroundColor: surface,
                borderRadius: AppRadii.lg,
                borderColor: hexToColor(context.myTheme.borderColor),
                borderWidth: 0.8,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_currency.code} ${_currency.symbol}',
                        style: AppFonts.body(fontSize: 15, color: fg),
                      ),
                    ),
                    Icon(CupertinoIcons.chevron_down, size: 14, color: muted),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _label(AppLocalizations.of(context).profile_calendarColor, muted),
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
            child: AnimatedButton(
              backgroundColor: accent,
              borderRadius: AppRadii.lg,
              padding: EdgeInsets.zero,
              onTap: _saving ? null : _save,
              child: Center(
                child: _saving
                    ? const CupertinoActivityIndicator()
                    : Text(
                        AppLocalizations.of(context).common_save,
                        style: AppFonts.body(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: onPrimary,
                        ),
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
