class GenderOption {
  final String id;
  final String label;

  const GenderOption({required this.id, required this.label});

  factory GenderOption.fromJson(Map<String, dynamic> json) {
    return GenderOption(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }
}