import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show CheckCircle, WarningCircle, InfoCircle, XmarkCircle;

// ── Enums ─────────────────────────────────────────────────────────────────────

enum ToastType { success, error, warning, info, neutral }

enum ToastPosition { top, bottom }

enum ToastAnimation { slideDown, slideUp, fade, bounce }

// ── Config ────────────────────────────────────────────────────────────────────

class AppToastConfig {
  final ToastType type;
  final String title;
  final String? description;
  final Widget? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final ToastPosition position;
  final ToastAnimation animation;
  final Duration duration;
  final bool dismissible;

  const AppToastConfig({
    required this.title,
    this.type = ToastType.neutral,
    this.description,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.position = ToastPosition.bottom,
    this.animation = ToastAnimation.slideUp,
    this.duration = const Duration(seconds: 3),
    this.dismissible = true,
  });
}

// ── Public API ────────────────────────────────────────────────────────────────

extension AppToastContext on BuildContext {
  void showToast(AppToastConfig config) => AppToastService.show(this, config);
}

class AppToastService {
  AppToastService._();

  static OverlayEntry? _current;

  static void show(BuildContext context, AppToastConfig config) {
    _current?.remove();
    _current = null;

    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        config: config,
        onDismiss: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }

  static void showOnOverlay(OverlayState overlay, AppToastConfig config) {
    _current?.remove();
    _current = null;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        config: config,
        onDismiss: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }
}

// ── Widget ────────────────────────────────────────────────────────────────────

class _ToastWidget extends StatefulWidget {
  final AppToastConfig config;
  final VoidCallback onDismiss;

  const _ToastWidget({required this.config, required this.onDismiss});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  Timer? _timer;
  double _dragDelta = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    // _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    final isDown = widget.config.animation == ToastAnimation.slideDown ||
        widget.config.position == ToastPosition.top;
    _slide = Tween<Offset>(
      begin: Offset(0, isDown ? -1.2 : 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();
    _timer = Timer(widget.config.duration, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    await _ctrl.reverse();
    widget.onDismiss();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() => _dragDelta += d.delta.dy);
  }

  void _onDragEnd(DragEndDetails d) {
    final isTop = widget.config.position == ToastPosition.top;
    final threshold = isTop ? -40.0 : 40.0;
    if ((isTop && _dragDelta < threshold) ||
        (!isTop && _dragDelta > threshold) ||
        d.velocity.pixelsPerSecond.dy.abs() > 800) {
      _dismiss();
    } else {
      setState(() => _dragDelta = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final c = _toastColors(theme, widget.config.type);
    final borderColor = hexToColor(theme.borderColor);
    final isTop = widget.config.position == ToastPosition.top;

    return SafeArea(
      child: Align(
        alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: AlwaysStoppedAnimation(1.0),
            child: Transform.translate(
              offset: Offset(0, _dragDelta),
              child: GestureDetector(
                onVerticalDragUpdate:
                    widget.config.dismissible ? _onDragUpdate : null,
                onVerticalDragEnd:
                    widget.config.dismissible ? _onDragEnd : null,
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                    16,
                    isTop ? 12 : 0,
                    16,
                    isTop ? 0 : 24,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: c.bg,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      widget.config.icon ??
                          _defaultIcon(widget.config.type, c.icon),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(
                              widget.config.title,
                              style: AppFonts.body(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: c.fg,
                              ),
                            ),
                            if (widget.config.description != null)
                              Text(
                                widget.config.description!,
                                style: AppFonts.body(
                                  fontSize: 12,
                                  color: c.fg,
                                ),
                              ),
                            if (widget.config.actionLabel != null)
                              GestureDetector(
                                onTap: () {
                                  widget.config.onAction?.call();
                                  _dismiss();
                                },
                                child: Text(
                                  widget.config.actionLabel!,
                                  style: AppFonts.body(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: c.icon,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (widget.config.dismissible)
                        GestureDetector(
                          onTap: _dismiss,
                          child: XmarkCircle(
                            width: 16,
                            height: 16,
                            color: c.fg,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _ToastColors {
  final Color bg;
  final Color fg;
  final Color icon;
  const _ToastColors({
    required this.bg,
    required this.fg,
    required this.icon,
  });
}

_ToastColors _toastColors(dynamic theme, ToastType type) {
  final onStatus = hexToColor(theme.onStatusColor);
  switch (type) {
    case ToastType.success:
      final c = hexToColor(theme.successColor);
      return _ToastColors(bg: c, fg: onStatus, icon: onStatus);
    case ToastType.error:
      final c = hexToColor(theme.errorColor);
      return _ToastColors(bg: c, fg: onStatus, icon: onStatus);
    case ToastType.warning:
      final c = hexToColor(theme.warningColor);
      return _ToastColors(bg: c, fg: onStatus, icon: onStatus);
    case ToastType.info:
      final c = hexToColor(theme.infoColor);
      final onInfo = hexToColor(theme.onInfoColor);
      return _ToastColors(bg: c, fg: onInfo, icon: onInfo);
    case ToastType.neutral:
      return _ToastColors(
        bg: hexToColor(theme.surfaceColor),
        fg: hexToColor(theme.foregroundColor),
        icon: hexToColor(theme.mutedColor),
      );
  }
}

Widget _defaultIcon(ToastType type, Color color) {
  const size = 32.0;
  return switch (type) {
    ToastType.success => CheckCircle(width: size, height: size, color: color),
    ToastType.error => XmarkCircle(width: size, height: size, color: color),
    ToastType.warning => WarningCircle(width: size, height: size, color: color),
    ToastType.info => InfoCircle(width: size, height: size, color: color),
    ToastType.neutral => InfoCircle(width: size, height: size, color: color),
  };
}
