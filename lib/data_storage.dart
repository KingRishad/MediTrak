import 'firebase_storage_service.dart';
import 'local_storage_service.dart';
import 'storage_service.dart';

/// Central accessor for the active storage implementation.
class DataStorage {
  static StorageService instance = LocalStorageService();

  /// Helper to check if the current storage service is Firebase
  static bool get isFirebase => instance is FirebaseStorageService;

  /// Helper to get [FirebaseStorageService] instance if active
  static FirebaseStorageService? get firebaseInstance {
    if (instance is FirebaseStorageService) {
      return instance as FirebaseStorageService;
    }
    return null;
  }
}
