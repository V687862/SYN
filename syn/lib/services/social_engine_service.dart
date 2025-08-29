import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/memory_event.dart';
import '../models/player_profile.dart';
import '../models/settings.dart';
import '../models/event_pool.dart';
import 'event_pool_service.dart';

final socialEngineServiceProvider = Provider<SocialEngineService>((ref) {
  final pool = ref.read(eventPoolServiceProvider);
  return SocialEngineService(pool);
});

class SocialEngineService {
  final EventPoolService poolService;
  SocialEngineService(this.poolService);

  /// Attempts to produce an NPC-initiated event based on relationship-gated pools.
  /// Returns null when none fit.
  Future<MemoryEvent?> maybeNpcInitiatedEvent(
    PlayerProfile profile,
    AppSettings settings,
  ) async {
    final eligible = await poolService.eligibleTemplates(profile, settings);
    // Keep only templates with relationship conditions
    final relTpls = eligible.where((e) => e.gate.relationshipConditions.isNotEmpty).toList();
    if (relTpls.isEmpty) return null;

    // Score templates by best matching NPC (affection + trust)
    double bestScore = -1;
    PooledEventTemplate? bestTpl;
    Map<String, String>? bestVars;

    for (final tpl in relTpls) {
      final conds = tpl.gate.relationshipConditions;
      // choose first condition's role as the actor
      final role = conds.first.role;
      final candidates = profile.relationships.where((n) => n.role == role);
      if (candidates.isEmpty) continue;
      final npc = candidates.reduce((a, b) => (a.affection + a.trust) > (b.affection + b.trust) ? a : b);
      final score = npc.affection + npc.trust + (npc.sexCompatibility * 0.25);
      if (score > bestScore) {
        bestScore = score;
        bestTpl = tpl;
        bestVars = {
          'NPC_NAME': npc.name,
          'NPC_ROLE': npc.role.name.toUpperCase(),
          'ACTOR_ID': npc.id,
        };
      }
    }

    if (bestTpl == null) return null;
    return bestTpl!.materialize(profile, variables: bestVars);
  }
}
