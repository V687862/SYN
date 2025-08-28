class CoreDrive {
  final String id;
  final String label;
  final String description;

  const CoreDrive({
    required this.id,
    required this.label,
    required this.description,
  });

  factory CoreDrive.fromJson(Map<String, dynamic> json) {
    return CoreDrive(
      id: json['id'] as String,
      label: json['label'] as String,
      description: json['description'] as String,
    );
  }
}