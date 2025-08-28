// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_state_provider.dart';
import '../providers/app_screen_provider.dart';
import '../models/app_screen.dart';
import '../models/player_profile.dart';

// Services & your existing widgets
import '../services/slm_events.dart';
import '../widgets/stat_stream.dart';
import '../widgets/advance_year.dart';

// ✨ Diviniko kit
import '../ui/syn_kit.dart';

// ---------- Helpers ----------
String getDashboardLifePhaseLabel(int age) {
  if (age < 13) return 'Childhood';
  if (age < 18) return 'Adolescence';
  if (age < 30) return 'Young Adulthood';
  if (age < 50) return 'Adulthood';
  if (age < 70) return 'Middle Age';
  return 'Old Age';
}

String getCurrentRole(PlayerProfile p) =>
    p.age < 18 ? 'Student' : (p.age > 65 ? 'Retired' : 'Citizen');

// ---------- Screen ----------
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,

      // Flat app bar with compact info row
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          (player.name.isEmpty ? 'UNIT' : player.name).toUpperCase(),
        ),
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Game Menu',
          icon: const Icon(Icons.menu),
          onPressed: () =>
              ref.read(appScreenProvider.notifier).push(AppScreen.inGameMenu),
        ),
        actions: [
          IconButton(
            tooltip: 'Save Profile',
            icon: const Icon(Icons.save_outlined),
            onPressed: () {
              ref.read(playerStateProvider.notifier).savePlayerProfile();
              Toast.notify(context, 'Profile saved');
            },
          ),
          IconButton(
            tooltip: 'Load Profile',
            icon: const Icon(Icons.folder_open_outlined),
            onPressed: () {
              ref.read(playerStateProvider.notifier).loadPlayerProfile();
              Toast.notify(context, 'Profile loaded');
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () =>
                ref.read(appScreenProvider.notifier).push(AppScreen.settings),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 12, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Age: ${player.age} • ${getDashboardLifePhaseLabel(player.age)}',
                    style: theme.textTheme.bodyMedium),
                Text(getCurrentRole(player), style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Event prompt / awaiting
            Expanded(child: _EventPrompt(panelPlayer: player)),

            // Stats in a ghost panel for cohesion
            const GhostPanel(
              margin: EdgeInsets.only(top: 8, bottom: 12),
              child: StatStreamWidget(),
            ),

            // Link-style secondary action
            // Advance year control
            const Padding(
              padding: EdgeInsets.only(top: 0, bottom: 8),
              child: AdvanceYearButton(),
            ),

            const SizedBox(height: 8),

            // Primary CTA styled like the system
            DivButton(
              label: 'GENERATE RANDOM EVENT (AI)',
              icon: Icons.auto_awesome,
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Center(
                      child: GhostPanel(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Generating event…'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                try {
                  final slm = ref.read(slmServiceProvider);
                  final profile = ref.read(playerStateProvider);
                  final newEvent = await slm.generateRandomEvent(profile);

                  if (context.mounted) Navigator.pop(context);
                  if (context.mounted) {
                    ref.read(playerStateProvider.notifier)
                        .setCurrentMemoryEvent(newEvent);
                    ref.read(appScreenProvider.notifier)
                        .push(AppScreen.memoryEventView);
                  }
                } catch (e) {
                  if (context.mounted) Navigator.pop(context);
                  if (context.mounted) {
                    Toast.notify(context, 'Failed to generate event: $e',
                        color: theme.colorScheme.error);
                  }
                }
              },
              fullWidth: true,
              showChevron: true,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),

      // Thin monochrome bottom navigation
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

// ---------- Event Prompt Panel ----------
class _EventPrompt extends ConsumerWidget {
  final PlayerProfile panelPlayer;
  const _EventPrompt({required this.panelPlayer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ev = panelPlayer.currentMemoryEvent;

    if (ev == null) {
      return const GhostPanel(
        margin: EdgeInsets.symmetric(vertical: 12),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        child: Center(
          child: Text(
            'Awaiting your choices…',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white70),
          ),
        ),
      );
    }

    final hasChoices = (ev.choices?.isNotEmpty ?? false);
    return GhostPanel(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ev.summary,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium!.copyWith(
              color: Colors.white, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          DivButton(
            label: hasChoices ? 'VIEW CHOICES' : 'CONTINUE',
            icon: hasChoices ? Icons.read_more_outlined : Icons.check_circle_outline,
            onPressed: () {
              if (hasChoices) {
                ref.read(appScreenProvider.notifier)
                    .push(AppScreen.memoryEventView);
              } else {
                ref.read(playerStateProvider.notifier)
                    .setCurrentMemoryEvent(null);
                TraceCircleOverlay.of(context)?.ping();
              }
            },
            fullWidth: true,
            showChevron: true,
          ),
        ],
      ),
    );
  }
}

// ---------- Bottom Nav ----------
class _BottomNav extends ConsumerWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stack = ref.watch(appScreenProvider);
    final current = stack.isNotEmpty ? stack.last : AppScreen.dashboard;

    Widget item(IconData icon, String label, AppScreen screen) {
      final selected = current == screen;
      final color = selected ? theme.colorScheme.primary : Colors.white70;
      return InkWell(
        onTap: () {
          if (!selected) ref.read(appScreenProvider.notifier).push(screen);
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(label.toUpperCase(),
                  style: TextStyle(fontSize: 10, letterSpacing: 1, color: color)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(.12), width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        top: 6,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          item(Icons.storefront_outlined, 'Shop', AppScreen.shop),
          item(Icons.bolt_outlined, 'Actions', AppScreen.actions),
          item(Icons.groups_outlined, 'Relations', AppScreen.relationshipView),
          item(Icons.menu_book_outlined, 'Journal', AppScreen.memoryLogView),
          item(Icons.public_outlined, 'World', AppScreen.world),
        ],
      ),
    );
  }
}
