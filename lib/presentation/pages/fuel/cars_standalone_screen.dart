import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/cars/cars_bloc.dart';
import 'package:hestia/presentation/pages/fuel/fuel_screen.dart';

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
    final bg = _c(theme.backgroundColor);

    return BlocProvider.value(
      value: _carsBloc,
      child: CupertinoPageScaffold(
        backgroundColor: bg,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: _c(theme.surfaceColor),
          border: Border(
            bottom: BorderSide(color: _c(theme.borderColor)),
          ),
          middle: Text(
            l10n.cars_title,
            style: AppFonts.heading(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _c(theme.onBackgroundColor),
            ),
          ),
        ),
        child: _loading
            ? const Center(child: CupertinoActivityIndicator())
            : const FuelScreen(),
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
