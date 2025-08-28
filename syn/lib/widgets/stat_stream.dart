// lib/widgets/stat_stream.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_profile.dart';
import '../models/settings.dart';
import '../providers/player_state_provider.dart';

// Helper class to hold stat data.
class DisplayStatInfo {
  final String shortLabel;
  final String fullName;
  final int value;
  final int maxValue;
  final Color color;
  final IconData? icon;

  const DisplayStatInfo({
    required this.shortLabel,
    required this.fullName,
    required this.value,
    this.maxValue = 100,
    required this.color,
    this.icon,
  });
}

enum LifeStage { infant, child, teen, youngAdult, adult, elder, digital }

LifeStage getLifeStage(int age) {
  if (age <= 4) return LifeStage.infant;
  if (age <= 12) return LifeStage.child;
  if (age <= 17) return LifeStage.teen;
  if (age <= 29) return LifeStage.youngAdult;
  if (age <= 64) return LifeStage.adult;
  return LifeStage.elder;
}

/// A compact, horizontal bar that displays core stats as a futuristic "data stream".
class StatStreamWidget extends ConsumerWidget {
  const StatStreamWidget({super.key});

  List<DisplayStatInfo> _getCurrentCoreStats(
    PlayerProfile profile,
    AppSettings settings,
    BuildContext context,
  ) {
    final stage = getLifeStage(profile.age);
    final stats = profile.stats;
    final theme = Theme.of(context);

    final color1 = theme.colorScheme.secondary;       // magenta/pink
    final color2 = Colors.cyanAccent[400]!;
    final color3 = Colors.orangeAccent[200]!;
    final color4 = Colors.greenAccent[400]!;
    final color5 = theme.colorScheme.primary;         // purple

    switch (stage) {
      case LifeStage.infant:
      case LifeStage.child:
        return [
          DisplayStatInfo(shortLabel: "HLT", fullName: "Health", value: stats.health, color: color1, icon: Icons.favorite_border),
          DisplayStatInfo(shortLabel: "MOO", fullName: "Mood", value: stats.mood, color: color2, icon: Icons.sentiment_satisfied_alt),
          DisplayStatInfo(shortLabel: "SOC", fullName: "Social", value: stats.social, color: color3, icon: Icons.people_outline),
          DisplayStatInfo(shortLabel: "INT", fullName: "Intelligence", value: stats.intelligence, color: color4, icon: Icons.lightbulb_outline),
          DisplayStatInfo(shortLabel: "APR", fullName: "Appearance", value: stats.appearanceRating, color: color5, icon: Icons.face_retouching_natural),
        ];

      case LifeStage.teen:
        final list = <DisplayStatInfo>[
          DisplayStatInfo(shortLabel: "HLT", fullName: "Health", value: stats.health, color: color1, icon: Icons.favorite_border),
          DisplayStatInfo(shortLabel: "MOO", fullName: "Mood", value: stats.mood, color: color2, icon: Icons.sentiment_satisfied_alt),
          DisplayStatInfo(shortLabel: "APR", fullName: "Appearance", value: stats.appearanceRating, color: color3, icon: Icons.face_retouching_natural),
          DisplayStatInfo(shortLabel: "CHR", fullName: "Charisma", value: stats.charisma, color: color4, icon: Icons.star_border),
        ];
        if (settings.nsfwEnabled) {
          list.add(DisplayStatInfo(shortLabel: "LIB", fullName: "Libido", value: stats.libido, color: color5, icon: Icons.whatshot));
        } else {
          list.add(DisplayStatInfo(shortLabel: "CRT", fullName: "Creativity", value: stats.creativity, color: color5, icon: Icons.brush));
        }
        return list;

      case LifeStage.youngAdult:
        // Include Wealth here for YA/adults to match your broader loop.
        return [
          DisplayStatInfo(shortLabel: "HLT", fullName: "Health", value: stats.health, color: color1, icon: Icons.favorite_border),
          DisplayStatInfo(shortLabel: "MOO", fullName: "Mood", value: stats.mood, color: color2, icon: Icons.sentiment_satisfied_alt),
          DisplayStatInfo(shortLabel: "WTH", fullName: "Wealth", value: stats.wealth.clamp(0, 100), color: color3, icon: Icons.account_balance_wallet_outlined),
          DisplayStatInfo(shortLabel: "INT", fullName: "Intelligence", value: stats.intelligence, color: color4, icon: Icons.lightbulb_outline),
          DisplayStatInfo(shortLabel: "CHR", fullName: "Charisma", value: stats.charisma, color: color5, icon: Icons.star_border),
        ];

      case LifeStage.adult:
        return [
          DisplayStatInfo(shortLabel: "HLT", fullName: "Health", value: stats.health, color: color1, icon: Icons.favorite_border),
          DisplayStatInfo(shortLabel: "WTH", fullName: "Wealth", value: stats.wealth.clamp(0, 100), color: color2, icon: Icons.account_balance_wallet_outlined),
          DisplayStatInfo(shortLabel: "REP", fullName: "Reputation", value: stats.reputation, color: color3, icon: Icons.campaign),
          DisplayStatInfo(shortLabel: "INT", fullName: "Intelligence", value: stats.intelligence, color: color4, icon: Icons.lightbulb_outline),
          DisplayStatInfo(shortLabel: "CHR", fullName: "Charisma", value: stats.charisma, color: color5, icon: Icons.star_border),
        ];

      case LifeStage.elder:
        return [
          DisplayStatInfo(shortLabel: "HLT", fullName: "Health", value: stats.health, color: color1, icon: Icons.favorite_border),
          DisplayStatInfo(shortLabel: "HAP", fullName: "Happiness", value: stats.happiness, color: color5, icon: Icons.sentiment_very_satisfied),
          DisplayStatInfo(shortLabel: "REP", fullName: "Reputation", value: stats.reputation, color: color3, icon: Icons.campaign),
          DisplayStatInfo(shortLabel: "WIS", fullName: "Wisdom", value: stats.wisdom, color: color4, icon: Icons.psychology),
          DisplayStatInfo(shortLabel: "CRT", fullName: "Creativity", value: stats.creativity, color: color2, icon: Icons.brush),
        ];

      case LifeStage.digital:
        // If/when you add digital stats to PlayerStats, swap the placeholders.
        return [
          DisplayStatInfo(shortLabel: "INT", fullName: "Digital Integrity", value: stats.intelligence, color: color1, icon: Icons.security),
          DisplayStatInfo(shortLabel: "MEM", fullName: "Memory", value: stats.wisdom, color: color2, icon: Icons.memory),
          DisplayStatInfo(shortLabel: "INF", fullName: "Influence", value: stats.reputation, color: color3, icon: Icons.waves),
          DisplayStatInfo(shortLabel: "REP", fullName: "Reputation", value: stats.reputation, color: color4, icon: Icons.campaign),
          DisplayStatInfo(shortLabel: "WIS", fullName: "Wisdom", value: stats.wisdom, color: color5, icon: Icons.psychology),
        ];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuild only when stats or age/settings change meaningfully.
    final profile = ref.watch(playerStateProvider.select((p) => p));
    final appSettings = ref.watch(appSettingsProvider);

    final coreStats = _getCurrentCoreStats(profile, appSettings, context);
    final cs = Theme.of(context).colorScheme;
    final reducedMotion = appSettings.accessibility.reducedMotion;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: coreStats.map((stat) {
          return Flexible(
            child: _StatBar(
              key: ValueKey(stat.shortLabel),
              fullName: stat.fullName,
              shortLabel: stat.shortLabel,
              value: stat.value,
              maxValue: stat.maxValue,
              color: stat.color,
              icon: stat.icon,
              reducedMotion: reducedMotion,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Renders a single vertical glowing bar for one stat, with smooth height animation.
class _StatBar extends StatelessWidget {
  final String fullName;
  final String shortLabel;
  final int value;
  final int maxValue;
  final Color color;
  final IconData? icon;
  final bool reducedMotion;

  const _StatBar({
    super.key,
    required this.fullName,
    required this.shortLabel,
    required this.value,
    required this.maxValue,
    required this.color,
    this.icon,
    this.reducedMotion = false,
  });

  @override
  Widget build(BuildContext context) {
    const barAreaHeight = 65.0;
    const barWidth = 18.0;

    // Safe fraction with clamp + zero-guard.
    final double targetFraction = (maxValue <= 0)
        ? 0.0
        : (value / maxValue).clamp(0.0, 1.0);

    final labelColor = color;

    return Semantics(
      label: fullName,
      value: '$value of $maxValue',
      child: Tooltip(
        message: '$fullName: $value',
        preferBelow: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: barAreaHeight,
              width: barWidth,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Light inner frame for glassy look
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  // Smoothly animate the filled portion (reduced-motion aware)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: targetFraction),
                    duration: reducedMotion
                        ? const Duration(milliseconds: 1)
                        : const Duration(milliseconds: 350),
                    curve: reducedMotion ? Curves.linear : Curves.easeOutCubic,
                    builder: (context, frac, child) {
                      return FractionallySizedBox(
                        heightFactor: frac,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: color,
                                blurRadius: reducedMotion ? 6.0 : 12.0,
                                spreadRadius: reducedMotion ? 0.5 : 1.0,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Icon(icon, color: labelColor.withOpacity(0.85), size: 12),
                if (icon != null) const SizedBox(width: 3),
                Text(
                  shortLabel,
                  style: TextStyle(
                    color: labelColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    shadows: [Shadow(color: labelColor, blurRadius: 2.0)],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
