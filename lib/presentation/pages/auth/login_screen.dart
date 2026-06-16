import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_events.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/common/app_toast.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Apple;

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
    final bg = hexToColor(theme.backgroundColor);
    final primary = hexToColor(theme.primaryColor);
    final onPrimary = hexToColor(theme.onPrimaryColor);
    final textPrimary = hexToColor(theme.onBackgroundColor);
    final textMuted = hexToColor(theme.onInactiveColor);
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.dashboard);
        } else if (state is AuthError) {
          context.showToast(AppToastConfig(
            type: ToastType.error,
            title: AppLocalizations.of(context).auth_signInFailed,
            description: state.failure.message,
            position: ToastPosition.bottom,
            duration: const Duration(seconds: 2),
          ));
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: bg,
        resizeToAvoidBottomInset: true,
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewPadding = MediaQuery.viewPaddingOf(context);
              final viewInsets = MediaQuery.viewInsetsOf(context);
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  32,
                  viewPadding.top + 24,
                  32,
                  math.max(viewPadding.bottom, 24) + viewInsets.bottom + 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(
                      0,
                      constraints.maxHeight -
                          viewPadding.top -
                          viewPadding.bottom -
                          viewInsets.bottom -
                          48,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(
                        'Hestia',
                        style: AppFonts.heading(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        l10n.auth_tagline,
                        style: AppFonts.body(fontSize: 15, color: textMuted),
                        textAlign: TextAlign.center,
                      ),
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
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SupabaseAuth extends StatefulWidget {
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
  State<_SupabaseAuth> createState() => _SupabaseAuthState();
}

class _SupabaseAuthState extends State<_SupabaseAuth> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Column(
          spacing: 8,
          children: [
            CupertinoTextField(
              controller: widget.emailCtrl,
              placeholder: l10n.auth_email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              style: AppFonts.body(fontSize: 15, color: widget.fg),
              placeholderStyle:
                  AppFonts.body(fontSize: 15, color: widget.muted),
              decoration: BoxDecoration(
                color: widget.surface,
                border: Border.all(color: widget.border, width: 1),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
            ),
            CupertinoTextField(
              controller: widget.passwordCtrl,
              placeholder: l10n.auth_password,
              obscureText: !_showPassword,
              autocorrect: false,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              style: AppFonts.body(fontSize: 15, color: widget.fg),
              placeholderStyle:
                  AppFonts.body(fontSize: 15, color: widget.muted),
              decoration: BoxDecoration(
                color: widget.surface,
                border: Border.all(color: widget.border, width: 1),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
            ),
            Row(
              children: [
                FCheckbox(
                  value: _showPassword,
                  onChange: (value) => setState(() => _showPassword = value),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _showPassword = !_showPassword),
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    l10n.auth_showPassword,
                    style: AppFonts.body(fontSize: 14, color: widget.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.only(top: 8),
              width: double.infinity,
              height: 52,
              child: AnimatedButton(
                backgroundColor: widget.primary,
                onTap: isLoading
                    ? null
                    : () => context.read<AuthBloc>().add(
                          AuthSignInWithEmail(
                            widget.emailCtrl.text.trim(),
                            widget.passwordCtrl.text,
                          ),
                        ),
                child: Center(
                  child: isLoading
                      ? const CupertinoActivityIndicator()
                      : Text(
                          l10n.auth_signIn,
                          style: AppFonts.body(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: widget.onPrimary,
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(child: Container(height: 1, color: widget.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      l10n.auth_or,
                      style: AppFonts.body(fontSize: 12, color: widget.muted),
                    ),
                  ),
                  Expanded(child: Container(height: 1, color: widget.border)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: AnimatedButton(
                  backgroundColor: hexToColor('#2c2c2e'),
                  onTap: isLoading
                      ? null
                      : () => context
                          .read<AuthBloc>()
                          .add(const AuthSignInWithApple()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      const Apple(
                        width: 20,
                        height: 20,
                        color: CupertinoColors.white,
                      ),
                      Text(
                        l10n.auth_signInWithApple,
                        style: AppFonts.body(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
