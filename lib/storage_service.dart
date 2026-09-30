import 'main.dart';
import 'user_profile.dart';

/// Abstract storage interface.
/// Implement this interface to swap local storage with Firebase or any other backend.
abstract class StorageService {
  /// Check whether the user is logged in
  Future<bool> isLoggedIn();

  /// Set user login status
  Future<void> setLoggedIn(bool loggedIn);

  /// Load all stored medicines
  Future<List<Medicine>> loadMedicines();

  /// Save or update the list of medicines
  Future<void> saveMedicines(List<Medicine> medicines);

  /// Pull user account login info and profile from server/storage
  Future<UserProfile?> getUserProfile();

  /// Push/save user profile updates to server/storage
  Future<void> saveUserProfile(UserProfile profile);
}
