import 'package:drivers/screens/account.dart';
import 'package:drivers/screens/home.dart'; // This is your home page
import 'package:drivers/screens/loading_screen.dart';
// Assuming this is your account/login screen
import 'package:drivers/screens/mapscreen.dart';
import 'package:drivers/screens/messagescreen.dart';
import 'package:drivers/screens/notificationscreen.dart';
import 'package:drivers/style/barvy.dart';
import 'package:drivers/upload_stations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Carmio App',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: LoadingScreen(), // MainApp includes the BottomNavigationBar
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  // List of screens for navigation
  final List<Widget> _screens = [
    MyHomePage(
      stations: [],
    ), // Home screen
    NotificationsScreen(), // Notifications screen
    MapScreen(), //Map screen
    MessagesScreen(),
    AccountScreen(), // Account screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Display the currently selected screen
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.secondary,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onPrimary,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            activeIcon: Image.asset(
              'assets/home.png',
              color: colorScheme.primary,
            ),
            icon: Image.asset('assets/home.png'),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            activeIcon: Image.asset(
              'assets/hledat.png',
              color: colorScheme.primary,
            ),
            icon: Image.asset('assets/hledat.png'),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/pridat.png'),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/zpravy.png'),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/profil.png'),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
