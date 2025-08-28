import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_state_provider.dart';

class AdvanceYearButton extends ConsumerWidget {
  const AdvanceYearButton({super.key});

  bool _shouldDisableButton(playerProfile) {
    final event = playerProfile.currentMemoryEvent;
    return event != null && (event.choices?.isNotEmpty ?? false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerProfile = ref.watch(playerStateProvider);
    final theme = Theme.of(context);

    final bool isDisabled = _shouldDisableButton(playerProfile);

    return Tooltip(
      message: isDisabled
          ? "Resolve the current event before advancing the year."
          : "Advance your life by one year.",
      child: ElevatedButton.icon(
        icon: const Icon(Icons.fast_forward_rounded),
        label: const Text("Advance Year"),
        onPressed: isDisabled
            ? null
            : () {
                ref
                    .read(playerStateProvider.notifier)
                    .advanceYear(context: context);
              },
        style: theme.elevatedButtonTheme.style?.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.grey[700];
              }
              return theme.colorScheme.secondary;
            },
          ),
          minimumSize: WidgetStateProperty.all(
            const Size(double.infinity, 50),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 16),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
    );
  }
}
