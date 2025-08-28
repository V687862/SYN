import 'package:syn/models/memory_event.dart';
import 'package:syn/models/player_profile.dart';

class EventGate {
  final int? minAge;
  final int? maxAge;
  final bool requiresNsfw;
  final List<String> requiredFlags;
  final List<String> excludedFlags;
  final Map<String, num>? minStats; // e.g., { "charisma": 40 }
  final Map<String, num>? maxStats;

  const EventGate({
    this.minAge,
    this.maxAge,
    this.requiresNsfw = false,
    this.requiredFlags = const [],
    this.excludedFlags = const [],
    this.minStats,
    this.maxStats,
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
      };
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

  MemoryEvent materialize(PlayerProfile profile) {
    return MemoryEvent(
      id: id,
      age: profile.age,
      summary: summary,
      description: description,
      tags: tags,
      effects: effects,
      nsfw: nsfw,
      choices: choices,
    );
  }
}

