import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_events.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';

class CustomSplashScreen extends StatelessWidget {
  const CustomSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF007CCC);
    const textMuted = Color(0xFFEAF6FF);
    const textBright = Color(0xFFFFFFFF);

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
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Welcome to Hestia',
                          textAlign: TextAlign.center,
                          style: AppFonts.heading(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: textBright,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your household finances, in one place.',
                          textAlign: TextAlign.center,
                          style: AppFonts.body(
                            fontSize: 15,
                            color: textMuted,
                          ),
                        ),
                        const SizedBox(height: 32),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final message = switch (state) {
                              AuthLoading(:final message) =>
                                message ?? 'Checking session…',
                              AuthAuthenticated() => 'Almost there…',
                              _ => 'Preparing your space…',
                            };
                            return Text(
                              message,
                              textAlign: TextAlign.center,
                              style: AppFonts.body(
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
              const Padding(
                padding: EdgeInsets.only(bottom: 32),
                child: CupertinoActivityIndicator(
                  radius: 14,
                  color: textBright,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
