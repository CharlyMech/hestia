import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';

class NotifData {
  final Widget icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  final bool unread;

  const NotifData({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
  });
}

class NotifRow extends StatelessWidget {
  final NotifData n;
  final bool divider;
  final Color border;
  final Color fg;
  final Color muted;
  final Color dim;
  final Color accent;

  const NotifRow({
    super.key,
    required this.n,
    this.divider = true,
    required this.border,
    required this.fg,
    required this.muted,
    required this.dim,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        border: divider
            ? Border(bottom: BorderSide(color: border, width: 1))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatTile(icon: n.icon, color: n.color, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        n.title,
                        style: AppFonts.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        ),
                      ),
                    ),
                    if (n.unread) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  n.body,
                  style: AppFonts.body(
                    fontSize: 12,
                    color: muted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              n.time,
              style: AppFonts.label(fontSize: 11, color: dim),
            ),
          ),
        ],
      ),
    );
  }
}
