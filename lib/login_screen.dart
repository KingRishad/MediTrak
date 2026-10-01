import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'data_storage.dart';
import 'home_page.dart';
import 'user_profile.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isSignUp = false;
  bool isLoading = false;

  String _getFriendlyErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
        case 'invalid-email-address':
          return 'Please enter a valid email address.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Invalid email/password.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'Password should be at least 6 characters.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many login attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        case 'operation-not-allowed':
          return 'Email login is currently disabled.';
        default:
          final msg = (e.message ?? '').toLowerCase();
          if (msg.contains('invalid email') || msg.contains('badly formatted')) {
            return 'Please enter a valid email address.';
          } else if (msg.contains('credential') || msg.contains('password') || msg.contains('user')) {
            return 'Invalid email/password.';
          }
          return 'Invalid email/password.';
      }
    }

    final errStr = e.toString().toLowerCase();
    if (errStr.contains('invalid-email') || errStr.contains('invalid email') || errStr.contains('badly formatted')) {
      return 'Please enter a valid email address.';
    } else if (errStr.contains('wrong-password') ||
        errStr.contains('user-not-found') ||
        errStr.contains('invalid-credential') ||
        errStr.contains('invalid email/password')) {
      return 'Invalid email/password.';
    } else if (errStr.contains('email-already-in-use')) {
      return 'An account already exists with this email address.';
    } else if (errStr.contains('weak-password')) {
      return 'Password should be at least 6 characters.';
    } else if (errStr.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }

    return 'Invalid email/password.';
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final firebaseStorage = DataStorage.firebaseInstance;

    if (firebaseStorage != null) {
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid email address.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid email address.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your password.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (isSignUp && password.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password should be at least 6 characters.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (firebaseStorage != null) {
        if (isSignUp) {
          await firebaseStorage.signUpWithEmail(email, password);
        } else {
          await firebaseStorage.signInWithEmail(email, password);
        }
      } else {
        if (email.isNotEmpty) {
          final existing = await DataStorage.instance.getUserProfile();
          final updated = (existing ??
                  UserProfile(
                    uid: 'local_user',
                    email: email,
                    name: email.contains('@') ? email.split('@').first : email,
                  ))
              .copyWith(
            email: email,
            name: email.contains('@') ? email.split('@').first : email,
          );
          await DataStorage.instance.saveUserProfile(updated);
        }
        await DataStorage.instance.setLoggedIn(true);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getFriendlyErrorMessage(e)),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.medication,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'MediTrak',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSignUp ? 'Create your account' : 'Track your medications easily',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email or Username',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            isSignUp ? 'Sign Up' : 'Login',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSignUp ? 'Already have an account? ' : 'Don\'t have an account? ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isSignUp = !isSignUp;
                        });
                      },
                      child: Text(
                        isSignUp ? 'Login' : 'Sign Up',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
