// lib/models/player_stats.dart

class PlayerStats {
  final int health;
  final int intelligence;
  final int charisma;
  final int libido;
  final int strength;
  final int creativity;
  final int karma;
  final int confidence;
  final int mood;
  final int social;
  final int wealth;
  final int happiness;
  final int reputation;
  // Added 'appearanceRating' and 'wisdom' as per GDD Core 5 requirements,
  // you can remove if not needed immediately but they are in GDD Core 5 lists.
  final int appearanceRating;
  final int wisdom;


  // Constructor with all named parameters and default values
  const PlayerStats({
    this.health = 50,
    this.intelligence = 50,
    this.charisma = 50,
    this.libido = 50,
    this.strength = 50,
    this.creativity = 50,
    this.karma = 0,
    this.confidence = 50,
    this.mood = 50,
    this.social = 50,
    this.wealth = 0, // Default wealth to 0
    this.happiness = 50,
    this.reputation = 0, // Default reputation to 0 (or 50 if neutral start)
    this.appearanceRating = 50, // Default appearance rating
    this.wisdom = 10, // Default wisdom, might start lower for younger ages
  });

  PlayerStats copyWith({
    int? health,
    int? intelligence,
    int? charisma,
    int? libido,
    int? strength,
    int? creativity,
    int? karma,
    int? confidence,
    int? mood,
    int? social,
    int? wealth,
    int? happiness,
    int? reputation,
    int? appearanceRating,
    int? wisdom,
  }) {
    return PlayerStats(
      health: health ?? this.health,
      intelligence: intelligence ?? this.intelligence,
      charisma: charisma ?? this.charisma,
      libido: libido ?? this.libido,
      strength: strength ?? this.strength,
      creativity: creativity ?? this.creativity,
      karma: karma ?? this.karma,
      confidence: confidence ?? this.confidence,
      mood: mood ?? this.mood,
      social: social ?? this.social,
      wealth: wealth ?? this.wealth,
      happiness: happiness ?? this.happiness,
      reputation: reputation ?? this.reputation,
      appearanceRating: appearanceRating ?? this.appearanceRating,
      wisdom: wisdom ?? this.wisdom,
    );
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      health: json['health'] as int? ?? 50,
      intelligence: json['intelligence'] as int? ?? 50,
      charisma: json['charisma'] as int? ?? 50,
      libido: json['libido'] as int? ?? 50,
      strength: json['strength'] as int? ?? 50,
      creativity: json['creativity'] as int? ?? 50,
      karma: json['karma'] as int? ?? 0,
      confidence: json['confidence'] as int? ?? 50,
      mood: json['mood'] as int? ?? 50,
      social: json['social'] as int? ?? 50,
      wealth: json['wealth'] as int? ?? 0,
      happiness: json['happiness'] as int? ?? 50,
      reputation: json['reputation'] as int? ?? 0,
      appearanceRating: json['appearanceRating'] as int? ?? 50,
      wisdom: json['wisdom'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'health': health,
      'intelligence': intelligence,
      'charisma': charisma,
      'libido': libido,
      'strength': strength,
      'creativity': creativity,
      'karma': karma,
      'confidence': confidence,
      'mood': mood,
      'social': social,
      'wealth': wealth,
      'happiness': happiness,
      'reputation': reputation,
      'appearanceRating': appearanceRating,
      'wisdom': wisdom,
    };
  }

  @override
  String toString() {
    return 'PlayerStats(health: $health, intelligence: $intelligence, charisma: $charisma, '
           'libido: $libido, strength: $strength, creativity: $creativity, karma: $karma, '
           'confidence: $confidence, mood: $mood, social: $social, wealth: $wealth, '
           'happiness: $happiness, reputation: $reputation, appearanceRating: $appearanceRating, wisdom: $wisdom)';
  }
}

/// Represents the character's moral standing, derived from their karma score.
enum KarmaTier {
  nefarious,
  villainous,
  troubled,
  neutral,
  principled,
  heroic,
  saintly;

  /// Provides a user-friendly title for the Karma tier.
  String get title {
    switch (this) {
      case KarmaTier.nefarious:
        return 'Nefarious';
      case KarmaTier.villainous:
        return 'Villainous';
      case KarmaTier.troubled:
        return 'Troubled';
      case KarmaTier.neutral:
        return 'Neutral';
      case KarmaTier.principled:
        return 'Principled';
      case KarmaTier.heroic:
        return 'Heroic';
      case KarmaTier.saintly:
        return 'Saintly';
    }
  }

  /// Determines the KarmaTier based on a numerical karma score.
  /// The ranges are based on the GDD's scale of -100 to +100.
  static KarmaTier fromKarma(int karma) {
    if (karma <= -80) return KarmaTier.nefarious;
    if (karma <= -40) return KarmaTier.villainous;
    if (karma < 0) return KarmaTier.troubled;
    if (karma == 0) return KarmaTier.neutral;
    if (karma < 40) return KarmaTier.principled;
    if (karma < 80) return KarmaTier.heroic;
    return KarmaTier.saintly; // for karma >= 80
  }
}
