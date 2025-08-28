// lib/services/age_service.dart

import '../models/player_profile.dart';
import '../models/settings.dart';
import '../models/memory_event.dart';
import 'memory_engine_service.dart';
// TODO: Consider importing other services if AgeService needs to coordinate more yearly updates
// e.g., import 'relationship_service.dart'; for NPC aging or relationship decay/progression.
// e.g., import 'job_service.dart'; if passive job progression/events happen yearly.

// A record to return the results of the aging process.
typedef AgeUpResult = ({
  int newAge,
  MemoryEvent? newEvent,
  bool isDeceased,            // Indicates if the player died this year
  String? deathReason,        // Optional reason such as 'old_age' or 'health_critical'
  // TODO: Expand AgeUpResult to include other yearly outcomes:
  // - List<String> yearlyMessages: General messages like "Happy Birthday!" or passive observations.
  // - List<NPCUpdate> npcUpdates: If NPCs age or their states change passively each year.
  // - FinancialUpdate financialUpdate: If there's yearly income/expenses not tied to specific events.
  // - HealthUpdate healthUpdate: Passive health changes due to age.
});

class AgeService {
  final MemoryEngineService _memoryEngineService;

  // Constructor: Injects the MemoryEngineService dependency.
  AgeService(this._memoryEngineService);

  // Processes the events and changes that occur when a player ages up by one year.
  Future<AgeUpResult> processNewYear({
    required PlayerProfile currentPlayerProfile,
    required AppSettings currentAppSettings,
    List<String> desiredEventTags = const [], // Optional: for specific event types this year
  }) async {
    print("AgeService: Processing new year for player ${currentPlayerProfile.name}, age ${currentPlayerProfile.age}.");

    // 1. Increment Player's Age
    final int newAge = currentPlayerProfile.age + 1;
    print("AgeService: Player new age will be $newAge.");

    // End-of-life check
    const int maxAge = 100; // Default maximum age; consider moving to settings later
    if (currentPlayerProfile.stats.health <= 0) {
      print("AgeService: Player has died due to critical health.");
      return (
        newAge: newAge,
        newEvent: null,
        isDeceased: true,
        deathReason: 'health_critical',
      );
    }

    if (newAge > maxAge) {
      print("AgeService: Player has reached end of life due to old age.");
      return (
        newAge: maxAge, // Cap age at max for summary consistency
        newEvent: null,
        isDeceased: true,
        deathReason: 'old_age',
      );
    }

    // Create a temporary updated profile for fetching events,
    // as the MemoryEngineService might need the new age.
    final profileForEventFetching = currentPlayerProfile.copyWith(age: newAge);

    // 2. Determine New Available Events using MemoryEngineService
    MemoryEvent? newEvent;
    try {
      // TODO: Consider if 'desiredEventTags' should be dynamically determined here.
      //       For example, based on player's current job, education stage, active flags, or relationship statuses.
      //       This could involve more complex logic to build the desiredTags list before calling getMemoryEvent.
      newEvent = await _memoryEngineService.getMemoryEvent(
        playerProfile: profileForEventFetching,
        appSettings: currentAppSettings,
        desiredTags: desiredEventTags,
      );

      if (newEvent != null) {
        print("AgeService: New event found for age $newAge: ${newEvent.summary}");
      } else {
        print("AgeService: No new event found for age $newAge with tags $desiredEventTags.");
        // TODO: Implement logic for years where no major event occurs.
        //       - Could trigger a minor, generic "uneventful year" event.
        //       - Could have a higher chance of passive stat changes or relationship drifts.
      }
    } catch (e) {
      print("AgeService: Error fetching memory event - $e");
      // TODO: More robust error handling for event fetching.
      //       Should this error be propagated? Should it prevent the year from advancing?
      //       For now, it proceeds with a null event.
      newEvent = null;
    }

    // 3. Potentially handle other yearly logic here (e.g., NPC aging, passive stat decay/growth)
    // TODO: NPC Aging:
    //       - If NPCs age, iterate through `currentPlayerProfile.relationships` and increment their age.
    //       - Handle NPC death due to old age or other factors.
    //       - This might involve a separate `RelationshipService.processYearlyNpcUpdates()`.

    // TODO: Passive Stat Changes:
    //       - Implement logic for stats to change passively with age (e.g., health might slowly decline after a certain age,
    //         intelligence might increase during formative years even without specific events).
    //       - This could be a set of rules or small random adjustments.

    // TODO: Relationship Metric Decay/Growth:
    //       - Affection/trust with NPCs might passively decay if not maintained, or grow if certain conditions are met.
    //       - Example: `RelationshipService.updatePassiveRelationshipChanges()`.

    // TODO: Financial Updates (if an economy system is implemented):
    //       - Passive income (e.g., investments if implemented).
    //       - Yearly living expenses.

    // TODO: Health Deterioration/Improvement:
    //       - Passive health changes based on age, lifestyle flags, etc.

    // TODO: Check for recurring events or conditions:
    //       - e.g., yearly holidays, anniversaries, subscription renewals.

    // TODO: Update Player Flags:
    //       - Some flags might expire or change based on age (e.g., "is_teenager" flag).

    // The results of these other yearly logic updates would ideally be collected and
    // returned as part of an expanded AgeUpResult. The PlayerStateNotifier would then
    // apply all these changes to the player's state.

      // Return the results.
      return (
        newAge: newAge,
        newEvent: newEvent,
        isDeceased: false,
        deathReason: null,
        // TODO: Populate other fields in AgeUpResult as they are implemented (yearlyMessages, npcUpdates etc.)
      );
    }

  // TODO: Consider adding other methods to AgeService if more complex age-related logic is needed.
  // For example:
  // - `checkLifeMilestones(PlayerProfile player)`: To see if certain age-based milestones are reached (e.g., legal adult, retirement age).
  // - `calculateLifespan(PlayerProfile player)`: If you want a dynamic lifespan based on health, lifestyle etc.
}
