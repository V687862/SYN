import 'package:syn/models/memory_event.dart';
import 'package:syn/models/player_profile.dart';
import 'package:syn/models/npc.dart';

class EventGate {
  final int? minAge;
  final int? maxAge;
  final bool requiresNsfw;
  final List<String> requiredFlags;
  final List<String> excludedFlags;
  final Map<String, num>? minStats; // e.g., { "charisma": 40 }
  final Map<String, num>? maxStats;
  final List<RelationshipCondition> relationshipConditions;

  const EventGate({
    this.minAge,
    this.maxAge,
    this.requiresNsfw = false,
    this.requiredFlags = const [],
    this.excludedFlags = const [],
    this.minStats,
    this.maxStats,
    this.relationshipConditions = const [],
  });

  factory EventGate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EventGate();
    return EventGate(
      minAge: json['minAge'] as int?,
      maxAge: json['maxAge'] as int?,
      requiresNsfw: json['requiresNsfw'] as bool? ?? false,
      requiredFlags: (json['requiredFlags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      excludedFlags: (json['excludedFlags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      minStats: json['minStats'] != null
          ? Map<String, num>.from(json['minStats'] as Map)
          : null,
      maxStats: json['maxStats'] != null
          ? Map<String, num>.from(json['maxStats'] as Map)
          : null,
      relationshipConditions: (json['relationshipConditions'] as List<dynamic>?)
              ?.map((e) => RelationshipCondition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        if (minAge != null) 'minAge': minAge,
        if (maxAge != null) 'maxAge': maxAge,
        'requiresNsfw': requiresNsfw,
        if (requiredFlags.isNotEmpty) 'requiredFlags': requiredFlags,
        if (excludedFlags.isNotEmpty) 'excludedFlags': excludedFlags,
        if (minStats != null) 'minStats': minStats,
        if (maxStats != null) 'maxStats': maxStats,
        if (relationshipConditions.isNotEmpty)
          'relationshipConditions': relationshipConditions.map((e) => e.toJson()).toList(),
      };
}

class RelationshipCondition {
  final NPCRole role; // required role
  final double? minAffection;
  final double? minTrust;
  final double? minSexCompatibility;
  final RelationshipStage? stage; // required stage (exact)

  const RelationshipCondition({
    required this.role,
    this.minAffection,
    this.minTrust,
    this.minSexCompatibility,
    this.stage,
  });

  factory RelationshipCondition.fromJson(Map<String, dynamic> json) {
    final roleName = json['role'] as String? ?? 'friend';
    final role = NPCRole.values.firstWhere(
      (r) => r.name.toLowerCase() == roleName.toLowerCase(),
      orElse: () => NPCRole.friend,
    );
    return RelationshipCondition(
      role: role,
      minAffection: (json['minAffection'] as num?)?.toDouble(),
      minTrust: (json['minTrust'] as num?)?.toDouble(),
      minSexCompatibility: (json['minSexCompatibility'] as num?)?.toDouble(),
      stage: _stageFrom(json['stage'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role.name,
        if (minAffection != null) 'minAffection': minAffection,
        if (minTrust != null) 'minTrust': minTrust,
        if (minSexCompatibility != null)
          'minSexCompatibility': minSexCompatibility,
        if (stage != null) 'stage': stage!.name,
      };
}

RelationshipStage? _stageFrom(String? s) {
  if (s == null) return null;
  try {
    return RelationshipStage.values
        .firstWhere((e) => e.name.toLowerCase() == s.toLowerCase());
  } catch (_) {
    return null;
  }
}

class PooledEventTemplate {
  final String id;
  final List<String> tags;
  final String summary;
  final String description;
  final List<int>? ageRange; // optional; gates take precedence
  final Map<String, num>? effects;
  final bool? nsfw;
  final List<EventChoice>? choices;
  final EventGate gate;
  final int weight;

  const PooledEventTemplate({
    required this.id,
    required this.tags,
    required this.summary,
    required this.description,
    this.ageRange,
    this.effects,
    this.nsfw,
    this.choices,
    this.gate = const EventGate(),
    this.weight = 1,
  });

  factory PooledEventTemplate.fromJson(Map<String, dynamic> json) {
    return PooledEventTemplate(
      id: json['id'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      summary: json['summary'] as String,
      description: json['description'] as String,
      ageRange: (json['ageRange'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      effects: json['effects'] != null
          ? Map<String, num>.from(json['effects'] as Map)
          : null,
      nsfw: json['nsfw'] as bool?,
      choices: (json['choices'] as List<dynamic>?)
          ?.map((e) => EventChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      gate: EventGate.fromJson(json['gate'] as Map<String, dynamic>?),
      weight: json['weight'] as int? ?? 1,
    );
  }

  MemoryEvent materialize(PlayerProfile profile, {Map<String, String>? variables}) {
    String sum = summary;
    String desc = description;
    List<EventChoice>? ch = choices;
    if (variables != null) {
      variables.forEach((k, v) {
        sum = sum.replaceAll('{$k}', v);
        desc = desc.replaceAll('{$k}', v);
      });
      if (choices != null) {
        ch = choices!.map((c) {
          String t = c.text;
          String? od = c.outcomeDescription;
          variables.forEach((k, v) {
            t = t.replaceAll('{$k}', v);
            if (od != null) od = od!.replaceAll('{$k}', v);
          });
          List<Map<String, dynamic>>? rel = c.relationshipEffects?.map((m) {
            final mm = Map<String, dynamic>.from(m);
            mm.updateAll((key, value) {
              if (value is String) {
                var s = value;
                variables.forEach((k, v) {
                  s = s.replaceAll('{$k}', v);
                });
                return s;
              }
              return value;
            });
            return mm;
          }).toList();
          Map<String, dynamic>? req;
          if (c.requires != null) {
            req = _deepReplace(Map<String, dynamic>.from(c.requires!), variables);
          }
          return c.copyWith(text: t, outcomeDescription: od, relationshipEffects: rel, requires: req);
        }).toList();
      }
    }
    return MemoryEvent(
      id: id,
      age: profile.age,
      summary: sum,
      description: desc,
      tags: tags,
      effects: effects,
      nsfw: nsfw,
      choices: ch,
    );
  }

  Map<String, dynamic> _deepReplace(Map<String, dynamic> input, Map<String, String> vars) {
    final out = <String, dynamic>{};
    input.forEach((k, v) {
      if (v is String) {
        var s = v;
        vars.forEach((vk, vv) { s = s.replaceAll('{$vk}', vv); });
        out[k] = s;
      } else if (v is Map) {
        out[k] = _deepReplace(Map<String, dynamic>.from(v), vars);
      } else if (v is List) {
        out[k] = v.map((e) => e is String ? vars.entries.fold(e, (acc, ent) => acc.replaceAll('{${ent.key}}', ent.value)) : e).toList();
      } else {
        out[k] = v;
      }
    });
    return out;
  }
}
