import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_state_provider.dart';
import '../providers/app_screen_provider.dart';
import '../models/education_stage.dart';
import '../models/education_focus.dart';
import '../ui/syn_kit.dart';

class ActionsScreen extends ConsumerWidget {
  const ActionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final player = ref.watch(playerStateProvider);
    final edu = ref.watch(educationServiceProvider);

    final currentSchool = (player.currentSchoolId != null)
        ? edu.getSchoolById(player.currentSchoolId!)
        : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Back',
          onPressed: () => ref.read(appScreenProvider.notifier).pop(),
        ),
        title: const Text('Actions'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Education panel
          const Text('Education', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GhostPanel(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      educationStageToString(player.currentEducationStage),
                      style: theme.textTheme.titleMedium,
                    ),
                    if (currentSchool != null)
                      Chip(
                        label: Text(currentSchool.name),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (currentSchool != null)
                  _SchoolProgressRow(
                    yearsInStage: player.yearsInCurrentStage ?? 0,
                    duration: currentSchool.typicalDurationInYears,
                  )
                else
                  Text(
                    'Not enrolled. You can enroll if eligible.',
                    style: theme.textTheme.bodyMedium,
                  ),

                const SizedBox(height: 12),
                if (currentSchool != null) ...[
                  Text('Focus This Year', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  _FocusPicker(currentFocus: player.educationFocus),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Eligible schools (shown only after high school)
          if (player.currentEducationStage == EducationStage.graduatedHighSchool) ...[
            const Text('Eligible Schools', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _EligibleSchoolsList(),
          ] else ...[
            GhostPanel(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Enrollment is automatic until high school graduation.\nProgress through your current school to unlock post-secondary choices.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SchoolProgressRow extends StatelessWidget {
  final int yearsInStage;
  final int duration;
  const _SchoolProgressRow({required this.yearsInStage, required this.duration});

  @override
  Widget build(BuildContext context) {
    final pct = (duration == 0) ? 0.0 : (yearsInStage / duration).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: pct),
        const SizedBox(height: 6),
        Text('Year $yearsInStage of $duration'),
      ],
    );
  }
}

class _EligibleSchoolsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final player = ref.watch(playerStateProvider);
    final educationService = ref.watch(educationServiceProvider);

    final potential = educationService.getPotentialSchools(player);
    if (potential.isEmpty) {
      return GhostPanel(
        padding: const EdgeInsets.all(12),
        child: Text(
          'No schools available right now. Age up or meet requirements.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      children: potential.map((s) {
        return GhostPanel(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text('${educationStageToString(s.stage)} • Start at ${s.minAgeToEnroll}+ • ${s.typicalDurationInYears}y'),
                  ],
                ),
              ),
              DivButton(
                label: 'Enroll',
                icon: Icons.school_outlined,
                onPressed: () async {
                  await ref.read(playerStateProvider.notifier).enrollInSchool(s.id);
                  Toast.notify(context, 'Enrollment updated');
                },
                fullWidth: false,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _FocusPicker extends ConsumerWidget {
  final EducationFocus currentFocus;
  const _FocusPicker({required this.currentFocus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = [
      educationFocusLabel(EducationFocus.study),
      educationFocusLabel(EducationFocus.athletics),
      educationFocusLabel(EducationFocus.social),
      educationFocusLabel(EducationFocus.work),
      educationFocusLabel(EducationFocus.skip),
    ];
    final idx = EducationFocus.values.indexOf(currentFocus);
    return DivSegmented(
      segments: labels,
      index: idx,
      onChanged: (i) {
        final selected = EducationFocus.values[i];
        ref.read(playerStateProvider.notifier).setEducationFocus(selected);
        Toast.notify(context, 'Focus set to ${labels[i]}');
      },
    );
  }
}
