import 'dart:convert';
import 'package:flutter/material.dart';

class AlarmModel {
  final int id;
  final String title;
  final int hour;
  final int minute;
  bool isEnabled;

  AlarmModel({
    required this.id,
    required this.title,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
  });

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  /// Serialisasi ke Map untuk disimpan di SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'hour': hour,
      'minute': minute,
      'isEnabled': isEnabled,
    };
  }

  /// Deserialisasi dari Map
  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      id: map['id'] as int,
      title: map['title'] as String,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      isEnabled: map['isEnabled'] as bool,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory AlarmModel.fromJson(String source) =>
      AlarmModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  AlarmModel copyWith({
    int? id,
    String? title,
    int? hour,
    int? minute,
    bool? isEnabled,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      title: title ?? this.title,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}