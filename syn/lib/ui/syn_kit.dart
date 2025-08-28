import 'dart:math' as math;
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

/// -------------------------------------------------------------
/// SYN · Divineko-inspired UI Kit (single-file, drop-in)
/// -------------------------------------------------------------
/// What you get (all reusable):
/// - SynTheme.buildTheme() : a cohesive dark theme (monochrome + one accent)
/// - GridBackdrop          : faint grid background
/// - CornerFrame           : four thin corner ticks framing the screen or a box
/// - GhostPanel            : flat black container with 1px outline
/// - DivButton             : ghost buttons (primary/secondary/success/danger)
///                          now supports `enabled`, `disabledReason`, and optional lock icon
/// - DivIconButton         : circular icon button variant
/// - DivSegmented          : segmented control / tabs (ghost pills)
/// - ThinDivider           : faint 1px divider
/// - HintText              : small, low-contrast helper line
/// - TitleHeader           : screen title (ALL CAPS) with system vibe
/// - TraceCircleOverlay    : global confirm pulse overlay (call .ping())
/// - Toast.notify()        : monochrome snackbar with colored border
///   Toast.success/info/error() shortcuts
/// - DivInputField         : minimal input (1px outline)
/// - GhostListItem         : list row with chevron and optional subtitle
/// - TimelineNode          : for timelines
/// - StatPill              : for compact stat display
/// - ModifierChip/Strip    : for dynamic buffs/debuffs row
///
/// Example usage is shown at the bottom of this file in a demo widget
/// (DemoScreen) that you can paste into your app and try immediately.
/// -------------------------------------------------------------

/* ======================= THEME ======================= */
class SynTheme {
  static const Color accent = Color(0xFF00E5FF); // cyan
  static const Color accentAlt = Color(0xFFB05CFF); // magenta
  static const Color danger = Color(0xFFFF5252);

  static ThemeData buildTheme({Color accentColor = accent}) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        secondary: accentAlt,
        surface: Colors.black,
        error: danger,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          letterSpacing: 6,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          letterSpacing: 1.2,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(fontSize: 14, height: 1.55, color: Colors.white70),
      ),
      useMaterial3: true,
    );
  }
}

/* ======================= BACKDROP & FRAME ======================= */
class GridBackdrop extends StatelessWidget {
  final double opacity; // 0..1
  final double cell;    // grid size in px
  const GridBackdrop({super.key, this.opacity = .06, this.cell = 24});

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GridPainter(opacity, cell));
}

class _GridPainter extends CustomPainter {
  final double opacity; final double cell;
  _GridPainter(this.opacity, this.cell);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .5;
    for (double x = 0; x <= size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }
  @override
  bool shouldRepaint(covariant _GridPainter old) => old.opacity != opacity || old.cell != cell;
}

class CornerFrame extends StatelessWidget {
  final EdgeInsets padding;
  final Color? color;
  final double len;
  final double stroke;
  final BorderRadius? radius; // if framing a panel
  const CornerFrame({super.key, this.padding = const EdgeInsets.all(16), this.color, this.len = 34, this.stroke = 1, this.radius});

  @override
  Widget build(BuildContext context) {
    final c = (color ?? Theme.of(context).colorScheme.primary).withOpacity(.55);
    return Padding(
      padding: padding,
      child: CustomPaint(painter: _CornerPainter(c, len, stroke, radius)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color; final double len; final double stroke; final BorderRadius? radius;
  _CornerPainter(this.color, this.len, this.stroke, this.radius);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = stroke;
    void drawCorner(Offset o, {bool tl=false, bool tr=false, bool bl=false, bool br=false}) {
      if (tl) { canvas.drawLine(o, o + Offset(len, 0), p); canvas.drawLine(o, o + Offset(0, len), p);} 
      if (tr) { final x=size.width-o.dx; canvas.drawLine(Offset(x, o.dy), Offset(x-len, o.dy), p); canvas.drawLine(Offset(x, o.dy), Offset(x, o.dy+len), p);} 
      if (bl) { final y=size.height-o.dy; canvas.drawLine(Offset(o.dx, y), Offset(o.dx+len, y), p); canvas.drawLine(Offset(o.dx, y), Offset(o.dx, y-len), p);} 
      if (br) { final x=size.width-o.dx, y=size.height-o.dy; canvas.drawLine(Offset(x, y), Offset(x-len, y), p); canvas.drawLine(Offset(x, y), Offset(x, y-len), p);} 
    }
    drawCorner(const Offset(0,0), tl: true);
    drawCorner(const Offset(0,0), tr: true);
    drawCorner(const Offset(0,0), bl: true);
    drawCorner(const Offset(0,0), br: true);
  }
  @override
  bool shouldRepaint(covariant _CornerPainter old) => old.color!=color || old.len!=len || old.stroke!=stroke;
}

/* ======================= PANELS & DIVIDERS ======================= */
class GhostPanel extends StatelessWidget {
  final Widget child; final EdgeInsets padding; final EdgeInsets margin; final Color? borderColor; final double radius; final Color? color;
  const GhostPanel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.margin = EdgeInsets.zero, this.borderColor, this.radius = 12, this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.black,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? Colors.white.withOpacity(.12), width: 1),
      ),
      child: child,
    );
  }
}

class ThinDivider extends StatelessWidget {
  final double opacity;
  const ThinDivider({super.key, this.opacity = .12});
  @override
  Widget build(BuildContext context) => Divider(color: Colors.white.withOpacity(opacity), height: 1);
}

class HintText extends StatelessWidget {
  final String text; final TextAlign align;
  const HintText(this.text, {super.key, this.align = TextAlign.center});
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: .7,
    child: Text(text, textAlign: align, style: const TextStyle(fontSize: 12, color: Colors.white70, letterSpacing: 1)),
  );
}

class TitleHeader extends StatelessWidget {
  final String title; final Color? color;
  const TitleHeader(this.title, {super.key, this.color});
  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.secondary;
    return Text(title.toUpperCase(), style: Theme.of(context).textTheme.displaySmall?.copyWith(color: c));
  }
}

/* ======================= BUTTONS ======================= */
enum DivButtonVariant { primary, secondary, success, danger }

enum DivButtonSize { sm, md, lg }

class DivButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final DivButtonVariant variant;
  final DivButtonSize size;
  final bool fullWidth;
  final bool showChevron;
  final EdgeInsets? padding;
  final bool enabled;                 // new
  final String? disabledReason;       // new
  final bool showLockWhenDisabled;    // new
  const DivButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = DivButtonVariant.primary,
    this.size = DivButtonSize.md,
    this.fullWidth = true,
    this.showChevron = true,
    this.padding,
    this.enabled = true,
    this.disabledReason,
    this.showLockWhenDisabled = true,
  });
  @override
  State<DivButton> createState() => _DivButtonState();
}

class _DivButtonState extends State<DivButton> with SingleTickerProviderStateMixin {
  late final AnimationController _hover = AnimationController(vsync: this, duration: const Duration(milliseconds: 160));
  bool get _enabled => widget.onPressed != null && widget.enabled;
  @override
  void dispose(){ _hover.dispose(); super.dispose(); }

  Color _accent(ColorScheme scheme){
    switch(widget.variant){
      case DivButtonVariant.primary: return scheme.primary;
      case DivButtonVariant.secondary: return Colors.white70;
      case DivButtonVariant.success: return const Color(0xFF2ECC71);
      case DivButtonVariant.danger: return SynTheme.danger;
    }
  }

  EdgeInsets _pad(){
    if(widget.padding!=null) return widget.padding!;
    switch(widget.size){
      case DivButtonSize.sm: return const EdgeInsets.symmetric(vertical: 10, horizontal: 12);
      case DivButtonSize.md: return const EdgeInsets.symmetric(vertical: 14, horizontal: 16);
      case DivButtonSize.lg: return const EdgeInsets.symmetric(vertical: 18, horizontal: 20);
    }
  }

  double _font(){
    switch(widget.size){
      case DivButtonSize.sm: return 14;
      case DivButtonSize.md: return 16;
      case DivButtonSize.lg: return 18;
    }
  }

  @override
  Widget build(BuildContext context){
    final scheme = Theme.of(context).colorScheme; final accent = _accent(scheme); final baseBorder = Colors.white.withOpacity(.14);
    final contentBuilder = Builder(builder: (context) {
      return MouseRegion(
      onEnter: (_) { if(_enabled) _hover.forward(); },
      onExit: (_) { if(_enabled) _hover.reverse(); },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled? (_) => _hover.forward() : null,
        onTapCancel: _enabled? () => _hover.reverse() : null,
        onTapUp: _enabled? (_) { _hover.reverse(); widget.onPressed?.call(); } : null,
        child: AnimatedBuilder(
          animation: _hover,
          builder:(context, _){
            final tBase = Curves.easeOut.transform(_hover.value);
            final t = _enabled ? tBase : 0.0;
            final outline = Color.lerp(baseBorder, accent.withOpacity(.5), t)!;
            final glowOpacity = _enabled ? .18 * t : 0.0;
            final textColor = !_enabled ? Colors.white38 : Color.lerp(Colors.white70, Colors.white, t*.6)!;
            final label = Text(
              widget.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textColor, fontSize: _font(), letterSpacing: 1.5, fontWeight: FontWeight.w600),
            );

            final content = Container(
              padding: _pad(),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: outline, width: 1),
                boxShadow: [ if(glowOpacity>0) BoxShadow(color: accent.withOpacity(glowOpacity), blurRadius: 16*t, spreadRadius: .6) ],
              ),
              child: Row(
                mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                children:[
                  SizedBox(width: 18, height: 2, child: CustomPaint(painter: _GrowLinePainter(progress: t, color: accent))),
                  const SizedBox(width: 10),
                  if(!_enabled && widget.showLockWhenDisabled) ...[ Icon(Icons.lock_outline, size: 18, color: textColor), const SizedBox(width: 8) ]
                  else if(widget.icon!=null) ...[ Icon(widget.icon, size: 20, color: textColor), const SizedBox(width: 8),],
                  if (widget.fullWidth)
                    Expanded(child: label)
                  else
                    Flexible(fit: FlexFit.loose, child: label),
                  if(widget.showChevron) ...[ const SizedBox(width: 6), Icon(Icons.chevron_right, size: 20, color: textColor), ],
                ],
              ),
            );
            // Avoid using Expanded here to be safe inside shrink-wrapping Rows.
            // If fullWidth and bounded, stretch to max width; otherwise, return intrinsic size.
            return LayoutBuilder(
              builder: (context, constraints) {
                if (widget.fullWidth && constraints.hasBoundedWidth) {
                  return SizedBox(width: constraints.maxWidth, child: content);
                }
                return content;
              },
            );
          },
        ),
      ),
    );
    });

    final child = widget.disabledReason != null
        ? Tooltip(message: widget.disabledReason!, child: contentBuilder)
        : contentBuilder;

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: child,
    );
  }
}

class DivIconButton extends StatelessWidget {
  final IconData icon; final VoidCallback? onPressed; final DivButtonVariant variant; final double size;
  const DivIconButton({super.key, required this.icon, this.onPressed, this.variant = DivButtonVariant.primary, this.size = 44});
  @override
  Widget build(BuildContext context){
    final scheme = Theme.of(context).colorScheme; Color accent;
    switch(variant){
      case DivButtonVariant.primary: accent = scheme.primary; break;
      case DivButtonVariant.secondary: accent = Colors.white70; break;
      case DivButtonVariant.success: accent = const Color(0xFF2ECC71); break;
      case DivButtonVariant.danger: accent = SynTheme.danger; break;
    }
    final enabled = onPressed!=null; final color = enabled? accent : Colors.white24;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size/2),
      child: Container(
        height: size, width: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black, border: Border.all(color: color.withOpacity(.6), width: 1), boxShadow: [if(enabled) BoxShadow(color: color.withOpacity(.18), blurRadius: 14, spreadRadius: .5)]),
        child: Icon(icon, size: size*0.5, color: enabled? Colors.white : Colors.white38),
      ),
    );
  }
}

/* ======================= SEGMENTED CONTROL ======================= */
class DivSegmented extends StatelessWidget {
  final List<String> segments; final int index; final ValueChanged<int> onChanged;
  const DivSegmented({super.key, required this.segments, required this.index, required this.onChanged});
  @override
  Widget build(BuildContext context){
    final accent = Theme.of(context).colorScheme.primary;
    return GhostPanel(
      padding: const EdgeInsets.all(6),
      child: Row(children:[
        for(int i=0;i<segments.length;i++) ...[
          Expanded(
            child: InkWell(
              onTap: ()=> onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: i==index ? Colors.white.withOpacity(.04) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: i==index ? accent.withOpacity(.5) : Colors.white.withOpacity(.12), width: 1),
                ),
                child: Center(child: Text(segments[i].toUpperCase(), style: const TextStyle(fontSize: 12, letterSpacing: 1.4, color: Colors.white))),
              ),
            ),
          ),
          if(i<segments.length-1) const SizedBox(width: 6),
        ]
      ]),
    );
  }
}

/* ======================= INPUT ======================= */
class DivInputField extends StatelessWidget {
  final TextEditingController controller; final String hint; final bool obscure; final TextInputType? keyboardType;
  const DivInputField({super.key, required this.controller, this.hint = '', this.obscure = false, this.keyboardType});
  @override
  Widget build(BuildContext context){
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.black,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withOpacity(.12), width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(.6), width: 1)),
      ),
    );
  }
}

/* ======================= LIST ITEM ======================= */
class GhostListItem extends StatelessWidget {
  final String title; final String? subtitle; final IconData? leading; final VoidCallback? onTap; final bool danger;
  const GhostListItem({super.key, required this.title, this.subtitle, this.leading, this.onTap, this.danger=false});
  @override
  Widget build(BuildContext context){
    final accent = danger ? SynTheme.danger : Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: GhostPanel(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Row(children:[
          SizedBox(width: 18, height: 2, child: CustomPaint(painter: _GrowLinePainter(progress: 1, color: accent))),
          const SizedBox(width: 10),
          if(leading!=null) ...[Icon(leading, size: 18, color: Colors.white70), const SizedBox(width: 8)],
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
            if(subtitle!=null) ...[ const SizedBox(height: 4), Text(subtitle!, style: const TextStyle(color: Colors.white70, fontSize: 12)) ],
          ])),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.white70, size: 20),
        ]),
      ),
    );
  }
}

/* ======================= TIMELINE NODE ======================= */
class TimelineNode extends StatelessWidget {
  final double size; final bool filled; final Color? color;
  const TimelineNode({super.key, this.size = 12, this.filled = false, this.color});
  @override
  Widget build(BuildContext context){
    final c = (color ?? Theme.of(context).colorScheme.primary).withOpacity(.8);
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: filled? c.withOpacity(.25) : Colors.black, border: Border.all(color: c, width: 1)));
  }
}

/* ======================= TRACE OVERLAY & TOAST ======================= */
class TraceCircleOverlay extends StatefulWidget {
  const TraceCircleOverlay({super.key});
  static TraceCircleOverlayState? of(BuildContext context) => context.findAncestorStateOfType<TraceCircleOverlayState>();
  @override
  State<TraceCircleOverlay> createState() => TraceCircleOverlayState();
}

class TraceCircleOverlayState extends State<TraceCircleOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  void ping(){ _ctrl..reset()..forward(); }
  @override
  void dispose(){ _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context){
    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(painter: _TracePainter(progress: Curves.easeInOut.transform(_ctrl.value)), child: const SizedBox.expand()),
      ),
    );
  }
}

class _TracePainter extends CustomPainter {
  final double progress; _TracePainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size){
    if(progress<=0) return;
    final shortest = math.min(size.width, size.height); final radius = shortest*.28; final center = Offset(size.width*.82, size.height*.18);
    final accent = SynTheme.accent;
    final guide = Paint()..color = Colors.white.withOpacity(.04)..style = PaintingStyle.stroke..strokeWidth = 1;
    canvas.drawCircle(center, radius, guide);
    final arc = Paint()..color = accent..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round;
    const start = -math.pi/2; final sweep = 2*math.pi*progress; canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, arc);
    final endAngle = start + sweep; final end = Offset(center.dx + radius*math.cos(endAngle), center.dy + radius*math.sin(endAngle));
    canvas.drawCircle(end, 2.2, Paint()..color = accent.withOpacity(.9));
  }
  @override bool shouldRepaint(covariant _TracePainter old)=> old.progress!=progress;
}

class Toast {
  static void notify(BuildContext context, String msg, {Color? color}){
    final c = color ?? Theme.of(context).colorScheme.primary;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(letterSpacing: .5)),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: c.withOpacity(.6), width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
  }
  static void success(BuildContext context, String msg) =>
      notify(context, msg, color: const Color(0xFF2ECC71));
  static void info(BuildContext context, String msg) =>
      notify(context, msg, color: Theme.of(context).colorScheme.primary);
  static void error(BuildContext context, String msg) =>
      notify(context, msg, color: Theme.of(context).colorScheme.error);
}

/* ======================= PAINTER (shared) ======================= */
class _GrowLinePainter extends CustomPainter { final double progress; final Color color; _GrowLinePainter({required this.progress, required this.color});
  @override void paint(Canvas canvas, Size size){ final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = size.height..strokeCap = StrokeCap.square; canvas.drawLine(Offset.zero, Offset(size.width*progress, 0), p);} 
  @override bool shouldRepaint(covariant _GrowLinePainter old)=> old.progress!=progress || old.color!=color; }

/* ======================= STATS & MODIFIERS ======================= */
enum ModifierKind { buff, debuff, neutral }

class StatPill extends StatelessWidget {
  final String label;
  final int value; // 0-100 typical, but agnostic
  final IconData? icon;
  final Color? color;
  final bool hidden; // when true, show obfuscated styling
  const StatPill({super.key, required this.label, required this.value, this.icon, this.color, this.hidden = false});
  @override
  Widget build(BuildContext context){
    final c = color ?? Theme.of(context).colorScheme.primary;
    final textColor = hidden ? Colors.white38 : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: hidden ? Colors.white24 : c.withOpacity(.6), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children:[
        if(icon!=null) ...[ Icon(icon, size: 14, color: textColor), const SizedBox(width: 6) ],
        Text(label.toUpperCase(), style: TextStyle(color: textColor, fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w700)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: hidden ? Colors.white10 : c.withOpacity(.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(hidden ? '— —' : '$value', style: TextStyle(color: textColor, fontSize: 11, fontFeatures: const [FontFeature.tabularFigures()])),
        ),
      ]),
    );
  }
}

class ModifierChip extends StatelessWidget {
  final String label;
  final ModifierKind kind;
  final IconData? icon;
  const ModifierChip({super.key, required this.label, this.kind = ModifierKind.neutral, this.icon});
  @override
  Widget build(BuildContext context){
    Color kcolor(){
      switch(kind){
        case ModifierKind.buff: return const Color(0xFF2ECC71);
        case ModifierKind.debuff: return SynTheme.danger;
        case ModifierKind.neutral: return Colors.white70;
      }
    }
    final c = kcolor();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(.6), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children:[
        if(icon!=null) ...[ Icon(icon, size: 14, color: Colors.white70), const SizedBox(width: 6) ],
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ]),
    );
  }
}

class ModifiersStrip extends StatelessWidget {
  final List<ModifierChip> modifiers;
  final Axis scrollDirection;
  const ModifiersStrip({super.key, required this.modifiers, this.scrollDirection = Axis.horizontal});
  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      child: Row(children:[
        for (int i=0;i<modifiers.length;i++) ...[
          if(i>0) const SizedBox(width: 6),
          modifiers[i],
        ]
      ]),
    );
  }
}

/* ======================= DEMO SCREEN (optional) ======================= */
class DemoScreen extends StatefulWidget { const DemoScreen({super.key}); @override State<DemoScreen> createState()=>_DemoScreenState(); }
class _DemoScreenState extends State<DemoScreen> {
  int tab = 0; final ctrl = TextEditingController();
  @override Widget build(BuildContext context){
    return Theme(
      data: SynTheme.buildTheme(),
      child: Scaffold(
        body: Stack(children:[
          const GridBackdrop(opacity: .06),
          // CornerFrame removed for parity with app shell
          const TraceCircleOverlay(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
                  const TitleHeader('Menu'),
                  const SizedBox(height: 16),
                  GhostPanel(
                    child: Column(children:[
                      DivButton(label:'Resume', icon: Icons.play_arrow, onPressed: ()=> TraceCircleOverlay.of(context)?.ping()),
                      const SizedBox(height: 8),
                      DivButton(label:'Save Game', icon: Icons.save_outlined, onPressed: ()=> Toast.notify(context,'Saved'), variant: DivButtonVariant.success),
                      const SizedBox(height: 8),
                      DivButton(label:'Load Game', icon: Icons.folder_open, onPressed: ()=> Toast.notify(context,'Loaded')),
                      const SizedBox(height: 8),
                      DivButton(label:'Settings', icon: Icons.settings_outlined, onPressed: (){}),
                      const SizedBox(height: 16),
                      DivButton(label:'Exit to Main Menu', icon: Icons.logout, variant: DivButtonVariant.danger, onPressed: (){}),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  const HintText('tip: trace to confirm · minimal ui · maximal focus'),
                  const SizedBox(height: 24),
                  DivSegmented(segments: const ['System','Video','Audio'], index: tab, onChanged: (i)=> setState(()=> tab=i)),
                  const SizedBox(height: 10),
                  DivInputField(controller: ctrl, hint: 'Type here…'),
                  const SizedBox(height: 10),
                  GhostListItem(title: 'A Ghost Row', subtitle: 'Low-contrast subtitle', leading: Icons.info_outline),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
