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

  // For simplicity, we'll omit fromJson/toJson for now,
  // as these might be hardcoded or loaded from a simpler structure initially.
  // They can be added if you decide to make schools dynamically loadable from JSON.
}
