import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/data/services/image_upload_service.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';

/// Generic image picker for forms. Tap → action sheet (Camera/Gallery/Remove).
/// Wraps [ImageUploadService] from [AppDependencies] so call sites don't care
/// whether storage is mock or live.
///
/// Provide [bucket] (one of [ImageBuckets]) and a unique [path] within that
/// bucket (e.g. `'{userId}/avatar.jpg'`).
class ImagePickerField extends StatefulWidget {
  final String bucket;
  final String path;

  /// Current image URL (or local file path in mock mode). Null = empty.
  final String? value;

  /// Called with the new URL/path after upload, or `null` after Remove.
  final ValueChanged<String?> onChanged;

  /// Visual diameter (square or circle).
  final double size;

  /// When true, renders a circle (avatars). Otherwise rounded square.
  final bool circle;

  /// Fallback color used behind initials/icon when no image.
  final Color fallbackColor;

  /// Fallback text rendered when no image (initials, single char). When null,
  /// a camera icon is shown instead.
  final String? fallbackText;

  const ImagePickerField({
    super.key,
    required this.bucket,
    required this.path,
    required this.value,
    required this.onChanged,
    this.size = 96,
    this.circle = true,
    this.fallbackColor = const Color(0xFF8B7AE6),
    this.fallbackText,
  });

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  bool _busy = false;

  Future<void> _open() async {
    if (_busy) return;
    final theme = context.myTheme;
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final expense = _c(theme.colorRed);

    final action = await showAppBottomSheet<_PickAction>(
      context: context,
      title: 'Photo',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _row('Take photo', CupertinoIcons.camera, fg,
                () => Navigator.of(context).pop(_PickAction.camera)),
            _divider(theme),
            _row('Choose from library', CupertinoIcons.photo, fg,
                () => Navigator.of(context).pop(_PickAction.gallery)),
            if (widget.value != null && widget.value!.isNotEmpty) ...[
              _divider(theme),
              _row('Remove photo', CupertinoIcons.trash, expense,
                  () => Navigator.of(context).pop(_PickAction.remove),
                  danger: true),
            ],
            const SizedBox(height: 8),
            Text(
              'Stored in ${widget.bucket}',
              style: AppFonts.body(fontSize: 11, color: muted),
            ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;

    if (action == _PickAction.remove) {
      await AppDependencies.instance.imageUploadService
          .remove(bucket: widget.bucket, path: widget.path);
      widget.onChanged(null);
      return;
    }

    setState(() => _busy = true);
    try {
      final result =
          await AppDependencies.instance.imageUploadService.pickAndUpload(
        bucket: widget.bucket,
        path: widget.path,
        source: action == _PickAction.camera
            ? ImageSource.camera
            : ImageSource.gallery,
      );
      if (!mounted) return;
      if (result != null) widget.onChanged(result.url);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _row(String label, IconData icon, Color color, VoidCallback onTap,
      {bool danger = false}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppFonts.body(
                fontSize: 15,
                fontWeight: danger ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(theme) => Container(height: 1, color: _c(theme.borderColor));

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final muted = _c(theme.onInactiveColor);

    final radius = widget.circle ? widget.size / 2 : 16.0;
    final hasImage = widget.value != null && widget.value!.isNotEmpty;
    final isRemote = hasImage &&
        (widget.value!.startsWith('http://') ||
            widget.value!.startsWith('https://'));

    Widget body;
    if (hasImage) {
      body = isRemote
          ? CachedNetworkImage(
              imageUrl: widget.value!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: widget.fallbackColor),
              errorWidget: (_, __, ___) => _placeholder(),
            )
          : Image.file(
              File(widget.value!),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            );
    } else {
      body = _placeholder();
    }

    return GestureDetector(
      onTap: _open,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: body,
            ),
          ),
          // Edit hint badge bottom-right.
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _c(theme.surfaceColor),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: _busy
                  ? const CupertinoActivityIndicator(radius: 8)
                  : Icon(CupertinoIcons.camera_fill, size: 14, color: muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: widget.fallbackColor,
      alignment: Alignment.center,
      child: widget.fallbackText != null
          ? Text(
              widget.fallbackText!,
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: (widget.size * 0.32).clamp(14.0, 36.0),
                fontWeight: FontWeight.w700,
              ),
            )
          : Icon(
              CupertinoIcons.camera,
              size: widget.size * 0.32,
              color: CupertinoColors.white.withValues(alpha: 0.85),
            ),
    );
  }
}

enum _PickAction { camera, gallery, remove }
