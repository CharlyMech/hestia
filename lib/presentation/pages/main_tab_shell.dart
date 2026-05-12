import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/bank_accounts/bank_accounts_bloc.dart';
import 'package:hestia/presentation/blocs/cars/cars_bloc.dart';
import 'package:hestia/presentation/blocs/pets/pets_bloc.dart';
import 'package:hestia/presentation/blocs/shopping/shopping_lists_bloc.dart';
import 'package:hestia/presentation/blocs/user_prefs/user_prefs_bloc.dart';
import 'package:hestia/presentation/pages/bank_accounts/bank_accounts_screen.dart';
import 'package:hestia/presentation/pages/dashboard/dashboard_screen.dart';
import 'package:hestia/presentation/pages/fuel/fuel_screen.dart';
import 'package:hestia/presentation/pages/pets/pets_screen.dart';
import 'package:hestia/presentation/pages/shopping/shopping_screen.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/dashboard/floating_nav_bar.dart';
import 'package:hestia/presentation/widgets/transactions/transaction_form.dart';

/// Persistent tab shell.
///
/// All tab-level blocs are created here and kept alive for the session.
/// Screens read from context — no bloc recreation on tab switch.
///
/// Tab order: Home(0) · Accounts(1) · Pets(2) · [Fuel(3)] · Shopping(3 or 4)
class MainTabShell extends StatefulWidget {
  final int initialTab;

  const MainTabShell({super.key, this.initialTab = 0});

  @override
  State<MainTabShell> createState() => _MainTabShellState();
}

class _MainTabShellState extends State<MainTabShell> {
  late PageController _controller;
  late int _index;
  double _offset = 0;
  bool _prevShowFuel = false;

  // Blocs live here — created once, survive tab switches.
  late final BankAccountsBloc _bankAccountsBloc;
  late final PetsBloc _petsBloc;
  late final CarsBloc _carsBloc;
  late final ShoppingListsBloc _shoppingBloc;

  // Pages cached — same instances survive rebuilds so StatefulWidget state
  // (including DashboardScreen._loading) is not reset on tab switch.
  late List<Widget> _cachedPages;
  late final Widget _dashboardPage;
  late final Widget _accountsPage;
  late final Widget _petsPage;
  late final Widget _shoppingPage;
  late final Widget _fuelPage;

  @override
  void initState() {
    super.initState();
    _index = widget.initialTab;
    _offset = widget.initialTab.toDouble();
    _controller = PageController(initialPage: widget.initialTab);
    _controller.addListener(_onScroll);

    _bankAccountsBloc =
        BankAccountsBloc(AppDependencies.instance.bankAccountRepository);
    _petsBloc = PetsBloc(AppDependencies.instance.petRepository);
    _carsBloc = CarsBloc(AppDependencies.instance.carRepository);
    _shoppingBloc =
        ShoppingListsBloc(AppDependencies.instance.shoppingRepository);

    _dashboardPage = DashboardScreen(
      onOpenMoneySource: (id) =>
          context.push(AppRoutes.bankAccountDetail, extra: id),
    );
    _accountsPage = const BankAccountsScreen(embeddedInTabShell: true);
    _petsPage = const PetsScreen();
    _shoppingPage = const ShoppingScreen();
    _fuelPage = const FuelScreen();
    _cachedPages = _buildPages(_prevShowFuel);

    // Align tab strip with saved fuel preference and load blocs — must not run
    // inside [build] (that disposed [PageController] during layout).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final showFuel = context.read<UserPrefsBloc>().state.showFuelModule;
      if (showFuel != _prevShowFuel) {
        _handleFuelToggle(showFuel);
      }
      _initialLoad();
    });
  }

  List<Widget> _buildPages(bool showFuel) => [
        _dashboardPage,
        _accountsPage,
        _petsPage,
        if (showFuel) _fuelPage,
        _shoppingPage,
      ];

  Future<void> _initialLoad() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final profile = auth.profile;
    final deps = AppDependencies.instance;

    final (household, _) =
        await deps.householdRepository.getCurrentHousehold(profile.id);
    if (household == null || !mounted) return;

    // Fire all loads in parallel — each bloc handles its own state.
    _bankAccountsBloc.add(BankAccountsLoad(
      householdId: household.id,
      userId: profile.id,
    ));
    _petsBloc.add(PetsLoad(household.id));
    _carsBloc.add(CarsLoad(household.id));
    _shoppingBloc.add(ShoppingListsLoad(
      householdId: household.id,
      userId: profile.id,
    ));
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final p = _controller.page;
    if (p == null) return;
    setState(() => _offset = p);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    _bankAccountsBloc.close();
    _petsBloc.close();
    _carsBloc.close();
    _shoppingBloc.close();
    super.dispose();
  }

  void _goTo(int i) {
    _controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openTransactionSheet(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(authState.profile.id);
    if (household == null || !context.mounted) return;

    await showAppBottomSheet<void>(
      context: context,
      title: 'New transaction',
      heightFactor: 0.92,
      expand: true,
      child: TransactionForm(
        householdId: household.id,
        userId: authState.profile.id,
        onClose: () {
          _bankAccountsBloc.add(const BankAccountsRefresh());
        },
      ),
    );
  }

  void _handleFuelToggle(bool showFuel) {
    if (showFuel == _prevShowFuel) return;
    _prevShowFuel = showFuel;

    final pageCount = showFuel ? 5 : 4;
    final newIndex = _index.clamp(0, pageCount - 1);

    _controller.removeListener(_onScroll);
    _controller.dispose();
    _controller = PageController(initialPage: newIndex);
    _controller.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _index = newIndex;
        _offset = newIndex.toDouble();
        _cachedPages = _buildPages(showFuel);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg =
        Color(int.parse(theme.backgroundColor.replaceFirst('#', '0xff')));

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _bankAccountsBloc),
        BlocProvider.value(value: _petsBloc),
        BlocProvider.value(value: _carsBloc),
        BlocProvider.value(value: _shoppingBloc),
      ],
      child: BlocListener<UserPrefsBloc, UserPrefsState>(
        listenWhen: (p, n) => p.showFuelModule != n.showFuelModule,
        listener: (context, state) {
          _handleFuelToggle(state.showFuelModule);
        },
        child: CupertinoPageScaffold(
          backgroundColor: bg,
          child: Stack(
            children: [
              PageView(
                controller: _controller,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                children: _cachedPages,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  minimum: const EdgeInsets.only(bottom: 16),
                  bottom: false,
                  child: FloatingNavBar(
                    activeIndex: _index,
                    pageOffset: _offset,
                    onTab: _goTo,
                    onPlus: () => _openTransactionSheet(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
