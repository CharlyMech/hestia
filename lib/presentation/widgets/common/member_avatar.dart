import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class MemberAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final double size;
  final Color? ringColor;

  /// Optional image: remote URL (http/https) or local file path. When null,
  /// falls back to color + initials.
  final String? imageUrl;

  const MemberAvatar({
    super.key,
    required this.name,
    required this.color,
    this.size = 24,
    this.ringColor,
    this.imageUrl,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
  }

  bool get _hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get _isRemote =>
      _hasImage &&
      (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: _hasImage ? null : color,
      shape: BoxShape.circle,
    );

    Widget child;
    if (_hasImage) {
      child = ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: _isRemote
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: color),
                  errorWidget: (_, __, ___) => _initialsFallback(),
                )
              : Image.file(
                  File(imageUrl!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _initialsFallback(),
                ),
        ),
      );
    } else {
      child = _initialsText();
    }

    Widget body = Container(
      width: size,
      height: size,
      decoration: decoration,
      alignment: Alignment.center,
      child: child,
    );

    if (ringColor != null) {
      body = DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ringColor!, width: 2),
        ),
        child: body,
      );
    }
    return body;
  }

  Widget _initialsFallback() => Container(
        color: color,
        alignment: Alignment.center,
        child: _initialsText(),
      );

  Widget _initialsText() => Text(
        _initials,
        style: TextStyle(
          color: CupertinoColors.white,
          fontSize: (size * 0.42).clamp(9.0, 18.0),
          fontWeight: FontWeight.w600,
        ),
      );
}

class AvatarStack extends StatelessWidget {
  final List<({String name, Color color, String? imageUrl})> members;
  final double size;
  final Color ringColor;

  const AvatarStack({
    super.key,
    required this.members,
    this.size = 22,
    required this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < members.length; i++)
            Positioned(
              left: i * (size - 6),
              child: MemberAvatar(
                name: members[i].name,
                color: members[i].color,
                size: size,
                ringColor: ringColor,
                imageUrl: members[i].imageUrl,
              ),
            ),
          SizedBox(width: members.length * (size - 6) + 6),
        ],
      ),
    );
  }
}
