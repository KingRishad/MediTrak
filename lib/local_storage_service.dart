import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'storage_service.dart';

/// SharedPreferences implementation of [StorageService].
class LocalStorageService implements StorageService {
  static const String _keyMedicines = 'saved_medicines';
  static const String _keyLastDate = 'last_date';
  static const String _keyIsLoggedIn = 'is_logged_in';

  static String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  @override
  Future<void> setLoggedIn(bool loggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, loggedIn);
  }

  @override
  Future<List<Medicine>> loadMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyMedicines);
    final String? lastDate = prefs.getString(_keyLastDate);
    final String today = _getTodayString();

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final medicines = jsonList
          .map((item) => Medicine.fromJson(item as Map<String, dynamic>))
          .toList();

      // Reset 'taken' status if launching on a new day
      if (lastDate != null && lastDate != today) {
        for (var med in medicines) {
          med.taken = false;
        }
        await saveMedicines(medicines);
      }

      return medicines;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading medicines: $e');
      }
      return [];
    }
  }

  @override
  Future<void> saveMedicines(List<Medicine> medicines) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString =
        jsonEncode(medicines.map((m) => m.toJson()).toList());
    final String today = _getTodayString();

    await prefs.setString(_keyMedicines, jsonString);
    await prefs.setString(_keyLastDate, today);
  }
}
