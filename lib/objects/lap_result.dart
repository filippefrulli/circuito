class LapResult {
  final int? id;
  final int raceId;
  final int lapNumber;
  final int completionTime;
  final int timeDifference;
  final String createdAt;

  LapResult({
    this.id,
    required this.raceId,
    required this.lapNumber,
    required this.completionTime,
    required this.timeDifference,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'race_id': raceId,
      'lap_number': lapNumber,
      'completion_time': completionTime,
      'time_difference': timeDifference,
      'created_at': createdAt,
    };
  }

  factory LapResult.fromMap(Map<String, dynamic> map) {
    return LapResult(
      id: map['id'],
      raceId: map['race_id'],
      lapNumber: map['lap_number'],
      completionTime: map['completion_time'],
      timeDifference: map['time_difference'],
      createdAt: map['created_at'],
    );
  }
}
