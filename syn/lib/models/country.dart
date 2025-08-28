// lib/models/country.dart

// Represents a country with a code and a name,
// matching the structure of objects in your countries.json file.
class Country {
  final String code; // e.g., "IN", "US"
  final String name; // e.g., "India", "United States"

  // Constructor for creating a Country instance.
  const Country({
    required this.code,
    required this.name,
  });

  // Factory constructor for creating a new Country instance from a JSON map.
  // This is used by the StaticDataService when parsing countries.json.
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['code'] as String, // Assumes 'code' field exists and is a string
      name: json['name'] as String, // Assumes 'name' field exists and is a string
    );
  }

  // Optional: toJson method if you ever need to serialize Country objects back to JSON.
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }

  // Optional: Override equals and hashCode if you plan to store Country objects in Sets or use them as Map keys.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          name == other.name;

  @override
  int get hashCode => code.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'Country(code: $code, name: $name)';
  }
}
