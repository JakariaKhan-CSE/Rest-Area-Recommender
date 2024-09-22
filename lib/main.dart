import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:rest_area_recommended/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: 'AIzaSyDCaGFju9cW22XZrza2zk3_fu0ov11hfVg',
            appId: '1:308815385769:android:b540dcc07a821a060c05b8',
            messagingSenderId: '308815385769',
            projectId: 'rest-area-recomended'));
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
