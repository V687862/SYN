import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_screen_provider.dart';
import '../models/app_screen.dart';
import '../widgets/static_starfield.dart';
import '../ui/syn_kit.dart';

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

  @override
  void initState() {
    super.initState();
    _startAnimations();
  }

  @override
  void dispose() {
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
    TraceCircleOverlay.of(context)?.ping();
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
      child: DivButton(
        label: 'BEGIN',
        icon: Icons.play_arrow,
        onPressed: () {
          _pingTrace();
          ref.read(appScreenProvider.notifier).resetTo(AppScreen.mainMenu);
        },
        fullWidth: false,
        showChevron: false,
      ),
    );
  }
}

/* No additional painters: chrome comes from the global shell (SynKit). */
