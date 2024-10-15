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
  List<LatLng> polylineCoordinates = [];
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
    _setPolylineCoordinates();
    _setMarkers();
  }

  void _setPolylineCoordinates() {
    polylineCoordinates = [
      widget.sourceLatLng,
      widget.destinationLatLng,
    ];
  }

  _setMarkers() async {
    // Add Source Marker (Blue)
    markers.add(
      Marker(
        point: widget.sourceLatLng,
        width: 40,
        height: 40,
        child:  const Icon(
          Icons.location_on,
          color: Colors.blue,
          size: 40,
        ),
      ),
    );

    // Add Destination Marker (Red)
    markers.add(
      Marker(
        point: widget.destinationLatLng,
        width: 40,
        height: 40,
        child:  const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40,
        ),
      ),
    );

    // Add Checkpoint Markers within 1 km of the polyline
    for (int i = 1; i < widget.csvListData.length; i++) {
      LatLng point = widget.checkPoints[i - 1];

      if (_isPointNearPolyline(point)) {
        final Uint8List? markerIcon = await getByteFromAssets(
          iconImage[i % iconImage.length],
          50,
        );

        markers.add(
          Marker(
            point: point,
            width: 50,
            height: 50,
            child:  GestureDetector(
              onTap: () => _showFacilityDialog(context, widget.csvListData[i]),
              child: markerIcon != null
                  ? Image.memory(markerIcon)
                  : const Icon(Icons.place, color: Colors.pink, size: 30),
            ),
          ),
        );
      }
    }
    setState(() {});
  }

  bool _isPointNearPolyline(LatLng point) {
    const double tolerance = 1.0; // 1 km tolerance

    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      LatLng start = polylineCoordinates[i];
      LatLng end = polylineCoordinates[i + 1];

      double distance = _calculateDistanceToLineSegment(point, start, end);
      if (distance <= tolerance) return true;
    }
    return false;
  }

  double _calculateDistanceToLineSegment(LatLng point, LatLng start, LatLng end) {
    final Distance distance = const Distance();

    double distToStart = distance.as(LengthUnit.Kilometer, point, start);
    double distToEnd = distance.as(LengthUnit.Kilometer, point, end);
    double distStartToEnd = distance.as(LengthUnit.Kilometer, start, end);

    if (distToStart + distToEnd == distStartToEnd) return 0.0;
    return distToStart < distToEnd ? distToStart : distToEnd;
  }



  void _showFacilityDialog(BuildContext context, List<dynamic> facilityData) {
    // Extract the place name from the CSV data (assuming it's at index 0)
    String placeName = facilityData[9].toString();

    // List of facilities to check (index 13-18)
    List<String> facilities = [
      "Separate female washroom",
      "Handicapped washroom facility",
      "Kids Feeding corner",
      "Separate female prayer room",
      "Kids and women refreshing area",
      "Others"
    ];

    // Collect available facilities
    List<String> availableFacilities = [];
    for (int j = 13; j <= 18; j++) {
      if (facilityData[j].toString().trim().toLowerCase() == 'yes') {
        availableFacilities.add(facilities[j - 13]);
      }
    }

    // Show the bottom sheet with place name and available facilities
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display the place name
              Text(
                placeName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
            Text(
              'Facilities Available',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
              SizedBox(height: 10,),
              // Display available facilities or "No facilities available"
              if (availableFacilities.isEmpty)
                ListTile(
                    leading: const Icon(Icons.highlight_remove_outlined, color: Colors.redAccent),
                    title: Text("No facilities available."))
              else
                ...availableFacilities.map(
                      (facility) => ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(facility),
                  ),
                ),
            ],
          ),
        );
      },
    );
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
          PolylineLayer(
            polylines: [
              Polyline(
                points: polylineCoordinates,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
