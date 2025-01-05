class Race {
  final int? id;
  final String name;
  final int car;
  final int circuit;
  final String type;
  final int status;

  Race({
    this.id,
    required this.name,
    required this.car,
    required this.circuit,
    required this.type,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'car': car,
      'circuit': circuit,
      'type': type,
      'status': status,
    };
  }
}
