// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screens
import 'screens/animated_genesis.dart';
import 'screens/new_life_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/memory_event_screen.dart';
import 'screens/initial_intro_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/placeholder_screen.dart';
import 'screens/actions_screen.dart';
import 'screens/in_game_menu_screen.dart';
import 'screens/journal_screen.dart';

// State
import 'providers/app_screen_provider.dart';
import 'models/app_screen.dart';

// ✨ Divineko UI kit
import 'ui/syn_kit.dart'; // <- the file I dropped in the canvas

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: SYN()));
}

class SYN extends ConsumerWidget {
  const SYN({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'SYN',
      debugShowCheckedModeBanner: false,
      // 1) Use the cohesive theme from the kit
      theme: SynTheme.buildTheme(), // pass a custom accent if you like
      home: const AppNavigator(),
    );
  }
}

/// 2) Shared shell: frames every page with grid + corner ticks + trace overlay
class _DivinikoShell extends StatelessWidget {
  final Widget child;
  const _DivinikoShell(this.child);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep app bars inside pages if they need one; shell just provides chrome
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GridBackdrop(opacity: .06), // faint system grid
          const CornerFrame(),              // corner ticks
          const TraceCircleOverlay(),       // call .ping() from pages for confirm
          // Your page content
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class AppNavigator extends ConsumerWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stack = ref.watch(appScreenProvider);
    final current = stack.isNotEmpty ? stack.last : AppScreen.animatedGenesis;

    Widget page;
    switch (current) {
      case AppScreen.animatedGenesis:
        page = const AnimatedGenesisScreen(); break;
      case AppScreen.initialIntro:
        page = const InitialIntroScreen(); break;
      case AppScreen.mainMenu:
        page = const MainMenuScreen(); break;
      case AppScreen.inGameMenu:
        page = const InGameMenuScreen(); break;
      case AppScreen.newLife:
        page = const NewLifeScreen(); break;
      case AppScreen.dashboard:
        page = const DashboardScreen(); break;
      case AppScreen.memoryEventView:
        page = const MemoryEventScreen(); break;
      case AppScreen.settings:
        page = const SettingsScreen(); break;
      case AppScreen.shop:
        page = const PlaceholderScreen(screenName: 'Shop'); break;
      case AppScreen.actions:
        page = const ActionsScreen(); break;
      case AppScreen.relationshipView:
        page = const PlaceholderScreen(screenName: 'Relationships'); break;
      case AppScreen.memoryLogView:
        page = const JournalScreen(); break;
      case AppScreen.world:
        page = const PlaceholderScreen(screenName: 'World'); break;
      default:
        page = const MainMenuScreen();
    }

    // Wrap everything in the shell for consistent chrome
    return _DivinikoShell(page);
  }
}
