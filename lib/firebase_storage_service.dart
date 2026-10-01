import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'main.dart';
import 'local_storage_service.dart';
import 'storage_service.dart';
import 'user_profile.dart';

/// Cloud Firestore and Firebase Auth implementation of [StorageService].
/// Medical data and account info are strictly linked to the authenticated Firebase account.
/// Local storage is synced while logged in and cleared upon log out.
class FirebaseStorageService implements StorageService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();

  static String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get current authenticated Firebase user
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
        // Clear local medical data on log out
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

  /// Record/update user login info in Firebase Firestore server asynchronously
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
            .timeout(const Duration(seconds: 4));

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
        // Existing user logging in: fetch current Firestore document first to preserve synced profile info
        final docSnapshot = await userDocRef.get().timeout(const Duration(seconds: 4));

        if (docSnapshot.exists && docSnapshot.data() != null) {
          final data = docSnapshot.data()!;

          // Update last login timestamp in server
          await userDocRef.set({
            'uid': user.uid,
            'email': user.email ?? 'Anonymous',
            'lastLogin': FieldValue.serverTimestamp(),
            'lastLoginIso': nowIso,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)).timeout(const Duration(seconds: 4));

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

          // Update local cache with remote user profile
          await _localStorage.saveUserProfile(profile);
        } else {
          // Document does not exist on server yet, initialize profile
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
              .timeout(const Duration(seconds: 4));

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

  /// Sign in using Firebase Auth with Email & Password and store login info in Firestore
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _localStorage.setLoggedIn(true);

      if (credential.user != null) {
        // Run server sync with timeout so auth completion is never blocked
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

  /// Sign up a new user using Firebase Auth with Email & Password and store login info in Firestore
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _localStorage.setLoggedIn(true);

      if (credential.user != null) {
        // Run server sync with timeout so auth completion is never blocked
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

  /// Sign in anonymously and store login info in Firestore
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
      // Pull login & user profile info from Cloud Firestore server (4s timeout)
      final docSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 4));

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        // Fallback or new profile
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

      // Store in local storage for fast access
      await _localStorage.saveUserProfile(profile);

      return profile;
    } catch (e) {
      if (kDebugMode) {
        print('Error pulling user profile from Firestore server: $e');
      }
      // Fallback to local cache if server is temporarily unreachable or timed out
      return await _localStorage.getUserProfile();
    }
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    final user = _auth.currentUser;

    // Always update local cache
    await _localStorage.saveUserProfile(profile);

    if (user == null) return;

    try {
      // Push updated profile to Firestore server with timeout
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
      ).timeout(const Duration(seconds: 4));
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
      // User is logged out: return empty list and ensure local storage is clear
      await _localStorage.saveMedicines([]);
      return [];
    }

    final today = _getTodayString();

    try {
      // Pull medical data from Firebase Cloud Firestore server with timeout
      final docSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 4));

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        // New account on Firebase without medical data
        await _localStorage.saveMedicines([]);
        return [];
      }

      final data = docSnapshot.data()!;
      final String? lastDate = data['lastDate'] as String?;
      final List<dynamic> jsonList = data['medicines'] as List<dynamic>? ?? [];

      final medicines = jsonList
          .map((item) => Medicine.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      // Reset 'taken' status if accessing on a new day
      if (lastDate != null && lastDate != today) {
        for (var med in medicines) {
          med.taken = false;
        }
        await saveMedicines(medicines);
      } else {
        // Store locally while account remains logged in
        await _localStorage.saveMedicines(medicines);
      }

      return medicines;
    } catch (e) {
      if (kDebugMode) {
        print('Error pulling medicines from Firestore server: $e');
      }
      // If server is unreachable, load local cache while user is logged in
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

    // Cache locally as long as the user stays logged in
    await _localStorage.saveMedicines(medicines);

    try {
      // Push medical data to Firebase server linked to user.uid
      await _firestore.collection('users').doc(user.uid).set(
        {
          'medicines': jsonList,
          'lastDate': today,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      ).timeout(const Duration(seconds: 4));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving medicines to Firestore server: $e');
      }
    }
  }
}
