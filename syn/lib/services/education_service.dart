// lib/services/education_service.dart

import '../models/player_profile.dart';
import '../models/education_stage.dart';
import '../models/school.dart';
// ignore: unused_import, for PlayerStats type reference in comments or future use
import '../models/player_stats.dart'; 
import '../models/memory_event.dart'; // For triggeredEvent
import '../models/education_focus.dart';
// TODO: Import MemoryEngineService if needed for fetching specific graduation events
// import 'memory_engine_service.dart'; 

// A record to return results from education progression
typedef EducationProgressResult = ({
  PlayerProfile updatedProfileBase, // Base profile changes (stage, schoolId, etc.)
  String? graduationMessage,       // Message like "Graduated from High School!"
  Map<String, num>? graduationEffects, // Effects to be applied by the notifier
  MemoryEvent? triggeredEvent,      // Optional: Graduation could trigger a specific event
  Map<String, num>? yearlyEffects,  // Effects to be applied each school year based on focus
  String? yearlyMessage,            // E.g., "You focused on sports this year."
  bool failedYear,                  // If true, do not increment stage year
});


class EducationService {
  // TODO: Inject MemoryEngineService if it will be used to fetch specific graduation events.
  // final MemoryEngineService _memoryEngineService;
  // EducationService(this._memoryEngineService); // Example constructor if injected

  // For a basic start, we can define a list of generic schools.
  // TODO: FUTURE - Replace this hardcoded list with a dynamic loading mechanism.
  // This list should be populated based on PlayerProfile.countryCode by loading
  // and parsing the detailed 'education.json' file.
  // This will involve creating more detailed Dart models for the education.json structure.
  final List<School> _availableSchools = [
    const School(
      id: "generic_preschool",
      name: "Local Preschool",
      stage: EducationStage.preschool,
      minAgeToEnroll: 3,
      typicalDurationInYears: 2,
      nextStageOnGraduation: EducationStage.elementarySchool,
      // TODO: Consider adding 'cost' or 'tuition' fields to School model.
      // TODO: Consider adding 'statRequirements' (e.g., min intelligence) for enrollment.
    ),
    const School(
      id: "generic_elementary",
      name: "Public Elementary School",
      stage: EducationStage.elementarySchool,
      minAgeToEnroll: 6,
      typicalDurationInYears: 5, 
      nextStageOnGraduation: EducationStage.middleSchool,
    ),
    const School(
      id: "generic_middle_school",
      name: "County Middle School",
      stage: EducationStage.middleSchool,
      minAgeToEnroll: 11,
      typicalDurationInYears: 3, 
      nextStageOnGraduation: EducationStage.highSchool,
    ),
    const School(
      id: "generic_high_school",
      name: "City High School",
      stage: EducationStage.highSchool,
      minAgeToEnroll: 14,
      typicalDurationInYears: 4, 
      graduationEffects: {"intelligence": 5, "charisma": 2}, 
      nextStageOnGraduation: EducationStage.graduatedHighSchool,
      // TODO: Add specific subjects or tracks for high school that might affect skills or job eligibility.
    ),
    const School(
      id: "generic_community_college",
      name: "Community College (Vocational Program)",
      stage: EducationStage.vocationalTraining,
      minAgeToEnroll: 18,
      typicalDurationInYears: 2,
      graduationEffects: {"strength": 2, "creativity": 3}, // Example, could be skill-based
      // TODO: Define specific vocational skills gained.
      // nextStageOnGraduation: null, // Or could lead to specific job tiers.
    ),
    const School(
      id: "generic_university_bachelor",
      name: "State University (Bachelor's Program)",
      stage: EducationStage.universityBachelor,
      minAgeToEnroll: 18,
      typicalDurationInYears: 4,
      graduationEffects: {"intelligence": 10, "charisma": 5},
      nextStageOnGraduation: EducationStage.graduatedUniversityBachelor,
      // TODO: Add fields for 'majors' or 'fieldsOfStudy'.
      // TODO: Implement application process (success/failure based on stats/grades).
    ),
    // TODO: Add definitions for Master's, Doctorate, and other specialized schools.
  ];

  // Helper to access a school definition by ID (for UI display)
  School? getSchoolById(String id) {
    try {
      return _availableSchools.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // Helper to access a school by stage (for auto-enrollment)
  School? getSchoolByStage(EducationStage stage) {
    try {
      return _availableSchools.firstWhere((s) => s.stage == stage);
    } catch (_) {
      return null;
    }
  }

  // Get a list of schools the player might be eligible to enroll in
  List<School> getPotentialSchools(PlayerProfile player) {
    // TODO: When using country-specific data, this method will first need to
    // load/filter schools available in player.countryCode.
    return _availableSchools.where((school) {
      // Basic age check
      if (player.age < school.minAgeToEnroll) return false;
      
      // Prevent re-enrolling in an already completed stage
      if (player.completedEducationStages.contains(school.stage)) return false;
      
      // Prevent enrolling in a lower or same stage unless it's a valid parallel path
      if (player.currentEducationStage.index >= school.stage.index &&
          player.currentEducationStage != EducationStage.none &&
          // Allow specific parallel enrollments (e.g., vocational after high school grad)
          !((player.currentEducationStage == EducationStage.graduatedHighSchool &&
                  (school.stage == EducationStage.vocationalTraining || school.stage == EducationStage.universityBachelor)) ||
              (player.currentEducationStage == EducationStage.graduatedUniversityBachelor && 
                  (school.stage == EducationStage.universityMaster)))) { // Example for future Master's
        return false;
      }

      // Prerequisite checks
      // TODO: Make prerequisite logic more robust and data-driven, possibly from school definitions.
      switch (school.stage) {
        case EducationStage.middleSchool:
          if (!player.completedEducationStages.contains(EducationStage.elementarySchool) &&
              player.currentEducationStage != EducationStage.elementarySchool) {
            return false;
          }
          break;
        case EducationStage.highSchool:
          if (!player.completedEducationStages.contains(EducationStage.middleSchool) &&
              player.currentEducationStage != EducationStage.middleSchool) {
            return false;
          }
          break;
        case EducationStage.vocationalTraining:
        case EducationStage.universityBachelor:
          if (!(player.completedEducationStages.contains(EducationStage.highSchool) ||
                player.currentEducationStage == EducationStage.graduatedHighSchool)) {
            return false;
          }
          // TODO: Add checks for specific grades or entrance exam scores if implemented.
          break;
        case EducationStage.universityMaster:
          if (!player.completedEducationStages.contains(EducationStage.universityBachelor) &&
              player.currentEducationStage != EducationStage.graduatedUniversityBachelor) {
            return false;
          }
          // TODO: Add checks for specific Bachelor's major or GPA.
          break;
        case EducationStage.universityDoctorate:
           if (!player.completedEducationStages.contains(EducationStage.universityMaster) &&
              player.currentEducationStage != EducationStage.universityMaster) {
             return false; // Assuming Master's is a prereq
           }
          break;
        default:
          break;
      }
      // TODO: Add checks for player flags (e.g., 'expelled_from_school') that might prevent enrollment.
      // TODO: Add checks for financial ability if tuition costs are implemented.
      return true;
    }).toList();
  }

  // Enroll the player in a school
  PlayerProfile enrollInSchool(PlayerProfile player, String schoolId) {
    // TODO: When using dynamic school lists, ensure schoolId is valid for the current context (e.g., country).
    final schoolToEnroll = _availableSchools.firstWhere((s) => s.id == schoolId,
        orElse: () => throw Exception("School with ID $schoolId not found."));

    // TODO: More robust checks before enrollment:
    // - Can the player afford it (if costs implemented)?
    // - Do they meet specific stat/grade requirements for this particular school?
    // - Is there a chance of rejection (e.g., for university)?
    if (player.currentSchoolId != null && player.currentEducationStage != EducationStage.none) {
      print("Player is already enrolled in ${player.currentSchoolId}. Cannot enroll again without graduating or dropping out.");
      // TODO: Implement logic for dropping out or transferring.
      return player;
    }

    print("Enrolling player ${player.name} in ${schoolToEnroll.name}");
    // TODO: Trigger an "enrollment" MemoryEvent or ActionLog entry.
    return player.copyWith(
      currentSchoolId: schoolToEnroll.id,
      currentEducationStage: schoolToEnroll.stage,
      yearsInCurrentStage: 0, // Reset years for the new stage
    );
  }

  // Process a year of education for the player
  EducationProgressResult progressYearInEducation(PlayerProfile player) {
    if (player.currentSchoolId == null || player.currentEducationStage == EducationStage.none) {
      // Not enrolled in any school
      return (
        updatedProfileBase: player,
        graduationMessage: null,
        graduationEffects: null,
        triggeredEvent: null,
        yearlyEffects: null,
        yearlyMessage: null,
        failedYear: false,
      );
    }

    final currentSchool = _availableSchools.firstWhere(
        (s) => s.id == player.currentSchoolId,
        orElse: () {
          // This case should ideally not be reached if data is consistent.
          print("ERROR: Current school with ID ${player.currentSchoolId} not found for player. Resetting education status.");
          // TODO: Handle this error more gracefully, perhaps by setting player to EducationStage.none.
          // For now, throw to highlight the data inconsistency.
          throw Exception("Current school with ID ${player.currentSchoolId} not found for player.");
        });

    // Compute yearly focus effects and performance
    final focus = player.educationFocus;
    Map<String, num>? yearlyEffects;
    String? yearlyMessage;
    int perfDelta = 0;

    switch (focus) {
      case EducationFocus.study:
        yearlyEffects = { 'intelligence': 2, 'mood': -1 };
        yearlyMessage = 'You focused on studying this year.';
        perfDelta = 2;
        break;
      case EducationFocus.athletics:
        yearlyEffects = { 'strength': 2, 'health': 1, 'mood': 1 };
        yearlyMessage = 'You trained hard in athletics this year.';
        perfDelta = 1;
        break;
      case EducationFocus.social:
        yearlyEffects = { 'charisma': 2, 'social': 2, 'mood': 1 };
        yearlyMessage = 'You invested in your social life this year.';
        perfDelta = 1;
        break;
      case EducationFocus.work:
        yearlyEffects = { 'wealth': 200, 'mood': -1 };
        yearlyMessage = 'You worked a side job alongside school.';
        perfDelta = 0; // neutral for academics
        break;
      case EducationFocus.skip:
        yearlyEffects = { 'mood': 1 };
        yearlyMessage = 'You skipped classes too often this year.';
        perfDelta = -2;
        break;
    }

    int newPerf = (player.educationPerformance + perfDelta).clamp(-10, 100);

    // Failure chance if skipping frequently or very low performance
    bool failedYear = false;
    if (focus == EducationFocus.skip && newPerf <= -2) {
      failedYear = true;
      yearlyMessage = '${yearlyMessage ?? ''} You failed to advance this year.';
    }

    int newYearsInStage = failedYear ? (player.yearsInCurrentStage ?? 0) : (player.yearsInCurrentStage ?? 0) + 1;
    PlayerProfile updatedProfileBase = player.copyWith(
      yearsInCurrentStage: newYearsInStage,
      educationPerformance: newPerf,
    );
    String? graduationMessage;
    Map<String, num>? effectsToApply;
    MemoryEvent? triggeredGraduationEvent; 

    // TODO: Implement yearly school events (e.g., exams, projects, social events at school).
    // These could be fetched from MemoryEngineService based on tags like "education_highschool_year_1".
    // Such events could modify stats, traits, or relationships during the school year.

    // Check for graduation
    if (!failedYear && newYearsInStage >= currentSchool.typicalDurationInYears) {
      // Honors if performance high
      final honors = newPerf >= 6;
      graduationMessage = honors
          ? "Honors! You've graduated from ${currentSchool.name} (${educationStageToString(currentSchool.stage)})."
          : "Congratulations! You've graduated from ${currentSchool.name} (${educationStageToString(currentSchool.stage)})!";
      print(graduationMessage);

      effectsToApply = Map<String, num>.from(currentSchool.graduationEffects ?? {});
      if (honors) {
        // Small additional boost for honors
        effectsToApply.update('intelligence', (v) => v + 3, ifAbsent: () => 3);
        effectsToApply.update('confidence', (v) => v + 2, ifAbsent: () => 2);
      }

      updatedProfileBase = updatedProfileBase.copyWith(
        currentSchoolId: null, // No longer in this specific school instance
        clearCurrentSchoolId: true, // Ensure copyWith clears it
        currentEducationStage: currentSchool.nextStageOnGraduation ?? EducationStage.none, // Move to next stage or none
        yearsInCurrentStage: 0, // Reset for next stage
        completedEducationStages: [...updatedProfileBase.completedEducationStages, currentSchool.stage],
        // Reset performance for next stage
        educationPerformance: 0,
      );

      // TODO: Implement logic to fetch/create a specific graduation MemoryEvent.
      // This event could have its own choices (e.g., "Attend graduation party?", "Apply for jobs?").
      // Example:
      // if (_memoryEngineService != null) { // Check if service is injected
      //   triggeredGraduationEvent = await _memoryEngineService.getEventById(
      //     "graduation_${currentSchool.stage.name.toLowerCase().replaceAll(' ', '_')}",
      //     playerProfile: updatedProfileBase, // Pass the profile *after* education stage update
      //     appSettings: currentAppSettings, // This would need to be passed into progressYearInEducation
      //   );
      // }
      // For now, it remains null.
    }
    
    // TODO: Implement logic for failing a year or dropping out.
    // This could be based on stats (e.g., low intelligence), random chance, or specific events.
    // If failed, yearsInCurrentStage might not reset, or player might be expelled (flag set).

    return (
      updatedProfileBase: updatedProfileBase,
      graduationMessage: graduationMessage,
      graduationEffects: effectsToApply,
      triggeredEvent: triggeredGraduationEvent,
      yearlyEffects: yearlyEffects,
      yearlyMessage: yearlyMessage,
      failedYear: failedYear,
    );
  }
}
