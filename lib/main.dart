import 'package:drivers/screens/home.dart';
import 'package:drivers/style/barvy.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase core balíček
import '../firebase_options.dart'; // Import Firebase konfiguračního souboru

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Zajišťuje inicializaci widgetů
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Načte konfiguraci podle platformy
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Inter',
        useMaterial3: true,
        scaffoldBackgroundColor: colorScheme.surface,
      ),
      home: const MyHomePage(),
    );
  }
}
