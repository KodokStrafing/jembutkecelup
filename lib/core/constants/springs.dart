import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// Every animation in this app is driven by a spring simulation.
/// No `Curves.easeInOut` anywhere — motion should feel physical.
class AppSprings {
  AppSprings._();

  /// Navigation transitions: snappy, confident.
  static const SpringDescription navigation =
      SpringDescription(mass: 1.0, stiffness: 400, damping: 30);

  /// Card appearances: gentle, premium.
  static const SpringDescription card =
      SpringDescription(mass: 1.0, stiffness: 150, damping: 15);

  /// Modal sheets: heavy, physical.
  static const SpringDescription sheet =
      SpringDescription(mass: 1.2, stiffness: 200, damping: 18);

  /// Button presses: quick feedback.
  static const SpringDescription button =
      SpringDescription(mass: 0.8, stiffness: 500, damping: 25);

  /// Orbital icons: floaty, weightless.
  static const SpringDescription orbital =
      SpringDescription(mass: 0.6, stiffness: 80, damping: 6);

  /// Scroll momentum / value transitions: fluid.
  static const SpringDescription scroll =
      SpringDescription(mass: 1.0, stiffness: 100, damping: 12);

  /// Page transitions.
  static const SpringDescription page =
      SpringDescription(mass: 1.0, stiffness: 300, damping: 22);
}

/// A small helper mixin: gives any [State] with a
/// [SingleTickerProviderStateMixin] an [AnimationController] that is driven
/// by a spring simulation from 0 -> 1 whenever [springTo] is called.
mixin SpringAnimationMixin<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  late final AnimationController springController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  void springTo(SpringDescription desc, {double from = 0, double to = 1}) {
    final simulation = SpringSimulation(desc, from, to, 0);
    springController.animateWith(simulation);
  }

  @override
  void dispose() {
    springController.dispose();
    super.dispose();
  }
}
