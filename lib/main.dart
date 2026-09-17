import 'package:flutter/material.dart';
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
      home: const LoginScreen(),
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
}
