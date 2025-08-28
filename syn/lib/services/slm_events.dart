import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// The official Firebase AI SDK for Flutter.
import 'package:firebase_ai/firebase_ai.dart';
import 'package:syn/models/memory_event.dart';
import 'package:syn/models/player_profile.dart';

// Provider for the SLMService.
final slmServiceProvider = Provider<SLMService>((ref) {
  // The service is now self-contained and initializes itself.
  return SLMService();
});

/// SLMService (Story and Lifecycle Manager) is responsible for generating
/// dynamic, AI-powered events that shape the player's life narrative.
class SLMService {
  // The generative AI model instance.
  final GenerativeModel _model;

  // Private constructor to initialize the model when the service is created.
  SLMService() : _model = _initializeModel();

  /// Configures and initializes the Gemini model with a strict JSON schema.
  /// This static method ensures the model is set up once.
  static GenerativeModel _initializeModel() {
    // This schema acts as a strict contract for the AI's output.
    // It forces the AI to return a response in a specific JSON format,
    // ensuring data consistency and preventing crashes from malformed data.
    final eventSchema = Schema.object(
      description:
          "A container for a list of generated game events. Must contain exactly one event.",
      properties: {
        'events': Schema.array(
          description: 'A list containing exactly one generated game event.',
          minItems: 1, // Enforce that the array is not empty.
          maxItems: 1, // Enforce that only one event is generated per call.
          items: Schema.object(
            properties: {
              'id': Schema.string(
                description:
                    'A unique, descriptive ID for the event in snake_case, e.g., "found_lost_wallet".',
              ),
              'age': Schema.integer(
                description: "The player's age at which this event occurs.",
              ),
              'summary': Schema.string(
                description: "A very brief, one-sentence summary of the event.",
              ),
              'description': Schema.string(
                description:
                    'The full narrative text describing the event scene and context.',
              ),
              'tags': Schema.array(
                description:
                    "A list of tags to categorize the event (e.g., 'social', 'work', 'crime', 'education').",
                items: Schema.string(),
              ),
              'nsfw': Schema.boolean(
                description: "Set to true if the event contains mature themes.",
              ),
              'choices': Schema.array(
                description:
                    'A list of 2 to 4 distinct choices the player can make.',
                minItems:
                    2, // CRITICAL: Force the AI to generate at least two choices.
                maxItems: 4, // Provide an upper bound for variety.
                items: Schema.object(
                  properties: {
                    'id': Schema.string(
                      description:
                          "A unique ID for this specific choice, e.g., 'return_wallet'.",
                    ),
                    'text': Schema.string(
                      description:
                          'The text for the choice presented to the player.',
                    ),
                    'nextEventId': Schema.string(
                      description:
                          "ID of a potential follow-up event, or 'null' if none.",
                    ),
                    'effects': Schema.object(
                      description:
                          "The direct impact of the choice on all relevant player stats. At least one stat must be affected. Unaffected stats can be omitted.",
                      properties: {
                        // UPDATED: The schema now includes all stats from PlayerStats.
                        'health': Schema.number(
                          description: 'Change in physical health.',
                        ),
                        'intelligence': Schema.number(
                          description:
                              'Change in logical and learning ability.',
                        ),
                        'charisma': Schema.number(
                          description: 'Change in charm and persuasiveness.',
                        ),
                        'libido': Schema.number(
                          description: 'Change in romantic or sexual drive.',
                        ),
                        'strength': Schema.number(
                          description: 'Change in physical power.',
                        ),
                        'creativity': Schema.number(
                          description:
                              'Change in artistic and innovative thinking.',
                        ),
                        'karma': Schema.number(
                          description:
                              'Moral alignment change. Positive for good, negative for bad.',
                        ),
                        'confidence': Schema.number(
                          description:
                              'Change in self-esteem and assertiveness.',
                        ),
                        'mood': Schema.number(
                          description: 'Temporary change in emotional state.',
                        ),
                        'social': Schema.number(
                          description:
                              'Change in social standing or connections.',
                        ),
                        'wealth': Schema.number(
                          description: 'Change in financial resources.',
                        ),
                        'happiness': Schema.number(
                          description: 'Change in overall life satisfaction.',
                        ),
                        'reputation': Schema.number(
                          description: 'Change in public perception.',
                        ),
                        'appearanceRating': Schema.number(
                          description: 'Change in physical appearance.',
                        ),
                        'wisdom': Schema.number(
                          description: 'Change in life experience and insight.',
                        ),
                      },
                    ),
                  },
                ),
              ),
            },
          ),
        ),
      },
    );

    // Initialize the model with the Gemini 1.5 Flash model for speed and efficiency.
    // The `generationConfig` forces the model to output valid JSON that matches our schema.
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-1.5-flash',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: eventSchema,
      ),
    );

    return model;
  }

  /// Generates a new `MemoryEvent` based on the player's current state.
  Future<MemoryEvent> generateRandomEvent(PlayerProfile playerProfile) async {
    final prompt = _buildPrompt(playerProfile);
    print(
      "--- SLM: Generating new event with the following prompt ---\n$prompt",
    );

    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      final responseText = response.text;
      if (responseText == null) {
        throw Exception('Received null or empty response from the AI model.');
      }

      print("--- SLM: Received raw AI response ---\n$responseText");
      final eventJson = jsonDecode(responseText);

      // The schema returns an object with an "events" array containing one event.
      // We access the first (and only) element of that array.
      final singleEventData = eventJson['events'].first;

      return MemoryEvent.fromJson(singleEventData as Map<String, dynamic>);
    } catch (e) {
      print(
        '--- SLM ERROR: Failed to generate or parse event content. ---\nError: $e',
      );
      // In a real app, you might want to return a fallback/error event instead of rethrowing.
      rethrow;
    }
  }

  /// Constructs the detailed, context-aware prompt for the AI model.
  String _buildPrompt(PlayerProfile playerProfile) {
    // Summarize the last few memories to give the AI recent context.
    final recentMemories = playerProfile.memories.length > 5
        ? playerProfile.memories.sublist(playerProfile.memories.length - 5)
        : playerProfile.memories;

    final memoriesSummary = recentMemories.isNotEmpty
        ? recentMemories.map((m) => '- ${m.summary}').join('\n')
        : 'No recent memories.';

    // The prompt is structured to give the AI a clear role, context, and strict instructions.
    return """
    You are the Story and Lifecycle Manager for SYN, a dark, synth-themed, cyberpunk-inspired life simulation game.
    Your mission is to generate a single, compelling, random life event for the player.
    The output MUST be a valid JSON object that strictly adheres to the provided schema.

    PLAYER CONTEXT:
    - Age: ${playerProfile.age}
    - Physical Stats: {Health: ${playerProfile.stats.health}, Strength: ${playerProfile.stats.strength}, Appearance: ${playerProfile.stats.appearanceRating}}
    - Mental Stats: {Intelligence: ${playerProfile.stats.intelligence}, Wisdom: ${playerProfile.stats.wisdom}, Creativity: ${playerProfile.stats.creativity}, Confidence: ${playerProfile.stats.confidence}}
    - Social Stats: {Charisma: ${playerProfile.stats.charisma}, Social: ${playerProfile.stats.social}, Reputation: ${playerProfile.stats.reputation}}
    - Meta Stats: {Karma: ${playerProfile.stats.karma}, Happiness: ${playerProfile.stats.happiness}, Wealth: ${playerProfile.stats.wealth}, Mood: ${playerProfile.stats.mood}, Libido: ${playerProfile.stats.libido}}
    - Recent Memories:
    $memoriesSummary

    INSTRUCTIONS:

    1.  Based on the player's context, create a new, random event. It could be a small daily occurrence, a social interaction, a personal challenge, or an unexpected opportunity that fits the dark, futuristic theme.
    2.  Provide AT LEAST TWO (2) and up to four (4) distinct, meaningful choices for the player.
    3.  For each choice, you MUST specify its impact in the 'effects' object. At least one stat must change. Use a mix of positive and negative effects. A choice can affect multiple stats.
    4.  Ensure the 'id', 'summary', and 'description' are creative and evocative.
    """;
  }
}
