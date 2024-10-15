import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ShowRestArea extends StatefulWidget {
  final List<List<dynamic>> csvListData;
  final List<LatLng> checkPoints;
  final LatLng sourceLatLng;
  final LatLng destinationLatLng;

  ShowRestArea({
    super.key,
    required this.sourceLatLng,
    required this.destinationLatLng,
    required this.csvListData,
    required this.checkPoints,
  });

  @override
  State<ShowRestArea> createState() => _ShowRestAreaState();
}

class _ShowRestAreaState extends State<ShowRestArea> {
  List<Marker> markers = [];
  List<String> iconImage = [
    'assets/icon/public_toilet.png',
    'assets/icon/hospital_moon.png',
    'assets/icon/park.png',
    'assets/icon/mall.png',
    'assets/icon/hotel.png',
    'assets/icon/restaurant.png',
    'assets/icon/petrol_station.png',
    'assets/icon/mosque.png'
  ];

  Future<Uint8List?> getByteFromAssets(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        ?.buffer
        .asUint8List();
  }

  @override
  void initState() {
    super.initState();
    _setMarkers();
  }

  _setMarkers() async {
    // Add Source Marker
    markers.add(
      Marker(
        point: widget.sourceLatLng,
        child: const Icon(
          Icons.location_on,
          color: Colors.blue,
          size: 30,
        ),
      ),
    );

    // Add Destination Marker
    markers.add(
      Marker(
        point: widget.destinationLatLng,
        child: const Icon(
          Icons.flag,
          color: Colors.red,
          size: 30,
        ),
      ),
    );

    // Add rest area markers from CSV
    for (int i = 1; i < widget.csvListData.length; i++) {
      LatLng point = widget.checkPoints[i - 1]; // Adjust index for checkPoints

      // Check if point is near polyline
      if (_isPointNearPolyline(point)) {
        final Uint8List? markerIcon = await getByteFromAssets(
          iconImage[i % iconImage.length],
          50,
        );

        markers.add(
          Marker(
            point: point,
            child: markerIcon != null
                ? Image.memory(markerIcon)
                : const Icon(Icons.place, color: Colors.pink, size: 30),
          ),
        );
      }
    }
    setState(() {});
  }

  bool _isPointNearPolyline(LatLng point) {
    const double tolerance = 1.0; // Tolerance in kilometers
    // Logic for checking proximity to polyline can be implemented here
    return true; // Placeholder return value for demonstration
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rest Area Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: widget.sourceLatLng,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
