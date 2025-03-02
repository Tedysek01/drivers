import 'package:drivers/screens/account.dart';
import 'package:drivers/screens/create_popup.dart';
import 'package:drivers/screens/home.dart'; // This is your home page
import 'package:drivers/screens/loading_screen.dart';
// Assuming this is your account/login screen
import 'package:drivers/screens/explore.dart';
import 'package:drivers/screens/messagescreen.dart';
import 'package:drivers/screens/notificationscreen.dart';
import 'package:drivers/style/barvy.dart';
import 'package:drivers/upload_stations.dart';
import 'package:drivers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'data_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DataProvider()..loadData()),
        ChangeNotifierProvider(create: (context) => UserProvider()..loadUserData()),
      ],
      child: MyApp(), // Zde už předáváš správně child
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Carmio App',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange)),

      home: LoadingScreen(),
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
    MyHomePage(stations: []),
    Explore(),
    Container(), // Placeholder, since CreatePopup is not a screen
    ChatListScreen(),
    ProfileScreen(),
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
  showSelectedLabels: true,
  showUnselectedLabels: false,
  iconSize: 32, // 🔥 Nastavení globální velikosti ikon
  currentIndex: _currentIndex,
  onTap: (index) {
    if (index == 2) {
      CreatePopup.show(context); // Otevře popup místo navigace
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  },
  items: <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      activeIcon: Image.asset(
        'assets/home.png',
        color: colorScheme.primary,
        width: 32, 
        height: 32,
      ),
      icon: Image.asset(
        'assets/home.png',
        width: 30, 
        height: 30,
      ),
      label: 'Domov',
    ),
    BottomNavigationBarItem(
      activeIcon: Image.asset(
        'assets/hledat.png',
        color: colorScheme.primary,
        width: 32,
        height: 32,
      ),
      icon: Image.asset(
        'assets/hledat.png',
        width: 30,
        height: 30,
      ),
      label: 'Objevovat',
    ),
    BottomNavigationBarItem(
      activeIcon: Image.asset(
        'assets/pridat.png',
        color: colorScheme.primary,
        width: 24, 
        height: 24,
      ),
      icon: Image.asset(
        'assets/pridat.png',
        width: 32,
        height: 32,
      ),
      label: 'Přidat',
    ),
    BottomNavigationBarItem(
      activeIcon: Image.asset(
        'assets/zpravy.png',
        color: colorScheme.primary,
        width: 32,
        height: 32,
      ),
      icon: Image.asset(
        'assets/zpravy.png',
        width: 30,
        height: 30,
      ),
      label: 'Zprávy',
    ),
    BottomNavigationBarItem(
      activeIcon: Image.asset(
        'assets/profil.png',
        color: colorScheme.primary,
        width: 32,
        height: 32,
      ),
      icon: Image.asset(
        'assets/profil.png',
        width: 30,
        height: 30,
      ),
      label: 'Profil',
    ),
  ],
),

    );
  }
}
