// lib/models/memory_event.dart

// ignore: unused_import
import 'dart:convert'; // For potential use in relationshipEffects if complex

// Represents a choice a player can make within a MemoryEvent.
class EventChoice {
  final String id; // Unique identifier for this choice within its event
  final String text; // Display text for the choice
  final Map<String, num>? effects; // Stat changes, e.g., {"health": -5, "charisma": 10}
  final String? outcomeDescription; // Text to display after this choice is made
  final List<String>? flagsSet; // Flags to add to PlayerProfile.flags
  final List<String>? flagsRemoved; // Flags to remove from PlayerProfile.flags
  final String? triggeredEventId; // ID of another MemoryTemplate to trigger next
  final Map<String, int>? driveAffinity; // Changes to core drives, e.g., {"driveId": 5}

  // Defines effects on relationships with NPCs.
  // Example: [{'targetType': 'role'/'id', 'targetValue': 'lover'/'npc_specific_id', 'affectionChange': 10, 'trustChange': -5}]
  // 'targetType' can be 'role' (e.g., "lover", "friend_closest") or 'id' (specific NPC ID).
  // 'targetValue' is the role name or the NPC's unique ID.
  final List<Map<String, dynamic>>? relationshipEffects;

  const EventChoice({
    required this.id,
    required this.text,
    this.effects,
    this.outcomeDescription,
    this.flagsSet,
    this.flagsRemoved,
    this.triggeredEventId,
    this.relationshipEffects,
    this.driveAffinity,
  });

  EventChoice copyWith({
    String? id,
    String? text,
    Map<String, num>? effects,
    String? outcomeDescription,
    List<String>? flagsSet,
    List<String>? flagsRemoved,
    String? triggeredEventId,
    List<Map<String, dynamic>>? relationshipEffects,
  }) {
    return EventChoice(
      id: id ?? this.id,
      text: text ?? this.text,
      effects: effects ?? this.effects,
      outcomeDescription: outcomeDescription ?? this.outcomeDescription,
      flagsSet: flagsSet ?? this.flagsSet,
      flagsRemoved: flagsRemoved ?? this.flagsRemoved,
      triggeredEventId: triggeredEventId ?? this.triggeredEventId,
      relationshipEffects: relationshipEffects ?? this.relationshipEffects,
    );
  }

  factory EventChoice.fromJson(Map<String, dynamic> json) {
    return EventChoice(
      id: json['id'] as String? ?? '',
      text: json['text'] as String,
      effects: json['effects'] != null
          ? Map<String, num>.from(json['effects'] as Map)
          : null,
      outcomeDescription: json['outcomeDescription'] as String?,
      flagsSet: (json['flagsSet'] as List<dynamic>?)
          ?.map((flag) => flag as String)
          .toList(),
      flagsRemoved: (json['flagsRemoved'] as List<dynamic>?)
          ?.map((flag) => flag as String)
          .toList(),
      triggeredEventId: json['triggeredEventId'] as String?,
      relationshipEffects: (json['relationshipEffects'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      driveAffinity: json['driveAffinity'] != null
          ? Map<String, int>.from(json['driveAffinity'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      if (effects != null) 'effects': effects,
      if (outcomeDescription != null) 'outcomeDescription': outcomeDescription,
      if (flagsSet != null) 'flagsSet': flagsSet,
      if (flagsRemoved != null) 'flagsRemoved': flagsRemoved,
      if (triggeredEventId != null) 'triggeredEventId': triggeredEventId,
      if (relationshipEffects != null) 'relationshipEffects': relationshipEffects,
    };
  }

  @override
  String toString() {
    return 'EventChoice(id: $id, text: "$text")';
  }
}

// Represents a specific memory or event instance for the player.
class MemoryEvent {
  final String id;
  final int age;
  final String summary;
  final String description;
  final List<String> tags;
  final Map<String, num>? effects; // Immediate effects if the event has no choices or before choices
  final bool? nsfw;
  final List<EventChoice>? choices; // List of choices available for this event

  const MemoryEvent({
    required this.id,
    required this.age,
    required this.summary,
    required this.description,
    required this.tags,
    this.effects,
    this.nsfw,
    this.choices,
  });

  MemoryEvent copyWith({
    String? id,
    int? age,
    String? summary,
    String? description,
    List<String>? tags,
    Map<String, num>? effects,
    bool? nsfw,
    List<EventChoice>? choices,
  }) {
    return MemoryEvent(
      id: id ?? this.id,
      age: age ?? this.age,
      summary: summary ?? this.summary,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      effects: effects ?? this.effects,
      nsfw: nsfw ?? this.nsfw,
      choices: choices ?? this.choices,
    );
  }

  factory MemoryEvent.fromJson(Map<String, dynamic> json) {
    return MemoryEvent(
      id: json['id'] as String,
      age: json['age'] as int? ?? 0, // Default to 0 if age is not provided
      summary: json['summary'] as String? ?? 'No summary provided.',

      // Provide a default placeholder if 'description' is null.
      description: json['description'] as String? ?? 'No description available.',

      // Safely handle the 'tags' list. If it's null, it defaults to an empty list.
      tags: (json['tags'] as List<dynamic>?)?.map((tag) => tag as String).toList() ?? [],

      // This pattern is already safe: it checks for null before creating the map.
      effects: json['effects'] != null
          ? Map<String, num>.from(json['effects'] as Map)
          : null,

      // Safely cast to a nullable bool, defaulting to 'false' if 'nsfw' is null.
      nsfw: json['nsfw'] as bool? ?? false,

      // This pattern is also safe, using the null-aware ?.map operator.
      // The result will be null if 'choices' is not present, which is acceptable
      // if the 'choices' property in your model is nullable.
      choices: (json['choices'] as List<dynamic>?)
          ?.map((choiceJson) => EventChoice.fromJson(choiceJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'age': age,
      'summary': summary,
      'description': description,
      'tags': tags,
      if (effects != null) 'effects': effects,
      if (nsfw != null) 'nsfw': nsfw,
      if (choices != null) 'choices': choices!.map((c) => c.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'MemoryEvent(id: $id, age: $age, summary: "$summary", choices: ${choices?.length ?? 0})';
  }
}

// Represents the structure of entries in your memories.json
class MemoryTemplate {
  final String id;
  final List<int> ageRange;
  final List<String> tags;
  final String summary;
  final String description;
  final Map<String, num>? effects; // Immediate effects if the event template has no choices
  final bool? nsfw;
  final List<EventChoice>? choices; // Choices defined in the template

  const MemoryTemplate({
    required this.id,
    required this.ageRange,
    required this.tags,
    required this.summary,
    required this.description,
    this.effects,
    this.nsfw,
    this.choices,
  });

  factory MemoryTemplate.fromJson(Map<String, dynamic> json) {
    return MemoryTemplate(
      id: json['id'] as String,
      ageRange: (json['ageRange'] as List<dynamic>)
          .map((age) => age as int)
          .toList(),
      tags: (json['tags'] as List<dynamic>).map((tag) => tag as String).toList(),
      summary: json['summary'] as String,
      description: json['description'] as String,
      effects: json['effects'] != null
          ? Map<String, num>.from(json['effects'] as Map)
          : null,
      nsfw: json['nsfw'] as bool?,
      choices: (json['choices'] as List<dynamic>?)
          ?.map((choiceJson) => EventChoice.fromJson(choiceJson as Map<String, dynamic>))
          .toList(),
    );
  }

  // toJson for MemoryTemplate might not be strictly necessary if you only load from JSON,
  // but included for completeness if you ever need to serialize them.
   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ageRange': ageRange,
      'tags': tags,
      'summary': summary,
      'description': description,
      if (effects != null) 'effects': effects,
      if (nsfw != null) 'nsfw': nsfw,
      if (choices != null) 'choices': choices!.map((c) => c.toJson()).toList(),
    };
  }
}
