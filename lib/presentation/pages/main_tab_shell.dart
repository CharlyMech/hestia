import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/spring_physics.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/widgets/common/app_toast.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/bank_accounts/bank_accounts_bloc.dart';
import 'package:hestia/presentation/blocs/cars/cars_bloc.dart';
import 'package:hestia/presentation/blocs/pets/pets_bloc.dart';
import 'package:hestia/presentation/blocs/shopping/shopping_lists_bloc.dart';
import 'package:hestia/presentation/blocs/user_prefs/user_prefs_bloc.dart';
import 'package:hestia/presentation/pages/bank_accounts/bank_accounts_screen.dart';
import 'package:hestia/presentation/pages/dashboard/dashboard_screen.dart';
import 'package:hestia/presentation/pages/fuel/car_screen.dart';
import 'package:hestia/presentation/pages/pets/pets_screen.dart';
import 'package:hestia/presentation/pages/shopping/shopping_screen.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/navigation/main_tab_scope.dart';
import 'package:hestia/presentation/widgets/common/status_bar_blur_overlay.dart';
import 'package:hestia/presentation/widgets/dashboard/floating_nav_bar.dart';
import 'package:hestia/presentation/widgets/transactions/transaction_form.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show CoinsSwap;

/// Persistent tab shell.
///
/// Tab order: Home(0) · Accounts(1) · Pets(2) · [Cars(3)] · Shopping(2 or 3)
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

  late final BankAccountsBloc _bankAccountsBloc;
  late final PetsBloc _petsBloc;
  late final CarsBloc _carsBloc;
  late final ShoppingListsBloc _shoppingBloc;

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
    _fuelPage = const CarScreen();
    _cachedPages = _buildPages(_prevShowFuel);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final showFuel = context.read<UserPrefsBloc>().state.showFuelModule;
      if (showFuel != _prevShowFuel) _handleFuelToggle(showFuel);
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
    if (!mounted) return;

    // No household yet (brand-new user): dispatch loads with an empty id so the
    // blocs resolve to an empty Loaded state instead of spinning forever.
    final hid = household?.id ?? '';

    _bankAccountsBloc.add(BankAccountsLoad(
      householdId: hid,
      userId: profile.id,
    ));
    _petsBloc.add(PetsLoad(hid));
    _carsBloc.add(CarsLoad(hid));
    _shoppingBloc.add(ShoppingListsLoad(
      householdId: hid,
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

  Future<void> _openTransactionSheet() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      context.showToast(const AppToastConfig(
        type: ToastType.error,
        title: 'Sign in required',
      ));
      return;
    }

    final (household, failure) = await AppDependencies
        .instance.householdRepository
        .getCurrentHousehold(authState.profile.id);
    if (!context.mounted) return;
    if (household == null) {
      context.showToast(AppToastConfig(
        type: ToastType.error,
        title: 'No household yet',
        description: failure?.message ??
            'Create a household before adding transactions.',
      ));
      return;
    }

    await showAppBottomSheet<void>(
      context: context,
      title: 'New transaction',
      heightFactor: 0.92,
      expand: true,
      child: TransactionForm(
        householdId: household.id,
        userId: authState.profile.id,
        onClose: () => _bankAccountsBloc.add(const BankAccountsRefresh()),
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
    final accent =
        Color(int.parse(theme.primaryColor.replaceFirst('#', '0xff')));
    final statusBarHeight = MediaQuery.viewPaddingOf(context).top;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _bankAccountsBloc),
        BlocProvider.value(value: _petsBloc),
        BlocProvider.value(value: _carsBloc),
        BlocProvider.value(value: _shoppingBloc),
      ],
      child: MainTabScope(
        selectTab: _goTo,
        statusBarHeight: statusBarHeight,
        child: BlocListener<UserPrefsBloc, UserPrefsState>(
          listenWhen: (p, n) => p.showFuelModule != n.showFuelModule,
          listener: (_, state) => _handleFuelToggle(state.showFuelModule),
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
                const StatusBarBlurOverlay(),
                // FAB — sits just above the nav bar
                Positioned(
                  right: 20,
                  bottom: 108,
                  child: _TransactionFab(
                    accent: accent,
                    onTap: _openTransactionSheet,
                  ),
                ),
                // Nav bar
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────────────────

class _TransactionFab extends StatefulWidget {
  final Color accent;
  final VoidCallback onTap;

  const _TransactionFab({required this.accent, required this.onTap});

  @override
  State<_TransactionFab> createState() => _TransactionFabState();
}

class _TransactionFabState extends State<_TransactionFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = SpringPhysics.tapScaleController(this);
    _scale = SpringPhysics.tapScaleAnimation(_ctrl, minScale: 0.88);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: widget.accent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: CoinsSwap(
            width: 24,
            height: 24,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}
