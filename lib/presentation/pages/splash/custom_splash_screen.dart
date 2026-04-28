import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_events.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/common/animated_progress_bar.dart';

class CustomSplashScreen extends StatelessWidget {
  const CustomSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF007CCC);
    final surface = const Color(0xFFFFFFFF).withValues(alpha: 0.25);
    final primary = const Color(0xFFD4ECFF);
    final textMuted = const Color(0xFFEAF6FF);

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
                  width: 132,
                  height: 120,
                  decoration: const BoxDecoration(),
                  child: Image.asset(
                    'assets/images/splash_logo.png',
                    fit: BoxFit.contain,
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

}
