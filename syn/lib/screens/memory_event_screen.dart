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
                return _buildChoiceButton(context, ref, choice, playerProfile);
              })
            else // If no choices, provide a "Continue" button
              _buildContinueButton(context, ref)
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(
      BuildContext context, WidgetRef ref, EventChoice choice, final playerProfile) {
    // Simple gating based on optional 'requires' metadata
    bool eligible = true;
    String? reason;
    final req = choice.requires;
    if (req != null) {
      // minStats
      final minStats = req['minStats'];
      if (minStats is Map) {
        for (final entry in minStats.entries) {
          final key = entry.key.toString();
          final min = (entry.value as num).toDouble();
          final v = _statValue(playerProfile, key);
          if (v < min) { eligible = false; reason = 'Requires $key ≥ ${min.toInt()}'; break; }
        }
      }
      // relationship
      if (eligible && req['relationship'] is Map) {
        final r = Map<String, dynamic>.from(req['relationship'] as Map);
        final role = (r['role'] as String?)?.toLowerCase();
        final stage = (r['stage'] as String?);
        final minAff = (r['minAffection'] as num?)?.toDouble();
        final minTr = (r['minTrust'] as num?)?.toDouble();
        final minCompat = (r['minSexCompatibility'] as num?)?.toDouble();
        final minJeal = (r['minJealousy'] as num?)?.toDouble();
        final maxJeal = (r['maxJealousy'] as num?)?.toDouble();
        final npcId = r['npcId'] as String?; // optional specific target
        bool found = false;
        for (final n in playerProfile.relationships) {
          if (npcId != null && n.id != npcId) continue;
          if (role != null && n.role.name.toLowerCase() != role) continue;
          if (stage != null && n.stage.name.toLowerCase() != stage.toLowerCase()) continue;
          if (minAff != null && n.affection < minAff) continue;
          if (minTr != null && n.trust < minTr) continue;
          if (minCompat != null && n.sexCompatibility < minCompat) continue;
          if (minJeal != null && n.jealousy < minJeal) continue;
          if (maxJeal != null && n.jealousy > maxJeal) continue;
          found = true; break;
        }
        if (!found) { eligible = false; reason = 'Relationship requirement not met'; }
      }
    }

    // Relationship preview (actor)
    String? affectsName;
    if (choice.relationshipEffects != null) {
      try {
        final eff = choice.relationshipEffects!
            .firstWhere((e) => (e['targetType'] as String?)?.toLowerCase() == 'id');
        final id = eff['targetValue'] as String?;
        if (id != null) {
          final npc = playerProfile.relationships.firstWhere((n) => n.id == id, orElse: () => null);
          if (npc != null) affectsName = npc.name;
        }
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DivButton(
            label: choice.text,
            icon: Icons.chevron_right,
            enabled: eligible,
            disabledReason: reason,
            onPressed: eligible
                ? () async {
                    // Relationship change toast (preview)
                    if (choice.relationshipEffects != null &&
                        choice.relationshipEffects!.isNotEmpty) {
                      final preview = _relationshipDeltaPreview(playerProfile, choice);
                      if (preview != null) {
                        Toast.info(context, preview);
                      }
                    }
                    await ref
                        .read(playerStateProvider.notifier)
                        .processEventChoice(choice);
                  }
                : null,
          ),
          if (affectsName != null) ...[
            const SizedBox(height: 4),
            const HintText('Affects:'),
            Text(affectsName,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 12)),
          ]
        ],
      ),
    );
  }

  double _statValue(final playerProfile, String key) {
    final s = playerProfile.stats;
    switch (key.toLowerCase()) {
      case 'health':
        return s.health.toDouble();
      case 'intelligence':
        return s.intelligence.toDouble();
      case 'charisma':
        return s.charisma.toDouble();
      case 'creativity':
        return s.creativity.toDouble();
      case 'strength':
        return s.strength.toDouble();
      case 'wealth':
        return s.wealth.toDouble();
      case 'appearance':
      case 'appearancerating':
        return s.appearanceRating.toDouble();
      case 'reputation':
        return s.reputation.toDouble();
      case 'mood':
        return s.mood.toDouble();
      case 'libido':
        return s.libido.toDouble();
      default:
        return 0;
    }
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

String? _relationshipDeltaPreview(final playerProfile, EventChoice choice) {
  // Aggregate first targeted id deltas for a concise message
  try {
    final eff = choice.relationshipEffects!
        .firstWhere((e) => (e['targetType'] as String?)?.toLowerCase() == 'id');
    final id = eff['targetValue'] as String?;
    if (id == null) return null;
    final npc = playerProfile.relationships.firstWhere((n) => n.id == id,
        orElse: () => null);
    if (npc == null) return null;
    final aff = (eff['affectionChange'] as num?)?.toInt();
    final tr = (eff['trustChange'] as num?)?.toInt();
    final parts = <String>[];
    if (aff != null && aff != 0) parts.add('${aff > 0 ? '+' : ''}$aff Aff');
    if (tr != null && tr != 0) parts.add('${tr > 0 ? '+' : ''}$tr Trust');
    if (parts.isEmpty) return null;
    return '${npc.name}: ' + parts.join(', ');
  } catch (_) {
    return null;
  }
}
