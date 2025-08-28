import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_screen_provider.dart';
import '../providers/player_state_provider.dart';
import '../models/app_screen.dart';
import '../ui/syn_kit.dart';

class InGameMenuScreen extends ConsumerStatefulWidget {
  const InGameMenuScreen({super.key});

  @override
  ConsumerState<InGameMenuScreen> createState() => _InGameMenuScreenState();
}

class _InGameMenuScreenState extends ConsumerState<InGameMenuScreen> {
  Future<void> _onSave() async {
    await ref.read(playerStateProvider.notifier).savePlayerProfile();
    if (!mounted) return;
    Toast.notify(context, 'Game Saved!', color: const Color(0xFF2ECC71));
    TraceCircleOverlay.of(context)?.ping();
  }

  Future<void> _onLoad() async {
    await ref.read(playerStateProvider.notifier).loadPlayerProfile();
    if (!mounted) return;
    Toast.notify(context, 'Game Loaded!', color: const Color(0xFF3498DB));
    ref.read(appScreenProvider.notifier).pop();
    TraceCircleOverlay.of(context)?.ping();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text('MENU', style: TextStyle(letterSpacing: 4)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: GhostPanel(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DivButton(
                    label: 'RESUME',
                    icon: Icons.play_arrow,
                    onPressed: () {
                      ref.read(appScreenProvider.notifier).pop();
                      TraceCircleOverlay.of(context)?.ping();
                    },
                  ),
                  const SizedBox(height: 8),
                  DivButton(
                    label: 'SAVE GAME',
                    icon: Icons.save_outlined,
                    variant: DivButtonVariant.success,
                    onPressed: _onSave,
                  ),
                  const SizedBox(height: 8),
                  DivButton(
                    label: 'LOAD GAME',
                    icon: Icons.folder_open,
                    onPressed: _onLoad,
                  ),
                  const SizedBox(height: 8),
                  DivButton(
                    label: 'SETTINGS',
                    icon: Icons.settings_outlined,
                    onPressed: () {
                      ref.read(appScreenProvider.notifier).push(AppScreen.settings);
                      TraceCircleOverlay.of(context)?.ping();
                    },
                  ),
                  const SizedBox(height: 16),
                  DivButton(
                    label: 'EXIT TO MAIN MENU',
                    icon: Icons.logout,
                    variant: DivButtonVariant.danger,
                    onPressed: () {
                      ref.read(appScreenProvider.notifier).resetTo(AppScreen.mainMenu);
                      TraceCircleOverlay.of(context)?.ping();
                    },
                  ),
                  const SizedBox(height: 6),
                  const HintText('tip: trace to confirm · minimal ui · maximal focus'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

