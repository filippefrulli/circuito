class TimedChallengeResult {
  final int? id;
  final int challengeId;
  final int completionTime;
  final int timeDifference;
  final int rank;
  final String createdAt;

  TimedChallengeResult({
    this.id,
    required this.challengeId,
    required this.completionTime,
    required this.timeDifference,
    required this.rank,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'challenge_id': challengeId,
      'completion_time': completionTime,
      'time_difference': timeDifference,
      'rank': rank,
      'created_at': createdAt,
    };
  }

  factory TimedChallengeResult.fromMap(Map<String, dynamic> map) {
    return TimedChallengeResult(
      id: map['id'],
      challengeId: map['challenge_id'],
      completionTime: map['completion_time'],
      timeDifference: map['time_difference'],
      rank: map['rank'],
      createdAt: map['created_at'],
    );
  }
}
