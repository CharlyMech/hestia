import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';

/// One-time onboarding shown on first install (and again after logout).
/// Controlled by [UserPreferencesService.onboardingSeen].
///
/// Layout is stacked: media fills the whole screen edge-to-edge (full-bleed,
/// down to the very bottom), a Skip action floats top-right, and a floating
/// card near the bottom holds the slide copy plus Previous/Next controls. The
/// final slide swaps its copy for interactive permission toggles. Skipping the
/// whole flow never prompts for permissions.
///
/// Required assets (place in assets/onboarding/ and register in pubspec.yaml):
///   onboarding_welcome.webp        - App logo + "Welcome to Hestia" hero
///   onboarding_transactions.mp4    - Video: create transaction flow
///   onboarding_accounts.webp       - Screenshot: bank accounts + wallet cards
///   onboarding_calendar.mp4        - Video: calendar week view with events
///   onboarding_shopping.mp4        - Video: start shared shopping session
///   onboarding_pets_cars.webp      - Screenshot: pets & cars tabs collage
///   onboarding_permissions.webp    - Graphic: lock + location + bell icons
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  // Permission toggle state (last slide).
  bool _notifications = false;
  bool _location = false;
  bool _busy = false;

  static const _slides = [
    _Slide(
      asset: 'assets/onboarding/onboarding_welcome.webp',
      isVideo: false,
      title: 'Welcome to Hestia',
      body: 'Your household finance hub — track spending, manage accounts, '
          'plan together.',
    ),
    _Slide(
      asset: 'assets/onboarding/onboarding_transactions.mp4',
      isVideo: true,
      title: 'Record transactions',
      body: 'Add income and expenses in seconds. Tag categories, accounts, '
          'and even attach a location.',
    ),
    _Slide(
      asset: 'assets/onboarding/onboarding_accounts.webp',
      isVideo: false,
      title: 'All your accounts',
      body: 'Checking, savings, credit, cash — see your total balance and '
          'spending trends at a glance.',
    ),
    _Slide(
      asset: 'assets/onboarding/onboarding_calendar.mp4',
      isVideo: true,
      title: 'Calendar & appointments',
      body: 'See upcoming events, plan ahead, and connect appointments to '
          'your pets or car.',
    ),
    _Slide(
      asset: 'assets/onboarding/onboarding_shopping.mp4',
      isVideo: true,
      title: 'Shop together',
      body: 'Start a shared shopping session and collaborate in real time '
          'with household members.',
    ),
    _Slide(
      asset: 'assets/onboarding/onboarding_pets_cars.webp',
      isVideo: false,
      title: 'Pets & cars',
      body: 'Track vet appointments, vaccinations, and fuel fills — all '
          'linked to your transactions.',
    ),
    _Slide(
      asset: 'assets/onboarding/onboarding_permissions.webp',
      isVideo: false,
      isPermissions: true,
      title: 'Stay in the loop',
      body: 'Enable the bits you want. You can change these any time in '
          'Settings.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Persist the seen flag and continue to login. Does NOT request permissions
  /// — those are opt-in via the toggles on the last slide.
  Future<void> _complete() async {
    await AppDependencies.instance.userPreferencesService
        .setOnboardingSeen(true);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      _complete();
    }
  }

  void _prev() {
    if (_page == 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _toggleNotifications(bool v) async {
    setState(() {
      _notifications = v;
      _busy = true;
    });
    final deps = AppDependencies.instance;
    var granted = false;
    if (v) {
      try {
        granted = await deps.pushNotificationService.requestPermission();
      } catch (_) {/* user can enable later in settings */}
    }
    await deps.userPreferencesService.setAllowNotifications(granted);
    if (mounted) {
      setState(() {
        _notifications = granted;
        _busy = false;
      });
    }
  }

  Future<void> _toggleLocation(bool v) async {
    setState(() {
      _location = v;
      _busy = true;
    });
    var granted = false;
    if (v) {
      try {
        // Re-prompts on next app start if only granted "while in use"/once via
        // LocationService.ensureWhenInUsePermission().
        final p =
            await AppDependencies.instance.locationService.requestPermission();
        granted = p == LocationPermission.always ||
            p == LocationPermission.whileInUse;
      } catch (_) {/* optional */}
    }
    if (mounted) {
      setState(() {
        _location = granted;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final fg = hexToColor(theme.foregroundColor);
    final muted = hexToColor(theme.mutedColor);
    final accent = hexToColor(theme.primaryColor);
    final onPrimary = hexToColor(theme.onPrimaryColor);
    final surface = hexToColor(theme.surfaceColor);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final isLast = _page == _slides.length - 1;

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: Stack(
        children: [
          // ── Full-bleed media — fills the entire screen, all the way down ──
          Positioned.fill(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _page = i),
              itemCount: _slides.length,
              itemBuilder: (_, i) => _MediaLayer(
                slide: _slides[i],
                accent: accent,
                bg: bg,
              ),
            ),
          ),

          // ── Skip (top-right, in the top safe area) ──
          Positioned(
            top: viewPadding.top + 4,
            right: 8,
            child: AnimatedButton(
              onTap: _busy ? null : _complete,
              child: Text('Skip',
                  style: AppFonts.body(
                      fontSize: 14, fontWeight: FontWeight.w600, color: muted)),
            ),
          ),

          // ── Floating copy / controls card + dots, pinned to bottom ──
          Positioned(
            left: 16,
            right: 16,
            bottom: viewPadding.bottom + 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: BoxDecoration(
                    color: surface.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: fg.withValues(alpha: 0.06), width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF000000).withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      Text(
                        _slides[_page].title,
                        textAlign: TextAlign.center,
                        style: AppFonts.heading(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: fg,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        _slides[_page].body,
                        textAlign: TextAlign.center,
                        style: AppFonts.body(
                            fontSize: 14, color: muted, height: 1.45),
                      ),

                      // Permission toggles on the last slide.
                      if (_slides[_page].isPermissions) ...[
                        _PermRow(
                          label: 'Notifications',
                          sub: 'Reminders for bills, events & shopping',
                          value: _notifications,
                          onChange: _busy ? null : _toggleNotifications,
                          fg: fg,
                          muted: muted,
                        ),
                        _PermRow(
                          label: 'Location',
                          sub: 'Tag transactions & find nearby spots',
                          value: _location,
                          onChange: _busy ? null : _toggleLocation,
                          fg: fg,
                          muted: muted,
                        ),
                      ],
                      // Previous / Next controls inside the card.
                      Row(
                        children: [
                          Opacity(
                            opacity: _page == 0 ? 0 : 1,
                            child: AnimatedButton(
                              padding: EdgeInsets.zero,
                              onTap: _page == 0 ? null : _prev,
                              child: Text('Previous',
                                  style: AppFonts.body(
                                      fontSize: 14, color: muted)),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _busy ? null : _next,
                            child: Container(
                              height: 46,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 28),
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                isLast ? 'Get started' : 'Next',
                                style: AppFonts.body(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 6,
                  children: List.generate(
                    _slides.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      width: i == _page ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color:
                            i == _page ? accent : accent.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide data ────────────────────────────────────────────────────────────────

class _Slide {
  final String asset;
  final bool isVideo;
  final bool isPermissions;
  final String title;
  final String body;

  const _Slide({
    required this.asset,
    required this.isVideo,
    this.isPermissions = false,
    required this.title,
    required this.body,
  });
}

// ── Permission toggle row ─────────────────────────────────────────────────────

class _PermRow extends StatelessWidget {
  final String label;
  final String sub;
  final bool value;
  final ValueChanged<bool>? onChange;
  final Color fg;
  final Color muted;

  const _PermRow({
    required this.label,
    required this.sub,
    required this.value,
    required this.onChange,
    required this.fg,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppFonts.body(
                      fontSize: 14, fontWeight: FontWeight.w600, color: fg)),
              const SizedBox(height: 2),
              Text(sub, style: AppFonts.body(fontSize: 11, color: muted)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FSwitch(value: value, onChange: onChange),
      ],
    );
  }
}

// ── Full-bleed media layer (placeholder until real assets land) ───────────────

class _MediaLayer extends StatelessWidget {
  final _Slide slide;
  final Color accent, bg;

  const _MediaLayer(
      {required this.slide, required this.accent, required this.bg});

  @override
  Widget build(BuildContext context) {
    // Until real assets are wired, render a full-bleed gradient placeholder so
    // the stacked layout/safe-area handling can be verified.
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: 0.22),
            bg,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 14,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                slide.isVideo ? '▶' : '🖼',
                style: const TextStyle(fontSize: 30),
              ),
            ),
            Text(
              slide.asset.split('/').last,
              style: TextStyle(
                fontSize: 11,
                color: accent.withValues(alpha: 0.6),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
