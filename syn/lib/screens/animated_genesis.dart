// lib/screens/animated_genesis.dart
import 'dart:async'; // Import for Timer
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import ConsumerWidget and WidgetRef
import '../providers/app_screen_provider.dart';      // To navigate
import '../models/app_screen.dart';                 // For AppScreen enum

// Change to ConsumerStatefulWidget to access ref for navigation
class AnimatedGenesisScreen extends ConsumerStatefulWidget {
  const AnimatedGenesisScreen({super.key});

  @override
  ConsumerState<AnimatedGenesisScreen> createState() => _AnimatedGenesisScreenState();
}

class _AnimatedGenesisScreenState extends ConsumerState<AnimatedGenesisScreen> // Change State to ConsumerState
    with TickerProviderStateMixin {
  late final AnimationController _controller; // Renamed for clarity
  late final Animation<double> _animation;    // Renamed for clarity

  // Define the duration for the splash screen
  static const Duration splashDuration = Duration(seconds: 7); // Let's try 7 seconds

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12), // Keep original animation cycle length
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);

    _controller.forward(); // Play the animation once

    // Timer to navigate after splashDuration
    Timer(splashDuration, () {
      // Check if the widget is still mounted before trying to update the state
      if (mounted) {
        // FIXED: Use `resetTo` to replace the splash screen in the navigation stack,
        // preventing the user from navigating back to it.
        ref.read(appScreenProvider.notifier).resetTo(AppScreen.initialIntro);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _SynLogoPainter(_animation.value),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

// _SynLogoPainter remains the same
class _SynLogoPainter extends CustomPainter {
  final double progress;
  final math.Random rand = math.Random();

  _SynLogoPainter(this.progress);

  final List<double> rings = [0.29, 0.325];
  final List<double> gapAngles = [math.pi / 7, math.pi / 9, math.pi / 7];
  final List<double> speeds = [1.0, 1.17, 0.91];
  final List<double> offsets = [0.0, 0.33, 0.47];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final minSide = math.min(size.width, size.height);
    final starPaint = Paint()..color = Colors.white.withOpacity(0.14);
    for (int i = 0; i < 90; i++) {
      final starParallax = (progress * (8 + (i % 7))).toDouble();
      final x = (rand.nextDouble() * size.width +
              18 * math.sin(progress * 2 * math.pi + i)) %
          size.width;
      final y = (rand.nextDouble() * size.height +
              starParallax * math.cos(i * 0.37 + progress * 4)) %
          size.height;
      final radius = rand.nextDouble() * 1.18;
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    for (int i = 0; i < rings.length; i++) {
      final radius = rings[i] * minSide;
      final gap = gapAngles[i % gapAngles.length];
      final speed = speeds[i % speeds.length];
      final offset = offsets[i % offsets.length];

      final anim = (progress * speed + offset) % 1.0;
      final startAngle = anim * 2 * math.pi;
      final secondGapOffset = math.pi + (gap / 2);

      final paint = Paint()
        ..color = Colors.purpleAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + gap / 2,
        math.pi - gap,
        false,
        paint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + secondGapOffset + gap / 2,
        math.pi - gap,
        false,
        paint,
      );
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: "SYN",
        style: TextStyle(
          fontSize: size.width * 0.12,
          fontWeight: FontWeight.bold,
          color: Colors.purpleAccent,
          shadows: [
            Shadow(
              blurRadius: 16,
              color: Colors.purpleAccent.withOpacity(0.5),
              offset: Offset.zero,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _SynLogoPainter oldDelegate) =>
      oldDelegate.progress != progress;
}