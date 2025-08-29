import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart'; // For BuildContext
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/player_profile.dart';
import '../models/game_phase.dart';
import '../models/memory_event.dart';
import '../models/player_stats.dart';
import '../models/settings.dart';
import '../services/age_service.dart';
import '../services/memory_engine_service.dart';
import '../services/education_service.dart';
import '../models/education_stage.dart';
import '../models/action_log_entry.dart';
import 'action_log_provider.dart';
import '../models/app_screen.dart';
import 'app_screen_provider.dart';
import '../widgets/life_stage_transition_modal.dart';
import '../widgets/stat_stream.dart';
import '../models/dynamic_modifiers.dart'; // Import the modifier model
import '../models/education_focus.dart';
import '../services/relationship_service.dart';
import '../services/social_engine_service.dart';

// --- Riverpod Providers for Services ---
final memoryEngineServiceProvider = Provider<MemoryEngineService>((ref) {
  return MemoryEngineService();
});

final ageServiceProvider = Provider<AgeService>((ref) {
  final memoryEngine = ref.watch(memoryEngineServiceProvider);
  return AgeService(memoryEngine);
});

final appSettingsProvider = StateProvider<AppSettings>((ref) {
  return const AppSettings();
});

final educationServiceProvider = Provider<EducationService>((ref) {
  return EducationService();
});

const uuid = Uuid();

// --- Enhanced PlayerStateNotifier ---
class PlayerStateNotifier extends StateNotifier<PlayerProfile> {
  final Ref _ref;

  PlayerStateNotifier(this._ref) : super(PlayerProfile.initial()) {
    loadPlayerProfile();
  }

  // --- Education operations ---
  Future<void> enrollInSchool(String schoolId) async {
    final educationService = _ref.read(educationServiceProvider);
    try {
      final updated = educationService.enrollInSchool(state, schoolId);
      state = updated;
    } catch (e) {
      debugPrint('Enroll failed: $e');
    }
  }

  void setEducationFocus(EducationFocus focus) {
    state = state.copyWith(educationFocus: focus);
  }

  void showLifeStageTransition(BuildContext context, int oldAge, int newAge) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LifeStageTransitionModal(
          oldAge: oldAge,
          newAge: newAge,
        );
      },
    );
  }

  // This function applies stat effects from events, choices, and active modifiers.
  PlayerStats _applyStatEffects(PlayerStats currentStats, Map<String, num> effects) {
    final modifierEffects = <String, num>{};
    for (var modifier in state.activeModifiers) {
      modifier.statEffects.forEach((key, value) {
        modifierEffects.update(key, (existing) => existing + value, ifAbsent: () => value);
      });
    }

    final combinedEffects = Map<String, num>.from(effects);
    modifierEffects.forEach((key, value) {
      combinedEffects.update(key, (existing) => existing + value, ifAbsent: () => value);
    });

    PlayerStats newStats = currentStats;
    combinedEffects.forEach((statKey, value) {
      final String normalizedKey = statKey.toLowerCase().replaceAll('rating', '');
      num currentValue;
      switch (normalizedKey) {
        case 'health':
          currentValue = newStats.health;
          newStats = newStats.copyWith(health: (currentValue + value).clamp(0, 100).toInt());
          break;
        case 'intelligence':
          currentValue = newStats.intelligence;
          newStats = newStats.copyWith(intelligence: (currentValue + value).clamp(0, 100).toInt());
          break;
        case 'charisma':
          currentValue = newStats.charisma;
          newStats = newStats.copyWith(charisma: (currentValue + value).clamp(0, 100).toInt());
          break;
        case 'libido':
          currentValue = newStats.libido;
          newStats = newStats.copyWith(libido: (currentValue + value).clamp(0, 100).toInt());
          break;
        case 'strength':
          currentValue = newStats.strength;
          newStats = newStats.copyWith(strength: (currentValue + value).clamp(0, 100).toInt());
          break;
        case 'creativity':
          currentValue = newStats.creativity;
          newStats = newStats.copyWith(creativity: (currentValue + value).clamp(0, 100).toInt());
          break;
        case 'karma':
          currentValue = newStats.karma;
          newStats = newStats.copyWith(karma: (currentValue + value).clamp(-100, 100).toInt());
          break;
        case 'confidence':
          currentValue = newStats.confidence;
          newStats = newStats.copyWith(confidence: (currentValue + value).clamp(0, 100).toInt());
          break;
        case 'mood':
          currentValue = newStats.mood;
          newStats = newStats.copyWith(mood: (currentValue + value).clamp(0, 100).toInt());
          break;
        case 'social':
          currentValue = newStats.social;
          newStats = newStats.copyWith(social: (currentValue + value).clamp(0, 100).toInt());
          break;
        case 'wealth':
          currentValue = newStats.wealth;
          newStats = newStats.copyWith(wealth: (currentValue + value).toInt());
          break;
        case 'happiness':
          currentValue = newStats.happiness;
          newStats = newStats.copyWith(happiness: (currentValue + value).clamp(0, 100).toInt());
          break;
        case 'reputation':
          currentValue = newStats.reputation;
          newStats = newStats.copyWith(reputation: (currentValue + value).clamp(0, 100).toInt());
          break;
        case 'appearancerating':
        case 'appearance':
          currentValue = newStats.appearanceRating;
          newStats = newStats.copyWith(appearanceRating: (currentValue + value).clamp(0, 100).toInt());
          break;
        case 'wisdom':
          currentValue = newStats.wisdom;
          newStats = newStats.copyWith(wisdom: (currentValue + value).clamp(0, 100).toInt());
          break;
        default:
          print("PlayerStateNotifier: Unknown stat key '$normalizedKey' in effects. Skipping.");
      }
    });
    return newStats;
  }

  void applyEffectsFromMemoryEvent(MemoryEvent event) {
    if (event.effects == null || event.effects!.isEmpty) {
      return;
    }
    final newStats = _applyStatEffects(state.stats, event.effects!);
    state = state.copyWith(stats: newStats);
  }

  Future<void> processEventChoice(EventChoice selectedChoice) async {
    if (state.currentMemoryEvent == null) {
      _ref.read(appScreenProvider.notifier).resetTo(AppScreen.dashboard);
      return;
    }
    final originalEvent = state.currentMemoryEvent!;
    PlayerProfile updatedProfile = state;

    if (selectedChoice.effects != null && selectedChoice.effects!.isNotEmpty) {
      final newStats = _applyStatEffects(updatedProfile.stats, selectedChoice.effects!);
      updatedProfile = updatedProfile.copyWith(stats: newStats);
    }
    // Apply relationship effects if present
    if (selectedChoice.relationshipEffects != null &&
        selectedChoice.relationshipEffects!.isNotEmpty) {
      final relSvc = RelationshipService();
      updatedProfile = relSvc.applyRelationshipEffects(
          updatedProfile, selectedChoice.relationshipEffects!);
    }
    
    final logEntry = ActionLogEntry(
      id: uuid.v4(),
      playerAge: updatedProfile.age,
      eventId: originalEvent.id,
      eventSummary: originalEvent.description,
      choiceId: selectedChoice.id,
      choiceText: selectedChoice.text,
      outcomeDescription: selectedChoice.outcomeDescription,
    );
    _ref.read(actionLogProvider.notifier).addLog(logEntry);
    
    final updatedMemories = List<MemoryEvent>.from(updatedProfile.memories)..add(originalEvent);
    
    updatedProfile = updatedProfile.copyWith(
      memories: updatedMemories,
      clearCurrentMemoryEvent: true,
      currentPhase: GamePhase.year,
    );

    state = updatedProfile;
    _ref.read(appScreenProvider.notifier).resetTo(AppScreen.dashboard);
  }

  void startNewLife(PlayerProfile newProfile) {
    state = newProfile;
    _ref.read(actionLogProvider.notifier).clearLog();
  }

  // This method now safely processes active modifiers before aging up.
  Future<void> advanceYear({required BuildContext context}) async {
    final int oldAge = state.age;

    // --- FIX: Modifier Processing Logic ---
    // Use a standard loop for clarity and null safety.
    final List<DynamicModifier> nextYearModifiers = [];
    for (final modifier in state.activeModifiers) {
      final tickedModifier = modifier.tickDown();
      if (tickedModifier.duration > 0) {
        nextYearModifiers.add(tickedModifier);
      }
    }

    PlayerProfile profileForAging = state.copyWith(activeModifiers: nextYearModifiers);

    // Yearly relationship decay + compatibility updates
    final relSvc = RelationshipService();
    profileForAging = relSvc.tickYearDecay(profileForAging);
    profileForAging = relSvc.recomputeCompatibility(profileForAging);
    
    final ageService = _ref.read(ageServiceProvider);
    final educationService = _ref.read(educationServiceProvider);
    final appSettings = _ref.read(appSettingsProvider);
    final ageUpResult = await ageService.processNewYear(
      currentPlayerProfile: profileForAging,
      currentAppSettings: appSettings,
    );
    
    // Handle end-of-life transition immediately
    if (ageUpResult.isDeceased) {
      final int finalAge = ageUpResult.newAge;
      PlayerProfile deceasedProfile = profileForAging.copyWith(
        age: finalAge,
        currentPhase: GamePhase.summary,
        clearCurrentMemoryEvent: true,
      );
      state = deceasedProfile;
      _ref.read(appScreenProvider.notifier).resetTo(AppScreen.dashboard);
      return;
    }

    final int newAge = ageUpResult.newAge;

    final LifeStage oldStage = getLifeStage(oldAge);
    final LifeStage newStage = getLifeStage(newAge);

    if (oldStage != newStage) {
      showLifeStageTransition(context, oldAge, newAge);
    }

    PlayerProfile newProfile = profileForAging.copyWith(age: newAge);

    // Education progression (auto-enroll through high school)
    if ((newProfile.currentSchoolId == null || newProfile.currentEducationStage == EducationStage.none) &&
        newProfile.currentEducationStage != EducationStage.graduatedHighSchool) {
      // Stages to auto-enroll before post-secondary options
      final autoStages = <EducationStage>[
        EducationStage.preschool,
        EducationStage.elementarySchool,
        EducationStage.middleSchool,
        EducationStage.highSchool,
      ];

      // Choose the most advanced stage suitable for the player's age
      for (final stage in autoStages.reversed) {
        // Skip if already completed this stage
        if (newProfile.completedEducationStages.contains(stage)) continue;

        final school = educationService.getSchoolByStage(stage);
        if (school != null && newAge >= school.minAgeToEnroll) {
          newProfile = educationService.enrollInSchool(newProfile, school.id);
          break; // enroll only one stage at a time
        }
      }
    }

    // Process yearly education progression (handles graduation updates and effects)
    final eduResult = educationService.progressYearInEducation(newProfile);
    newProfile = eduResult.updatedProfileBase;

    // Apply yearly school effects based on focus
    if (eduResult.yearlyEffects != null && eduResult.yearlyEffects!.isNotEmpty) {
      final newStats = _applyStatEffects(newProfile.stats, eduResult.yearlyEffects!);
      newProfile = newProfile.copyWith(stats: newStats);
    }

    if (eduResult.graduationEffects != null && eduResult.graduationEffects!.isNotEmpty) {
      final newStats = _applyStatEffects(newProfile.stats, eduResult.graduationEffects!);
      newProfile = newProfile.copyWith(stats: newStats);
    }

    // Determine event for the year, preferring age-driven event, then education-triggered event
    MemoryEvent? finalEventForYear = ageUpResult.newEvent ?? eduResult.triggeredEvent ?? newProfile.currentMemoryEvent;

    // If still none, allow an NPC-initiated social event via the social engine
    if (finalEventForYear == null) {
      final social = _ref.read(socialEngineServiceProvider);
      final npcEvent = await social.maybeNpcInitiatedEvent(newProfile, appSettings);
      finalEventForYear = npcEvent ?? finalEventForYear;
    }
    newProfile = newProfile.copyWith(currentMemoryEvent: finalEventForYear);

    if (newProfile.currentMemoryEvent != null) {
        newProfile = newProfile.copyWith(currentPhase: GamePhase.memory);
        if (newProfile.currentMemoryEvent == ageUpResult.newEvent &&
            (newProfile.currentMemoryEvent!.effects?.isNotEmpty ?? false)) {
            final newStats = _applyStatEffects(newProfile.stats, newProfile.currentMemoryEvent!.effects!);
            newProfile = newProfile.copyWith(stats: newStats);
        }
    } else {
        newProfile = newProfile.copyWith(currentPhase: GamePhase.year);
    }
    
    state = newProfile;
    _ref.read(appScreenProvider.notifier).resetTo(AppScreen.dashboard);
  }
  
  void setPlayerName(String name) => state = state.copyWith(name: name);
  void setPlayerGender(String gender) => state = state.copyWith(gender: gender);
  void setPlayerCountryCode(String countryCode) => state = state.copyWith(countryCode: countryCode);
  void setPlayerPronouns(String? pronouns) => state = state.copyWith(pronouns: pronouns);

  void setGamePhase(GamePhase phase) {
      if (phase == GamePhase.year && state.currentMemoryEvent != null) {
          state = state.copyWith(currentPhase: phase, clearCurrentMemoryEvent: true);
      } else {
          state = state.copyWith(currentPhase: phase);
      }
  }
  
  void setCurrentMemoryEvent(MemoryEvent? event) {
    if (event == null) {
      state = state.copyWith(clearCurrentMemoryEvent: true, currentPhase: GamePhase.year);
    } else {
      state = state.copyWith(currentMemoryEvent: event, currentPhase: GamePhase.memory);
    }
  }
  
  void resetToNewLife() {
    state = PlayerProfile.initial();
    _ref.read(actionLogProvider.notifier).clearLog();
    _ref.read(appScreenProvider.notifier).resetTo(AppScreen.newLife);
  }
  
  Future<void> savePlayerProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playerJson = state.toJson();
      final playerString = jsonEncode(playerJson);
      await prefs.setString('playerProfileSave', playerString);
      print("--- Player Profile Saved Successfully ---");
    } catch (e) {
      print("--- Error Saving Player Profile: $e ---");
    }
  }

  Future<void> loadPlayerProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playerString = prefs.getString('playerProfileSave');
      
      if (playerString == null) {
        print("--- No saved profile found. Starting new life. ---");
        state = PlayerProfile.initial();
        return;
      }
      
      final playerJson = jsonDecode(playerString);
      final loadedProfile = PlayerProfile.fromJson(playerJson as Map<String, dynamic>);
      
      state = loadedProfile;
      print("--- Player Profile Loaded Successfully ---");

    } catch (e) {
      print("--- Error Loading Player Profile: $e ---");
      state = PlayerProfile.initial();
    }
  }
}

final playerStateProvider = StateNotifierProvider<PlayerStateNotifier, PlayerProfile>((ref) {
  return PlayerStateNotifier(ref);
});
