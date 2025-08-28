import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_screen_provider.dart';
import '../providers/player_state_provider.dart';
import '../models/app_screen.dart';

class InGameMenuScreen extends ConsumerStatefulWidget {
  const InGameMenuScreen({super.key});

  @override
  ConsumerState<InGameMenuScreen> createState() => _InGameMenuScreenState();

  static void _notify(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(letterSpacing: .5)),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: color.withOpacity(.6), width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
  }

  static void _tracePing(BuildContext context) {
    _TraceCircleOverlay.of(context)?.ping();
  }
}

class _InGameMenuScreenState extends ConsumerState<InGameMenuScreen> {
  Future<void> _onSave() async {
    await ref.read(playerStateProvider.notifier).savePlayerProfile();
    if (!mounted) return;
    InGameMenuScreen._notify(context, 'Game Saved!', const Color(0xFF2ECC71));
    InGameMenuScreen._tracePing(context);
  }

  Future<void> _onLoad() async {
    await ref.read(playerStateProvider.notifier).loadPlayerProfile();
    if (!mounted) return;
    InGameMenuScreen._notify(context, 'Game Loaded!', const Color(0xFF3498DB));
    ref.read(appScreenProvider.notifier).pop();
    InGameMenuScreen._tracePing(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text('MENU', style: TextStyle(letterSpacing: 4)),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _MonoGridBackdrop(opacity: 0.06),
          const _CornerLines(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _OutlinedPanel(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _GhostButton(
                        label: 'RESUME',
                        onPressed: () {
                          ref.read(appScreenProvider.notifier).pop();
                          InGameMenuScreen._tracePing(context);
                        },
                      ),
                      const SizedBox(height: 8),
                      _GhostButton(
                        label: 'SAVE GAME',
                        onPressed: () {
                          _onSave();
                        },
                      ),
                      const SizedBox(height: 8),
                      _GhostButton(
                        label: 'LOAD GAME',
                        onPressed: () {
                          _onLoad();
                        },
                      ),
                      const SizedBox(height: 8),
                      _GhostButton(
                        label: 'SETTINGS',
                        onPressed: () {
                          ref.read(appScreenProvider.notifier).push(AppScreen.settings);
                          InGameMenuScreen._tracePing(context);
                        },
                      ),
                      const SizedBox(height: 16),
                      _GhostButton(
                        label: 'EXIT TO MAIN MENU',
                        danger: true,
                        onPressed: () {
                          ref.read(appScreenProvider.notifier).resetTo(AppScreen.mainMenu);
                          InGameMenuScreen._tracePing(context);
                        },
                      ),
                      const SizedBox(height: 6),
                      const _HintLine(text: 'tip: trace to confirm · minimal ui · maximal focus'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // confirmation trace overlay
          const _TraceCircleOverlay(),
        ],
      ),
    );
  }
}

/* ---------- Styled Widgets ---------- */

class _GhostButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool danger;
  const _GhostButton({required this.label, required this.onPressed, this.danger = false});

  @override
  State<_GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<_GhostButton> with SingleTickerProviderStateMixin {
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
    final accent = widget.danger ? Colors.redAccent : const Color(0xFF00E5FF);
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
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(.14 + .18 * t),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(.18 * t),
                    blurRadius: 16 * t,
                    spreadRadius: .5,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // leading trace
                  SizedBox(
                    width: 18,
                    height: 2,
                    child: CustomPaint(
                      painter: _GrowLinePainter(progress: t, color: accent),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: accent,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
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

class _OutlinedPanel extends StatelessWidget {
  final Widget child;
  const _OutlinedPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(.12), width: 1),
      ),
      child: child,
    );
  }
}

class _HintLine extends StatelessWidget {
  final String text;
  const _HintLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: .7,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/* ---------- Visual Dressing ---------- */

class _MonoGridBackdrop extends StatelessWidget {
  final double opacity;
  const _MonoGridBackdrop({this.opacity = .08});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter(opacity: opacity));
  }
}

class _GridPainter extends CustomPainter {
  final double opacity;
  _GridPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .5;
    const cell = 24.0;
    for (double x = 0; x <= size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.opacity != opacity;
}

class _CornerLines extends StatelessWidget {
  const _CornerLines();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _CornerPainter()));
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final color = const Color(0xFF00E5FF).withOpacity(.5);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
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

/* ---------- Confirmation Trace Overlay ---------- */

class _TraceCircleOverlay extends StatefulWidget {
  const _TraceCircleOverlay();

  static _TraceCircleOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<_TraceCircleOverlayState>();
  }

  @override
  State<_TraceCircleOverlay> createState() => _TraceCircleOverlayState();
}

class _TraceCircleOverlayState extends State<_TraceCircleOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 650));

  void ping() {
    _ctrl
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _TraceCirclePainter(progress: Curves.easeInOut.transform(_ctrl.value)),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
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
    final accent = const Color(0xFF00E5FF);

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

    final start = -math.pi / 2;
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, arc);

    final endAngle = start + sweep;
    final end = Offset(center.dx + radius * math.cos(endAngle), center.dy + radius * math.sin(endAngle));
    canvas.drawCircle(end, 2.2, Paint()..color = accent.withOpacity(.9));
  }

  @override
  bool shouldRepaint(covariant _TraceCirclePainter old) => old.progress != progress;
}

/* ---------- Painters ---------- */

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
