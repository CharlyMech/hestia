import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/pet.dart';
import 'package:hestia/domain/entities/pet_health_record.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/pets/pet_detail_bloc.dart';
import 'package:hestia/presentation/blocs/pets/pets_bloc.dart';
import 'package:hestia/presentation/pages/pets/add_edit_health_record_screen.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/common/sliver_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/pets/paw_icon.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:skeletonizer/skeletonizer.dart';

class PetDetailScreen extends StatelessWidget {
  final String petId;
  const PetDetailScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PetDetailBloc(AppDependencies.instance.petRepository)
        ..add(PetDetailLoad(petId)),
      child: _PetDetailBody(petId: petId),
    );
  }
}

class _PetDetailBody extends StatelessWidget {
  final String petId;
  const _PetDetailBody({required this.petId});

  void _syncListBloc(BuildContext context) {
    try {
      context.read<PetsBloc>().add(const PetsRefresh());
    } catch (_) {}
  }

  void _confirmDelete(BuildContext ctx, Pet pet) {
    final l10n = AppLocalizations.of(ctx);
    showCupertinoDialog(
      context: ctx,
      builder: (_) => CupertinoAlertDialog(
        title: Text(l10n.pets_deletePetTitle),
        content: Text(l10n.pets_deletePetConfirm(pet.name)),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<PetDetailBloc>().add(const PetDetailDelete());
            },
            child: Text(l10n.common_delete),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.common_cancel),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRecord(
      BuildContext ctx, PetHealthRecord record, PetDetailBloc bloc) {
    final l10n = AppLocalizations.of(ctx);
    showCupertinoDialog(
      context: ctx,
      builder: (_) => CupertinoAlertDialog(
        title: Text(l10n.pets_deleteRecordTitle),
        content: Text(l10n.pets_deleteRecordConfirm(record.title)),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              await AppDependencies.instance.petRepository
                  .deleteHealthRecord(record.id);
              if (ctx.mounted) bloc.add(const PetDetailReloadRecords());
            },
            child: Text(l10n.common_delete),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.common_cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.myTheme;
    final surface = hexToColor(theme.surfaceColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);

    return BlocConsumer<PetDetailBloc, PetDetailState>(
      listenWhen: (prev, curr) =>
          curr is PetDetailDeleted ||
          (prev is PetDetailLoaded &&
              curr is PetDetailLoaded &&
              prev.pet.isActive != curr.pet.isActive),
      listener: (context, state) {
        if (state is PetDetailDeleted) {
          _syncListBloc(context);
          context.pop();
          return;
        }
        if (state is PetDetailLoaded) {
          _syncListBloc(context);
        }
      },
      builder: (context, state) {
        final bloc = context.read<PetDetailBloc>();
        final loading = state is PetDetailInitial || state is PetDetailLoading;

        if (state is PetDetailNotFound) {
          return SliverPushedRouteShell(
            title: l10n.pets_title,
            content: Center(
              heightFactor: 1,
              child: Text(l10n.pets_notFound,
                  style: AppFonts.body(fontSize: 14, color: muted)),
            ),
          );
        }

        final pet = state is PetDetailLoaded ? state.pet : null;
        final records = state is PetDetailLoaded
            ? state.records
            : const <PetHealthRecord>[];

        return SliverPushedRouteShell(
          title: pet?.name ?? '',
          isActive: pet?.isActive,
          header: pet != null ? _PetHeader(pet: pet) : null,
          onRefresh: () async => bloc.add(const PetDetailRefresh()),
          actions: pet == null
              ? null
              : [
                  AppMenuAction(
                    icon: iconoir.EditPencil(
                        width: 18, height: 18, color: accent),
                    label: l10n.common_edit,
                    onTap: () async {
                      await context.push(AppRoutes.editPet, extra: pet.id);
                      if (context.mounted) {
                        bloc.add(const PetDetailRefresh());
                      }
                    },
                  ),
                  AppMenuAction.toggleActive(
                    isActive: pet.isActive,
                    setActiveLabel: l10n.pets_setActive,
                    setInactiveLabel: l10n.pets_setInactive,
                    fg: fg,
                    onTap: () => bloc.add(const PetDetailToggleActive()),
                  ),
                  AppMenuAction(
                    icon: iconoir.Trash(
                        width: 18,
                        height: 18,
                        color: CupertinoColors.destructiveRed),
                    label: l10n.common_delete,
                    isDestructive: true,
                    onTap: () => _confirmDelete(context, pet),
                  ),
                ],
          content: Skeletonizer(
            enabled: loading,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              child: loading
                  ? _PetSkeleton(surface: surface, muted: muted)
                  : _PetBody(
                      l10n: l10n,
                      pet: pet!,
                      records: records,
                      surface: surface,
                      fg: fg,
                      muted: muted,
                      accent: accent,
                      onAddRecord: () async {
                        await showHealthRecordSheet(context, petId: pet.id);
                        if (context.mounted) {
                          bloc.add(const PetDetailReloadRecords());
                        }
                      },
                      onEditRecord: (r) async {
                        await showHealthRecordSheet(context, existing: r);
                        if (context.mounted) {
                          bloc.add(const PetDetailReloadRecords());
                        }
                      },
                      onDeleteRecord: (r) =>
                          _confirmDeleteRecord(context, r, bloc),
                    ),
            ),
          ),
        );
      },
    );
  }
}

// ── Skeleton placeholder ──────────────────────────────────────────────────────

class _PetSkeleton extends StatelessWidget {
  final Color surface;
  final Color muted;
  const _PetSkeleton({required this.surface, required this.muted});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 112,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 16,
          width: 140,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < 3; i++) ...[
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

// ── Real body ─────────────────────────────────────────────────────────────────

class _PetBody extends StatelessWidget {
  final AppLocalizations l10n;
  final Pet pet;
  final List<PetHealthRecord> records;
  final Color surface, fg, muted, accent;
  final VoidCallback onAddRecord;
  final void Function(PetHealthRecord) onEditRecord;
  final void Function(PetHealthRecord) onDeleteRecord;

  const _PetBody({
    required this.l10n,
    required this.pet,
    required this.records,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.onAddRecord,
    required this.onEditRecord,
    required this.onDeleteRecord,
  });

  @override
  Widget build(BuildContext context) {
    final fg = hexToColor(context.myTheme.foregroundColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroCard(
            pet: pet,
            l10n: l10n,
            surface: surface,
            fg: fg,
            muted: muted,
            accent: accent),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(l10n.pets_healthRecords,
                  style: AppFonts.body(
                      fontSize: 15, fontWeight: FontWeight.w600, color: fg)),
            ),
            AnimatedButton(
                onTap: onAddRecord,
                padding: const EdgeInsets.all(4),
                child: iconoir.Plus(width: 16, height: 16, color: fg))
          ],
        ),
        const SizedBox(height: 10),
        if (records.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  PawIcon(size: 36, color: muted),
                  const SizedBox(height: 8),
                  Text(l10n.pets_noHealthRecordsYet,
                      style: AppFonts.body(fontSize: 13, color: muted)),
                ],
              ),
            ),
          )
        else
          Column(
            children: records
                .map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RecordCard(
                        l10n: l10n,
                        record: r,
                        surface: surface,
                        fg: fg,
                        muted: muted,
                        accent: accent,
                        onEdit: () => onEditRecord(r),
                        onDelete: () => onDeleteRecord(r),
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Pet pet;
  final AppLocalizations l10n;
  final Color surface;
  final Color fg;
  final Color muted;
  final Color accent;

  const _HeroCard({
    required this.pet,
    required this.l10n,
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
                : Image.file(File(pet.imageUrl!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _initBox(initial, accent)))
            : _initBox(initial, accent),
      ),
    );

    final speciesLabel = _speciesLabel(pet.species, l10n);
    final genderLabel =
        pet.gender != PetGender.unknown ? _genderLabel(pet.gender, l10n) : null;

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
                Text(pet.name,
                    style: AppFonts.body(
                        fontSize: 18, fontWeight: FontWeight.w700, color: fg)),
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
                          label: l10n.pets_ageYears(pet.ageYears!),
                          accent: accent,
                        ),
                      if (pet.weightKg != null)
                        _Chip(
                          label: l10n.pets_weightKg(
                            pet.weightKg!.toStringAsFixed(1),
                          ),
                          accent: accent,
                        ),
                    ],
                  ),
                ],
                if (pet.notes != null) ...[
                  const SizedBox(height: 8),
                  Text(pet.notes!,
                      style: AppFonts.body(fontSize: 12, color: muted),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
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
        child: Text(initial,
            style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700)),
      );

  String _speciesLabel(PetSpecies s, AppLocalizations l10n) => switch (s) {
        PetSpecies.dog => l10n.pets_speciesDog,
        PetSpecies.cat => l10n.pets_speciesCat,
        PetSpecies.bird => l10n.pets_speciesBird,
        PetSpecies.rabbit => l10n.pets_speciesRabbit,
        PetSpecies.fish => l10n.pets_speciesFish,
        PetSpecies.reptile => l10n.pets_speciesReptile,
        PetSpecies.other => l10n.pets_speciesOther,
      };

  String _genderLabel(PetGender g, AppLocalizations l10n) => switch (g) {
        PetGender.male => l10n.pets_genderMaleFull,
        PetGender.female => l10n.pets_genderFemaleFull,
        PetGender.unknown => l10n.pets_genderUnknown,
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
      child: Text(label, style: AppFonts.numeric(fontSize: 11, color: accent)),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final AppLocalizations l10n;
  final PetHealthRecord record;
  final Color surface, fg, muted, accent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecordCard({
    required this.l10n,
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
                Text(record.title,
                    style: AppFonts.body(
                        fontSize: 14, fontWeight: FontWeight.w600, color: fg)),
                const SizedBox(height: 2),
                Text(_typeLabel(record.type, l10n),
                    style: AppFonts.label(fontSize: 10, color: muted)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(dateStr,
                        style: AppFonts.numeric(fontSize: 11, color: muted)),
                    if (dueStr != null) ...[
                      Text(l10n.pets_recordNextDue,
                          style: AppFonts.body(fontSize: 11, color: muted)),
                      Text(dueStr,
                          style: AppFonts.numeric(
                              fontSize: 11,
                              color: isOverdue
                                  ? CupertinoColors.destructiveRed
                                  : muted)),
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
                  Text(l10n.pets_costEuro(record.cost!.toStringAsFixed(2)),
                      style: AppFonts.numeric(fontSize: 11, color: accent)),
                ],
                if (record.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(record.notes!,
                      style: AppFonts.body(fontSize: 11, color: muted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
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

  String _typeLabel(HealthRecordType t, AppLocalizations l10n) => switch (t) {
        HealthRecordType.vaccine => l10n.pets_healthTypeVaccine,
        HealthRecordType.vet => l10n.pets_healthTypeVet,
        HealthRecordType.medication => l10n.pets_healthTypeMedication,
        HealthRecordType.grooming => l10n.pets_healthTypeGrooming,
        HealthRecordType.deworming => l10n.pets_healthTypeDeworming,
        HealthRecordType.other => l10n.pets_healthTypeOther,
      };
}

class _PetHeader extends StatelessWidget {
  final Pet pet;

  const _PetHeader({required this.pet});

  bool get _hasImage => pet.imageUrl != null && pet.imageUrl!.isNotEmpty;
  bool get _isRemote =>
      _hasImage &&
      (pet.imageUrl!.startsWith('http://') ||
          pet.imageUrl!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final primary = hexToColor(context.myTheme.primaryColor);
    final initial = pet.name.isNotEmpty ? pet.name[0].toUpperCase() : '?';
    if (_hasImage) {
      return _isRemote
          ? CachedNetworkImage(
              imageUrl: pet.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, __) => ColoredBox(color: primary),
              errorWidget: (_, __, ___) => _fallback(initial, primary),
            )
          : Image.file(File(pet.imageUrl!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => _fallback(initial, primary));
    }
    return _fallback(initial, primary);
  }

  Widget _fallback(String initial, Color primary) => Container(
        color: primary,
        alignment: Alignment.center,
        child: Text(initial,
            style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 80,
                fontWeight: FontWeight.w700)),
      );
}
