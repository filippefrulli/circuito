class Circuit {
  final int? id;
  final String name;

  Circuit({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Circuit.fromMap(Map<String, dynamic> map) {
    Circuit race = Circuit(
      id: map['id'],
      name: map['name'],
    );
    return race;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Circuit && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
