// lib/widgets/static_starfield.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class StaticStarfield extends StatefulWidget {
  final int starCount;
  final Color starColor;
  final int? seed;

  /// Max fractional radius jitter (±). Example: 0.05 = ±5% twinkle.
  final double twinkleJitter;

  /// Changing this value causes a *new* twinkle pattern on next rebuild,
  /// without regenerating star positions.
  final int twinkleSeed;

  const StaticStarfield({
    super.key,
    this.starCount = 120,
    this.starColor = Colors.white,
    this.seed,
    this.twinkleJitter = 0.05,
    this.twinkleSeed = 0, // bump this when you want a new twinkle
  });

  @override
  State<StaticStarfield> createState() => _StaticStarfieldState();
}

class _StaticStarfieldState extends State<StaticStarfield> {
  late math.Random _rand;
  Size _lastSize = Size.zero;
  late List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _rand = widget.seed != null ? math.Random(widget.seed) : math.Random();
    _stars = const [];
  }

  void _regen(Size size) {
    final w = size.width, h = size.height;
    final list = <_Star>[];
    for (var i = 0; i < widget.starCount; i++) {
      list.add(_Star(
        x: _rand.nextDouble() * w,
        y: _rand.nextDouble() * h,
        r: _rand.nextDouble() * 1.3 + 0.2,           // base radius
        a: _rand.nextDouble().clamp(0.1, 0.7),        // base alpha
      ));
    }
    _stars = list;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (size != _lastSize) {
          _lastSize = size;
          _regen(size);
        }
        return CustomPaint(
          isComplex: true,
          willChange: false, // painter doesn't animate; rebuilds only when widget changes
          painter: _StarListPainter(
            _stars,
            widget.starColor,
            widget.twinkleJitter,
            widget.twinkleSeed,
          ),
        );
      },
    );
  }
}

class _Star {
  final double x, y, r, a;
  const _Star({required this.x, required this.y, required this.r, required this.a});
}

class _StarListPainter extends CustomPainter {
  final List<_Star> stars;
  final Color color;
  final double twinkleJitter;
  final int twinkleSeed;

  _StarListPainter(this.stars, this.color, this.twinkleJitter, this.twinkleSeed);

  // Deterministic hash → 0..1 for per-star jitter
  double _noise(double x, double y, int seed) {
    final n = math.sin(x * 12.9898 + y * 78.233 + seed * 37.719) * 43758.5453;
    return n - n.floorToDouble(); // fract(n)
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in stars) {
      final n = _noise(s.x, s.y, twinkleSeed);

      // radius jitter in ±twinkleJitter (fraction of base r)
      final r = (s.r * (1.0 + ((n * 2 - 1) * twinkleJitter))).clamp(0.12, 3.0);

      // slight alpha jitter too (subtle brightness twinkle)
      final aj = (s.a * (1.0 + ((n * 2 - 1) * twinkleJitter * 0.6)))
          .clamp(0.08, 0.9);

      paint.color = color.withOpacity(aj);
      canvas.drawCircle(Offset(s.x, s.y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarListPainter old) =>
      old.stars != stars ||
      old.color != color ||
      old.twinkleJitter != twinkleJitter ||
      old.twinkleSeed != twinkleSeed;

  @override
  bool shouldRebuildSemantics(covariant _StarListPainter oldDelegate) => false;
}
