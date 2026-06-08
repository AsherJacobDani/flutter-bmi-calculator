import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../models/bmi_record.dart';

class UserProfileRepository {
  static const String _keyUserProfile = 'user_profile';

  Future<void> saveUserProfile(UserProfile userProfile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(userProfile.toJson());
    await prefs.setString(_keyUserProfile, jsonString);
  }

  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUserProfile);
    if (jsonString == null) return null;
    try {
      final Map<String, dynamic> jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return UserProfile.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  Future<void> addBMIRecord(String userId, BMIRecord record) async {
    var currentProfile = await getUserProfile();
    if (currentProfile == null || currentProfile.userId != userId) {
      final user = FirebaseAuth.instance.currentUser;
      final name = (user?.displayName != null && user!.displayName!.isNotEmpty)
          ? user.displayName!
          : (user?.email?.split('@')[0] ?? 'User');
      currentProfile = UserProfile(
        userId: userId,
        name: name,
        email: user?.email ?? '',
        bmiHistory: [],
      );
    }
    final updatedHistory = List<BMIRecord>.from(currentProfile.bmiHistory)..add(record);
    final updatedProfile = currentProfile.copyWith(bmiHistory: updatedHistory);
    await saveUserProfile(updatedProfile);
  }

  Future<List<BMIRecord>> getBMIHistory(String userId) async {
    final currentProfile = await getUserProfile();
    if (currentProfile != null && currentProfile.userId == userId) {
      return currentProfile.bmiHistory;
    }
    return [];
  }
}
