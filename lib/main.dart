import 'package:flutter/material.dart';
import 'data_storage.dart';
import 'home_page.dart';
import 'login_screen.dart';

void main() {
  runApp(const MediTrack());
}

class MediTrack extends StatelessWidget {
  const MediTrack({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey.shade100,
        fontFamily: 'Roboto',
      ),
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: DataStorage.instance.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.data == true) {
          return const HomePage();
        }
        return const LoginScreen();
      },
    );
  }
}

class Medicine {
  String name;
  String form;
  String quantity;
  String dose;
  String frequency;
  String time;
  bool taken;

  Medicine({
    required this.name,
    required this.form,
    required this.quantity,
    required this.dose,
    required this.frequency,
    required this.time,
    this.taken = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'form': form,
      'quantity': quantity,
      'dose': dose,
      'frequency': frequency,
      'time': time,
      'taken': taken,
    };
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'] as String? ?? '',
      form: json['form'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '',
      dose: json['dose'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      time: json['time'] as String? ?? '',
      taken: json['taken'] as bool? ?? false,
    );
  }
}
