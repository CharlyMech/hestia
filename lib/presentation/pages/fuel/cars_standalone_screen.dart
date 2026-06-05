import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/cars/cars_bloc.dart';
import 'package:hestia/presentation/pages/fuel/car_screen.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Plus;

/// Cars list outside the tab shell (e.g. when the cars tab is hidden).
class CarsStandaloneScreen extends StatefulWidget {
  const CarsStandaloneScreen({super.key});

  @override
  State<CarsStandaloneScreen> createState() => _CarsStandaloneScreenState();
}

class _CarsStandaloneScreenState extends State<CarsStandaloneScreen> {
  late final CarsBloc _carsBloc;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carsBloc = CarsBloc(AppDependencies.instance.carRepository);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(auth.profile.id);
    if (!mounted) return;
    if (household != null) {
      _carsBloc.add(CarsLoad(household.id));
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _carsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final surface = hexToColor(theme.surfaceColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final border = hexToColor(theme.borderColor);

    return BlocProvider.value(
      value: _carsBloc,
      child: CupertinoPushedRouteShell(
        backgroundColor: bg,
        navBackground: surface,
        borderColor: border,
        foregroundColor: fg,
        titleText: l10n.cars_title,
        trailing: AnimatedButton(
          padding: const EdgeInsets.all(4),
          onTap: () async {
            await context.push(AppRoutes.addCar);
            if (context.mounted) _carsBloc.add(const CarsRefresh());
          },
          child: Plus(width: 22, height: 22, color: fg),
        ),
        child: _loading
            ? const Center(child: CupertinoActivityIndicator())
            : const CarScreen(),
      ),
    );
  }
}
