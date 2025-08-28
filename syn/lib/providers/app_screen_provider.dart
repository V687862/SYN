// lib/providers/app_screen_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_screen.dart';

/// Manages the navigation stack of the application.
/// Instead of a single screen, it holds a list of screens representing the history.
class NavigationNotifier extends StateNotifier<List<AppScreen>> {
  // The initial screen when the app starts.
  NavigationNotifier() : super([AppScreen.animatedGenesis]);

  /// The currently visible screen is always the last one in the list.
  AppScreen get currentScreen => state.last;

  /// Pushes a new screen onto the stack, making it the current screen.
  void push(AppScreen screen) {
    state = [...state, screen];
  }

  /// Removes the top screen from the stack, effectively going "back".
  void pop() {
    if (state.length > 1) {
      final newState = List<AppScreen>.from(state)..removeLast();
      state = newState;
    }
  }

  /// Replaces the current screen with a new one.
  void replace(AppScreen screen) {
    if (state.isNotEmpty) {
      final newState = List<AppScreen>.from(state)..removeLast();
      state = [...newState, screen];
    } else {
      state = [screen];
    }
  }

  /// Resets the entire navigation stack to a single screen.
  /// Used for returning to a main state, like the Main Menu or a new game.
  void resetTo(AppScreen screen) {
    state = [screen];
  }
}

/// The global provider for the app's navigation state.
final appScreenProvider = StateNotifierProvider<NavigationNotifier, List<AppScreen>>((ref) {
  return NavigationNotifier();
});