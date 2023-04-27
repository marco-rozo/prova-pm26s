// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ResponseCep {
  final String longitude;
  final String latitude;
  final String city;

  ResponseCep({
    required this.longitude,
    required this.latitude,
    required this.city,
  });

  ResponseCep copyWith({
    String? longitude,
    String? latitude,
    String? city,
  }) {
    return ResponseCep(
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      city: city ?? this.city,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'longitude': longitude,
      'latitude': latitude,
      'city': city,
    };
  }

  factory ResponseCep.fromMap(Map<String, dynamic> map) {
    return ResponseCep(
      longitude: map['location']['coordinates']['longitude'] ?? '' as String,
      latitude: map['location']['coordinates']['latitude'] ?? '' as String,
      city: map['city'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ResponseCep.fromJson(String source) =>
      ResponseCep.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ResponseCep(longitude: $longitude, latitude: $latitude, city: $city)';

  @override
  bool operator ==(covariant ResponseCep other) {
    if (identical(this, other)) return true;

    return other.longitude == longitude &&
        other.latitude == latitude &&
        other.city == city;
  }

  @override
  int get hashCode => longitude.hashCode ^ latitude.hashCode ^ city.hashCode;
}
