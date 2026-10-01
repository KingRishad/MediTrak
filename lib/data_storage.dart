import 'firebase_storage_service.dart';
import 'local_storage_service.dart';
import 'storage_service.dart';

class DataStorage {
  static StorageService instance = LocalStorageService();

  static bool get isFirebase => instance is FirebaseStorageService;

  static FirebaseStorageService? get firebaseInstance {
    if (instance is FirebaseStorageService) {
      return instance as FirebaseStorageService;
    }
    return null;
  }
}
