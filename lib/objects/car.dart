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
}
