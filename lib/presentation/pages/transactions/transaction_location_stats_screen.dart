import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

/// First-pass map of recent transactions that include coordinates.
class TransactionLocationStatsScreen extends StatefulWidget {
  const TransactionLocationStatsScreen({super.key});

  @override
  State<TransactionLocationStatsScreen> createState() =>
      _TransactionLocationStatsScreenState();
}

class _TransactionLocationStatsScreenState
    extends State<TransactionLocationStatsScreen> {
  List<Transaction> _located = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      setState(() {
        _loading = false;
        _error = 'Not signed in';
      });
      return;
    }
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(auth.profile.id);
    if (!mounted) return;
    if (household == null) {
      setState(() {
        _loading = false;
        _error = 'No household';
      });
      return;
    }
    final (txs, failure) =
        await AppDependencies.instance.transactionRepository.getTransactions(
      householdId: household.id,
      viewMode: ViewMode.household,
      limit: 200,
    );
    if (!mounted) return;
    if (failure != null) {
      setState(() {
        _loading = false;
        _error = failure.message;
      });
      return;
    }
    final located = txs.where((t) => t.hasLocation).toList();
    setState(() {
      _located = located;
      _loading = false;
    });
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
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return CupertinoPushedRouteShell(
        backgroundColor: bg,
        navBackground: surface,
        borderColor: border,
        foregroundColor: fg,
        titleText: l10n.transactionLocation_statsTitle,
        child: const Center(child: CupertinoActivityIndicator()),
      );
    }

    if (_error != null) {
      return CupertinoPushedRouteShell(
        backgroundColor: bg,
        navBackground: surface,
        borderColor: border,
        foregroundColor: fg,
        titleText: l10n.transactionLocation_statsTitle,
        child: Center(
          child:
              Text(_error!, style: AppFonts.body(fontSize: 14, color: muted)),
        ),
      );
    }

    if (_located.isEmpty) {
      return CupertinoPushedRouteShell(
        backgroundColor: bg,
        navBackground: surface,
        borderColor: border,
        foregroundColor: fg,
        titleText: l10n.transactionLocation_statsTitle,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.transactionLocation_empty,
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 14, color: muted),
            ),
          ),
        ),
      );
    }

    final center = LatLng(_located.first.latitude!, _located.first.longitude!);
    final markers = _located
        .map(
          (t) => Marker(
            width: 28,
            height: 28,
            point: LatLng(t.latitude!, t.longitude!),
            child: Container(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                border: Border.all(color: fg.withValues(alpha: 0.3)),
              ),
            ),
          ),
        )
        .toList();

    final fmt = DateFormat.MMMd();

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: l10n.transactionLocation_statsTitle,
      child: Column(
        children: [
          SizedBox(
            height: 260,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.hestia.app',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_located.length} ${l10n.transactionLocation_statsCount}',
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              itemCount: _located.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final t = _located[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${t.amount.toStringAsFixed(2)} · ${t.categoryName ?? '—'}',
                        style: AppFonts.body(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fmt.format(t.date),
                        style: AppFonts.body(fontSize: 12, color: muted),
                      ),
                      if (t.note != null && t.note!.isNotEmpty)
                        Text(
                          t.note!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(fontSize: 12, color: muted),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
