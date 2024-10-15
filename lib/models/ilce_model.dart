class Ilce {
  final String district;

  Ilce({required this.district});

  factory Ilce.fromJson(Map<String, dynamic> json) {
    return Ilce(
      district: json['district'],
    );
  }
}