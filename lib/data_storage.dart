import 'local_storage_service.dart';
import 'storage_service.dart';

/// Central accessor for the active storage implementation.
/// To switch to Firebase later, assign a Firebase implementation to [DataStorage.instance]:
/// e.g. `DataStorage.instance = FirebaseStorageService();`
class DataStorage {
  static StorageService instance = LocalStorageService();
}
