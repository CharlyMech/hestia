import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:forui/forui.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/home.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/common/primary_button.dart';
import 'package:hestia/presentation/widgets/common/select_location_screen.dart';
import 'package:latlong2/latlong.dart';

class AddEditHomeSheetForm extends StatefulWidget {
  final Home? existing;
  final void Function(Home) onSaved;

  const AddEditHomeSheetForm({super.key, required this.onSaved, this.existing});

  @override
  State<AddEditHomeSheetForm> createState() => _AddEditHomeSheetFormState();
}

class _AddEditHomeSheetFormState extends State<AddEditHomeSheetForm> {
  late final TextEditingController _name;
  late final TextEditingController _address;
  static const _kMadridLat = 40.4168;
  static const _kMadridLng = -3.7038;
  late double _lat;
  late double _lng;
  bool _saving = false;
  String? _nameError;
  String? _addressError;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _address = TextEditingController(text: widget.existing?.address ?? '');
    _lat = widget.existing?.latitude ?? _kMadridLat;
    _lng = widget.existing?.longitude ?? _kMadridLng;
    // New home: seed the preview with the device location when available.
    if (widget.existing == null) _resolveDeviceLocation();
  }

  Future<void> _resolveDeviceLocation() async {
    final pos =
        await AppDependencies.instance.locationService.getCurrentPosition();
    if (pos != null && mounted) {
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final nameEmpty = _name.text.trim().isEmpty;
    final addressEmpty = _address.text.trim().isEmpty;
    if (nameEmpty || addressEmpty) {
      setState(() {
        _nameError = nameEmpty ? l10n.homes_nameRequired : null;
        _addressError = addressEmpty ? l10n.homes_addressRequired : null;
      });
      return;
    }
    setState(() => _saving = true);

    final auth = context.read<AuthBloc>().state;
    final householdId = auth is AuthAuthenticated
        ? (await AppDependencies.instance.householdRepository
                .getCurrentHousehold(auth.profile.id))
            .$1
            ?.id
        : null;
    if (householdId == null) return;

    final home = Home(
      id: widget.existing?.id ?? '',
      householdId: householdId,
      name: _name.text.trim(),
      address: _address.text.trim(),
      latitude: _lat,
      longitude: _lng,
      description: widget.existing?.description,
      imageUrl: widget.existing?.imageUrl,
      isActive: widget.existing?.isActive ?? true,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    widget.onSaved(home);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final border = hexToColor(theme.outlineColor);
    final muted = hexToColor(theme.mutedColor);
    final accent = hexToColor(theme.primaryColor);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
        left: 20,
        right: 20,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          _field(_name, l10n.homes_name, l10n.homes_namePlaceholder,
              error: _nameError,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              }),
          _field(_address, l10n.homes_address, l10n.homes_addressPlaceholder,
              error: _addressError,
              onChanged: (_) {
                if (_addressError != null) setState(() => _addressError = null);
              }),
          _MapPreview(
            key: ValueKey('$_lat,$_lng'),
            latitude: _lat,
            longitude: _lng,
            accent: accent,
            border: border,
            muted: muted,
            note: l10n.homes_coordinatesNote(
              _lat.toStringAsFixed(4),
              _lng.toStringAsFixed(4),
            ),
            onTap: _pickLocation,
          ),
          PrimaryButton(
            label: widget.existing == null
                ? l10n.homes_addHome
                : l10n.homes_saveChanges,
            onPressed: _saving ? null : _save,
            loading: _saving,
          ),
        ],
      ),
    );
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<(double, double)>(
      CupertinoPageRoute(
        builder: (_) => SelectLocationScreen(
          initialLatitude: _lat,
          initialLongitude: _lng,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _lat = result.$1;
        _lng = result.$2;
      });
    }
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String placeholder, {
    String? error,
    void Function(String)? onChanged,
  }) {
    return FTextField(
      controller: ctrl,
      label: Text(label),
      hint: placeholder,
      textCapitalization: TextCapitalization.sentences,
      forceErrorText: error,
      onChange: onChanged,
    );
  }
}

// ── Tappable map preview ──────────────────────────────────────────────────────

class _MapPreview extends StatelessWidget {
  final double latitude, longitude;
  final Color accent, border, muted;
  final String note;
  final VoidCallback onTap;

  const _MapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.accent,
    required this.border,
    required this.muted,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: border, width: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: IgnorePointer(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 14,
                    interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.charlymech.hestia',
                      retinaMode: MediaQuery.devicePixelRatioOf(context) > 1,
                    ),
                    MarkerLayer(markers: [
                      Marker(
                        point: point,
                        width: 32,
                        height: 32,
                        child: Icon(CupertinoIcons.location_solid,
                            color: accent, size: 28),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          Text(note, style: AppFonts.body(fontSize: 11, color: muted)),
        ],
      ),
    );
  }
}
