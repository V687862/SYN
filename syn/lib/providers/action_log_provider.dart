        // lib/providers/action_log_provider.dart
        import 'package:flutter_riverpod/flutter_riverpod.dart';
        import '../models/action_log_entry.dart'; // Ensure this path is correct

        class ActionLogNotifier extends StateNotifier<List<ActionLogEntry>> {
          ActionLogNotifier() : super([]);

          void addLog(ActionLogEntry entry) {
            state = [entry, ...state]; // Prepend to keep newest logs first
          }

          void clearLog() {
            state = [];
          }
        }

        final actionLogProvider = StateNotifierProvider<ActionLogNotifier, List<ActionLogEntry>>((ref) {
          return ActionLogNotifier();
        });
        