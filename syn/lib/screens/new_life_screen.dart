// lib/screens/new_life_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/player_profile.dart';
import '../models/game_phase.dart';
import '../models/app_screen.dart';
import '../models/country.dart';
import '../models/gender_option.dart';
import '../models/core_drive.dart';
import '../models/appearance.dart';

import '../providers/player_state_provider.dart';
import '../providers/app_screen_provider.dart';
import '../providers/static_data_providers.dart';

// Your new custom widget is now imported
import '../widgets/custom_input_field.dart';
import '../ui/syn_kit.dart';

class NewLifeScreen extends ConsumerStatefulWidget {
  const NewLifeScreen({super.key});

  @override
  ConsumerState<NewLifeScreen> createState() => _NewLifeScreenState();
}

class _NewLifeScreenState extends ConsumerState<NewLifeScreen> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  // State controllers for text fields
  late final TextEditingController _nameController;
  late final TextEditingController _pronounsController;
  late final TextEditingController _hairColorController;
  late final TextEditingController _eyeColorController;

  // State variables for dropdowns
  Country? _selectedCountry;
  GenderOption? _selectedGender;
  CoreDrive? _selectedCoreDrive;

  int _currentPage = 0;
  String? _selectedDriveDescription;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _nameController = TextEditingController();
    _pronounsController = TextEditingController();
    _hairColorController = TextEditingController();
    _eyeColorController = TextEditingController();

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    // Dispose of all controllers
    _pageController.dispose();
    _nameController.dispose();
    _pronounsController.dispose();
    _hairColorController.dispose();
    _eyeColorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final countriesAsyncValue = ref.watch(countriesProvider);
    final gendersAsyncValue = ref.watch(gendersProvider);
    final coreDrivesAsyncValue = ref.watch(coreDrivesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Craft Your SYN'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.read(appScreenProvider.notifier).resetTo(AppScreen.mainMenu),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCoreIdentityPage(theme, gendersAsyncValue),
                _buildOriginAndDrivePage(theme, countriesAsyncValue, coreDrivesAsyncValue),
                _buildAppearancePage(theme),
              ],
            ),
            _buildNavigationControls(theme),
          ],
        ),
      ),
    );
  }

  // --- Page Builder Methods ---

  Widget _buildCoreIdentityPage(
    ThemeData theme,
    AsyncValue<List<GenderOption>> gendersAsyncValue,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomInputField(
            label: "Your Name",
            hint: "Enter your character's name",
            controller: _nameController,
            // The onSaved callback is required by your new widget
            onSaved: (value) {},
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name.';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          _buildDropdown<GenderOption>(
            label: "Gender Identity",
            value: _selectedGender,
            asyncValue: gendersAsyncValue,
            onChanged: (newValue) => setState(() => _selectedGender = newValue),
            itemBuilder: (gender) => DropdownMenuItem(value: gender, child: Text(gender.label)),
            validator: (value) => value == null ? 'Please select a gender.' : null,
          ),
          const SizedBox(height: 10),
          CustomInputField(
            label: "Pronouns",
            hint: "e.g., they/them, she/her",
            controller: _pronounsController,
            onSaved: (value) {}, // onSaved is required
          ),
        ],
      ),
    );
  }

  Widget _buildOriginAndDrivePage(
    ThemeData theme,
    AsyncValue<List<Country>> countriesAsyncValue,
    AsyncValue<List<CoreDrive>> coreDrivesAsyncValue,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdown<Country>(
            label: "Country of Origin",
            value: _selectedCountry,
            asyncValue: countriesAsyncValue,
            onChanged: (newValue) => setState(() => _selectedCountry = newValue),
            itemBuilder: (country) => DropdownMenuItem(value: country, child: Text(country.name)),
            validator: (value) => value == null ? 'Please select a country.' : null,
          ),
          const SizedBox(height: 10),
          _buildDropdown<CoreDrive>(
            label: "Initial Drive",
            value: _selectedCoreDrive,
            asyncValue: coreDrivesAsyncValue,
            onChanged: (newValue) {
              setState(() {
                _selectedCoreDrive = newValue;
                _selectedDriveDescription = newValue?.description;
              });
            },
            itemBuilder: (drive) => DropdownMenuItem(value: drive, child: Text(drive.label)),
            validator: (value) => value == null ? 'Please select a drive.' : null,
          ),
          const SizedBox(height: 15),
          if (_selectedDriveDescription != null)
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                ),
                child: Text(
                  _selectedDriveDescription!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppearancePage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "APPEARANCE",
            style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18, color: theme.colorScheme.secondary),
          ),
          const Divider(height: 20),
          CustomInputField(
            label: "Hair Color",
            hint: "e.g., Neon Pink, Cyber Blue",
            controller: _hairColorController,
            onSaved: (value) {}, // onSaved is required
          ),
          const SizedBox(height: 10),
          CustomInputField(
            label: "Eye Color",
            hint: "e.g., Silver, Crimson Glow",
            controller: _eyeColorController,
            onSaved: (value) {}, // onSaved is required
          ),
        ],
      ),
    );
  }

  // --- Helper for Dropdowns ---
  Widget _buildDropdown<T>({
    required String label, required T? value, required AsyncValue<List<T>> asyncValue,
    required void Function(T?) onChanged, required DropdownMenuItem<T> Function(T) itemBuilder,
    required String? Function(T?)? validator,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.secondary.withOpacity(0.8),
              fontSize: 14,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          asyncValue.when(
            data: (items) => DropdownButtonFormField<T>(
              initialValue: value,
              onChanged: onChanged,
              items: items.map(itemBuilder).toList(),
              validator: validator,
              dropdownColor: theme.colorScheme.surface,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withOpacity(.12), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(.6), width: 1),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
                ),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- Navigation and Submission ---

  Widget _buildNavigationControls(ThemeData theme) {
    bool isLastPage = _currentPage == 2;
    return Positioned(
      bottom: 20, left: 20, right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
              child: Text("<< BACK", style: TextStyle(color: theme.colorScheme.secondary)),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: DivButton(
              label: isLastPage ? 'Initiate Consciousness' : 'Next',
              icon: isLastPage ? Icons.check_circle_outline : Icons.chevron_right,
              onPressed: () {
                if (isLastPage) {
                  _submitNewLife();
                } else {
                  _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                }
              },
              fullWidth: true,
              showChevron: !isLastPage,
            ),
          ),
        ],
      ),
    );
  }

  void _submitNewLife() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // This will trigger onSaved for all fields
      if (_selectedGender == null || _selectedCountry == null || _selectedCoreDrive == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete all required fields.'), backgroundColor: Colors.red),
        );
        return;
      }

      final String playerName = _nameController.text.trim();
      final String pronouns = _pronounsController.text.trim();
      final String hairColor = _hairColorController.text.trim();
      final String eyeColor = _eyeColorController.text.trim();

      // Initialize all drive scores with a base value
      final Map<String, int> initialDriveScores = {
        'seek_knowledge': 5,
        'achieve_fame': 5,
        'build_connections': 5,
        'experience_everything': 5,
        'master_a_craft': 5,
        'amass_wealth': 5,
        'fight_for_a_cause': 5,
        'seek_transcendence': 5,
        'survive_at_all_costs': 5,
      };
      // Give the selected drive a starting boost
      initialDriveScores[_selectedCoreDrive!.id] = 15;
      
      final initialProfile = PlayerProfile.initial().copyWith(
        name: playerName,
        gender: _selectedGender!.id,
        countryCode: _selectedCountry!.code,
        pronouns: pronouns.isNotEmpty ? pronouns : null,
        coreDriveScores: initialDriveScores,
        appearance: Appearance(
          hairColor: hairColor.isNotEmpty ? hairColor : null,
          eyeColor: eyeColor.isNotEmpty ? eyeColor : null,
        ),
        currentPhase: GamePhase.year,
      );

      ref.read(playerStateProvider.notifier).startNewLife(initialProfile);
      ref.read(appScreenProvider.notifier).resetTo(AppScreen.dashboard);

      print("New life started for: $playerName");
    }
  }
}
