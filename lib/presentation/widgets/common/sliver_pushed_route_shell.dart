import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/common/status_bar_blur_overlay.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show MoreHoriz, NavArrowLeft;

/// A single item in the actions dropdown menu.
class AppMenuAction {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const AppMenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// iOS-style sliver pushed route shell for entity detail pages
/// (profile, pet, car, etc.).
///
/// [header] fills the expanded app bar and stretches on over-scroll.
/// [title] starts bottom-left expanded and slides to top-center on collapse.
/// [actions] are shown in a custom animated dropdown under a MoreHoriz button.
/// [content] is placed in a [SliverToBoxAdapter] inside the body card.
class SliverPushedRouteShell extends StatelessWidget {
  const SliverPushedRouteShell({
    super.key,
    required this.title,
    required this.content,
    this.header,
    this.headerHeight = 320.0,
    this.actions,
    this.onBack,
    this.backgroundColor,
    this.headerColor,
    this.onRefresh,
  });

  final String title;
  final Widget content;
  final Widget? header;
  final double headerHeight;
  final List<AppMenuAction>? actions;
  final VoidCallback? onBack;
  final Color? backgroundColor;
  final Color? headerColor;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final surface = hexToColor(theme.surfaceColor);
    final bg = backgroundColor ?? hexToColor(theme.backgroundColor);
    final headerBg = headerColor ?? surface;
    final fg = hexToColor(theme.foregroundColor);
    final border = hexToColor(theme.borderColor);
    const top = 44.0;
    const collapsedH = top;

    void goBack() => onBack != null ? onBack!() : context.pop();

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                pinned: true,
                snap: false,
                floating: false,
                stretch: true,
                expandedHeight: headerHeight,
                collapsedHeight: collapsedH,
                toolbarHeight: collapsedH,
                automaticallyImplyLeading: false,
                backgroundColor: headerBg,
                surfaceTintColor: headerBg,
                shadowColor: CupertinoColors.black.withValues(alpha: 0.08),
                flexibleSpace: _SliverHeader(
                  title: title,
                  headerContent: header,
                  headerBg: headerBg,
                  fg: fg,
                  border: border,
                  bg: bg,
                  top: top,
                  collapsedHeight: collapsedH,
                  expandedHeight: headerHeight,
                ),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: AnimatedButton(
                    onTap: goBack,
                    size: top,
                    borderRadius: AppRadii.full,
                    backgroundColor: surface.withValues(alpha: 0.82),
                    borderColor: border,
                    borderWidth: 0.8,
                    padding: const EdgeInsets.all(10),
                    child: NavArrowLeft(width: 18, height: 18, color: fg),
                  ),
                ),
                leadingWidth: 56,
                actions: (actions != null && actions!.isNotEmpty)
                    ? [
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _ActionsButton(
                            actions: actions!,
                            surface: surface,
                            border: border,
                            fg: fg,
                            size: top,
                          ),
                        ),
                      ]
                    : null,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(AppRadii.xxl),
                  child: Container(
                    height: AppRadii.xxl,
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadii.xxxl),
                      ),
                      border:
                          Border(top: BorderSide(color: border, width: 0.8)),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: fg.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (onRefresh != null)
                CupertinoSliverRefreshControl(onRefresh: onRefresh),
              SliverToBoxAdapter(
                child: Container(color: bg, child: content),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: ColoredBox(color: bg),
              ),
            ],
          ),
          StatusBarBlurOverlay(
              tint: headerBg, peakOpacity: 0.92, fadeExtent: 20),
        ],
      ),
    );
  }
}

// ── Flexible space ─────────────────────────────────────────────────────────────

class _SliverHeader extends StatelessWidget {
  final String title;
  final Widget? headerContent;
  final Color headerBg;
  final Color fg;
  final Color border;
  final Color bg;
  final double top;
  final double collapsedHeight;
  final double expandedHeight;

  const _SliverHeader({
    required this.title,
    required this.headerContent,
    required this.headerBg,
    required this.fg,
    required this.border,
    required this.bg,
    required this.top,
    required this.collapsedHeight,
    required this.expandedHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final currentH = constraints.maxHeight;
        final scrollRange = expandedHeight - collapsedHeight;
        final shrink = (expandedHeight - currentH).clamp(0.0, scrollRange);
        final t =
            scrollRange > 0 ? (shrink / scrollRange).clamp(0.0, 1.0) : 1.0;

        final titleOpacityExpanded = (1.0 - t * 2).clamp(0.0, 1.0);
        final titleOpacityCollapsed = ((t - 0.5) * 2).clamp(0.0, 1.0);
        final expandedTitleColor =
            headerContent != null ? CupertinoColors.white : fg;

        return Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: headerBg)),
            if (headerContent != null) Positioned.fill(child: headerContent!),
            if (headerContent != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 120,
                child: Opacity(
                  opacity: titleOpacityExpanded,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0x8C000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 20,
              bottom: AppRadii.xxl + 16,
              right: 80,
              child: Opacity(
                opacity: titleOpacityExpanded,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: expandedTitleColor,
                  ),
                ),
              ),
            ),
            Positioned(
              top: top,
              left: 56,
              right: 56,
              height: 52,
              child: Opacity(
                opacity: titleOpacityCollapsed,
                child: Center(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.heading(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
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

// ── Actions button + custom dropdown ─────────────────────────────────────────

class _ActionsButton extends StatefulWidget {
  final List<AppMenuAction> actions;
  final Color surface;
  final Color border;
  final Color fg;
  final double size;

  const _ActionsButton({
    required this.actions,
    required this.surface,
    required this.border,
    required this.fg,
    required this.size,
  });

  @override
  State<_ActionsButton> createState() => _ActionsButtonState();
}

class _ActionsButtonState extends State<_ActionsButton>
    with TickerProviderStateMixin {
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;

  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _dismissMenu();
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _dismissMenu() {
    _overlay?.remove();
    _overlay = null;
  }

  void _toggleMenu() {
    if (_overlay != null) {
      _dismissMenu();
      return;
    }
    final theme = context.myTheme;
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.foregroundColor);

    _overlay = OverlayEntry(
      builder: (_) => _DropdownMenu(
        link: _layerLink,
        actions: widget.actions,
        surface: surface,
        border: border,
        fg: fg,
        onDismiss: _dismissMenu,
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _onTapDown(TapDownDetails _) => _scaleCtrl.forward();

  void _onTapUp(TapUpDetails _) {
    _scaleCtrl.reverse();
    _toggleMenu();
  }

  void _onTapCancel() => _scaleCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.surface.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(AppRadii.full),
              border: Border.all(color: widget.border, width: 0.8),
            ),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Center(
                child: MoreHoriz(width: 18, height: 18, color: widget.fg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dropdown overlay ──────────────────────────────────────────────────────────

class _DropdownMenu extends StatefulWidget {
  final LayerLink link;
  final List<AppMenuAction> actions;
  final Color surface;
  final Color border;
  final Color fg;
  final VoidCallback onDismiss;

  const _DropdownMenu({
    required this.link,
    required this.actions,
    required this.surface,
    required this.border,
    required this.fg,
    required this.onDismiss,
  });

  @override
  State<_DropdownMenu> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<_DropdownMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Transparent barrier — tap outside dismisses.
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismiss,
            behavior: HitTestBehavior.opaque,
            child: const ColoredBox(color: Color(0x00000000)),
          ),
        ),

        CompositedTransformFollower(
          link: widget.link,
          showWhenUnlinked: false,
          // Anchor top-right of follower to bottom-right of target.
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(0, 8),
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _slide,
              child: ScaleTransition(
                scale: _scale,
                alignment: Alignment.topRight,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 220,
                    decoration: BoxDecoration(
                      color: widget.surface,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border:
                          Border.all(color: widget.border, width: 0.8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x28000000),
                          blurRadius: 20,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < widget.actions.length; i++) ...[
                            _MenuItem(
                              action: widget.actions[i],
                              fg: widget.fg,
                              border: widget.border,
                              onTap: () async {
                                await _dismiss();
                                widget.actions[i].onTap();
                              },
                            ),
                            if (i < widget.actions.length - 1)
                              Divider(
                                height: 1,
                                thickness: 0.8,
                                color: widget.border
                                    .withValues(alpha: 0.6),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatefulWidget {
  final AppMenuAction action;
  final Color fg;
  final Color border;
  final VoidCallback onTap;

  const _MenuItem({
    required this.action,
    required this.fg,
    required this.border,
    required this.onTap,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final labelColor = widget.action.isDestructive
        ? CupertinoColors.destructiveRed
        : widget.fg;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        color: _pressed
            ? widget.border.withValues(alpha: 0.15)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          spacing: 12,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: widget.action.icon,
            ),
            Expanded(
              child: Text(
                widget.action.label,
                style: AppFonts.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
