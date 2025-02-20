class TimedRaceSection {
  final int? id;
  final int raceId;
  final String name;
  final int completed;

  TimedRaceSection({
    this.id,
    required this.raceId,
    required this.name,
    required this.completed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'race_id': raceId,
      'name': name,
      'completed': completed,
    };
  }

  factory TimedRaceSection.fromMap(Map<String, dynamic> map) {
    return TimedRaceSection(
      id: map['id'],
      raceId: map['race_id'],
      name: map['name'],
      completed: map['completed'],
    );
  }
}
