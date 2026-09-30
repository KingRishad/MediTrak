import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing user account login info and profile details.
class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String age;
  final String bloodGroup;
  final String height;
  final String weight;
  final String allergies;
  final String emergencyContact;
  final String lastLogin;
  final String createdAt;

  UserProfile({
    required this.uid,
    required this.email,
    this.name = '',
    this.age = '',
    this.bloodGroup = '',
    this.height = '',
    this.weight = '',
    this.allergies = '',
    this.emergencyContact = '',
    this.lastLogin = '',
    this.createdAt = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'age': age,
      'bloodGroup': bloodGroup,
      'height': height,
      'weight': weight,
      'allergies': allergies,
      'emergencyContact': emergencyContact,
      'lastLogin': lastLogin,
      'createdAt': createdAt,
    };
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Timestamp) return value.toDate().toIso8601String();
    return value.toString();
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    String defaultUid = '',
    String defaultEmail = '',
  }) {
    final parsedUid = _parseString(json['uid']);
    final parsedEmail = _parseString(json['email']);

    final lastLoginVal = _parseString(json['lastLogin']).isNotEmpty
        ? _parseString(json['lastLogin'])
        : _parseString(json['lastLoginIso']);

    final createdAtVal = _parseString(json['createdAt']).isNotEmpty
        ? _parseString(json['createdAt'])
        : _parseString(json['createdAtIso']);

    return UserProfile(
      uid: parsedUid.isNotEmpty ? parsedUid : defaultUid,
      email: parsedEmail.isNotEmpty ? parsedEmail : defaultEmail,
      name: _parseString(json['name']),
      age: _parseString(json['age']),
      bloodGroup: _parseString(json['bloodGroup']),
      height: _parseString(json['height']),
      weight: _parseString(json['weight']),
      allergies: _parseString(json['allergies']),
      emergencyContact: _parseString(json['emergencyContact']),
      lastLogin: lastLoginVal,
      createdAt: createdAtVal,
    );
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? name,
    String? age,
    String? bloodGroup,
    String? height,
    String? weight,
    String? allergies,
    String? emergencyContact,
    String? lastLogin,
    String? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      allergies: allergies ?? this.allergies,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
