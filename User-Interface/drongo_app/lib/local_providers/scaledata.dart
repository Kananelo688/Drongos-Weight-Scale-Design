import 'dart:convert';

class ScaleData {
  final String tagID;
  final String date;
  final String latitude;
  final String time;
  final String longitude;
  final double mass;

  ScaleData({
    required this.tagID,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.time,
    required this.mass,
  });

  factory ScaleData.fromJson(Map<String, dynamic> json) {
    return ScaleData(
      tagID: json['tagID'] as String,
      date: json['date'] as String,
      latitude: json['latitude'],
      longitude: json['longitude'] as String,
      time: json['time'] as String,
      mass: json['mass'] as double,
    );
  }
}
