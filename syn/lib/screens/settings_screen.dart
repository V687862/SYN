import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings.dart';
import '../providers/player_state_provider.dart';
import '../providers/app_screen_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.read(appScreenProvider.notifier).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _SettingsSectionHeader(title: 'Gameplay'),
          _SettingsSwitchTile(
            title: 'Show Tutorial Hints',
            subtitle: 'Display helpful tips for new players.',
            value: settings.gameplay.showTutorialHints,
            onChanged: (newValue) {
              settingsNotifier.update((s) =>
                  s.copyWith(gameplay: s.gameplay.copyWith(showTutorialHints: newValue)));
            },
          ),
          _SettingsDropdownTile<AgingPace>(
            title: 'Aging Pace',
            subtitle: 'Control how quickly time passes.',
            value: settings.gameplay.agingPace,
            items: AgingPace.values,
            onChanged: (newValue) {
              if (newValue != null) {
                settingsNotifier.update((s) =>
                    s.copyWith(gameplay: s.gameplay.copyWith(agingPace: newValue)));
              }
            },
            itemLabelBuilder: (pace) => formatEnumName(pace.name),
          ),
          const Divider(height: 30),

          _SettingsSectionHeader(title: 'Content'),
          _SettingsSwitchTile(
            title: 'Enable NSFW Content',
            subtitle: 'Allows for mature themes and events. (18+)',
            value: settings.nsfwEnabled,
            onChanged: (newValue) {
              settingsNotifier.update((s) => s.copyWith(nsfwEnabled: newValue));
            },
          ),
          const Divider(height: 30),

          _SettingsSectionHeader(title: 'Audio'),
          _SettingsSliderTile(
            label: 'Master Volume',
            value: settings.audio.masterVolume,
            onChanged: (v) => settingsNotifier.update((s) =>
                s.copyWith(audio: s.audio.copyWith(masterVolume: v))),
          ),
          _SettingsSliderTile(
            label: 'Music',
            value: settings.audio.musicVolume,
            onChanged: (v) => settingsNotifier.update((s) =>
                s.copyWith(audio: s.audio.copyWith(musicVolume: v))),
          ),
          _SettingsSliderTile(
            label: 'Sound Effects',
            value: settings.audio.sfxVolume,
            onChanged: (v) => settingsNotifier.update((s) =>
                s.copyWith(audio: s.audio.copyWith(sfxVolume: v))),
          ),
          const Divider(height: 30),

          _SettingsSectionHeader(title: 'Accessibility'),
          _SettingsSwitchTile(
            title: 'Reduced Motion',
            subtitle: 'Disables non-essential animations and screen effects.',
            value: settings.accessibility.reducedMotion,
            onChanged: (newValue) {
              settingsNotifier.update((s) => s.copyWith(
                  accessibility: s.accessibility.copyWith(reducedMotion: newValue)));
            },
          ),
          _SettingsSwitchTile(
            title: 'Dyslexia-Friendly Font',
            subtitle:
                'Uses a font designed for better readability. (Requires app restart)',
            value: settings.accessibility.dyslexiaMode,
            onChanged: (newValue) {
              settingsNotifier.update((s) => s.copyWith(
                  accessibility: s.accessibility.copyWith(dyslexiaMode: newValue)));
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  final String title;
  const _SettingsSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: theme.colorScheme.secondary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SwitchListTile.adaptive(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: theme.colorScheme.secondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
    );
  }
}

class _SettingsSliderTile extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _SettingsSliderTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Expanded(
            flex: 2,
            child: Slider.adaptive(
              value: value,
              onChanged: onChanged,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              label: '${(value * 100).toInt()}%',
              activeColor: theme.colorScheme.secondary,
              inactiveColor: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsDropdownTile<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabelBuilder;

  const _SettingsDropdownTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
      ),
      trailing: DropdownButton<T>(
        value: value,
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<T>>((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(itemLabelBuilder(item)),
          );
        }).toList(),
        dropdownColor: theme.colorScheme.surface,
        underline: const SizedBox(),
      ),
    );
  }
}

// Shared enum formatting helper
String formatEnumName(String name) =>
    name.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ').capitalizeFirst();

extension StringExtension on String {
  String capitalizeFirst() =>
      isNotEmpty ? "${this[0].toUpperCase()}${substring(1)}" : this;
}
