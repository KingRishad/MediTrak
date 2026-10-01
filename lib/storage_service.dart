import 'main.dart';
import 'user_profile.dart';

abstract class StorageService {
  Future<bool> isLoggedIn();

  Future<void> setLoggedIn(bool loggedIn);

  Future<List<Medicine>> loadMedicines();

  Future<void> saveMedicines(List<Medicine> medicines);

  Future<UserProfile?> getUserProfile();

  Future<void> saveUserProfile(UserProfile profile);
}
