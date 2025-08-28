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

class NPC {
  final String id; // Unique identifier for the NPC
  final String name;
  final int age; // NPC's current age
  final NPCRole role;
  final double affection; // Player's affection level towards this NPC
  final double trust;     // Player's trust level in this NPC
  final double sexCompatibility; // Compatibility score

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
  });

  NPC copyWith({
    String? id,
    String? name,
    int? age,
    NPCRole? role,
    double? affection,
    double? trust,
    double? sexCompatibility,
  }) {
    return NPC(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      role: role ?? this.role,
      affection: affection ?? this.affection,
      trust: trust ?? this.trust,
      sexCompatibility: sexCompatibility ?? this.sexCompatibility,
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
    };
  }

  @override
  String toString() {
    return 'NPC(id: $id, name: "$name", age: $age, role: ${role.name}, affection: $affection, trust: $trust, sexCompatibility: $sexCompatibility)';
  }
}