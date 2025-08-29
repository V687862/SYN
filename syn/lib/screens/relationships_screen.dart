import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_state_provider.dart';
import '../models/npc.dart';
import '../ui/syn_kit.dart';

class RelationshipsScreen extends ConsumerWidget {
  const RelationshipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerStateProvider);
    final rels = List<NPC>.from(profile.relationships)
      ..sort((a, b) => b.affection.compareTo(a.affection));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relationships'),
      ),
      body: rels.isEmpty
          ? const Center(child: HintText('No relationships yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, i) {
                final n = rels[i];
                return GhostPanel(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  child: Row(
                    children: [
                      Icon(_iconFor(n.role), color: Colors.white70, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1),
                            ),
                            const SizedBox(height: 4),
                            Text('${n.role.name.toUpperCase()} • ${n.stage.name.toUpperCase()} • AGE ${n.age}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            final shared = _sharedInterest(playerProfile, n);
                            if (shared != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.tag, size: 12, color: Colors.white54),
                                  const SizedBox(width: 4),
                                  Text('Shared: $shared', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatPill(
                              label: 'Aff',
                              value: n.affection.round(),
                              icon: Icons.favorite_border),
                          const SizedBox(height: 6),
                          StatPill(
                              label: 'Trust',
                              value: n.trust.round(),
                              icon: Icons.handshake_outlined),
                          const SizedBox(height: 6),
                          _compatBar(context, n.sexCompatibility.round()),
                        ],
                      )
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: rels.length,
            ),
    );
  }

  IconData _iconFor(NPCRole role) {
    switch (role) {
      case NPCRole.family:
        return Icons.family_restroom;
      case NPCRole.friend:
        return Icons.groups_2_outlined;
      case NPCRole.lover:
        return Icons.favorite_border;
      case NPCRole.enemy:
        return Icons.report_problem_outlined;
      case NPCRole.coworker:
        return Icons.work_outline;
      case NPCRole.classmate:
        return Icons.school_outlined;
      case NPCRole.acquaintance:
        return Icons.person_outline;
      case NPCRole.mentor:
        return Icons.psychology_alt_outlined;
      case NPCRole.rival:
        return Icons.sports_kabaddi_outlined;
    }
  }

  Widget _compatBar(BuildContext context, int value) {
    final pct = (value.clamp(0, 100)) / 100.0;
    final c = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 120,
          height: 6,
          child: Stack(children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            FractionallySizedBox(
              widthFactor: pct,
              child: Container(
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 2),
        Text('Compat ${value}%', style: const TextStyle(fontSize: 10, color: Colors.white70)),
      ],
    );
  }

  String? _sharedInterest(final profile, NPC n) {
    // Mirror mapping used in RelationshipService._playerInterests
    final drives = profile.coreDriveScores;
    final playerInterests = <String>{};
    drives.forEach((k, v) {
      if (v <= 10) return;
      switch (k) {
        case 'master_a_craft':
          playerInterests.addAll(['art', 'craft', 'skill']);
          break;
        case 'seek_knowledge':
          playerInterests.addAll(['science', 'learning', 'tech']);
          break;
        case 'build_connections':
          playerInterests.addAll(['community', 'social']);
          break;
        case 'amass_wealth':
          playerInterests.addAll(['finance', 'business']);
          break;
        case 'experience_everything':
          playerInterests.addAll(['travel', 'adventure', 'food']);
          break;
        case 'fight_for_a_cause':
          playerInterests.addAll(['activism', 'politics']);
          break;
        case 'seek_transcendence':
          playerInterests.addAll(['philosophy', 'spirituality']);
          break;
        case 'survive_at_all_costs':
          playerInterests.addAll(['fitness', 'survival']);
          break;
      }
    });
    final overlap = n.interests.toSet().intersection(playerInterests);
    if (overlap.isEmpty) return null;
    return overlap.first;
  }
}
