import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:rest_area_recommended/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: 'AIzaSyDc1b3h8KR5JKIAbA5Ka9jCns84_0bVcWY',
            appId: '1:767718137838:android:c4cd792261fd89c4cdf8ff',
            messagingSenderId: '767718137838',
            projectId: 'restarearecommender'));
  } catch (e) {
    print('Firebase initialization error is: $e');
  }
  await Hive.initFlutter();
  await Hive.openBox('destinations');
  runApp(const myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light, // not get device theme all time use light theme
      home: SplashScreen(),
    );
  }
}
