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
}
