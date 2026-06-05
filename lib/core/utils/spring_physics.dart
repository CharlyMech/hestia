import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// Standard spring parameters used across the app for tap-scale and
/// pill animations — Apple liquid-glass inspired bounce.
class SpringPhysics {
  const SpringPhysics._();

  static const _spring = SpringDescription(
    mass: 1.0,
    stiffness: 400.0,
    damping: 20.0,
  );

  /// Returns an [AnimationController] pre-configured for a tap-scale spring.
  /// The animation drives scale from 1.0 down to [minScale] and back.
  /// Caller must dispose the controller.
  static AnimationController tapScaleController(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 120),
    );
  }

  /// Tween to use with [tapScaleController]: 1.0 → [minScale].
  static Animation<double> tapScaleAnimation(
    AnimationController ctrl, {
    double minScale = 0.96,
  }) {
    return Tween<double>(begin: 1.0, end: minScale).animate(
      CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
    );
  }

  /// Drives [ctrl] forward with spring physics, then reverses after [delay].
  static Future<void> bounce(
    AnimationController ctrl, {
    Duration delay = const Duration(milliseconds: 80),
  }) async {
    ctrl.animateWith(SpringSimulation(_spring, 0, 1, 0));
    await Future.delayed(delay);
    ctrl.animateWith(SpringSimulation(_spring, 1, 0, 0));
  }
}
