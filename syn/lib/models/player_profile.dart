// lib/models/player_profile.dart
import 'package:syn/models/player_stats.dart';
import 'package:syn/models/memory_event.dart';
import 'package:syn/models/game_phase.dart';
import 'package:syn/models/npc.dart';
import 'package:syn/models/education_stage.dart';
import 'package:syn/models/appearance.dart';
import 'package:syn/models/dynamic_modifiers.dart';


class PlayerProfile {
  final String name;
  final int age;
  final String gender;
  final String countryCode;
  final Appearance appearance;
  final PlayerStats stats;
  final List<NPC> relationships;
  final String? currentJobId;
  final String? educationLevel;
  final String? pronouns;
  final List<String> traits;
  final List<String> kinks;
  final List<String> flags;
  final Map<String, int> coreDriveScores;
  final List<DynamicModifier> activeModifiers;
  final GamePhase currentPhase;
  final MemoryEvent? currentMemoryEvent;
  final EducationStage currentEducationStage;
  final String? currentSchoolId;
  final int? yearsInCurrentStage;
  final List<EducationStage> completedEducationStages;
  final List<MemoryEvent> memories;

  const PlayerProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.countryCode,
    required this.appearance,
    required this.stats,
    this.relationships = const [],
    this.currentJobId,
    this.educationLevel,
    this.pronouns,
    this.traits = const [],
    this.kinks = const [],
    this.flags = const [],
    this.coreDriveScores = const {},
    this.activeModifiers = const [],
    required this.currentPhase,
    this.currentMemoryEvent,
    this.currentEducationStage = EducationStage.none,
    this.currentSchoolId,
    this.yearsInCurrentStage = 0,
    this.completedEducationStages = const [],
    this.memories = const [],
  });

  String get dominantDrive {
    if (coreDriveScores.isEmpty) {
      return 'Undeclared';
    }
    var sortedDrives = coreDriveScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedDrives.first.key;
  }

  factory PlayerProfile.initial() {
    return const PlayerProfile(
      name: '',
      age: 6,
      gender: '',
      countryCode: '',
      appearance: Appearance(),
      stats: PlayerStats(),
      currentPhase: GamePhase.newLife,
      coreDriveScores: {},
      activeModifiers: [],
      currentEducationStage: EducationStage.none,
    );
  }

  PlayerProfile copyWith({
    String? name,
    int? age,
    String? gender,
    String? countryCode,
    Appearance? appearance,
    PlayerStats? stats,
    List<NPC>? relationships,
    String? currentJobId,
    bool clearCurrentJobId = false,
    String? educationLevel,
    String? pronouns,
    List<String>? traits,
    List<String>? kinks,
    List<String>? flags,
    Map<String, int>? coreDriveScores,
     List<DynamicModifier>? activeModifiers,
    GamePhase? currentPhase,
    MemoryEvent? currentMemoryEvent,
    bool clearCurrentMemoryEvent = false,
    EducationStage? currentEducationStage,
    String? currentSchoolId,
    bool clearCurrentSchoolId = false,
    int? yearsInCurrentStage,
    List<EducationStage>? completedEducationStages,
    List<MemoryEvent>? memories, // Added memories to copyWith parameters
  }) {
    return PlayerProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      countryCode: countryCode ?? this.countryCode,
      appearance: appearance ?? this.appearance,
      stats: stats ?? this.stats,
      relationships: relationships ?? this.relationships,
      currentJobId:
          clearCurrentJobId ? null : currentJobId ?? this.currentJobId,
      educationLevel: educationLevel ?? this.educationLevel,
      pronouns: pronouns ?? this.pronouns,
      traits: traits ?? this.traits,
      kinks: kinks ?? this.kinks,
      flags: flags ?? this.flags,
      coreDriveScores: coreDriveScores ?? this.coreDriveScores,
      activeModifiers: activeModifiers ?? this.activeModifiers,
      currentPhase: currentPhase ?? this.currentPhase,
      currentMemoryEvent: clearCurrentMemoryEvent
          ? null
          : currentMemoryEvent ?? this.currentMemoryEvent,
      currentEducationStage:
          currentEducationStage ?? this.currentEducationStage,
      currentSchoolId:
          clearCurrentSchoolId ? null : currentSchoolId ?? this.currentSchoolId,
      yearsInCurrentStage:
          yearsInCurrentStage ?? this.yearsInCurrentStage,
      completedEducationStages:
          completedEducationStages ?? this.completedEducationStages,
      memories: memories ?? this.memories, // Use the provided or existing memories
    );
  }

  /// Deserializes a JSON map into a PlayerProfile object.
  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      countryCode: json['countryCode'] as String,
      appearance: Appearance.fromJson(json['appearance'] as Map<String, dynamic>),
      stats: PlayerStats.fromJson(json['stats'] as Map<String, dynamic>),
      relationships: (json['relationships'] as List<dynamic>)
          .map((e) => NPC.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentJobId: json['currentJobId'] as String?,
      educationLevel: json['educationLevel'] as String?,
      pronouns: json['pronouns'] as String?,
      traits: List<String>.from(json['traits'] as List<dynamic>),
      kinks: List<String>.from(json['kinks'] as List<dynamic>),
      flags: List<String>.from(json['flags'] as List<dynamic>),
      coreDriveScores: Map<String, int>.from(json['coreDriveScores'] as Map),
      activeModifiers: (json['activeModifiers'] as List<dynamic>? ?? [])
          .map((e) => DynamicModifier.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPhase: GamePhase.values.byName(json['currentPhase'] as String),
      currentMemoryEvent: json['currentMemoryEvent'] != null
          ? MemoryEvent.fromJson(json['currentMemoryEvent'] as Map<String, dynamic>)
          : null,
      currentEducationStage: EducationStage.values.byName(json['currentEducationStage'] as String),
      currentSchoolId: json['currentSchoolId'] as String?,
      yearsInCurrentStage: json['yearsInCurrentStage'] as int?,
      completedEducationStages: (json['completedEducationStages'] as List<dynamic>)
          .map((e) => EducationStage.values.byName(e as String))
          .toList(),
      memories: (json['memories'] as List<dynamic>)
          .map((e) => MemoryEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Serializes a PlayerProfile object into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'countryCode': countryCode,
      'appearance': appearance.toJson(),
      'stats': stats.toJson(),
      'relationships': relationships.map((e) => e.toJson()).toList(),
      'currentJobId': currentJobId,
      'educationLevel': educationLevel,
      'pronouns': pronouns,
      'traits': traits,
      'kinks': kinks,
      'flags': flags,
      'coreDriveScores': coreDriveScores,
      'activeModifiers': activeModifiers.map((e) => e.toJson()).toList(),
      'currentPhase': currentPhase.name,
      'currentMemoryEvent': currentMemoryEvent?.toJson(),
      'currentEducationStage': currentEducationStage.name,
      'currentSchoolId': currentSchoolId,
      'yearsInCurrentStage': yearsInCurrentStage,
      'completedEducationStages': completedEducationStages.map((e) => e.name).toList(),
      'memories': memories.map((e) => e.toJson()).toList(),
    };
  }
}