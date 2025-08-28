// lib/screens/placeholder_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_screen_provider.dart'; // To handle navigation

/// A generic placeholder screen for features that are not yet implemented.
/// Includes a functional back button that works with the stack-based navigation system.
class PlaceholderScreen extends ConsumerWidget {
  final String screenName;

  const PlaceholderScreen({super.key, required this.screenName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        // FIXED: Add a leading IconButton to act as a manual back button.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Back',
          onPressed: () {
            // This calls the pop() method on your AppScreenNotifier
            // to go back to the previous screen in the stack (e.g., the Dashboard).
            ref.read(appScreenProvider.notifier).pop();
          },
        ),
        title: Text(screenName),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
      ),
      body: Center(
        child: Text(
          '$screenName Screen\n(Under Construction)',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
        ),
      ),
    );
  }
}