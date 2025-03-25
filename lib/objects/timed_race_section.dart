class TimedRaceSection {
  final int? id;
  final int raceId;
  final String name;
  final int result;
  final int completed;

  TimedRaceSection({
    this.id,
    required this.raceId,
    required this.name,
    required this.result,
    required this.completed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'race_id': raceId,
      'name': name,
      'result': result,
      'completed': completed,
    };
  }

  factory TimedRaceSection.fromMap(Map<String, dynamic> map) {
    return TimedRaceSection(
      id: map['id'],
      raceId: map['race_id'],
      name: map['name'],
      result: map['result'],
      completed: map['completed'],
    );
  }
}
