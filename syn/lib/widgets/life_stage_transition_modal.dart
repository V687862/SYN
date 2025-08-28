import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_profile.dart';
import '../models/settings.dart';
import '../providers/player_state_provider.dart';
import '../widgets/stat_stream.dart'; // For DisplayStatInfo & LifeStage
import '../ui/syn_kit.dart';

class LifeStageTransitionModal extends ConsumerStatefulWidget {
  final int oldAge;
  final int newAge;

  const LifeStageTransitionModal({
    super.key,
    required this.oldAge,
    required this.newAge,
  });

  @override
  ConsumerState<LifeStageTransitionModal> createState() =>
      _LifeStageTransitionModalState();
}

class _LifeStageTransitionModalState
    extends ConsumerState<LifeStageTransitionModal> {
  bool _showNewStats = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showNewStats = true);
      }
    });
  }

  List<DisplayStatInfo> _getCoreStatsForStage(
    PlayerProfile profile,
    AppSettings settings,
    LifeStage stage,
    ThemeData theme,
  ) {
    final stats = profile.stats;

    final colors = [
      theme.colorScheme.secondary,
      Colors.cyanAccent[400]!,
      Colors.orangeAccent[200]!,
      Colors.greenAccent[400]!,
      theme.colorScheme.primary,
    ];

    switch (stage) {
      case LifeStage.infant:
      case LifeStage.child:
        return [
          DisplayStatInfo(shortLabel: "HLT", fullName: "Health", value: stats.health, color: colors[0], icon: Icons.favorite_border),
          DisplayStatInfo(shortLabel: "MOO", fullName: "Mood", value: stats.mood, color: colors[1], icon: Icons.sentiment_satisfied_alt),
          DisplayStatInfo(shortLabel: "SOC", fullName: "Social", value: stats.social, color: colors[2], icon: Icons.people_outline),
          DisplayStatInfo(shortLabel: "INT", fullName: "Intelligence", value: stats.intelligence, color: colors[3], icon: Icons.lightbulb_outline),
          DisplayStatInfo(shortLabel: "APR", fullName: "Appearance", value: stats.appearanceRating, color: colors[4], icon: Icons.face_retouching_natural),
        ];
      case LifeStage.teen:
        final list = [
          DisplayStatInfo(shortLabel: "HLT", fullName: "Health", value: stats.health, color: colors[0], icon: Icons.favorite_border),
          DisplayStatInfo(shortLabel: "MOO", fullName: "Mood", value: stats.mood, color: colors[1], icon: Icons.sentiment_satisfied_alt),
          DisplayStatInfo(shortLabel: "APR", fullName: "Appearance", value: stats.appearanceRating, color: colors[2], icon: Icons.face_retouching_natural),
          DisplayStatInfo(shortLabel: "CHR", fullName: "Charisma", value: stats.charisma, color: colors[3], icon: Icons.star_border),
        ];
        list.add(settings.nsfwEnabled
            ? DisplayStatInfo(shortLabel: "LIB", fullName: "Libido", value: stats.libido, color: colors[4], icon: Icons.whatshot)
            : DisplayStatInfo(shortLabel: "CRT", fullName: "Creativity", value: stats.creativity, color: colors[4], icon: Icons.brush));
        return list;
      case LifeStage.youngAdult:
      case LifeStage.adult:
        return [
          DisplayStatInfo(shortLabel: "HLT", fullName: "Health", value: stats.health, color: colors[0], icon: Icons.favorite_border),
          DisplayStatInfo(shortLabel: "MOO", fullName: "Mood", value: stats.mood, color: colors[1], icon: Icons.sentiment_satisfied_alt),
          DisplayStatInfo(shortLabel: "REP", fullName: "Reputation", value: stats.reputation, color: colors[2], icon: Icons.campaign),
          DisplayStatInfo(shortLabel: "INT", fullName: "Intelligence", value: stats.intelligence, color: colors[3], icon: Icons.lightbulb_outline),
          DisplayStatInfo(shortLabel: "CHR", fullName: "Charisma", value: stats.charisma, color: colors[4], icon: Icons.star_border),
        ];
      case LifeStage.elder:
        return [
          DisplayStatInfo(shortLabel: "HLT", fullName: "Health", value: stats.health, color: colors[0], icon: Icons.favorite_border),
          DisplayStatInfo(shortLabel: "HAP", fullName: "Happiness", value: stats.happiness, color: colors[4], icon: Icons.sentiment_very_satisfied),
          DisplayStatInfo(shortLabel: "REP", fullName: "Reputation", value: stats.reputation, color: colors[2], icon: Icons.campaign),
          DisplayStatInfo(shortLabel: "WIS", fullName: "Wisdom", value: stats.wisdom, color: colors[3], icon: Icons.psychology),
          DisplayStatInfo(shortLabel: "CRT", fullName: "Creativity", value: stats.creativity, color: colors[1], icon: Icons.brush),
        ];
      case LifeStage.digital:
        return [
          DisplayStatInfo(shortLabel: "INT", fullName: "Intelligence", value: stats.intelligence, color: colors[0], icon: Icons.memory),
          DisplayStatInfo(shortLabel: "REP", fullName: "Reputation", value: stats.reputation, color: colors[1], icon: Icons.campaign),
          DisplayStatInfo(shortLabel: "CRT", fullName: "Creativity", value: stats.creativity, color: colors[2], icon: Icons.brush),
          DisplayStatInfo(shortLabel: "WIS", fullName: "Wisdom", value: stats.wisdom, color: colors[3], icon: Icons.psychology),
          DisplayStatInfo(shortLabel: "CHR", fullName: "Charisma", value: stats.charisma, color: colors[4], icon: Icons.star_border),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playerProfile = ref.watch(playerStateProvider);
    final appSettings = ref.watch(appSettingsProvider);

    final oldStage = getLifeStage(widget.oldAge);
    final newStage = getLifeStage(widget.newAge);

    final oldCoreStats = _getCoreStatsForStage(playerProfile, appSettings, oldStage, theme);
    final newCoreStats = _getCoreStatsForStage(playerProfile, appSettings, newStage, theme);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface.withAlpha((0.9 * 255).toInt()),
          border: Border.all(
            color: theme.colorScheme.secondary.withAlpha((0.7 * 255).toInt()),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.secondary.withAlpha((0.3 * 255).toInt()),
              blurRadius: 15,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "NEW PHASE: ${newStage.name.toUpperCase()}",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'Orbitron',
                color: theme.colorScheme.secondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              getFlavorTextForStage(newStage),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha((0.8 * 255).toInt()),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            Text(
              "CORE STATS EVOLVED",
              style: theme.textTheme.labelLarge?.copyWith(
                fontFamily: 'Orbitron',
                letterSpacing: 1.5,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _buildStatList(
                _showNewStats ? newCoreStats : oldCoreStats,
                theme,
                key: ValueKey(_showNewStats ? newStage : oldStage),
              ),
            ),
            const SizedBox(height: 24),
            DivButton(
              label: 'CONTINUE',
              icon: Icons.check,
              onPressed: () => Navigator.of(context).pop(),
              fullWidth: false,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatList(List<DisplayStatInfo> stats, ThemeData theme, {Key? key}) {
    if (stats.isEmpty) return const SizedBox.shrink();
    return Column(
      key: key,
      children: stats.map((stat) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(stat.icon, color: stat.color, size: 16),
              const SizedBox(width: 8),
              Text(
                stat.fullName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: stat.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String getFlavorTextForStage(LifeStage stage) {
    switch (stage) {
      case LifeStage.infant:
        return "Your journey begins. Every moment shapes the years to come.";
      case LifeStage.child:
        return "The world opens up. School, friendships, and new hobbies await.";
      case LifeStage.teen:
        return "Identity, rebellion, and romance. Life becomes more complex.";
      case LifeStage.youngAdult:
        return "Independence is yours. Forge your own path in work, love, and life.";
      case LifeStage.adult:
        return "Responsibilities mount, but so do the rewards. Your legacy begins now.";
      case LifeStage.elder:
        return "A lifetime of memories behind you. Time for reflection and wisdom.";
      case LifeStage.digital:
        return "Transcendence achieved. You exist beyond the physical, in the digital realm.";
    }
  }
}
