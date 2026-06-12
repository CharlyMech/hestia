import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/data/services/image_upload_service.dart';
import 'package:hestia/domain/entities/pet.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/common/animated_pill_tabs.dart';
import 'package:hestia/presentation/widgets/common/app_toast.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/image_picker_field.dart';
import 'package:hestia/presentation/widgets/common/primary_button.dart';

class AddEditPetScreen extends StatelessWidget {
  final String? petId;
  const AddEditPetScreen({super.key, this.petId});

  @override
  Widget build(BuildContext context) {
    return _AddEditPetView(petId: petId);
  }
}

class _AddEditPetView extends StatefulWidget {
  final String? petId;
  const _AddEditPetView({this.petId});
  @override
  State<_AddEditPetView> createState() => _AddEditPetViewState();
}

class _AddEditPetViewState extends State<_AddEditPetView> {
  final _name = TextEditingController();
  final _breed = TextEditingController();
  final _weight = TextEditingController();
  final _notes = TextEditingController();

  PetSpecies _species = PetSpecies.dog;
  PetGender _gender = PetGender.unknown;
  DateTime? _birthDate;
  String? _imageUrl;
  Pet? _existing;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (widget.petId != null) {
      final (pet, _) =
          await AppDependencies.instance.petRepository.getPet(widget.petId!);
      if (pet != null) {
        _existing = pet;
        _name.text = pet.name;
        _breed.text = pet.breed ?? '';
        _weight.text = pet.weightKg?.toString() ?? '';
        _notes.text = pet.notes ?? '';
        _species = pet.species;
        _gender = pet.gender;
        _birthDate = pet.birthDate;
        _imageUrl = pet.imageUrl;
      }
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _weight.dispose();
    _notes.dispose();
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
    final pet = Pet(
      id: _existing?.id ?? '',
      householdId: household.id,
      name: name,
      species: _species,
      breed: _breed.text.trim().isEmpty ? null : _breed.text.trim(),
      gender: _gender,
      birthDate: _birthDate,
      weightKg: double.tryParse(_weight.text.replaceAll(',', '.')),
      imageUrl: _imageUrl,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      isActive: _existing?.isActive ?? true,
      createdBy: _existing?.createdBy ?? auth.profile.id,
      createdAt: _existing?.createdAt ?? now,
      lastUpdate: now,
    );

    if (!mounted) return;
    final repo = AppDependencies.instance.petRepository;
    if (_existing == null) {
      final (_, failure) = await repo.createPet(pet);
      if (!mounted) return;
      if (failure != null) {
        context.showToast(AppToastConfig(
            type: ToastType.error,
            title: 'Could not save',
            description: failure.message));
        return;
      }
      context.showToast(
          AppToastConfig(type: ToastType.success, title: '${pet.name} added'));
    } else {
      final failure = await repo.updatePet(pet);
      if (!mounted) return;
      if (failure != null) {
        context.showToast(AppToastConfig(
            type: ToastType.error,
            title: 'Could not save',
            description: failure.message));
        return;
      }
      context.showToast(AppToastConfig(
          type: ToastType.success, title: '${pet.name} updated'));
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

    final authState = context.read<AuthBloc>().state;
    final uid = authState is AuthAuthenticated ? authState.profile.id : 'anon';

    if (_loading) {
      return CupertinoPushedRouteShell(
        backgroundColor: bg,
        navBackground: surface,
        borderColor: border,
        foregroundColor: fg,
        titleText: widget.petId == null ? 'Add Pet' : 'Edit Pet',
        child: const Center(child: CupertinoActivityIndicator()),
      );
    }

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: widget.petId == null ? 'Add Pet' : 'Edit Pet',
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
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, 40 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ImagePickerField(
                bucket: ImageBuckets.pets,
                // First path segment must be the auth uid for storage RLS.
                path: '$uid/pet_${_existing?.id ?? 'new'}.jpg',
                value: _imageUrl,
                onChanged: (url) => setState(() => _imageUrl = url),
                circle: false,
                size: 96,
                fallbackText:
                    _name.text.isNotEmpty ? _name.text[0].toUpperCase() : null,
              ),
            ),
            const SizedBox(height: 20),
            _label('Name', fg),
            _field(_name, 'e.g. Max', fg, surface, border),
            const SizedBox(height: 12),
            _label('Species', fg),
            _speciesPicker(surface, border, fg, muted),
            const SizedBox(height: 12),
            _label('Gender', fg),
            AnimatedPillTabs(
              labels: const ['Male', 'Female', 'Unknown'],
              selectedIndex: PetGender.values.indexOf(_gender),
              onChanged: (i) =>
                  setState(() => _gender = PetGender.values[i]),
              surface: surface,
              border: border,
              fg: fg,
              muted: muted,
              pillColor: accent,
            ),
            const SizedBox(height: 12),
            _label('Breed', fg),
            _field(_breed, 'e.g. Labrador', fg, surface, border),
            const SizedBox(height: 12),
            _label('Birth date', fg),
            _birthDatePicker(surface, border, fg, muted, accent),
            const SizedBox(height: 12),
            _label('Weight (kg)', fg),
            _field(_weight, 'e.g. 28.5', fg, surface, border, numeric: true),
            const SizedBox(height: 12),
            _label('Notes', fg),
            _field(_notes, 'Optional notes…', fg, surface, border, maxLines: 3),
            const SizedBox(height: 28),
            PrimaryButton(
              label: widget.petId == null ? 'Add pet' : 'Save changes',
              onPressed: _save,
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

  Widget _speciesPicker(Color surface, Color border, Color fg, Color muted) =>
      Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: border),
        ),
        child: AnimatedButton(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          onTap: () => _pickSpecies(fg, surface),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _speciesLabel(_species),
                  style: AppFonts.body(fontSize: 14, color: fg),
                ),
              ),
              Icon(CupertinoIcons.chevron_down, size: 14, color: muted),
            ],
          ),
        ),
      );

  Widget _birthDatePicker(
      Color surface, Color border, Color fg, Color muted, Color accent) {
    return GestureDetector(
      onTap: () => _pickDate(fg, surface, accent),
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
                _birthDate != null
                    ? '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'
                    : 'Not set',
                style: AppFonts.body(
                    fontSize: 14,
                    color:
                        _birthDate != null ? fg : fg.withValues(alpha: 0.35)),
              ),
            ),
            Icon(CupertinoIcons.calendar, size: 16, color: muted),
          ],
        ),
      ),
    );
  }

  void _pickSpecies(Color fg, Color surface) {
    final options = PetSpecies.values;
    showAppBottomSheet<void>(
      context: context,
      title: 'Species',
      heightFactor: 0.5,
      child: SizedBox(
        height: 240,
        child: CupertinoPicker(
          itemExtent: 40,
          scrollController: FixedExtentScrollController(
            initialItem: options.indexOf(_species),
          ),
          onSelectedItemChanged: (i) => setState(() => _species = options[i]),
          children: options
              .map((s) => Center(
                    child: Text(_speciesLabel(s),
                        style: AppFonts.body(fontSize: 16, color: fg)),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _pickDate(Color fg, Color surface, Color accent) {
    DateTime temp = _birthDate ?? DateTime(2020, 1, 1);
    showAppBottomSheet<void>(
      context: context,
      title: 'Birth date',
      heightFactor: 0.55,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedButton(
                  padding: EdgeInsets.zero,
                  onTap: () {
                    setState(() => _birthDate = null);
                    Navigator.pop(context);
                  },
                  child: Text('Clear',
                      style: AppFonts.body(fontSize: 15, color: fg)),
                ),
                AnimatedButton(
                  padding: EdgeInsets.zero,
                  onTap: () {
                    setState(() => _birthDate = temp);
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
          SizedBox(
            height: 240,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: temp,
              maximumDate: DateTime.now(),
              onDateTimeChanged: (d) => temp = d,
            ),
          ),
        ],
      ),
    );
  }

  String _speciesLabel(PetSpecies s) => switch (s) {
        PetSpecies.dog => 'Dog',
        PetSpecies.cat => 'Cat',
        PetSpecies.bird => 'Bird',
        PetSpecies.rabbit => 'Rabbit',
        PetSpecies.fish => 'Fish',
        PetSpecies.reptile => 'Reptile',
        PetSpecies.other => 'Other',
      };

}
