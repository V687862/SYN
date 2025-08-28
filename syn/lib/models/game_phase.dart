// lib/models/game_phase.dart
// Corresponds to currentPhase in Svelte's PlayerProfile and general game states
enum GamePhase {
  newLife, // Character creation
  year,    // Main gameplay, yearly cycle
  memory,  // Viewing/interacting with a specific memory/event
  freeform,// (If this is a distinct phase from your GDD)
  summary, // End of life summary
  relationship,
  job
  // Add others if needed
}