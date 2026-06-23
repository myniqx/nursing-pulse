class BabyProfile {
  const BabyProfile({
    required this.name,
    required this.birthDate,
    this.customFeedIntervalHours,
  });

  final String name;
  final DateTime birthDate;

  /// If set, overrides the age-based recommendation.
  final double? customFeedIntervalHours;

  int get ageInWeeks => DateTime.now().difference(birthDate).inDays ~/ 7;

  /// Age-based recommended range.
  (double min, double max) get recommendedIntervalHours {
    final weeks = ageInWeeks;
    if (weeks < 4) return (2.0, 3.0);
    if (weeks < 12) return (2.5, 3.5);
    return (3.0, 4.0);
  }

  /// Effective interval used for next-feed suggestion.
  /// Custom value takes priority; falls back to midpoint of recommended range.
  double get effectiveIntervalHours {
    if (customFeedIntervalHours != null) return customFeedIntervalHours!;
    final (min, max) = recommendedIntervalHours;
    return (min + max) / 2;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'birthDate': birthDate.toIso8601String(),
        if (customFeedIntervalHours != null)
          'customFeedIntervalHours': customFeedIntervalHours,
      };

  factory BabyProfile.fromJson(Map<String, dynamic> json) => BabyProfile(
        name: json['name'] as String,
        birthDate: DateTime.parse(json['birthDate'] as String),
        customFeedIntervalHours:
            (json['customFeedIntervalHours'] as num?)?.toDouble(),
      );
}
