// lib/models/appearance.dart

class Appearance {
  final String? hairColor;
  final String? eyeColor;
  final String? bodyType;
  final String? genitalDescriptor;
  final String? style;

  const Appearance({
    this.hairColor,
    this.eyeColor,
    this.bodyType,
    this.genitalDescriptor,
    this.style,
  });

  Appearance copyWith({
    String? hairColor,
    String? eyeColor,
    String? bodyType,
    String? genitalDescriptor,
    String? style,
  }) {
    return Appearance(
      hairColor: hairColor ?? this.hairColor,
      eyeColor: eyeColor ?? this.eyeColor,
      bodyType: bodyType ?? this.bodyType,
      genitalDescriptor: genitalDescriptor ?? this.genitalDescriptor,
      style: style ?? this.style,
    );
  }

  factory Appearance.fromJson(Map<String, dynamic> json) {
    return Appearance(
      hairColor: json['hairColor'] as String?,
      eyeColor: json['eyeColor'] as String?,
      bodyType: json['bodyType'] as String?,
      genitalDescriptor: json['genitalDescriptor'] as String?,
      style: json['style'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'hairColor': hairColor,
        'eyeColor': eyeColor,
        'bodyType': bodyType,
        'genitalDescriptor': genitalDescriptor,
        'style': style,
      };
}
// This class represents the appearance of a player character in the game.
// It includes properties for hair color, eye color, body type, genital descriptor, and style.