import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_screen_provider.dart';
import '../models/app_screen.dart';
import '../widgets/static_starfield.dart';

class InitialIntroScreen extends ConsumerStatefulWidget {
  const InitialIntroScreen({super.key});
  @override
  ConsumerState<InitialIntroScreen> createState() => _InitialIntroScreenState();
}

class _InitialIntroScreenState extends ConsumerState<InitialIntroScreen>
    with TickerProviderStateMixin {
  static const accent = Color(0xFF00E5FF);

  double _opacityTitle = 0.0;
  double _opacityText = 0.0;
  double _opacityButton = 0.0;
  double _titleScale = 0.96;

  late final AnimationController _traceCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    _startAnimations();
  }

  @override
  void dispose() {
    _traceCtrl.dispose();
    super.dispose();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _opacityTitle = 1.0;
      _titleScale = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _opacityText = 1.0);

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _opacityButton = 1.0);
  }

  void _pingTrace() {
    _traceCtrl
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: Colors.black,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 42,
          letterSpacing: 2,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(fontSize: 16, height: 1.6, color: Colors.white70),
      ),
      useMaterial3: true,
    );

    return Theme(
      data: theme,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Stars (monochrome)
            const Positioned.fill(
              child: StaticStarfield(starCount: 140, starColor: Colors.white70),
            ),

            // Subtle monochrome vignette instead of colorful gradient
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.03),
                        Colors.black.withOpacity(0.92),
                      ],
                      radius: 1.2,
                      center: const Alignment(0.0, -0.2),
                    ),
                  ),
                ),
              ),
            ),

            // Corner ticks (thin cyan lines)
            const _CornerLines(),

            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTitle(theme),
                      const SizedBox(height: 28),
                      _buildIntroText(theme),
                      const SizedBox(height: 44),
                      _buildBeginButton(context, theme),
                    ],
                  ),
                ),
              ),
            ),

            // Confirm trace overlay
            IgnorePointer(
              ignoring: true,
              child: AnimatedBuilder(
                animation: _traceCtrl,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _TraceCirclePainter(progress: Curves.easeInOut.transform(_traceCtrl.value)),
                    child: const SizedBox.expand(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return AnimatedOpacity(
      opacity: _opacityTitle,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      child: AnimatedScale(
        scale: _titleScale,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Thin outline/glow
            Text(
              'AWAKENING',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 42,
                letterSpacing: 6,
                color: accent.withOpacity(0.10),
              ),
            ),
            Text(
              'AWAKENING',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 42,
                letterSpacing: 6,
                color: Colors.white,
                shadows: [
                  Shadow(blurRadius: 14, color: accent.withOpacity(0.25)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroText(ThemeData theme) {
    return AnimatedOpacity(
      opacity: _opacityText,
      duration: const Duration(milliseconds: 700),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
        ),
        child: Text(
          'A new consciousness flickers into existence. Yours.\n\n'
          'Ahead lies a journey shaped by your choices, experiences, and desires.\n'
          'This is a sandbox of identity. Explore what it means to be.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 17,
            color: Colors.white.withOpacity(0.88),
          ),
        ),
      ),
    );
  }

  Widget _buildBeginButton(BuildContext context, ThemeData theme) {
    return AnimatedOpacity(
      opacity: _opacityButton,
      duration: const Duration(milliseconds: 700),
      child: _GhostButton(
        label: 'BEGIN',
        onPressed: () {
          // pulse + navigate
          _pingTrace();
          ref.read(appScreenProvider.notifier).resetTo(AppScreen.mainMenu);
        },
      ),
    );
  }
}

/* ----------------- Supporting visuals ----------------- */

class _GhostButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  const _GhostButton({required this.label, required this.onPressed});

  @override
  State<_GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<_GhostButton> with SingleTickerProviderStateMixin {
  static const accent = Color(0xFF00E5FF);
  late final AnimationController _hover = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    lowerBound: 0,
    upperBound: 1,
  );

  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hover.forward(),
      onExit: (_) => _hover.reverse(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _hover.forward(),
        onTapCancel: () => _hover.reverse(),
        onTapUp: (_) {
          _hover.reverse();
          widget.onPressed();
        },
        child: AnimatedBuilder(
          animation: _hover,
          builder: (context, _) {
            final t = Curves.easeOut.transform(_hover.value);
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white.withOpacity(.14 + .18 * t), width: 1),
                boxShadow: [
                  BoxShadow(color: accent.withOpacity(.18 * t), blurRadius: 18 * t, spreadRadius: .6),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 2,
                    child: CustomPaint(painter: _GrowLinePainter(progress: t, color: accent)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'BEGIN',
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CornerLines extends StatelessWidget {
  const _CornerLines();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _CornerPainter()));
  }
}

class _CornerPainter extends CustomPainter {
  static const accent = Color(0xFF00E5FF);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = accent.withOpacity(.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const len = 34.0;
    // TL
    canvas.drawLine(const Offset(16, 16), const Offset(16 + len, 16), p);
    canvas.drawLine(const Offset(16, 16), const Offset(16, 16 + len), p);
    // TR
    canvas.drawLine(Offset(size.width - 16, 16), Offset(size.width - 16 - len, 16), p);
    canvas.drawLine(Offset(size.width - 16, 16), Offset(size.width - 16, 16 + len), p);
    // BL
    canvas.drawLine(Offset(16, size.height - 16), Offset(16 + len, size.height - 16), p);
    canvas.drawLine(Offset(16, size.height - 16), Offset(16, size.height - 16 - len), p);
    // BR
    canvas.drawLine(
      Offset(size.width - 16, size.height - 16),
      Offset(size.width - 16 - len, size.height - 16),
      p,
    );
    canvas.drawLine(
      Offset(size.width - 16, size.height - 16),
      Offset(size.width - 16, size.height - 16 - len),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) => false;
}

class _TraceCirclePainter extends CustomPainter {
  final double progress; // 0..1
  _TraceCirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final shortest = math.min(size.width, size.height);
    final radius = shortest * .28;
    final center = Offset(size.width * .82, size.height * .18);
    const accent = Color(0xFF00E5FF);

    final guide = Paint()
      ..color = Colors.white.withOpacity(.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, guide);

    final arc = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const start = -math.pi / 2;
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, arc);

    final endAngle = start + sweep;
    final end = Offset(center.dx + radius * math.cos(endAngle), center.dy + radius * math.sin(endAngle));
    canvas.drawCircle(end, 2.2, Paint()..color = accent.withOpacity(.9));
  }

  @override
  bool shouldRepaint(covariant _TraceCirclePainter old) => old.progress != progress;
}

class _GrowLinePainter extends CustomPainter {
  final double progress;
  final Color color;
  _GrowLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(Offset.zero, Offset(size.width * progress, 0), paint);
  }

  @override
  bool shouldRepaint(covariant _GrowLinePainter old) =>
      old.progress != progress || old.color != color;
}
