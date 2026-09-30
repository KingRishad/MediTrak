import 'data_storage.dart';
import 'main.dart';

/// Legacy helper class that delegates calls to [DataStorage.instance].
class MedicineStorage {
  static Future<bool> isLoggedIn() => DataStorage.instance.isLoggedIn();

  static Future<void> setLoggedIn(bool loggedIn) =>
      DataStorage.instance.setLoggedIn(loggedIn);

  static Future<List<Medicine>> loadMedicines() =>
      DataStorage.instance.loadMedicines();

  static Future<void> saveMedicines(List<Medicine> medicines) =>
      DataStorage.instance.saveMedicines(medicines);
}
