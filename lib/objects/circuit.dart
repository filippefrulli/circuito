class Circuit {
  final int? id;
  final String name;
  final String country;

  Circuit({this.id, required this.name, required this.country});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'country': country,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Circuit && other.id == id && other.name == name && other.country == country;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ country.hashCode;
}
