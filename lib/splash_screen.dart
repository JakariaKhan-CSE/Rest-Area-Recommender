import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rest_area_recommended/homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(const Duration(seconds: 4), ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx)=>const HomePage())));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Animate(
          effects: const [FadeEffect(duration: Duration(milliseconds: 1500)),ScaleEffect(duration: Duration(milliseconds: 1500))],
          child: Image.asset('assets/images/splash_screen.png'),
        )
      ),
    );
  }
}
