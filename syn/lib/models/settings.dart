// lib/models/settings.dart

// --- Enums for Settings ---

/// Defines the pace at which the player ages in the game.
enum AgingPace {
  yearly, // Standard one year at a time.
  halfYear, // Slower, more detailed progression.
  eventDriven, // Time only advances after major events.
}


// --- Settings Models ---

/// Represents audio settings for the application.
class AudioSettings {
  final double masterVolume;
  final double musicVolume;
  final double sfxVolume;

  const AudioSettings({
    this.masterVolume = 1.0, // 0.0 to 1.0
    this.musicVolume = 1.0,
    this.sfxVolume = 1.0,
  });

  AudioSettings copyWith({
    double? masterVolume,
    double? musicVolume,
    double? sfxVolume,
  }) {
    return AudioSettings(
      masterVolume: masterVolume ?? this.masterVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
    );
  }

  factory AudioSettings.fromJson(Map<String, dynamic> json) {
    return AudioSettings(
      masterVolume: (json['masterVolume'] as num?)?.toDouble() ?? 1.0,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 1.0,
      sfxVolume: (json['sfxVolume'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'masterVolume': masterVolume,
    'musicVolume': musicVolume,
    'sfxVolume': sfxVolume,
  };
}


/// Represents gameplay-specific settings.
class GameplaySettings {
  final AgingPace agingPace;
  final bool showTutorialHints;

  const GameplaySettings({
    this.agingPace = AgingPace.yearly,
    this.showTutorialHints = true,
  });

  GameplaySettings copyWith({
    AgingPace? agingPace,
    bool? showTutorialHints,
  }) {
    return GameplaySettings(
      agingPace: agingPace ?? this.agingPace,
      showTutorialHints: showTutorialHints ?? this.showTutorialHints,
    );
  }

   factory GameplaySettings.fromJson(Map<String, dynamic> json) {
    return GameplaySettings(
      // Safely parse enum from string
      agingPace: AgingPace.values.firstWhere(
        (e) => e.name == json['agingPace'],
        orElse: () => AgingPace.yearly,
      ),
      showTutorialHints: json['showTutorialHints'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'agingPace': agingPace.name, // Store enum as string
    'showTutorialHints': showTutorialHints,
  };
}


/// Represents accessibility settings within the application.
class AccessibilitySettings {
  final bool reducedMotion;
  final bool dyslexiaMode;

  const AccessibilitySettings({
    this.reducedMotion = false,
    this.dyslexiaMode = false,
  });

  AccessibilitySettings copyWith({
    bool? reducedMotion,
    bool? dyslexiaMode,
  }) {
    return AccessibilitySettings(
      reducedMotion: reducedMotion ?? this.reducedMotion,
      dyslexiaMode: dyslexiaMode ?? this.dyslexiaMode,
    );
  }

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      dyslexiaMode: json['dyslexiaMode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'reducedMotion': reducedMotion,
    'dyslexiaMode': dyslexiaMode,
  };
}

// Represents the overall application settings.
class AppSettings {
  final bool nsfwEnabled;
  final String theme;
  final GameplaySettings gameplay; // Added
  final AudioSettings audio; // Added
  final AccessibilitySettings accessibility;

  const AppSettings({
    this.nsfwEnabled = false,
    this.theme = 'dark',
    this.gameplay = const GameplaySettings(), // Added
    this.audio = const AudioSettings(), // Added
    this.accessibility = const AccessibilitySettings(),
  });

  AppSettings copyWith({
    bool? nsfwEnabled,
    String? theme,
    GameplaySettings? gameplay, // Added
    AudioSettings? audio, // Added
    AccessibilitySettings? accessibility,
  }) {
    return AppSettings(
      nsfwEnabled: nsfwEnabled ?? this.nsfwEnabled,
      theme: theme ?? this.theme,
      gameplay: gameplay ?? this.gameplay, // Added
      audio: audio ?? this.audio, // Added
      accessibility: accessibility ?? this.accessibility,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      nsfwEnabled: json['nsfwEnabled'] as bool? ?? false,
      theme: json['theme'] as String? ?? 'dark',
      gameplay: json['gameplay'] != null
          ? GameplaySettings.fromJson(json['gameplay'] as Map<String, dynamic>)
          : const GameplaySettings(),
      audio: json['audio'] != null
          ? AudioSettings.fromJson(json['audio'] as Map<String, dynamic>)
          : const AudioSettings(),
      accessibility: json['accessibility'] != null
          ? AccessibilitySettings.fromJson(json['accessibility'] as Map<String, dynamic>)
          : const AccessibilitySettings(),
    );
  }

  Map<String, dynamic> toJson() => {
    'nsfwEnabled': nsfwEnabled,
    'theme': theme,
    'gameplay': gameplay.toJson(),
    'audio': audio.toJson(),
    'accessibility': accessibility.toJson(),
  };
}