import 'package:flutter/material.dart';

/// A single, app-wide animation clock that every glass surface listens to
/// for its shimmer highlight. One shared Ticker instead of one per widget
/// keeps the traveling-light effect cheap even with a dozen+ glass panels
/// on screen — each surface just reads the current value, nothing spins
/// its own animation loop.
class ShimmerClockScope extends StatefulWidget {
  final Widget child;

  const ShimmerClockScope({super.key, required this.child});

  @override
  State<ShimmerClockScope> createState() => _ShimmerClockScopeState();
}

class _ShimmerClockScopeState extends State<ShimmerClockScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ShimmerClockInherited(notifier: _controller, child: widget.child);
  }
}

class _ShimmerClockInherited extends InheritedNotifier<AnimationController> {
  const _ShimmerClockInherited({required super.notifier, required super.child});
}

/// Access point for glass widgets. Returns null if no scope is mounted
/// above (widgets should render without the shimmer in that case, rather
/// than crash).
class ShimmerClock {
  ShimmerClock._();

  static AnimationController? of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_ShimmerClockInherited>();
    return inherited?.notifier;
  }
}

/// The traveling highlight itself — a soft diagonal band with a hint of
/// iridescence that sweeps across whatever it's placed inside. Cheap to
/// repaint: it's a single gradient container, not a re-blur, and it's
/// wrapped in its own RepaintBoundary by the caller so the (expensive)
/// backdrop blur beneath it doesn't get recomputed every frame just
/// because this moves.
class ShimmerSweep extends StatelessWidget {
  final Animation<double> clock;

  const ShimmerSweep({super.key, required this.clock});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 200.0;
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 80.0;
        return AnimatedBuilder(
          animation: clock,
          builder: (context, _) {
            final t = clock.value;
            final dx = (-0.4 + 1.8 * t) * w;
            return Transform.translate(
              offset: Offset(dx, 0),
              child: Transform.rotate(
                angle: -0.35,
                child: Container(
                  width: w * 0.45,
                  height: h * 1.6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.16),
                        const Color(0xFFFFB3E6).withValues(alpha: 0.10),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.45, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
