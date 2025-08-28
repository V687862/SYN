    // lib/models/action_log_entry.dart

    class ActionLogEntry {
      final String id; // Unique ID for the log entry (e.g., timestamp or UUID)
      final int playerAge;
      final String eventId; // ID of the MemoryEvent this choice belonged to
      final String eventSummary; // Summary of the event
      final String choiceId; // ID of the EventChoice taken
      final String choiceText; // Text of the choice taken
      final String? outcomeDescription; // Outcome description from the EventChoice
      // You could add more details like stats changed, flags set/removed, etc.

      const ActionLogEntry({
        required this.id,
        required this.playerAge,
        required this.eventId,
        required this.eventSummary,
        required this.choiceId,
        required this.choiceText,
        this.outcomeDescription,
      });

      // For potential future use (e.g., saving/loading logs, though often logs are transient per session)
      factory ActionLogEntry.fromJson(Map<String, dynamic> json) {
        return ActionLogEntry(
          id: json['id'] as String,
          playerAge: json['playerAge'] as int,
          eventId: json['eventId'] as String,
          eventSummary: json['eventSummary'] as String,
          choiceId: json['choiceId'] as String,
          choiceText: json['choiceText'] as String,
          outcomeDescription: json['outcomeDescription'] as String?,
        );
      }

      Map<String, dynamic> toJson() => {
            'id': id,
            'playerAge': playerAge,
            'eventId': eventId,
            'eventSummary': eventSummary,
            'choiceId': choiceId,
            'choiceText': choiceText,
            if (outcomeDescription != null) 'outcomeDescription': outcomeDescription,
          };
    }
    