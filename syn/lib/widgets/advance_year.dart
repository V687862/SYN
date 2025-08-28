import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/syn_kit.dart';
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
      child: DivButton(
        label: 'ADVANCE YEAR',
        icon: Icons.fast_forward_rounded,
        onPressed: isDisabled
            ? null
            : () {
                ref.read(playerStateProvider.notifier).advanceYear(context: context);
              },
      ),
    );
  }
}
