import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_screen_provider.dart';
import '../models/app_screen.dart';
import '../providers/player_state_provider.dart';
import '../ui/syn_kit.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        // Optional: Add a subtle background gradient or starfield painter
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.2),
              Colors.black,
              Colors.black,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Game Title
                  Text(
                    'SYN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                      shadows: [
                        Shadow(
                          blurRadius: 20.0,
                          color: theme.colorScheme.secondary.withOpacity(0.7),
                          offset: Offset.zero,
                        ),
                        Shadow(
                          blurRadius: 30.0,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                          offset: Offset.zero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'SIMULATE YOUR NARRATIVE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 16,
                      letterSpacing: 4,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Menu Buttons
                  DivButton(
                    label: 'New Life',
                    icon: Icons.add_circle_outline,
                    onPressed: () {
                      // Reset player data and then explicitly reset navigation stack.
                      ref.read(playerStateProvider.notifier).resetToNewLife();
                      ref
                          .read(appScreenProvider.notifier)
                          .resetTo(AppScreen.newLife);
                    },
                  ),
                  const SizedBox(height: 20),
                  DivButton(
                    label: 'Load Life',
                    icon: Icons.folder_open_outlined,
                    onPressed: () async {
                      // Make the callback async to await the loading process.
                      await ref.read(playerStateProvider.notifier).loadPlayerProfile();
                      
                      // After loading, read the potentially updated state to check if it's valid.
                      final loadedProfile = ref.read(playerStateProvider);

                      // It's good practice to check if the widget is still in the tree
                      // before using its context, especially after an `await`.
                      if (context.mounted) {
                        // A simple check to see if a real profile was loaded (e.g., name is not empty)
                        if (loadedProfile.name.isNotEmpty) {
                          Toast.notify(context, 'Profile Loaded! Welcome back.', color: Colors.blue);
                          // Navigate to the dashboard since a game is loaded.
                          ref.read(appScreenProvider.notifier).resetTo(AppScreen.dashboard);
                        } else {
                          // Inform the user if no saved game was found.
                          Toast.notify(context, 'No saved game found.');
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  DivButton(
                    label: 'Settings',
                    icon: Icons.settings_outlined,
                    onPressed: () {
                      // Use the 'push' method to navigate to the settings screen.
                      ref
                          .read(appScreenProvider.notifier)
                          .push(AppScreen.settings);
                    },
                  ),
                  const SizedBox(height: 20),
                  DivButton(
                    label: 'Quit',
                    icon: Icons.exit_to_app_rounded,
                    variant: DivButtonVariant.danger,
                    onPressed: () {
                      // Close the application
                      SystemNavigator.pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
