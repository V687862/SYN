// lib/screens/memory_event_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_state_provider.dart';
import '../providers/app_screen_provider.dart'; // For fallback navigation
import '../models/app_screen.dart'; // For fallback navigation
import '../models/memory_event.dart'; // To access EventChoice
import '../ui/syn_kit.dart';

class MemoryEventScreen extends ConsumerWidget {
  const MemoryEventScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerProfile = ref.watch(playerStateProvider);
    final currentEvent = playerProfile.currentMemoryEvent;

    if (currentEvent == null) {
      // This screen should ideally not be visible if there's no current event.
      // Schedule a post-frame callback to navigate away safely.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check if the widget is still mounted before interacting with ref.
        if (context.mounted) {
          // FIXED: Use `resetTo` to clear the navigation history and go to the dashboard.
          ref.read(appScreenProvider.notifier).resetTo(AppScreen.dashboard);
          print(
            "MemoryEventScreen: No current event. Navigating to dashboard.",
          );
        }
      });
      // Show a loading or empty state while the navigation occurs.
      return const Scaffold(
        body: Center(
          child: Text(
            "Loading next state...",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // FIXED: Added a back button that uses the new pop method.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.read(appScreenProvider.notifier).pop(),
        ),
        title: Text(
          currentEvent.summary,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display Event Description
            GhostPanel(
              padding: const EdgeInsets.all(12.0),
              margin: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                currentEvent.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18),
              ),
            ),

            // Display Choices or Continue Button
            if (currentEvent.choices?.isNotEmpty ?? false)
              ...currentEvent.choices!.map((EventChoice choice) {
                return _buildChoiceButton(context, ref, choice);
              })
            else // If no choices, provide a "Continue" button
              _buildContinueButton(context, ref)
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(
      BuildContext context, WidgetRef ref, EventChoice choice) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DivButton(
        label: choice.text,
        icon: Icons.chevron_right,
        onPressed: () async {
          print(
            "--- UI: Choice '${choice.text}' (ID: ${choice.id}) Button Pressed ---",
          );
          // This method handles its own navigation logic (pushing a new event or popping).
          await ref.read(playerStateProvider.notifier).processEventChoice(choice);
        },
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DivButton(
        label: 'Continue',
        icon: Icons.check_circle_outline,
        onPressed: () {
          print("--- UI: Event Acknowledged (No Choices) ---");
          // First, update the player state to clear the event.
          ref.read(playerStateProvider.notifier).setCurrentMemoryEvent(null);
          // FIXED: Then, explicitly navigate back to the previous screen (dashboard).
          ref.read(appScreenProvider.notifier).pop();
        },
      ),
    );
  }
}
