import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/category.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/categories/category_form_content.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Plus;
import 'package:skeletonizer/skeletonizer.dart';

/// Household categories (expense / income) with create / edit via bottom sheet.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _tab = 0; // 0 = Expense, 1 = Income
  String? _householdId;
  List<Category> _categories = const [];
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
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Sign in to manage categories';
        });
      }
      return;
    }
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(auth.profile.id);
    if (household == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'No household found';
        });
      }
      return;
    }
    final (cats, failure) =
        await AppDependencies.instance.categoryRepository.getCategories(
      householdId: household.id,
    );
    if (!mounted) return;
    if (failure != null) {
      setState(() {
        _loading = false;
        _error = failure.message;
      });
      return;
    }
    setState(() {
      _householdId = household.id;
      _categories = cats;
      _loading = false;
      _error = null;
    });
  }

  TransactionType get _selectedType =>
      _tab == 0 ? TransactionType.expense : TransactionType.income;

  List<Category> get _filtered => _categories
      .where((c) => c.type == _selectedType && c.isActive)
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  Future<void> _openSheet({Category? existing}) async {
    if (_householdId == null) return;
    await showAppBottomSheet<void>(
      context: context,
      title: existing == null ? 'New category' : 'Edit category',
      heightFactor: 0.72,
      expand: true,
      child: CategoryFormContent(
        existing: existing,
        householdId: _householdId!,
        initialType: _selectedType,
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final surface2 = _c(theme.surface2Color);
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
        titleText: 'Categories',
        child: Skeletonizer(
          enabled: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(
                '0 expense categories',
                style: AppFonts.body(fontSize: 13, color: muted),
              ),
              const SizedBox(height: 18),
              SizedBox(height: 44),
              const SizedBox(height: 20),
              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: surface,
                  border: Border.all(color: border),
                  borderRadius:
                      BorderRadius.circular(AppRadii.xl),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_error != null) {
      return CupertinoPushedRouteShell(
        backgroundColor: bg,
        navBackground: surface,
        borderColor: border,
        foregroundColor: fg,
        titleText: 'Categories',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 14, color: muted),
            ),
          ),
        ),
      );
    }

    final shown = _filtered;

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: 'Categories',
      trailing: GestureDetector(
        onTap: () => _openSheet(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Plus(
              width: 18,
              height: 18,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ),
      child: ScreenShell(
        bg: bg,
        bottomPadding: 24,
        onRefresh: _load,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                '${shown.length} ${_tab == 0 ? 'expense' : 'income'} categories',
                style: AppFonts.body(fontSize: 13, color: muted),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SegmentedControl(
                options: const ['Expense', 'Income'],
                active: _tab,
                onChanged: (i) => setState(() => _tab = i),
                surface: surface,
                border: border,
                fg: fg,
                muted: muted,
                activeColor: surface2,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          if (shown.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No categories yet — tap + to add one',
                  style: AppFonts.body(fontSize: 13, color: muted),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: _CategoryCard(
                categories: shown,
                surface: surface,
                border: border,
                fg: fg,
                muted: muted,
                onTap: (c) => _openSheet(existing: c),
              ),
            ),
        ],
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _CategoryCard extends StatelessWidget {
  final List<Category> categories;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final ValueChanged<Category> onTap;

  const _CategoryCard({
    required this.categories,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(color: border, width: 1),
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < categories.length; i++)
              GestureDetector(
                onTap: () => onTap(categories[i]),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: i < categories.length - 1
                        ? Border(bottom: BorderSide(color: border, width: 1))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: (categories[i].color != null
                                  ? Color(int.parse(categories[i].color!
                                      .replaceFirst('#', '0xff')))
                                  : muted)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          categories[i].name.isNotEmpty
                              ? categories[i].name[0].toUpperCase()
                              : '?',
                          style: AppFonts.body(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: categories[i].color != null
                                ? Color(int.parse(categories[i].color!
                                    .replaceFirst('#', '0xff')))
                                : fg,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          categories[i].name,
                          style: AppFonts.body(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: fg,
                          ),
                        ),
                      ),
                      ChevronIcon(color: muted.withValues(alpha: 0.6)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
