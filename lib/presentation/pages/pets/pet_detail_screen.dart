import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/pet.dart';
import 'package:hestia/domain/entities/pet_health_record.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:hestia/presentation/widgets/pets/paw_icon.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;

class PetDetailScreen extends StatelessWidget {
  final String petId;
  const PetDetailScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return _PetDetailView(petId: petId);
  }
}

class _PetDetailView extends StatefulWidget {
  final String petId;
  const _PetDetailView({required this.petId});
  @override
  State<_PetDetailView> createState() => _PetDetailViewState();
}

class _PetDetailViewState extends State<_PetDetailView> {
  Pet? _pet;
  List<PetHealthRecord> _records = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = AppDependencies.instance.petRepository;
    final (pet, _) = await repo.getPet(widget.petId);
    if (!mounted) return;
    setState(() {
      _pet = pet;
      _loading = false;
    });
    if (pet != null) await _loadRecords();
  }

  Future<void> _loadRecords() async {
    final (records, _) = await AppDependencies.instance.petRepository
        .getHealthRecords(widget.petId);
    if (!mounted) return;
    setState(() => _records = records);
  }

  void _confirmDelete(BuildContext ctx, Color accent) {
    showCupertinoDialog(
      context: ctx,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Remove ${_pet!.name}? This cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              await AppDependencies.instance.petRepository
                  .deletePet(widget.petId);
              if (ctx.mounted) ctx.pop();
            },
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRecord(BuildContext ctx, PetHealthRecord record) {
    showCupertinoDialog(
      context: ctx,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete Record'),
        content: Text('Remove "${record.title}"?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              await AppDependencies.instance.petRepository
                  .deleteHealthRecord(record.id);
              if (ctx.mounted) await _loadRecords();
            },
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
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

    if (_loading) {
      return CupertinoPushedRouteShell(
        backgroundColor: bg,
        navBackground: surface,
        borderColor: border,
        foregroundColor: fg,
        titleText: '',
        child: const Center(child: CupertinoActivityIndicator()),
      );
    }

    if (_pet == null) {
      return CupertinoPushedRouteShell(
        backgroundColor: bg,
        navBackground: surface,
        borderColor: border,
        foregroundColor: fg,
        titleText: 'Pet',
        child: Center(
          child: Text('Not found',
              style: AppFonts.body(fontSize: 14, color: muted)),
        ),
      );
    }

    final pet = _pet!;

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: pet.name,
      trailing: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await context.push(
                  AppRoutes.editPet,
                  extra: pet.id,
                );
                if (mounted) await _load();
              },
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: iconoir.EditPencil(width: 18, height: 18, color: accent),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _confirmDelete(context, accent),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: iconoir.Trash(
                    width: 18,
                    height: 18,
                    color: CupertinoColors.destructiveRed),
              ),
            ),
          ],
        ),
      ),
      child: ScreenShell(
        bg: bg,
        bottomPadding: 40,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroCard(
                    pet: pet,
                    surface: surface,
                    fg: fg,
                    muted: muted,
                    accent: accent,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Health Records',
                          style: AppFonts.body(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: fg,
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          await context.push(
                            AppRoutes.addHealthRecord,
                            extra: pet.id,
                          );
                          if (mounted) await _loadRecords();
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          child: iconoir.Plus(
                              width: 18, height: 18, color: accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_records.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          PawIcon(size: 36, color: muted),
                          const SizedBox(height: 8),
                          Text(
                            'No health records yet',
                            style: AppFonts.body(
                              fontSize: 13,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: _records
                          .map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _RecordCard(
                                record: r,
                                surface: surface,
                                fg: fg,
                                muted: muted,
                                accent: accent,
                                onEdit: () async {
                                  await context.push(
                                    AppRoutes.editHealthRecord,
                                    extra: r,
                                  );
                                  if (mounted) await _loadRecords();
                                },
                                onDelete: () =>
                                    _confirmDeleteRecord(context, r),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _HeroCard extends StatelessWidget {
  final Pet pet;
  final Color surface;
  final Color fg;
  final Color muted;
  final Color accent;

  const _HeroCard({
    required this.pet,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.accent,
  });

  bool get _isRemote =>
      pet.imageUrl != null &&
      (pet.imageUrl!.startsWith('http://') ||
          pet.imageUrl!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final hasImage = pet.imageUrl != null && pet.imageUrl!.isNotEmpty;
    final initial = pet.name.isNotEmpty ? pet.name[0].toUpperCase() : '?';

    Widget thumb = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 80,
        height: 80,
        child: hasImage
            ? (_isRemote
                ? CachedNetworkImage(
                    imageUrl: pet.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: accent),
                    errorWidget: (_, __, ___) => _initBox(initial, accent),
                  )
                : Image.file(
                    File(pet.imageUrl!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _initBox(initial, accent),
                  ))
            : _initBox(initial, accent),
      ),
    );

    final speciesLabel = _speciesLabel(pet.species);
    final genderLabel =
        pet.gender != PetGender.unknown ? _genderLabel(pet.gender) : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          thumb,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: AppFonts.body(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    speciesLabel,
                    if (pet.breed != null) pet.breed!,
                    if (genderLabel != null) genderLabel,
                  ].join(' · '),
                  style: AppFonts.body(fontSize: 13, color: muted),
                ),
                if (pet.ageYears != null || pet.weightKg != null) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (pet.ageYears != null)
                        _Chip(
                          label:
                              '${pet.ageYears} yr${pet.ageYears == 1 ? '' : 's'}',
                          accent: accent,
                        ),
                      if (pet.weightKg != null)
                        _Chip(
                          label: '${pet.weightKg!.toStringAsFixed(1)} kg',
                          accent: accent,
                        ),
                    ],
                  ),
                ],
                if (pet.notes != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    pet.notes!,
                    style: AppFonts.body(fontSize: 12, color: muted),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _initBox(String initial, Color color) => Container(
        color: color.withValues(alpha: 0.3),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  String _speciesLabel(PetSpecies s) => switch (s) {
        PetSpecies.dog => 'Dog',
        PetSpecies.cat => 'Cat',
        PetSpecies.bird => 'Bird',
        PetSpecies.rabbit => 'Rabbit',
        PetSpecies.fish => 'Fish',
        PetSpecies.reptile => 'Reptile',
        PetSpecies.other => 'Other',
      };

  String _genderLabel(PetGender g) => switch (g) {
        PetGender.male => 'Male',
        PetGender.female => 'Female',
        PetGender.unknown => 'Unknown',
      };
}

class _Chip extends StatelessWidget {
  final String label;
  final Color accent;
  const _Chip({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppFonts.numeric(fontSize: 11, color: accent),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final PetHealthRecord record;
  final Color surface;
  final Color fg;
  final Color muted;
  final Color accent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecordCard({
    required this.record,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final d = record.recordedAt;
    final dateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final hasDue = record.nextDueAt != null;
    final due = record.nextDueAt;
    final dueStr = hasDue
        ? '${due!.year}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}'
        : null;
    final isOverdue = hasDue && due!.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: _typeIcon(record.type, accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: AppFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _typeLabel(record.type),
                  style: AppFonts.label(fontSize: 10, color: muted),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(dateStr,
                        style: AppFonts.numeric(fontSize: 11, color: muted)),
                    if (dueStr != null) ...[
                      Text(' · Next: ',
                          style: AppFonts.body(fontSize: 11, color: muted)),
                      Text(
                        dueStr,
                        style: AppFonts.numeric(
                          fontSize: 11,
                          color: isOverdue
                              ? CupertinoColors.destructiveRed
                              : muted,
                        ),
                      ),
                    ],
                  ],
                ),
                if (record.vetName != null) ...[
                  const SizedBox(height: 2),
                  Text(record.vetName!,
                      style: AppFonts.body(fontSize: 11, color: muted)),
                ],
                if (record.cost != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '€${record.cost!.toStringAsFixed(2)}',
                    style: AppFonts.numeric(fontSize: 11, color: accent),
                  ),
                ],
                if (record.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.notes!,
                    style: AppFonts.body(fontSize: 11, color: muted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child:
                      iconoir.EditPencil(width: 16, height: 16, color: muted),
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: iconoir.Trash(
                      width: 16,
                      height: 16,
                      color: CupertinoColors.destructiveRed),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeIcon(HealthRecordType type, Color color) {
    const s = 18.0;
    return switch (type) {
      HealthRecordType.vaccine =>
        iconoir.HealthShield(width: s, height: s, color: color),
      HealthRecordType.vet =>
        iconoir.Healthcare(width: s, height: s, color: color),
      HealthRecordType.medication =>
        iconoir.Activity(width: s, height: s, color: color),
      HealthRecordType.grooming =>
        iconoir.Scissor(width: s, height: s, color: color),
      HealthRecordType.deworming =>
        iconoir.Heart(width: s, height: s, color: color),
      HealthRecordType.other =>
        iconoir.Notes(width: s, height: s, color: color),
    };
  }

  String _typeLabel(HealthRecordType t) => switch (t) {
        HealthRecordType.vaccine => 'Vaccine',
        HealthRecordType.vet => 'Vet visit',
        HealthRecordType.medication => 'Medication',
        HealthRecordType.grooming => 'Grooming',
        HealthRecordType.deworming => 'Deworming',
        HealthRecordType.other => 'Other',
      };
}
