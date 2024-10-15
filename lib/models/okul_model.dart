class Okul {
  final String id;
  final String name;
  final String district;
  final String location;

  Okul({required this.id, required this.name, required this.district, required this.location});

  factory Okul.fromJson(Map<String, dynamic> json) {
    return Okul(
      id: json['id'],
      name: json['name'],
      district: json['district'],
      location: json['location'],
    );
  }
}