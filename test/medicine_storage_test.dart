import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meditrak/data_storage.dart';
import 'package:meditrak/local_storage_service.dart';
import 'package:meditrak/main.dart';
import 'package:meditrak/medicine_storage.dart';
import 'package:meditrak/storage_service.dart';

class MockStorageService implements StorageService {
  bool _loggedIn = false;
  List<Medicine> _medicines = [];

  @override
  Future<bool> isLoggedIn() async => _loggedIn;

  @override
  Future<void> setLoggedIn(bool loggedIn) async {
    _loggedIn = loggedIn;
  }

  @override
  Future<List<Medicine>> loadMedicines() async => _medicines;

  @override
  Future<void> saveMedicines(List<Medicine> medicines) async {
    _medicines = List.from(medicines);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DataStorage.instance = LocalStorageService();
  });

  test('Medicine toJson and fromJson serialization works', () {
    final original = Medicine(
      name: 'Aspirin',
      form: 'Tablet',
      quantity: '2 pills',
      dose: '500 mg',
      frequency: 'Everyday',
      time: '08:00 AM',
      taken: true,
    );

    final json = original.toJson();
    final restored = Medicine.fromJson(json);

    expect(restored.name, 'Aspirin');
    expect(restored.form, 'Tablet');
    expect(restored.quantity, '2 pills');
    expect(restored.dose, '500 mg');
    expect(restored.frequency, 'Everyday');
    expect(restored.time, '08:00 AM');
    expect(restored.taken, isTrue);
  });

  test('MedicineStorage loads and saves medicines to SharedPreferences', () async {
    final list = [
      Medicine(
        name: 'Paracetamol',
        form: 'Tablet',
        quantity: '1 pill',
        dose: '250 mg',
        frequency: 'Everyday',
        time: '10:00 AM',
        taken: false,
      ),
    ];

    await MedicineStorage.saveMedicines(list);

    final loaded = await MedicineStorage.loadMedicines();

    expect(loaded.length, 1);
    expect(loaded.first.name, 'Paracetamol');
    expect(loaded.first.taken, isFalse);
  });

  test('MedicineStorage persists login state', () async {
    expect(await MedicineStorage.isLoggedIn(), isFalse);

    await MedicineStorage.setLoggedIn(true);
    expect(await MedicineStorage.isLoggedIn(), isTrue);

    await MedicineStorage.setLoggedIn(false);
    expect(await MedicineStorage.isLoggedIn(), isFalse);
  });

  test('DataStorage allows plugging in custom StorageService (e.g. Firebase)', () async {
    final mockStorage = MockStorageService();
    DataStorage.instance = mockStorage;

    expect(await DataStorage.instance.isLoggedIn(), isFalse);
    await DataStorage.instance.setLoggedIn(true);
    expect(await DataStorage.instance.isLoggedIn(), isTrue);

    final testMed = Medicine(
      name: 'Ibuprofen',
      form: 'Tablet',
      quantity: '1 pill',
      dose: '200 mg',
      frequency: 'Everyday',
      time: '12:00 PM',
    );
    await DataStorage.instance.saveMedicines([testMed]);

    final loaded = await DataStorage.instance.loadMedicines();
    expect(loaded.length, 1);
    expect(loaded.first.name, 'Ibuprofen');
  });
}
