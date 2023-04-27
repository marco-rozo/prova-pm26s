// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:intl/intl.dart';

class TuristSpots {
  static const TABLE_NAME = 'turist_spots';
  static const FIELD_ID = '_id';
  static const FIELD_NAME = 'name';
  static const FIELD_CEP = 'cep';
  static const FIELD_DIFFERENTIAL = 'differential';
  static const FIELD_CREATE_AT = 'create_at';
  static const FIELD_WORKING_HOURS = 'working_hours';
  static const FIELD_URL_PHOTO = 'url_photo';
  static const FIELD_LATITUDE = 'latitude';
  static const FIELD_LONGITUDE = 'longitude';

  int? id;
  String name;
  String cep;
  String? workingHours;
  String? differential;
  String? longitude;
  String? latitude;
  DateTime? createAt;
  String? urlPhoto;

  TuristSpots({
    this.id,
    required this.name,
    required this.cep,
    this.workingHours,
    this.differential,
    this.longitude,
    this.latitude,
    this.createAt,
    this.urlPhoto,
  });

  String get dateFormatted {
    if (createAt == null) {
      return "";
    }
    return DateFormat('dd/MM/yyyy').format(createAt!);
  }

  TuristSpots copyWith({
    int? id,
    String? name,
    String? cep,
    String? workingHours,
    String? hourClose,
    String? differential,
    String? latitude,
    String? longitude,
    DateTime? createAt,
    String? urlPhoto,
  }) {
    return TuristSpots(
      id: id ?? this.id,
      name: name ?? this.name,
      cep: cep ?? this.cep,
      workingHours: workingHours ?? this.workingHours,
      differential: differential ?? this.differential,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      createAt: createAt ?? this.createAt,
      urlPhoto: urlPhoto ?? this.urlPhoto,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'id': id,
      'name': name,
      'cep': cep,
      'working_hours': workingHours,
      'differential': differential,
      'create_at':
          createAt == null ? null : DateFormat("yyyy-MM-dd").format(createAt!),
      'url_photo': urlPhoto,
      'longitude': longitude,
      'latitude': latitude,
    };
  }

  factory TuristSpots.fromMap(Map<String, dynamic> map) {
    return TuristSpots(
      id: map['_id'] != null ? map['_id'] as int : null,
      name: map['name'] as String,
      cep: map['cep'] as String,
      workingHours:
          map['working_hours'] != null ? map['working_hours'] as String : null,
      differential:
          map['differential'] != null ? map['differential'] as String : null,
      createAt: map['create_at'] != null
          ? DateFormat("yyyy-MM-dd").parse(map['create_at'])
          // ? DateTime.fromMillisecondsSinceEpoch(map['date'] as int)
          : null,
      urlPhoto: map['url_photo'] != null ? map['url_photo'] as String : null,
      longitude: map['longitude'] != null ? map['longitude'] as String : null,
      latitude: map['latitude'] != null ? map['latitude'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TuristSpots.fromJson(String source) =>
      TuristSpots.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TuristSpots(id: $id, name: $name, cep: $cep, workingHours: $workingHours, differential: $differential, createAt: $createAt, urlPhoto: $urlPhoto)';
  }

  @override
  bool operator ==(covariant TuristSpots other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.cep == cep &&
        other.workingHours == workingHours &&
        other.differential == differential &&
        other.createAt == createAt &&
        other.longitude == longitude &&
        other.latitude == latitude &&
        other.urlPhoto == urlPhoto;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        cep.hashCode ^
        workingHours.hashCode ^
        differential.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        createAt.hashCode;
  }
}
