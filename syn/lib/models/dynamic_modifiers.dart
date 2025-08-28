// lib/models/dynamic_modifier.dart
class DynamicModifier {
  final String id;
  final String description;
  int duration; // In game years/turns. Made non-final to allow decrementing.
  final Map<String, num> statEffects;

  DynamicModifier({
    required this.id,
    required this.description,
    required this.duration,
    required this.statEffects,
  });

  // A method to create a copy with a decremented duration.
  DynamicModifier tickDown() {
    return DynamicModifier(
      id: id,
      description: description,
      duration: duration - 1,
      statEffects: statEffects,
    );
  }

  factory DynamicModifier.fromJson(Map<String, dynamic> json) {
    return DynamicModifier(
      id: json['id'] as String,
      description: json['description'] as String,
      duration: json['duration'] as int,
      statEffects: Map<String, num>.from(json['statEffects'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'duration': duration,
      'statEffects': statEffects,
    };
  }
}