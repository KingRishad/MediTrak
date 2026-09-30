import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meditrak/data_storage.dart';
import 'package:meditrak/local_storage_service.dart';
import 'package:meditrak/main.dart';
import 'package:meditrak/medicine_storage.dart';
import 'package:meditrak/storage_service.dart';
import 'package:meditrak/user_profile.dart';

class MockStorageService implements StorageService {
  bool _loggedIn = false;
  List<Medicine> _medicines = [];
  UserProfile? _profile;

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

  @override
  Future<UserProfile?> getUserProfile() async => _profile;

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    _profile = profile;
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

  test('UserProfile toJson and fromJson serialization works', () {
    final original = UserProfile(
      uid: 'firebase_123',
      email: 'test@meditrak.app',
      name: 'John Doe',
      age: '30',
      bloodGroup: 'O+',
      height: "5' 11\"",
      weight: '75 kg',
      allergies: 'Pollen',
      emergencyContact: '+123456789',
      lastLogin: '2025-02-23T10:00:00.000',
      createdAt: '2025-01-01T10:00:00.000',
    );

    final json = original.toJson();
    final restored = UserProfile.fromJson(json);

    expect(restored.uid, 'firebase_123');
    expect(restored.email, 'test@meditrak.app');
    expect(restored.name, 'John Doe');
    expect(restored.age, '30');
    expect(restored.bloodGroup, 'O+');
    expect(restored.allergies, 'Pollen');
    expect(restored.lastLogin, '2025-02-23T10:00:00.000');
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

  test('MedicineStorage loads and saves user profile to storage', () async {
    final profile = UserProfile(
      uid: 'uid_test',
      email: 'user@test.com',
      name: 'Test User',
      age: '28',
    );

    await MedicineStorage.saveUserProfile(profile);

    final loaded = await MedicineStorage.getUserProfile();

    expect(loaded, isNotNull);
    expect(loaded!.uid, 'uid_test');
    expect(loaded.email, 'user@test.com');
    expect(loaded.name, 'Test User');
    expect(loaded.age, '28');
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
