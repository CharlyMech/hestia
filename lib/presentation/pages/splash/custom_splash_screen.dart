import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_events.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/common/animated_progress_bar.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' hide Text;

class CustomSplashScreen extends StatelessWidget {
  const CustomSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final primary = _c(theme.primaryColor);
    final textMuted = _c(theme.onInactiveColor);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case AuthUnauthenticated():
            context.go(AppRoutes.login);
          case AuthBiometricRequired():
            context.read<AuthBloc>().add(const AuthBiometricCheck());
          case AuthAuthenticated():
            context.go(AppRoutes.dashboard);
          case AuthError():
            context.go(AppRoutes.login);
          default:
            break;
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: bg,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 24,
              children: [
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
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final progress = switch (state) {
                      AuthAuthenticated() => 1.0,
                      AuthLoading() => 0.5,
                      _ => 0.0,
                    };
                    return AnimatedProgressBar(
                      value: progress,
                      trackColor: surface,
                      fillColor: primary,
                    );
                  },
                ),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final message = switch (state) {
                      AuthLoading(:final message) => message ?? 'Loading...',
                      _ => 'Starting...',
                    };
                    return Text(
                      message,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: textMuted,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
