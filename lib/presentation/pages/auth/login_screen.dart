import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/flavor.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_events.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' hide Text;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final primary = _c(theme.primaryColor);
    final onPrimary = _c(theme.onPrimaryColor);
    final textPrimary = _c(theme.onBackgroundColor);
    final textMuted = _c(theme.onInactiveColor);
    final errorColor = _c(theme.colorRed);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.dashboard);
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: bg,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.vertical,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Home(width: 48, height: 48, color: primary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Hestia',
                      style: AppFonts.heading(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your household finances together',
                      style: AppFonts.body(fontSize: 15, color: textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthError) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              state.failure.message,
                              style: AppFonts.body(
                                fontSize: 14,
                                color: errorColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    if (FlavorConfig.isMock)
                      _MockButtons(
                        primary: primary,
                        onPrimary: onPrimary,
                        surface: surface,
                        border: border,
                        fg: textPrimary,
                      )
                    else
                      _SupabaseAuth(
                        emailCtrl: _emailCtrl,
                        passwordCtrl: _passwordCtrl,
                        primary: primary,
                        onPrimary: onPrimary,
                        surface: surface,
                        border: border,
                        fg: textPrimary,
                        muted: textMuted,
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _MockButtons extends StatelessWidget {
  final Color primary;
  final Color onPrimary;
  final Color surface;
  final Color border;
  final Color fg;

  const _MockButtons({
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.border,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: CupertinoButton(
            color: primary,
            borderRadius: BorderRadius.circular(12),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthDevBypass()),
            child: Text(
              'Continue (dev)',
              style: AppFonts.body(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: CupertinoButton(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthBiometricCheck()),
            child: Text(
              'Test Face ID',
              style: AppFonts.body(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SupabaseAuth extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final Color primary;
  final Color onPrimary;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;

  const _SupabaseAuth({
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Column(
          children: [
            CupertinoTextField(
              controller: emailCtrl,
              placeholder: 'Email',
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              style: AppFonts.body(fontSize: 15, color: fg),
              placeholderStyle: AppFonts.body(fontSize: 15, color: muted),
              decoration: BoxDecoration(
                color: surface,
                border: Border.all(color: border, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 10),
            CupertinoTextField(
              controller: passwordCtrl,
              placeholder: 'Password',
              obscureText: true,
              autocorrect: false,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              style: AppFonts.body(fontSize: 15, color: fg),
              placeholderStyle: AppFonts.body(fontSize: 15, color: muted),
              decoration: BoxDecoration(
                color: surface,
                border: Border.all(color: border, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: CupertinoButton(
                color: primary,
                borderRadius: BorderRadius.circular(12),
                onPressed: isLoading
                    ? null
                    : () => context.read<AuthBloc>().add(
                          AuthSignInWithEmail(
                            emailCtrl.text.trim(),
                            passwordCtrl.text,
                          ),
                        ),
                child: isLoading
                    ? const CupertinoActivityIndicator()
                    : Text(
                        'Sign in',
                        style: AppFonts.body(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: onPrimary,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container(height: 1, color: border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or',
                    style: AppFonts.body(fontSize: 12, color: muted),
                  ),
                ),
                Expanded(child: Container(height: 1, color: border)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: CupertinoButton(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
                onPressed: isLoading
                    ? null
                    : () => context
                        .read<AuthBloc>()
                        .add(const AuthSignInWithApple()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.person_fill,
                      color: CupertinoColors.black,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sign in with Apple',
                      style: AppFonts.body(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
