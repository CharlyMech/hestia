import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Bell, Group, Shield, Trophy, WarningTriangle;

/// Maps a [NotificationType] to a presentation icon + tint pair so list,
/// popover, and detail screens stay visually consistent.
class NotifVisual {
  final Widget icon;
  final Color color;
  const NotifVisual(this.icon, this.color);

  static NotifVisual of(BuildContext context, NotificationType type) {
    final theme = context.myTheme;
    final tints = theme.categoryTints
        .map((h) => Color(int.parse(h.replaceFirst('#', '0xff'))))
        .toList();
    final green = Color(int.parse(theme.colorGreen.replaceFirst('#', '0xff')));
    final red = Color(int.parse(theme.colorRed.replaceFirst('#', '0xff')));

    return switch (type) {
      NotificationType.transaction =>
        NotifVisual(Group(width: 18, height: 18, color: tints[0]), tints[0]),
      NotificationType.goal =>
        NotifVisual(Trophy(width: 18, height: 18, color: green), green),
      NotificationType.alert =>
        NotifVisual(WarningTriangle(width: 18, height: 18, color: red), red),
      NotificationType.system =>
        NotifVisual(Shield(width: 18, height: 18, color: tints[2]), tints[2]),
      NotificationType.reminder =>
        NotifVisual(Bell(width: 18, height: 18, color: tints[1]), tints[1]),
    };
  }
}
