import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'providers/deck_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DeckProvider(),
        ),
      ],
      child: const MemoraApp(),
    ),
  );
}

class MemoraApp extends StatelessWidget {
  const MemoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // App name
      title: 'Memora',

      // ========================================================
      // THEME
      // ========================================================

      // Light mode
      theme: AppTheme.lightTheme,

      // Dark mode
      darkTheme: AppTheme.darkTheme,

      // Follow the device's theme automatically
      themeMode: ThemeMode.system,

      // ========================================================
      // START SCREEN
      // ========================================================

      home: const SplashScreen(),
    );
  }
}