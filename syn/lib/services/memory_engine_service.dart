// lib/services/memory_engine_service.dart

import 'dart:convert'; // For JSON decoding
import 'dart:math';   // For random selection
import 'package:flutter/services.dart' show rootBundle; // For loading assets

// Import your data models
import '../models/memory_event.dart';   // Contains MemoryEvent, MemoryTemplate, and EventChoice
import '../models/player_profile.dart'; // Needed for player's age and other conditions
import '../models/settings.dart';       // For AppSettings, including nsfwEnabled
// TODO: Consider importing PlayerStats directly if complex stat checks are done here.
// import '../models/player_stats.dart';

// Service responsible for loading, filtering, and providing memory events.
class MemoryEngineService {
  List<MemoryTemplate>? _memoryPool;
  bool _isLoading = false;

  // TODO: Implement a mechanism to refresh or reload memories if the underlying JSON can change during gameplay (e.g., mods, updates).
  // TODO: Consider error reporting strategies beyond print statements for loading failures (e.g., reporting to an analytics service or a user-facing error state).
  Future<void> _loadMemories() async {
    if (_memoryPool != null || _isLoading) return;
    _isLoading = true;
    print("MemoryEngineService: Starting to load memories...");
    try {
      // TODO: Allow loading memories from different sources (e.g., user-generated content, DLC packs) by making the path configurable or accepting multiple paths.
      final jsonString = await rootBundle.loadString('assets/data/memories.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _memoryPool = jsonList
          .map((data) => MemoryTemplate.fromJson(data as Map<String, dynamic>))
          .toList();
      print("MemoryEngineService: Successfully loaded ${_memoryPool?.length ?? 0} memory templates.");
    } catch (e) {
      print("MemoryEngineService: Error loading memories - $e");
      _memoryPool = []; // Initialize to empty list to prevent null issues on subsequent calls.
      // TODO: Propagate this error or set a state indicating that memories failed to load, so the game can react accordingly (e.g., show an error message to the player).
    } finally {
      _isLoading = false;
    }
  }

  // Fetches a random eligible memory event based on player profile and settings.
  Future<MemoryEvent?> getMemoryEvent({
    required PlayerProfile playerProfile,
    required AppSettings appSettings,
    List<String> desiredTags = const [],
    // TODO: Add parameter for 'contextualTags' (e.g., current location, current activity) to allow for more dynamic event selection.
    // TODO: Add parameter for 'excludedEventIds' to prevent recently seen events from reappearing too soon.
  }) async {
    await _loadMemories();
    if (_memoryPool == null || _memoryPool!.isEmpty) {
      print("MemoryEngineService: No memory templates available to select from.");
      return null;
    }

    final currentPlayerAge = playerProfile.age;
    final nsfwEnabled = appSettings.nsfwEnabled;

    // TODO: Implement a more sophisticated event weighting/priority system instead of pure random selection.
    //       Some events might be rarer or more important based on game state or player progression.
    final eligibleTemplates = _memoryPool!.where((memTemplate) {
      // 1. Age Range Check
      final ageMatch = currentPlayerAge >= memTemplate.ageRange[0] &&
                       currentPlayerAge <= memTemplate.ageRange[1];
      if (!ageMatch) return false;

      // 2. NSFW Check
      final nsfwOk = nsfwEnabled || !(memTemplate.nsfw ?? false);
      if (!nsfwOk) return false;

      // 3. Desired Tags Check
      final desiredTagMatch = desiredTags.isEmpty ||
                             memTemplate.tags.any((t) => desiredTags.contains(t));
      if (!desiredTagMatch) return false;
      
      // --- GDD-based Filtering Enhancements (TODOs) ---
      // TODO: Implement Gender-based filtering:
      //       - Add `genderCondition` (e.g., "male", "female", "any", "not_male") to MemoryTemplate and memories.json.
      //       - Filter: if (memTemplate.genderCondition != null && !checkGenderCondition(playerProfile.gender, memTemplate.genderCondition)) return false;

      // TODO: Implement Country-based filtering:
      //       - Add `countryCondition` (e.g., "US", "IN", "NOT_US") or `allowedCountries: List<String>` to MemoryTemplate.
      //       - Filter: if (memTemplate.countryCondition != null && !checkCountryCondition(playerProfile.countryCode, memTemplate.countryCondition)) return false;

      // TODO: Implement Trait-based filtering:
      //       - Add `requiredTraits: List<String>?` and `forbiddenTraits: List<String>?` to MemoryTemplate.
      //       - Filter: if (memTemplate.requiredTraits != null && !memTemplate.requiredTraits!.every((trait) => playerProfile.traits.contains(trait))) return false;
      //       - Filter: if (memTemplate.forbiddenTraits != null && memTemplate.forbiddenTraits!.any((trait) => playerProfile.traits.contains(trait))) return false;

      // TODO: Implement Stat-based filtering (more complex conditions):
      //       - Add `statConditions: Map<String, Map<String, num>>?` to MemoryTemplate (e.g., {"intelligence": {"min": 50, "max": 70}, "libido": {"min": 60}}).
      //       - Filter: if (memTemplate.statConditions != null && !checkStatConditions(playerProfile.stats, memTemplate.statConditions!)) return false;
      //         (This would require a helper function `checkStatConditions`).

      // TODO: Implement Player Flag-based filtering:
      //       - Add `requiredFlags: List<String>?` and `forbiddenFlags: List<String>?` to MemoryTemplate.
      //       - Filter: if (memTemplate.requiredFlags != null && !memTemplate.requiredFlags!.every((flag) => playerProfile.flags.contains(flag))) return false;
      //       - Filter: if (memTemplate.forbiddenFlags != null && memTemplate.forbiddenFlags!.any((flag) => playerProfile.flags.contains(flag))) return false;
      
      // TODO: Implement "hidden" tag filtering or prerequisite event completion checks.
      //       Some events should only appear if another specific event (or one with a certain tag) has already occurred.
      //       - Add `prerequisiteEventIds: List<String>?` or `prerequisiteEventTags: List<String>?` to MemoryTemplate.
      //       - Check against player's memory log (ActionLog).

      return true;
    }).toList();

    if (eligibleTemplates.isEmpty) {
      print(
          "MemoryEngineService: No eligible memories found for age $currentPlayerAge, nsfw: $nsfwEnabled, tags: $desiredTags.");
      // TODO: Consider if a "fallback" or "generic" event should be returned if no specific eligible event is found, to ensure gameplay continues.
      return null;
    }

    final random = Random();
    final selectedTemplate = eligibleTemplates[random.nextInt(eligibleTemplates.length)];
    // TODO: Implement logic to prevent immediate repetition of the same event if desired.

    print("MemoryEngineService: Selected event '${selectedTemplate.id}' for age $currentPlayerAge.");
    return MemoryEvent(
      id: selectedTemplate.id,
      age: currentPlayerAge,
      summary: selectedTemplate.summary,
      description: selectedTemplate.description, // TODO: Implement localization for summary & description.
      tags: selectedTemplate.tags,
      effects: selectedTemplate.effects,
      nsfw: selectedTemplate.nsfw,
      choices: selectedTemplate.choices?.map((choiceTemplate) { // Ensure choices are also mapped correctly
        // TODO: Implement localization for choice.text and choice.outcomeDescription.
        return EventChoice(
          id: choiceTemplate.id,
          text: choiceTemplate.text,
          effects: choiceTemplate.effects,
          outcomeDescription: choiceTemplate.outcomeDescription,
          flagsSet: choiceTemplate.flagsSet,
          flagsRemoved: choiceTemplate.flagsRemoved,
          triggeredEventId: choiceTemplate.triggeredEventId,
          relationshipEffects: choiceTemplate.relationshipEffects,
        );
      }).toList(),
    );
  }

  // Fetches a specific memory template by its ID and converts it to a MemoryEvent.
  Future<MemoryEvent?> getEventById(String eventId, { required PlayerProfile playerProfile, required AppSettings appSettings }) async {
    await _loadMemories();
    if (_memoryPool == null || _memoryPool!.isEmpty) {
      print("MemoryEngineService: Memory pool not loaded or empty, cannot get event by ID: $eventId");
      return null;
    }

    try {
      final MemoryTemplate selectedTemplate = _memoryPool!.firstWhere(
        (template) => template.id == eventId,
      ); // firstWhere throws StateError if not found, which is caught below.

      // Perform eligibility checks even for specifically triggered events.
      // This prevents a triggered event from appearing if conditions have changed (e.g., player no longer meets flag requirements).
      final nsfwOk = appSettings.nsfwEnabled || !(selectedTemplate.nsfw ?? false);
      if (!nsfwOk) {
        print("MemoryEngineService: Triggered event '$eventId' is NSFW but NSFW is disabled. Skipping.");
        return null;
      }

      // TODO: Add more comprehensive eligibility checks for specifically triggered events:
      //       - Check `requiredFlags`, `forbiddenFlags` against `playerProfile.flags`.
      //       - Check `statConditions` against `playerProfile.stats`.
      //       - Check `genderCondition`, `countryCondition` etc.
      //       If any condition is not met, this specific event should not be triggered, return null.
      //       This is important because the game state might have changed between the point the event was
      //       set to trigger and when it's actually being fetched.

      print("MemoryEngineService: Found specific event template by ID: $eventId");
      return MemoryEvent(
        id: selectedTemplate.id,
        age: playerProfile.age, // Event occurs at the player's current age when triggered
        summary: selectedTemplate.summary, // TODO: Localization
        description: selectedTemplate.description, // TODO: Localization
        tags: selectedTemplate.tags,
        effects: selectedTemplate.effects,
        nsfw: selectedTemplate.nsfw,
        choices: selectedTemplate.choices?.map((choiceTemplate) { // Ensure choices are mapped
           // TODO: Implement localization for choice.text and choice.outcomeDescription.
          return EventChoice(
            id: choiceTemplate.id,
            text: choiceTemplate.text,
            effects: choiceTemplate.effects,
            outcomeDescription: choiceTemplate.outcomeDescription,
            flagsSet: choiceTemplate.flagsSet,
            flagsRemoved: choiceTemplate.flagsRemoved,
            triggeredEventId: choiceTemplate.triggeredEventId,
            relationshipEffects: choiceTemplate.relationshipEffects,
          );
        }).toList(),
      );
    } catch (e) { // Catches StateError from firstWhere if no element is found
      print("MemoryEngineService: No event template found with ID '$eventId' or error during processing: $e");
      // TODO: Decide if this should throw an error further up or just return null.
      //       If a triggeredEventId is crucial and not found, it might indicate a content error.
      return null;
    }
  }

  // TODO: Consider adding a method to validate the entire _memoryPool after loading,
  //       checking for schema errors, duplicate IDs, broken triggeredEventId chains, etc.
  //       This could be run during development or as a debug option.
}

