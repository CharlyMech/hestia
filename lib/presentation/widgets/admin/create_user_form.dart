import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';

class CreateUserForm extends StatefulWidget {
  const CreateUserForm({super.key});

  @override
  State<CreateUserForm> createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<CreateUserForm> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    final (profile, failure) =
        await AppDependencies.instance.authRepository.createUser(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      displayName: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
    );
    if (!mounted) return;
    if (failure != null || profile == null) {
      setState(() {
        _submitting = false;
        _error = failure?.message ?? 'Could not create user';
      });
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final onPrimary = _c(theme.onPrimaryColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final expense = _c(theme.colorRed);

    BoxDecoration field() => BoxDecoration(
          color: surface,
          border: Border.all(color: border, width: 1),
          borderRadius: BorderRadius.circular(12),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoTextField(
            controller: _emailCtrl,
            placeholder: 'Email',
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            style: AppFonts.body(fontSize: 15, color: fg),
            placeholderStyle: AppFonts.body(fontSize: 15, color: muted),
            decoration: field(),
          ),
          const SizedBox(height: 10),
          CupertinoTextField(
            controller: _passwordCtrl,
            placeholder: 'Temporary password',
            obscureText: true,
            autocorrect: false,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            style: AppFonts.body(fontSize: 15, color: fg),
            placeholderStyle: AppFonts.body(fontSize: 15, color: muted),
            decoration: field(),
          ),
          const SizedBox(height: 10),
          CupertinoTextField(
            controller: _nameCtrl,
            placeholder: 'Display name (optional)',
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            style: AppFonts.body(fontSize: 15, color: fg),
            placeholderStyle: AppFonts.body(fontSize: 15, color: muted),
            decoration: field(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 12, color: expense),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: CupertinoButton(
              color: accent,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              padding: EdgeInsets.zero,
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const CupertinoActivityIndicator()
                  : Text(
                      'Create user',
                      style: AppFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: onPrimary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
