import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShowRestArea extends StatefulWidget {
  LatLng sourceLatLng;
  LatLng destinationLatLng;
  ShowRestArea({super.key, required this.sourceLatLng, required this.destinationLatLng});

  @override
  State<ShowRestArea> createState() => _ShowRestAreaState();
}

class _ShowRestAreaState extends State<ShowRestArea> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rest Area Recommended"),centerTitle: true,elevation: 10,),
      body: Center(
        child: Text('${widget.sourceLatLng}            - ${widget.destinationLatLng}'),
      ),
    );
  }
}
