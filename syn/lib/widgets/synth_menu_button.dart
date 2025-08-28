import 'package:flutter/material.dart';

/// Minimal, monochrome "ghost" menu button with thin outline,
/// subtle glow on hover/press, and a trace-line animation.
class SynthMenuButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final EdgeInsetsGeometry padding;

  const SynthMenuButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.fullWidth = true,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  });

  @override
  State<SynthMenuButton> createState() => _SynthMenuButtonState();
}

class _SynthMenuButtonState extends State<SynthMenuButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
    lowerBound: 0,
    upperBound: 1,
  );

  bool get _isEnabled => widget.onPressed != null;

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  void _onEnter(_) {
    if (_isEnabled) _hoverCtrl.forward();
  }

  void _onExit(_) {
    if (_isEnabled) _hoverCtrl.reverse();
  }

  void _onTapDown(_) {
    if (_isEnabled) _hoverCtrl.forward();
  }

  void _onTapCancel() {
    if (_isEnabled) _hoverCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary; // keep a single accent color
    final baseBorder = Colors.white.withOpacity(.14);

    final child = AnimatedBuilder(
      animation: _hoverCtrl,
      builder: (context, _) {
        final t = Curves.easeOut.transform(_hoverCtrl.value);
        final outline = Color.lerp(baseBorder, accent.withOpacity(.5), t)!;
        final glowOpacity = 0.18 * t;
        final iconAndTextColor = Color.lerp(
          Colors.white70,
          Colors.white,
          t * 0.6,
        )!;

        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: outline, width: 1),
            boxShadow: [
              if (_isEnabled && glowOpacity > 0)
                BoxShadow(
                  color: accent.withOpacity(glowOpacity),
                  blurRadius: 16 * t,
                  spreadRadius: .6,
                ),
            ],
          ),
          padding: widget.padding,
          child: Row(
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              // Leading trace line (grows with hover/press)
              SizedBox(
                width: 18,
                height: 2,
                child: CustomPaint(
                  painter: _GrowLinePainter(progress: t, color: accent),
                ),
              ),
              const SizedBox(width: 10),
              Icon(widget.icon, size: 20, color: iconAndTextColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: iconAndTextColor,
                    fontSize: 16,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, size: 20, color: iconAndTextColor),
            ],
          ),
        );
      },
    );

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: FocusableActionDetector(
        enabled: _isEnabled,
        onShowFocusHighlight: (hasFocus) {
          if (!_isEnabled) return;
          if (hasFocus) {
            _hoverCtrl.forward();
          } else {
            _hoverCtrl.reverse();
          }
        },
        child: Semantics(
          button: true,
          enabled: _isEnabled,
          label: widget.label,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _isEnabled ? _onTapDown : null,
            onTapCancel: _isEnabled ? _onTapCancel : null,
            onTapUp: _isEnabled
                ? (_) {
                    _hoverCtrl.reverse();
                    widget.onPressed?.call();
                  }
                : null,
            child: widget.fullWidth
                ? Row(children: [Expanded(child: child)])
                : child,
          ),
        ),
      ),
    );
  }
}

/* ── Painters ─────────────────────────────────────────── */

class _GrowLinePainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  _GrowLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.square;
    final w = size.width * progress;
    canvas.drawLine(Offset.zero, Offset(w, 0), paint);
  }

  @override
  bool shouldRepaint(covariant _GrowLinePainter old) =>
      old.progress != progress || old.color != color;
}
