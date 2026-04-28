import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
// TODO: re-enable with Apple Sign In button
// import 'package:hestia/presentation/blocs/auth/auth_events.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' hide Text;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final primary = _c(theme.primaryColor);
    final textPrimary = _c(theme.onBackgroundColor);
    final textMuted = _c(theme.onInactiveColor);
    final errorColor = _c(theme.colorRed);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.dashboard);
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: bg,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Home(
                      width: 48,
                      height: 48,
                      color: primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Hestia',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your household finances together',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 3),

                // Error display
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthError) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          state.failure.message,
                          style: TextStyle(
                            color: errorColor,
                            fontSize: 14,
                            fontFamily: 'Inter',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // TODO: re-enable once Apple Developer paid account is set up
                // Apple Sign-In button hidden until Sign In with Apple capability
                // is available (requires paid Apple Developer membership).
                // BlocBuilder<AuthBloc, AuthState>(
                //   builder: (context, state) {
                //     final isLoading = state is AuthLoading;
                //
                //     return SizedBox(
                //       width: double.infinity,
                //       height: 52,
                //       child: CupertinoButton(
                //         color: CupertinoColors.white,
                //         borderRadius: BorderRadius.circular(12),
                //         onPressed: isLoading
                //             ? null
                //             : () => context
                //                 .read<AuthBloc>()
                //                 .add(const AuthSignInWithApple()),
                //         child: isLoading
                //             ? const CupertinoActivityIndicator()
                //             : const Row(
                //                 mainAxisAlignment: MainAxisAlignment.center,
                //                 children: [
                //                   Icon(
                //                     CupertinoIcons.person_fill,
                //                     color: CupertinoColors.black,
                //                     size: 20,
                //                   ),
                //                   SizedBox(width: 8),
                //                   Text(
                //                     'Sign in with Apple',
                //                     style: TextStyle(
                //                       fontFamily: 'Inter',
                //                       fontWeight: FontWeight.w600,
                //                       color: CupertinoColors.black,
                //                       fontSize: 16,
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //       ),
                //     );
                //   },
                // ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
