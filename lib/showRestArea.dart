import 'package:flutter/material.dart';

class ShowRestArea extends StatefulWidget {
  const ShowRestArea({super.key});

  @override
  State<ShowRestArea> createState() => _ShowRestAreaState();
}

class _ShowRestAreaState extends State<ShowRestArea> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rest Area Recommended"),centerTitle: true,elevation: 10,),
    );
  }
}
