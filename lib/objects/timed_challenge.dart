class TimedChallenge {
  int? id;
  int? sectionId;
  int? completionTime;
  int? rank;

  TimedChallenge({
    this.id,
    this.sectionId,
    this.completionTime,
    this.rank,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'section_id': sectionId,
      'completion_time': completionTime,
      'rank': rank,
    };
  }

  factory TimedChallenge.fromMap(Map<String, dynamic> map) {
    return TimedChallenge(
      id: map['id'],
      sectionId: map['section_id'],
      completionTime: map['completion_time'],
      rank: map['rank'],
    );
  }
}
