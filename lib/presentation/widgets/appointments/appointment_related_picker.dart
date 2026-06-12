import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/presentation/widgets/common/animated_pill_tabs.dart';

/// Appointment "related to" picker (bug #10).
///
/// An [FCheckbox] enables the section; a pill-tab toggle switches between Cars
/// and Pets; each shows a 2-column grid of selectable cards with a primary
/// colour indicator and the entity image when present.
///
/// Pets are **multi-select** (persisted via the `appointment_pets` join); cars
/// are single-select (one `car_id`).
class AppointmentRelatedPicker extends StatefulWidget {
  final String? householdId;
  final Set<String> petIds;
  final String? carId;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;

  final void Function(Set<String> petIds) onPetsChanged;
  final void Function(String? carId) onCarChanged;

  const AppointmentRelatedPicker({
    super.key,
    required this.householdId,
    required this.petIds,
    required this.carId,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.onPetsChanged,
    required this.onCarChanged,
  });

  @override
  State<AppointmentRelatedPicker> createState() =>
      _AppointmentRelatedPickerState();
}

class _AppointmentRelatedPickerState extends State<AppointmentRelatedPicker> {
  List<({String id, String name, String? image})> _pets = [];
  List<({String id, String name, String? image})> _cars = [];
  bool _enabled = false;
  int _tab = 0; // 0 = Cars, 1 = Pets
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _enabled = widget.petIds.isNotEmpty || widget.carId != null;
    _tab = widget.petIds.isNotEmpty ? 1 : 0;
    _load();
  }

  Future<void> _load() async {
    final hh = widget.householdId;
    if (hh == null) {
      setState(() => _loading = false);
      return;
    }
    final deps = AppDependencies.instance;
    final (pets, _) = await deps.petRepository.getPets(householdId: hh);
    final (cars, _) = await deps.carRepository.getCars(householdId: hh);
    if (!mounted) return;
    setState(() {
      _pets =
          pets.map((p) => (id: p.id, name: p.name, image: p.imageUrl)).toList();
      _cars =
          cars.map((c) => (id: c.id, name: c.name, image: c.imageUrl)).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    if (_pets.isEmpty && _cars.isEmpty) return const SizedBox.shrink();

    final items = _tab == 0 ? _cars : _pets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            FCheckbox(
              value: _enabled,
              onChange: (v) {
                setState(() => _enabled = v);
                if (!v) {
                  widget.onPetsChanged(const {});
                  widget.onCarChanged(null);
                }
              },
            ),
            const SizedBox(width: 10),
            Text('Add related pet or car',
                style: AppFonts.body(fontSize: 14, color: widget.fg)),
          ],
        ),
        if (_enabled) ...[
          const SizedBox(height: 12),
          AnimatedPillTabs(
            labels: const ['Cars', 'Pets'],
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
            surface: widget.surface,
            border: widget.border,
            fg: widget.fg,
            muted: widget.muted,
            pillColor: widget.accent,
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _tab == 0 ? 'No cars yet' : 'No pets yet',
                style: AppFonts.body(fontSize: 13, color: widget.muted),
              ),
            )
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.6,
              children: [
                for (final it in items)
                  _Card(
                    name: it.name,
                    image: it.image,
                    selected: _tab == 0
                        ? widget.carId == it.id
                        : widget.petIds.contains(it.id),
                    surface: widget.surface,
                    border: widget.border,
                    fg: widget.fg,
                    accent: widget.accent,
                    onTap: () {
                      if (_tab == 0) {
                        // Cars: single-select (toggle).
                        widget.onCarChanged(
                            widget.carId == it.id ? null : it.id);
                      } else {
                        // Pets: multi-select (toggle membership).
                        final next = Set<String>.from(widget.petIds);
                        if (!next.add(it.id)) next.remove(it.id);
                        widget.onPetsChanged(next);
                      }
                    },
                  ),
              ],
            ),
        ],
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String name;
  final String? image;
  final bool selected;
  final Color surface;
  final Color border;
  final Color fg;
  final Color accent;
  final VoidCallback onTap;

  const _Card({
    required this.name,
    required this.image,
    required this.selected,
    required this.surface,
    required this.border,
    required this.fg,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.14) : surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected ? accent : border,
            width: selected ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          spacing: 8,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: SizedBox(
                width: 34,
                height: 34,
                child: image != null && image!.isNotEmpty
                    ? Image.network(
                        image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _fallback(),
                      )
                    : _fallback(),
              ),
            ),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? accent : fg,
                ),
              ),
            ),
            if (selected)
              Icon(CupertinoIcons.checkmark_circle_fill,
                  size: 16, color: accent),
          ],
        ),
      ),
    );
  }

  Widget _fallback() => Container(
        color: accent.withValues(alpha: 0.18),
        alignment: Alignment.center,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppFonts.heading(
              fontSize: 14, fontWeight: FontWeight.w700, color: accent),
        ),
      );
}
