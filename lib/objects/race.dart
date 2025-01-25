class Race {
  final int? id;
  final String name;
  final int car;
  final int circuit;
  final int type;
  final int status;
  final String timestamp;

  Race({
    this.id,
    required this.name,
    required this.car,
    required this.circuit,
    required this.type,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'car': car,
      'circuit': circuit,
      'type': type,
      'status': status,
      'timestamp': timestamp,
    };
  }

  factory Race.fromMap(Map<String, dynamic> map) {
    Race race = Race(
      id: map['id'],
      name: map['name'],
      car: map['car'],
      circuit: map['circuit'],
      type: map['type'],
      status: map['status'],
      timestamp: map['timestamp'],
    );
    return race;
  }
}

enum RaceType {
  timed(1, 'time_trial'),
  laps(2, 'lap_race');

  final int id;
  final String display;

  const RaceType(this.id, this.display);

  static RaceType fromId(int id) {
    return RaceType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => throw ArgumentError('Invalid race type id: $id'),
    );
  }

  static RaceType fromDisplay(String display) {
    return RaceType.values.firstWhere(
      (type) => type.display == display,
      orElse: () => throw ArgumentError('Invalid race type display: $display'),
    );
  }
}
