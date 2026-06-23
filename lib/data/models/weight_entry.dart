class WeightEntry {
  const WeightEntry({
    required this.id,
    required this.date,
    required this.grams,
  });

  final String id;
  final DateTime date;
  final int grams;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'grams': grams,
      };

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        grams: json['grams'] as int,
      );
}
