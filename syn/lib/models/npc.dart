// lib/models/npc.dart

// Enum for the different roles an NPC can have, based on GDD
enum NPCRole {
  family,
  friend,
  lover,
  enemy,
  coworker,
  classmate,
  acquaintance,
  mentor,
  rival
  // Add other roles as needed
}

// Relationship lifecycle stage (orthogonal to role)
enum RelationshipStage {
  none,
  crush,
  dating,
  committed,
  cohabiting,
  married,
  separated,
  brokenUp,
}

class NPC {
  final String id; // Unique identifier for the NPC
  final String name;
  final int age; // NPC's current age
  final NPCRole role;
  final double affection; // Player's affection level towards this NPC
  final double trust;     // Player's trust level in this NPC
  final double sexCompatibility; // Compatibility score
  final RelationshipStage stage; // lifecycle stage

  // Personality (Big Five 0..100). Defaults neutral 50.
  final int openness;
  final int conscientiousness;
  final int extraversion;
  final int agreeableness;
  final int neuroticism;

  // Interests / tags (e.g., 'music', 'coding', 'fitness').
  final List<String> interests;

  // Additional social parameters (0..100 scale where applicable)
  final int jealousy; // tendency to jealousy (lover contexts)
  final int honesty;  // honesty/integrity
  final int ambition; // drive for status/achievement
  final String? romanticOrientation; // e.g., 'hetero', 'bi', 'ace', etc.
  final String? sexualOrientation;   // e.g., 'hetero', 'bi', 'ace', etc.

  // Optional: Add other NPC-specific attributes here later, like:
  // final String gender;
  // final PlayerStats? stats; // If NPCs have their own stats
  // final List<String>? traits;

  const NPC({
    required this.id,
    required this.name,
    required this.age,
    required this.role,
    this.affection = 0.0, // Default to 0
    this.trust = 0.0,     // Default to 0
    this.sexCompatibility = 50.0, // Default to a neutral 50, or adjust as needed
    this.stage = RelationshipStage.none,
    this.openness = 50,
    this.conscientiousness = 50,
    this.extraversion = 50,
    this.agreeableness = 50,
    this.neuroticism = 50,
    this.interests = const [],
    this.jealousy = 50,
    this.honesty = 50,
    this.ambition = 50,
    this.romanticOrientation,
    this.sexualOrientation,
  });

  NPC copyWith({
    String? id,
    String? name,
    int? age,
    NPCRole? role,
    double? affection,
    double? trust,
    double? sexCompatibility,
    RelationshipStage? stage,
    int? openness,
    int? conscientiousness,
    int? extraversion,
    int? agreeableness,
    int? neuroticism,
    List<String>? interests,
    int? jealousy,
    int? honesty,
    int? ambition,
    String? romanticOrientation,
    String? sexualOrientation,
  }) {
    return NPC(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      role: role ?? this.role,
      affection: affection ?? this.affection,
      trust: trust ?? this.trust,
      sexCompatibility: sexCompatibility ?? this.sexCompatibility,
      stage: stage ?? this.stage,
      openness: openness ?? this.openness,
      conscientiousness: conscientiousness ?? this.conscientiousness,
      extraversion: extraversion ?? this.extraversion,
      agreeableness: agreeableness ?? this.agreeableness,
      neuroticism: neuroticism ?? this.neuroticism,
      interests: interests ?? this.interests,
      jealousy: jealousy ?? this.jealousy,
      honesty: honesty ?? this.honesty,
      ambition: ambition ?? this.ambition,
      romanticOrientation: romanticOrientation ?? this.romanticOrientation,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
    );
  }

  factory NPC.fromJson(Map<String, dynamic> json) {
    return NPC(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      // Safely convert string from JSON to NPCRole enum
      role: NPCRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => NPCRole.friend, // Default role if parse fails
      ),
      affection: (json['affection'] as num?)?.toDouble() ?? 0.0,
      trust: (json['trust'] as num?)?.toDouble() ?? 0.0,
      sexCompatibility: (json['sexCompatibility'] as num?)?.toDouble() ?? 50.0,
      stage: _stageFromString(json['stage'] as String?),
      openness: (json['openness'] as num?)?.toInt() ?? 50,
      conscientiousness: (json['conscientiousness'] as num?)?.toInt() ?? 50,
      extraversion: (json['extraversion'] as num?)?.toInt() ?? 50,
      agreeableness: (json['agreeableness'] as num?)?.toInt() ?? 50,
      neuroticism: (json['neuroticism'] as num?)?.toInt() ?? 50,
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      jealousy: (json['jealousy'] as num?)?.toInt() ?? 50,
      honesty: (json['honesty'] as num?)?.toInt() ?? 50,
      ambition: (json['ambition'] as num?)?.toInt() ?? 50,
      romanticOrientation: json['romanticOrientation'] as String?,
      sexualOrientation: json['sexualOrientation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'role': role.name, // Store enum as string
      'affection': affection,
      'trust': trust,
      'sexCompatibility': sexCompatibility,
      'stage': stage.name,
      'openness': openness,
      'conscientiousness': conscientiousness,
      'extraversion': extraversion,
      'agreeableness': agreeableness,
      'neuroticism': neuroticism,
      'interests': interests,
      'jealousy': jealousy,
      'honesty': honesty,
      'ambition': ambition,
      'romanticOrientation': romanticOrientation,
      'sexualOrientation': sexualOrientation,
    };
  }

  static RelationshipStage _stageFromString(String? s) {
    if (s == null) return RelationshipStage.none;
    try {
      return RelationshipStage.values
          .firstWhere((e) => e.name.toLowerCase() == s.toLowerCase());
    } catch (_) {
      return RelationshipStage.none;
    }
  }

  @override
  String toString() {
    return 'NPC(id: $id, name: "$name", age: $age, role: ${role.name}, affection: $affection, trust: $trust, sexCompatibility: $sexCompatibility)';
  }
}
