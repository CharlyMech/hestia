import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/pet.dart';
import 'package:hestia/presentation/blocs/pets/pets_bloc.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/pets/paw_icon.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:skeletonizer/skeletonizer.dart';

class PetsScreen extends StatelessWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context) => const _PetsView();
}

class _PetsView extends StatefulWidget {
  const _PetsView();

  @override
  State<_PetsView> createState() => _PetsViewState();
}

class _PetsViewState extends State<_PetsView> {
  bool _refreshing = false;

  Future<void> _onPullRefresh(BuildContext context) async {
    setState(() => _refreshing = true);
    try {
      final bloc = context.read<PetsBloc>();
      final start = bloc.state;
      final startRev = start is PetsLoaded ? start.revision : -1;
      bloc.add(const PetsRefresh());
      await bloc.stream.firstWhere((s) {
        if (s is PetsLoaded) return s.revision > startRev;
        if (s is PetsError) return true;
        return false;
      });
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
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
    final tints = theme.categoryTints.map(_c).toList();

    return ColoredBox(
      color: bg,
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<PetsBloc, PetsState>(
          builder: (context, state) {
            return Skeletonizer(
              enabled: _refreshing,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () => _onPullRefresh(context),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Pets',
                              style: AppFonts.heading(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: fg,
                              ),
                            ),
                          ),
                          IconBtn(
                            icon:
                                iconoir.Plus(width: 16, height: 16, color: fg),
                            surface: surface,
                            border: border,
                            onTap: () async {
                              await context.push(AppRoutes.addPet);
                              if (context.mounted) {
                                context
                                    .read<PetsBloc>()
                                    .add(const PetsRefresh());
                              }
                            },
                            size: 36,
                            radius: AppRadii.lg,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  _buildBody(state, surface, fg, muted, accent, tints, context),
                  const SliverToBoxAdapter(child: SizedBox(height: 110)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    PetsState state,
    Color surface,
    Color fg,
    Color muted,
    Color accent,
    List<Color> tints,
    BuildContext context,
  ) {
    if (state is PetsLoading || state is PetsInitial) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    if (state is PetsError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(state.message,
              style: AppFonts.body(fontSize: 13, color: muted)),
        ),
      );
    }
    final pets = (state as PetsLoaded).pets;
    if (pets.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PawIcon(size: 48, color: muted),
              const SizedBox(height: 12),
              Text('No pets yet',
                  style: AppFonts.body(
                      fontSize: 15, fontWeight: FontWeight.w600, color: fg)),
              const SizedBox(height: 6),
              Text('Tap + to add one',
                  style: AppFonts.body(fontSize: 12, color: muted)),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      sliver: SliverList.separated(
        itemCount: pets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _PetCard(
          pet: pets[i],
          surface: surface,
          fg: fg,
          muted: muted,
          accent: accent,
          tint: tints[i % tints.length],
          onTap: () async {
            await context.push(AppRoutes.petDetail, extra: pets[i].id);
            if (context.mounted) {
              context.read<PetsBloc>().add(const PetsRefresh());
            }
          },
        ),
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _PetCard extends StatelessWidget {
  final Pet pet;
  final Color surface;
  final Color fg;
  final Color muted;
  final Color accent;
  final Color tint;
  final VoidCallback onTap;

  const _PetCard({
    required this.pet,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.tint,
    required this.onTap,
  });

  bool get _isRemote =>
      pet.imageUrl != null &&
      (pet.imageUrl!.startsWith('http://') ||
          pet.imageUrl!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final hasImage = pet.imageUrl != null && pet.imageUrl!.isNotEmpty;
    final initial = pet.name.isNotEmpty ? pet.name[0].toUpperCase() : '?';

    final thumb = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64,
        height: 64,
        child: hasImage
            ? (_isRemote
                ? CachedNetworkImage(
                    imageUrl: pet.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: tint),
                    errorWidget: (_, __, ___) => _initialBox(initial),
                  )
                : Image.file(
                    File(pet.imageUrl!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _initialBox(initial),
                  ))
            : _initialBox(initial),
      ),
    );

    final subParts = <String>[
      _speciesLabel(pet.species),
      if (pet.breed != null) pet.breed!,
    ];

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Row(
          children: [
            thumb,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pet.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: fg,
                          ),
                        ),
                      ),
                      _GenderBadge(gender: pet.gender, accent: accent),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subParts.join(' · '),
                    style: AppFonts.body(fontSize: 12, color: muted),
                  ),
                  if (pet.ageYears != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${pet.ageYears} yr${pet.ageYears == 1 ? '' : 's'}',
                      style: AppFonts.numeric(fontSize: 12, color: muted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initialBox(String initial) => Container(
        color: tint,
        alignment: Alignment.center,
        child: Text(
          initial,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 22,
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
}

class _GenderBadge extends StatelessWidget {
  final PetGender gender;
  final Color accent;
  const _GenderBadge({required this.gender, required this.accent});

  @override
  Widget build(BuildContext context) {
    if (gender == PetGender.unknown) return const SizedBox.shrink();
    final label = gender == PetGender.male ? 'M' : 'F';
    final mutedHex = context.myTheme.onInactiveColor;
    final muted = Color(int.parse(mutedHex.replaceFirst('#', '0xff')));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: muted.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppFonts.label(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: muted,
        ),
      ),
    );
  }
}
