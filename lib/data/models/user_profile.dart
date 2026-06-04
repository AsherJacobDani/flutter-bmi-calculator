import 'bmi_record.dart';

class UserProfile {
  final String userId;
  final String name;
  final String email;
  final List<BMIRecord> bmiHistory;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.bmiHistory = const [],
  });

  UserProfile copyWith({
    String? userId,
    String? name,
    String? email,
    List<BMIRecord>? bmiHistory,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      bmiHistory: bmiHistory ?? this.bmiHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'bmiHistory': bmiHistory.map((x) => x.toJson()).toList(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      bmiHistory: (json['bmiHistory'] as List<dynamic>?)
              ?.map((x) => BMIRecord.fromJson(x as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
