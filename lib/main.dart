import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/user_info_screen.dart';
import 'firebase_options.dart';
import 'home.dart'; // yeni eklediğimiz HomePage burada

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final hasUserInfo = prefs.containsKey('user_name') && prefs.containsKey('birth_date');

  runApp(MyApp(showUserInfoScreen: !hasUserInfo));
}

class MyApp extends StatelessWidget {
  final bool showUserInfoScreen;

  const MyApp({super.key, required this.showUserInfoScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fal Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        ),
      ),
      supportedLocales: const [
        Locale('en', 'US'), // İngilizce
        Locale('tr', 'TR'), // Türkçe
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: showUserInfoScreen ? const UserInfoScreen() : const HomePage(),
    );
  }
}
