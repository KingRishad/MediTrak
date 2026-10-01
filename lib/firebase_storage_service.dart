import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'main.dart';
import 'local_storage_service.dart';
import 'storage_service.dart';
import 'user_profile.dart';

class FirebaseStorageService implements StorageService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();

  static String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  User? get currentUser => _auth.currentUser;

  @override
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  @override
  Future<void> setLoggedIn(bool loggedIn) async {
    try {
      await _localStorage.setLoggedIn(loggedIn);
      if (!loggedIn) {
        await _localStorage.saveMedicines([]);
        if (_auth.currentUser != null) {
          await _auth.signOut();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating login state: $e');
      }
    }
  }

  Future<void> _recordUserLoginInServer(User user, {bool isNewUser = false}) async {
    try {
      final nowIso = DateTime.now().toIso8601String();
      final userDocRef = _firestore.collection('users').doc(user.uid);

      if (isNewUser) {
        final defaultName = user.email != null && user.email!.contains('@')
            ? user.email!.split('@').first
            : 'User';

        final Map<String, dynamic> dataToUpdate = {
          'uid': user.uid,
          'email': user.email ?? 'Anonymous',
          'name': defaultName,
          'age': '',
          'bloodGroup': '',
          'height': '',
          'weight': '',
          'allergies': '',
          'emergencyContact': '',
          'lastLogin': FieldValue.serverTimestamp(),
          'lastLoginIso': nowIso,
          'createdAt': FieldValue.serverTimestamp(),
          'createdAtIso': nowIso,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await userDocRef
            .set(dataToUpdate, SetOptions(merge: true))
            .timeout(const Duration(seconds: 10));

        final profile = UserProfile(
          uid: user.uid,
          email: user.email ?? 'Anonymous',
          name: defaultName,
          age: '',
          bloodGroup: '',
          height: '',
          weight: '',
          allergies: '',
          emergencyContact: '',
          lastLogin: nowIso,
          createdAt: nowIso,
        );
        await _localStorage.saveUserProfile(profile);
      } else {
        final docSnapshot = await userDocRef.get().timeout(const Duration(seconds: 10));

        if (docSnapshot.exists && docSnapshot.data() != null) {
          final data = docSnapshot.data()!;

          await userDocRef.set({
            'uid': user.uid,
            'email': user.email ?? 'Anonymous',
            'lastLogin': FieldValue.serverTimestamp(),
            'lastLoginIso': nowIso,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)).timeout(const Duration(seconds: 10));

          String formatTimestamp(dynamic val, String fallbackIso) {
            if (val is Timestamp) {
              return val.toDate().toIso8601String();
            } else if (val is String && val.isNotEmpty) {
              return val;
            }
            return fallbackIso;
          }

          final createdAtStr = formatTimestamp(data['createdAt'], data['createdAtIso'] as String? ?? nowIso);

          final profile = UserProfile.fromJson(
            data,
            defaultUid: user.uid,
            defaultEmail: user.email ?? 'Anonymous',
          ).copyWith(
            lastLogin: nowIso,
            createdAt: createdAtStr,
          );

          await _localStorage.saveUserProfile(profile);

          final List<dynamic> jsonList = data['medicines'] as List<dynamic>? ?? [];
          final medicines = jsonList
              .map((item) => Medicine.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
          await _localStorage.saveMedicines(medicines);
        } else {
          final defaultName = user.email != null && user.email!.contains('@')
              ? user.email!.split('@').first
              : 'User';

          final Map<String, dynamic> dataToUpdate = {
            'uid': user.uid,
            'email': user.email ?? 'Anonymous',
            'name': defaultName,
            'age': '',
            'bloodGroup': '',
            'height': '',
            'weight': '',
            'allergies': '',
            'emergencyContact': '',
            'lastLogin': FieldValue.serverTimestamp(),
            'lastLoginIso': nowIso,
            'createdAt': FieldValue.serverTimestamp(),
            'createdAtIso': nowIso,
            'updatedAt': FieldValue.serverTimestamp(),
          };

          await userDocRef
              .set(dataToUpdate, SetOptions(merge: true))
              .timeout(const Duration(seconds: 10));

          final profile = UserProfile(
            uid: user.uid,
            email: user.email ?? 'Anonymous',
            name: defaultName,
            age: '',
            bloodGroup: '',
            height: '',
            weight: '',
            allergies: '',
            emergencyContact: '',
            lastLogin: nowIso,
            createdAt: nowIso,
          );
          await _localStorage.saveUserProfile(profile);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Background Firestore server sync warning/timeout: $e');
      }
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _localStorage.setLoggedIn(true);

      if (credential.user != null) {
        await _recordUserLoginInServer(credential.user!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Sign In error: ${e.message}');
      }
      rethrow;
    }
  }

  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _localStorage.setLoggedIn(true);

      if (credential.user != null) {
        await _recordUserLoginInServer(credential.user!, isNewUser: true);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Sign Up error: ${e.message}');
      }
      rethrow;
    }
  }

  Future<UserCredential?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      await _localStorage.setLoggedIn(true);

      if (credential.user != null) {
        await _recordUserLoginInServer(credential.user!);
      }

      return credential;
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Anonymous Sign In error: $e');
      }
      return null;
    }
  }

  @override
  Future<UserProfile?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return await _localStorage.getUserProfile();
    }

    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        final defaultName = user.email != null && user.email!.contains('@')
            ? user.email!.split('@').first
            : 'User';
        final defaultProfile = UserProfile(
          uid: user.uid,
          email: user.email ?? 'Anonymous',
          name: defaultName,
          age: '',
          bloodGroup: '',
          height: '',
          weight: '',
          allergies: '',
          emergencyContact: '',
          lastLogin: DateTime.now().toIso8601String(),
          createdAt: DateTime.now().toIso8601String(),
        );
        await saveUserProfile(defaultProfile);
        return defaultProfile;
      }

      final data = docSnapshot.data()!;
      
      String formatTimestamp(dynamic val, String fallbackIso) {
        if (val is Timestamp) {
          return val.toDate().toIso8601String();
        } else if (val is String && val.isNotEmpty) {
          return val;
        }
        return fallbackIso;
      }

      final lastLoginStr = formatTimestamp(data['lastLogin'], data['lastLoginIso'] as String? ?? '');
      final createdAtStr = formatTimestamp(data['createdAt'], data['createdAtIso'] as String? ?? '');

      final profile = UserProfile.fromJson(
        data,
        defaultUid: user.uid,
        defaultEmail: user.email ?? 'Anonymous',
      ).copyWith(
        lastLogin: lastLoginStr,
        createdAt: createdAtStr,
      );

      await _localStorage.saveUserProfile(profile);

      return profile;
    } catch (e) {
      if (kDebugMode) {
        print('Error pulling user profile from Firestore server: $e');
      }
      return await _localStorage.getUserProfile();
    }
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    final user = _auth.currentUser;

    await _localStorage.saveUserProfile(profile);

    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set(
        {
          'uid': profile.uid,
          'email': profile.email,
          'name': profile.name,
          'age': profile.age,
          'bloodGroup': profile.bloodGroup,
          'height': profile.height,
          'weight': profile.weight,
          'allergies': profile.allergies,
          'emergencyContact': profile.emergencyContact,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user profile to Firestore server: $e');
      }
    }
  }

  @override
  Future<List<Medicine>> loadMedicines() async {
    final user = _auth.currentUser;
    if (user == null) {
      await _localStorage.saveMedicines([]);
      return [];
    }

    final today = _getTodayString();

    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return await _localStorage.loadMedicines();
      }

      final data = docSnapshot.data()!;
      final String? lastDate = data['lastDate'] as String?;
      final List<dynamic> jsonList = data['medicines'] as List<dynamic>? ?? [];

      final medicines = jsonList
          .map((item) => Medicine.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      if (lastDate != null && lastDate != today) {
        for (var med in medicines) {
          med.taken = false;
        }
        await saveMedicines(medicines);
      } else {
        await _localStorage.saveMedicines(medicines);
      }

      return medicines;
    } catch (e) {
      if (kDebugMode) {
        print('Error pulling medicines from Firestore server: $e');
      }
      return await _localStorage.loadMedicines();
    }
  }

  @override
  Future<void> saveMedicines(List<Medicine> medicines) async {
    final user = _auth.currentUser;
    if (user == null) {
      await _localStorage.saveMedicines([]);
      return;
    }

    final today = _getTodayString();
    final jsonList = medicines.map((m) => m.toJson()).toList();

    await _localStorage.saveMedicines(medicines);

    try {
      await _firestore.collection('users').doc(user.uid).set(
        {
          'medicines': jsonList,
          'lastDate': today,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving medicines to Firestore server: $e');
      }
    }
  }
}
