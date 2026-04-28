import 'package:flutter/cupertino.dart';

class MemberAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final double size;
  final Color? ringColor;

  const MemberAvatar({
    super.key,
    required this.name,
    required this.color,
    this.size = 24,
    this.ringColor,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: ringColor != null
            ? Border.all(color: ringColor!, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: CupertinoColors.white,
          fontSize: (size * 0.42).clamp(9.0, 18.0),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class AvatarStack extends StatelessWidget {
  final List<({String name, Color color})> members;
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
              ),
            ),
          SizedBox(width: members.length * (size - 6) + 6),
        ],
      ),
    );
  }
}
