import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/npc.dart';
import '../models/player_profile.dart';

final _uuid = const Uuid();

class RelationshipService {
  NPCRole _parseRole(String? roleStr) {
    if (roleStr == null) return NPCRole.friend;
    final norm = roleStr.toLowerCase();
    for (final r in NPCRole.values) {
      if (r.name.toLowerCase() == norm) return r;
    }
    // simple aliasing
    switch (norm) {
      case 'crush':
        return NPCRole.lover;
      case 'enemy':
        return NPCRole.enemy;
      case 'coworker':
        return NPCRole.coworker;
      case 'classmate':
        return NPCRole.classmate;
      case 'acquaintance':
        return NPCRole.acquaintance;
      case 'mentor':
        return NPCRole.mentor;
      case 'rival':
        return NPCRole.rival;
      case 'family':
        return NPCRole.family;
      case 'lover':
        return NPCRole.lover;
      case 'friend':
      default:
        return NPCRole.friend;
    }
  }

  NPC _createNPC({
    required String name,
    required int age,
    required NPCRole role,
  }) {
    return NPC(
      id: _uuid.v4(),
      name: name,
      age: age,
      role: role,
      affection: 0,
      trust: 0,
      sexCompatibility: 50,
    );
  }

  PlayerProfile upsertById(
    PlayerProfile profile, {
    required String id,
    String? name,
    int? age,
    NPCRole? role,
    double affectionDelta = 0,
    double trustDelta = 0,
    double sexCompatibilityDelta = 0,
  }) {
    final list = List<NPC>.from(profile.relationships);
    final idx = list.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      final n = list[idx];
      list[idx] = n.copyWith(
        name: name ?? n.name,
        age: age ?? n.age,
        role: role ?? n.role,
        affection: ((n.affection + affectionDelta).clamp(-100.0, 100.0) as num).toDouble(),
        trust: ((n.trust + trustDelta).clamp(-100.0, 100.0) as num).toDouble(),
        sexCompatibility: ((n.sexCompatibility + sexCompatibilityDelta).clamp(0.0, 100.0) as num).toDouble(),
      );
    } else {
      // insert new minimal NPC if not found
      final newNpc = _createNPC(
        name: name ?? 'Unknown',
        age: age ?? profile.age,
        role: role ?? NPCRole.acquaintance,
      ).copyWith(
        affection: (affectionDelta.clamp(-100.0, 100.0) as num).toDouble(),
        trust: (trustDelta.clamp(-100.0, 100.0) as num).toDouble(),
        sexCompatibility: ((50 + sexCompatibilityDelta).clamp(0.0, 100.0) as num).toDouble(),
      );
      list.add(newNpc);
    }
    return profile.copyWith(relationships: list);
  }

  PlayerProfile upsertFirstByRole(
    PlayerProfile profile, {
    required NPCRole role,
    String? name,
    int? age,
    double affectionDelta = 0,
    double trustDelta = 0,
    double sexCompatibilityDelta = 0,
  }) {
    final list = List<NPC>.from(profile.relationships);
    final idx = list.indexWhere((n) => n.role == role);
    if (idx >= 0) {
      final n = list[idx];
      list[idx] = n.copyWith(
        name: name ?? n.name,
        age: age ?? n.age,
        affection: ((n.affection + affectionDelta).clamp(-100.0, 100.0) as num).toDouble(),
        trust: ((n.trust + trustDelta).clamp(-100.0, 100.0) as num).toDouble(),
        sexCompatibility: ((n.sexCompatibility + sexCompatibilityDelta).clamp(0.0, 100.0) as num).toDouble(),
      );
    } else {
      final newNpc = _createNPC(
        name: name ?? role.name,
        age: age ?? profile.age,
        role: role,
      ).copyWith(
        affection: (affectionDelta.clamp(-100.0, 100.0) as num).toDouble(),
        trust: (trustDelta.clamp(-100.0, 100.0) as num).toDouble(),
        sexCompatibility: ((50 + sexCompatibilityDelta).clamp(0.0, 100.0) as num).toDouble(),
      );
      list.add(newNpc);
    }
    return profile.copyWith(relationships: list);
  }

  PlayerProfile createNew(
    PlayerProfile profile, {
    required String name,
    required int age,
    required NPCRole role,
    double affection = 0,
    double trust = 0,
    double sexCompatibility = 50,
  }) {
    final list = List<NPC>.from(profile.relationships);
    list.add(NPC(
      id: _uuid.v4(),
      name: name,
      age: age,
      role: role,
      affection: affection,
      trust: trust,
      sexCompatibility: sexCompatibility,
    ));
    return profile.copyWith(relationships: list);
  }

  /// Applies a list of relationship effects from an event choice.
  /// Each entry may contain keys like:
  /// - targetType: 'id' | 'role' | 'role_new' | 'role_update_or_create'
  /// - targetValue: id string when targetType=='id', or role name when 'role'
  /// - npcName, npcAge (for creation)
  /// - newRole (when updating role)
  /// - affectionChange, trustChange, sexCompatibilityChange (numbers)
  PlayerProfile applyRelationshipEffects(
      PlayerProfile profile, List<Map<String, dynamic>> effects) {
    var p = profile;
    for (final e in effects) {
      try {
        final targetType = (e['targetType'] as String?)?.toLowerCase() ?? '';
        final affectionDelta = (e['affectionChange'] as num?)?.toDouble() ?? 0;
        final trustDelta = (e['trustChange'] as num?)?.toDouble() ?? 0;
        final sexCompDelta =
            (e['sexCompatibilityChange'] as num?)?.toDouble() ?? 0;
        final newStageStr = e['newStage'] as String?;
        final newStage = _stageFromString(newStageStr);
        switch (targetType) {
          case 'id':
            final id = e['targetValue'] as String?;
            if (id == null) break;
            final newRole = _parseRole(e['newRole'] as String?);
            p = upsertById(
              p,
              id: id,
              name: e['npcName'] as String?,
              age: (e['npcAge'] as num?)?.toInt(),
              role: e.containsKey('newRole') ? newRole : null,
              affectionDelta: affectionDelta,
              trustDelta: trustDelta,
              sexCompatibilityDelta: sexCompDelta,
            );
            // Update stage if provided
            if (newStage != null) {
              final list = List<NPC>.from(p.relationships);
              final idx = list.indexWhere((n) => n.id == id);
              if (idx >= 0) {
                list[idx] = list[idx].copyWith(stage: newStage);
                p = p.copyWith(relationships: list);
              }
            }
            break;
          case 'role':
            final roleName = e['targetValue'] as String?;
            final role = _parseRole(roleName);
            p = upsertFirstByRole(
              p,
              role: role,
              name: e['npcName'] as String?,
              age: (e['npcAge'] as num?)?.toInt(),
              affectionDelta: affectionDelta,
              trustDelta: trustDelta,
              sexCompatibilityDelta: sexCompDelta,
            );
            if (newStage != null) {
              final list = List<NPC>.from(p.relationships);
              final idx = list.indexWhere((n) => n.role == role);
              if (idx >= 0) {
                list[idx] = list[idx].copyWith(stage: newStage);
                p = p.copyWith(relationships: list);
              }
            }
            break;
          case 'role_new':
            final role = _parseRole(e['newRole'] as String? ?? e['targetValue'] as String?);
            final name = e['npcName'] as String? ?? role.name;
            final age = (e['npcAge'] as num?)?.toInt() ?? profile.age;
            p = createNew(p, name: name, age: age, role: role);
            if (newStage != null) {
              final list = List<NPC>.from(p.relationships);
              final idx = list.indexWhere((n) => n.name == name && n.role == role);
              if (idx >= 0) {
                list[idx] = list[idx].copyWith(stage: newStage);
                p = p.copyWith(relationships: list);
              }
            }
            break;
          case 'role_update_or_create':
            final newRole = _parseRole(e['newRole'] as String?);
            final maybeOldRole = _parseRole(e['targetValue'] as String?);
            // try to find by old role and update to new
            final list = List<NPC>.from(p.relationships);
            final idx = list.indexWhere((n) => n.role == maybeOldRole);
            if (idx >= 0) {
              final n = list[idx];
              list[idx] = n.copyWith(
                role: newRole,
                name: e['npcName'] as String? ?? n.name,
                age: (e['npcAge'] as num?)?.toInt() ?? n.age,
                affection: ((n.affection + affectionDelta).clamp(-100.0, 100.0) as num).toDouble(),
                trust: ((n.trust + trustDelta).clamp(-100.0, 100.0) as num).toDouble(),
                sexCompatibility: ((n.sexCompatibility + sexCompDelta).clamp(0.0, 100.0) as num).toDouble(),
              );
              if (newStage != null) {
                list[idx] = list[idx].copyWith(stage: newStage);
              }
              p = p.copyWith(relationships: list);
            } else {
              // fallback upsert by new role
              p = upsertFirstByRole(
                p,
                role: newRole,
                name: e['npcName'] as String?,
                age: (e['npcAge'] as num?)?.toInt(),
                affectionDelta: affectionDelta,
                trustDelta: trustDelta,
                sexCompatibilityDelta: sexCompDelta,
              );
              if (newStage != null) {
                final l2 = List<NPC>.from(p.relationships);
                final i2 = l2.indexWhere((n) => n.role == newRole);
                if (i2 >= 0) {
                  l2[i2] = l2[i2].copyWith(stage: newStage);
                  p = p.copyWith(relationships: l2);
                }
              }
            }
            break;
          default:
            debugPrint('Unknown relationship targetType: $targetType');
        }
      } catch (err) {
        debugPrint('applyRelationshipEffects error: $err for $e');
      }
    }
    return p;
  }

  RelationshipStage? _stageFromString(String? s) {
    if (s == null) return null;
    try {
      return RelationshipStage.values
          .firstWhere((e) => e.name.toLowerCase() == s.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  // --- Yearly decay and compatibility updates ---
  PlayerProfile tickYearDecay(PlayerProfile profile) {
    final list = <NPC>[];
    for (final n in profile.relationships) {
      final roleBase = _baseDecayForRole(n.role);
      final affFactor = 1 + (n.neuroticism - 50) / 200 - (n.agreeableness - 50) / 200 - (n.extraversion - 50) / 200;
      final trustFactor = 1 + (n.neuroticism - 50) / 200 - (n.honesty - 50) / 200 + (n.jealousy - 50) / 300;
      final affDecay = ((roleBase.affection * affFactor).clamp(0.0, 5.0) as num).toDouble();
      final trustDecay = ((roleBase.trust * trustFactor).clamp(0.0, 5.0) as num).toDouble();
      final updated = n.copyWith(
        affection: ((n.affection - affDecay).clamp(-100.0, 100.0) as num).toDouble(),
        trust: ((n.trust - trustDecay).clamp(-100.0, 100.0) as num).toDouble(),
      );
      list.add(updated);
    }
    return profile.copyWith(relationships: list);
  }

  PlayerProfile recomputeCompatibility(PlayerProfile profile) {
    final s = profile.stats;
    final list = <NPC>[];
    for (final n in profile.relationships) {
      // Player side proxy (charisma + appearance + libido)
      final playerSignal = ((s.charisma + s.appearanceRating + s.libido) / 3).toDouble();
      // NPC predisposition
      final npcSignal = (n.agreeableness * 0.3 + n.extraversion * 0.2 + n.honesty * 0.2 + (100 - n.jealousy) * 0.15 + (100 - n.neuroticism) * 0.15).toDouble();
      final raw = ((playerSignal * 0.5 + npcSignal * 0.5).clamp(0.0, 100.0) as num).toDouble();
      // Blend to avoid jitter
      final blended = ((n.sexCompatibility * 0.7 + raw * 0.3).clamp(0.0, 100.0) as num).toDouble();
      list.add(n.copyWith(sexCompatibility: blended));
    }
    return profile.copyWith(relationships: list);
  }

  _Decay _baseDecayForRole(NPCRole role) {
    switch (role) {
      case NPCRole.family:
        return const _Decay(affection: 0.4, trust: 0.3);
      case NPCRole.lover:
        return const _Decay(affection: 0.6, trust: 0.5);
      case NPCRole.friend:
        return const _Decay(affection: 0.8, trust: 0.6);
      case NPCRole.coworker:
      case NPCRole.classmate:
        return const _Decay(affection: 1.0, trust: 0.8);
      case NPCRole.mentor:
        return const _Decay(affection: 0.6, trust: 0.4);
      case NPCRole.acquaintance:
        return const _Decay(affection: 1.2, trust: 1.0);
      case NPCRole.rival:
      case NPCRole.enemy:
        return const _Decay(affection: 0.2, trust: 0.6);
    }
  }
}

class _Decay {
  final double affection;
  final double trust;
  const _Decay({required this.affection, required this.trust});
}
