import 'package:flutter/material.dart';
import 'main.dart';
import 'today_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int currentTab = 0;
  List<Medicine> medicines = [];

  void refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget screen;
    if (currentTab == 0) {
      screen = TodayScreen(medicines: medicines);
    } else if (currentTab == 1) {
      screen = ProgressScreen(medicines: medicines);
    } else {
      screen = const ProfileScreen();
    }

    return Scaffold(
      body: screen,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentTab,
          onTap: (index) {
            setState(() {
              currentTab = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Today',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
