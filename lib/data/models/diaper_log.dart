enum DiaperType { wet, dirty, both }

class DiaperLog {
  const DiaperLog({
    required this.id,
    required this.time,
    required this.type,
  });

  final String id;
  final DateTime time;
  final DiaperType type;

  Map<String, dynamic> toJson() => {
        'id': id,
        'time': time.toIso8601String(),
        'type': type.name,
      };

  factory DiaperLog.fromJson(Map<String, dynamic> json) => DiaperLog(
        id: json['id'] as String,
        time: DateTime.parse(json['time'] as String),
        type: DiaperType.values.byName(json['type'] as String),
      );
}
