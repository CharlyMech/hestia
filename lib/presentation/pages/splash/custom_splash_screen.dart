import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:home_expenses/core/config/router.dart';
import 'package:home_expenses/core/utils/theme_utils.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' hide Text;

import '../../widgets/common/animated_progress_bar.dart';

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  String _status = 'Initializing...';
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // Step 1: Check session
      _updateProgress('Checking session...', 0.15);
      await Future.delayed(const Duration(milliseconds: 500)); // placeholder

      // TODO: Replace with real auth check
      // final hasSession = await authRepo.hasValidSession();
      // if (!hasSession) { context.go(AppRoutes.login); return; }

      // Step 2: Biometrics
      _updateProgress('Verifying identity...', 0.3);
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 3: Load profile
      _updateProgress('Loading profile...', 0.45);
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 4: Sync money sources
      _updateProgress('Syncing accounts...', 0.6);
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 5: Load transactions
      _updateProgress('Loading transactions...', 0.75);
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 6: Load goals
      _updateProgress('Loading goals...', 0.9);
      await Future.delayed(const Duration(milliseconds: 200));

      // Done
      _updateProgress('Ready', 1.0);
      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted) context.go(AppRoutes.dashboard);
    } catch (e) {
      if (mounted) context.go(AppRoutes.login);
    }
  }

  void _updateProgress(String status, double progress) {
    if (!mounted) return;
    setState(() {
      _status = status;
      _progress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final primary = _c(theme.primaryColor);
    final textMuted = _c(theme.onInactiveColor);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Home(
                    width: 40,
                    height: 40,
                    color: primary,
                  ),
                ),
              ),
              // Animated progress bar
              AnimatedProgressBar(
                value: _progress,
                trackColor: surface,
                fillColor: primary,
              ),
              // Status text
              Text(
                _status,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
