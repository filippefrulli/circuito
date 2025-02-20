class Car {
  final int? id;
  final String name;
  final int year;
  final String image;

  Car({this.id, required this.name, required this.year, required this.image});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'year': year,
      'image': image,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    Car race = Car(
      id: map['id'],
      name: map['name'],
      year: map['year'],
      image: map['image'],
    );
    return race;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Car && other.id == id && other.name == name && other.year == year;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ year.hashCode;
}
