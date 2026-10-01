import 'data_storage.dart';
import 'main.dart';
import 'user_profile.dart';

class MedicineStorage {
  static Future<bool> isLoggedIn() => DataStorage.instance.isLoggedIn();

  static Future<void> setLoggedIn(bool loggedIn) =>
      DataStorage.instance.setLoggedIn(loggedIn);

  static Future<List<Medicine>> loadMedicines() =>
      DataStorage.instance.loadMedicines();

  static Future<void> saveMedicines(List<Medicine> medicines) =>
      DataStorage.instance.saveMedicines(medicines);

  static Future<UserProfile?> getUserProfile() =>
      DataStorage.instance.getUserProfile();

  static Future<void> saveUserProfile(UserProfile profile) =>
      DataStorage.instance.saveUserProfile(profile);
}
