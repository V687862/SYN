import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/syn_kit.dart';
// ← Needed for .characters
import '../providers/player_state_provider.dart';
import '../providers/static_data_providers.dart';
import '../models/player_profile.dart';
import '../models/core_drive.dart';

/* ---------- Helper Extensions ---------- */
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    final firstChar = characters.first.toUpperCase();
    return '$firstChar${substring(firstChar.length)}';
  }
}

/* ---------- Helper Functions ---------- */
String getLifePhaseLabel(int age) {
  if (age <= 4) return 'Infant';
  if (age <= 12) return 'Child';
  if (age <= 17) return 'Teen';
  if (age <= 29) return 'Young Adult';
  if (age <= 64) return 'Adult';
  return 'Elder';
}

String getTopPersonalityTraitAdjective(PlayerProfile player) {
  final statAdjectives = {
    'intelligence': 'Clever',
    'charisma': 'Charming',
    'creativity': 'Imaginative',
    'strength': 'Resilient',
    'confidence': 'Confident',
  };

  final relevantStats = {
    'intelligence': player.stats.intelligence,
    'charisma': player.stats.charisma,
    'creativity': player.stats.creativity,
    'strength': player.stats.strength,
    'confidence': player.stats.confidence,
  };

  final topStat = relevantStats.entries.reduce((a, b) => b.value > a.value ? b : a);
  return statAdjectives[topStat.key] ?? 'Unique';
}

String getIdentitySummary(PlayerProfile player, String dominantDriveLabel) {
  final statAdj = getTopPersonalityTraitAdjective(player);
  final drivePhrase = dominantDriveLabel != 'Undeclared'
      ? "driven by ${dominantDriveLabel.toLowerCase()}"
      : "on a path of self-discovery";
  return '$statAdj ${player.age}-year-old, $drivePhrase.';
}

/* ---------- Divineko-style Card ---------- */
class PlayerInfoCard extends ConsumerWidget {
  const PlayerInfoCard({super.key});

  static const Color _accent = Color(0xFF00E5FF); // single accent

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerStateProvider);
    final coreDrivesAsync = ref.watch(coreDrivesProvider);

    return coreDrivesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Could not load drives: $err')),
      data: (drives) {
        final dominantDriveObject = (player.dominantDrive != 'Undeclared')
            ? drives.firstWhere(
                (d) => d.id == player.dominantDrive,
                orElse: () => CoreDrive(id: 'Undeclared', label: 'Undeclared', description: ''),
              )
            : null;
        final dominantDriveLabel = dominantDriveObject?.label ?? 'Undeclared';

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black, // flat, no gradient/glass
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Minimal glyph
                  Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _accent.withOpacity(.8), width: 1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${player.name.isEmpty ? "Unit Designate" : player.name}, Age ${player.age}',
                      style: const TextStyle(
                        fontSize: 18,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Meta line: phase • drive
              Row(
                children: [
                  Icon(Icons.explore_outlined, size: 16, color: _accent),
                  const SizedBox(width: 6),
                  Text(
                    getLifePhaseLabel(player.age),
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  if (dominantDriveLabel != 'Undeclared') ...[
                    const SizedBox(width: 8),
                    Text('•', style: TextStyle(color: Colors.white.withOpacity(.6))),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dominantDriveLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 14),

              // Identity summary
              Text(
                getIdentitySummary(player, dominantDriveLabel),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Active modifiers → ghost chips
              if (player.activeModifiers.isNotEmpty) ...[
                const SizedBox(height: 14),
                const ThinDivider(),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final mod in player.activeModifiers)
                      _GhostTag(
                        text: '${mod.description} (${mod.duration}y)',
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/* ---------- Minimal Ghost Tag ---------- */
class _GhostTag extends StatelessWidget {
  final String text;
  const _GhostTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(.14), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: .3,
          color: Colors.white70,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
