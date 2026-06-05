import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/themes.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';

class GlobalErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const GlobalErrorScreen({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = themes[ThemeType.dark]!;
    final bg = hexToColor(theme.backgroundColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final orange = hexToColor(theme.colorOrange);
    final primary = hexToColor(theme.primaryColor);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: Stack(
        children: [
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_triangle_fill,
                      size: 56,
                      color: orange,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppFonts.heading(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppFonts.body(
                        fontSize: 14,
                        height: 1.4,
                        color: muted,
                      ),
                    ),
                    if (onRetry != null) ...[
                      const SizedBox(height: 24),
                      CupertinoButton(
                        color: primary,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: onRetry,
                        child: Text(
                          'Retry',
                          style: AppFonts.body(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: hexToColor(theme.onPrimaryColor),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal CupertinoApp wrapper for boot-time failure (used before deps init).
class GlobalErrorApp extends StatelessWidget {
  final String title;
  final String message;

  const GlobalErrorApp({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Hestia',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      home: GlobalErrorScreen(title: title, message: message),
    );
  }
}
