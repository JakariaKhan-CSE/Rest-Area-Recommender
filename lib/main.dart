import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:rest_area_recommended/splash_screen.dart';

void main() async{
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
      themeMode: ThemeMode.light,
      home: SplashScreen(),
    );
  }
}
