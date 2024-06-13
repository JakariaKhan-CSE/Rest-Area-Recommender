import 'package:flutter/material.dart';
import 'package:rest_area_recommended/homepage.dart';
import 'package:rest_area_recommended/splash_screen.dart';
void main()=>runApp(const myApp());

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
