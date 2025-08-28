class BabyName {
  final String name;
  final String? genderId; // Optional: aligns with GenderOption.id
  final List<String>? countryCodes; // Optional: list of ISO country codes

  const BabyName({
    required this.name,
    this.genderId,
    this.countryCodes,
  });

  factory BabyName.fromJson(Map<String, dynamic> json) {
    return BabyName(
      name: json['name'] as String,
      genderId: json['genderId'] as String?,
      countryCodes: (json['countryCodes'] as List?)?.cast<String>(),
    );
  }
}

