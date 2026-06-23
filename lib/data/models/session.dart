enum NursingSide { left, right }

class Session {
  const Session({
    required this.id,
    required this.startTime,
    required this.side,
    this.endTime,
  });

  final String id;
  final DateTime startTime;
  final NursingSide side;
  final DateTime? endTime;

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  bool get isActive => endTime == null;

  Session copyWith({DateTime? endTime}) {
    return Session(
      id: id,
      startTime: startTime,
      side: side,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'side': side.name,
        'endTime': endTime?.toIso8601String(),
      };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        side: NursingSide.values.byName(json['side'] as String),
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
      );
}
