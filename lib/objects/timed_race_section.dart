class TimedRaceSection {
  final int? id;
  final int raceId;
  final String name;

  TimedRaceSection({
    this.id,
    required this.raceId,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'race_id': raceId,
      'name': name,
    };
  }

  factory TimedRaceSection.fromMap(Map<String, dynamic> map) {
    return TimedRaceSection(
      id: map['id'],
      raceId: map['race_id'],
      name: map['name'],
    );
  }
}
