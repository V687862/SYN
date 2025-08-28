import 'education_stage.dart';
// import 'player_stats.dart'; // If graduation has direct stat effects

// Represents a generic school or educational institution.
class School {
  final String id; // Unique ID, e.g., "generic_elementary_1"
  final String name;
  final EducationStage stage; // The stage this school belongs to
  final int minAgeToEnroll;
  final int typicalDurationInYears; // How many years this stage typically lasts
  final Map<String, num>? graduationEffects; // Optional: e.g., {"intelligence": 5}
  final EducationStage? nextStageOnGraduation; // What stage the player moves to after graduating this

  const School({
    required this.id,
    required this.name,
    required this.stage,
    required this.minAgeToEnroll,
    required this.typicalDurationInYears,
    this.graduationEffects,
    this.nextStageOnGraduation,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    EducationStage parseStage(String? s) {
      if (s == null) return EducationStage.none;
      return EducationStage.values.firstWhere(
        (e) => e.name == s,
        orElse: () => EducationStage.none,
      );
    }

    Map<String, num>? parseEffects(dynamic m) {
      if (m is Map) {
        return m.map<String, num>((key, value) => MapEntry(key.toString(), (value as num)));
      }
      return null;
    }

    return School(
      id: json['id'] as String,
      name: json['name'] as String,
      stage: parseStage(json['stage'] as String?),
      minAgeToEnroll: (json['minAgeToEnroll'] as num).toInt(),
      typicalDurationInYears: (json['typicalDurationInYears'] as num).toInt(),
      graduationEffects: parseEffects(json['graduationEffects']),
      nextStageOnGraduation: parseStage(json['nextStageOnGraduation'] as String?),
    );
  }
}
