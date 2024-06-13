import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
class ShowRestArea extends StatefulWidget {
  final List<List<dynamic>> csvListData;
  final List<LatLng> checkPoints;
  LatLng sourceLatLng;
  LatLng destinationLatLng;
  ShowRestArea({super.key, required this.sourceLatLng, required this.destinationLatLng, required this.csvListData, required this.checkPoints});

  @override
  State<ShowRestArea> createState() => _ShowRestAreaState();
}

class _ShowRestAreaState extends State<ShowRestArea> {
  GoogleMapController? _controller;
  List<LatLng> polylineCoordinates = [];
  List<Marker> _markers = [];
  Uint8List? markerImage;

  List<String> iconImage = ['assets/icon/public_toilet.png','assets/icon/hospital_moon.png',
  'assets/icon/park.png','assets/icon/mall.png', 'assets/icon/hotel.png', 'assets/icon/restaurant.png',
    'assets/icon/petrol_station.png','assets/icon/mosque.png'
  ];

  Future<Uint8List?> getByteFromAssets(String path, int width)async{
    print('this function call for making custom icon');
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))?.buffer.asUint8List();

  }

  @override
  void initState() {
    super.initState();

    _setPolyline();
  }


  _setPolyline() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyDtrIULtBZpbwdbvDlMiwf8W9u8Zem1T1g', // Replace with your actual Google API Key
      PointLatLng(widget.sourceLatLng.latitude, widget.sourceLatLng.longitude),
      PointLatLng(widget.destinationLatLng.latitude, widget.destinationLatLng.longitude),
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates = result.points
          .map((PointLatLng point) => LatLng(point.latitude, point.longitude))
          .toList();
    }

    _addMarkers();
    setState(() {});
  }

  _addMarkers() async {
    _markers.add(Marker(
      markerId: const MarkerId('source'),
      position: widget.sourceLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),  // source color icon blue
      infoWindow: const InfoWindow(title: 'Source'),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('destination'),
      position: widget.destinationLatLng,
      infoWindow: const InfoWindow(title: 'Destination'),
    ));

    for(int i=1, j=0; i<widget.csvListData.length; i++, j++)
      {
        // print('call function which is check near point');
        LatLng point = widget.checkPoints[j];
        // print(point);
        if (_isPointNearPolyline(point)) {
          print('Find near by point');
          //public toilet
          if(widget.csvListData[i][0].trim().toLowerCase() == 'yes'){
            // Concatenate facility information
            String facilities = '';
            String placename = widget.csvListData[i][9];
            final Uint8List? markerIcon = await getByteFromAssets(iconImage[0], 50);
            for (int j = 14; j <= 19; j++) {
              if (widget.csvListData[i][j].trim().isNotEmpty) {
                facilities += '${widget.csvListData[i][j].trim()}, ';
              }
            }
            // Remove the trailing comma and space
            if (facilities.isNotEmpty) {
              facilities = facilities.substring(0, facilities.length - 2);
            }
            _markers.add(Marker(markerId: MarkerId(point.toString()),
            position: point,
              icon: BitmapDescriptor.fromBytes(markerIcon!),
              infoWindow:  InfoWindow(
                title: '${placename}',
                snippet: facilities
              )
            ));
          }
          else if(widget.csvListData[i][1].trim().toLowerCase() == 'yes'){
            // Concatenate facility information
            String facilities = '';
            String placename = widget.csvListData[i][9];
            final Uint8List? markerIcon = await getByteFromAssets(iconImage[1], 50);
            for (int j = 14; j <= 19; j++) {
              if (widget.csvListData[i][j].trim().isNotEmpty) {
                facilities += '${widget.csvListData[i][j].trim()}, ';
              }
            }
            // Remove the trailing comma and space
            if (facilities.isNotEmpty) {
              facilities = facilities.substring(0, facilities.length - 2);
            }
            _markers.add(Marker(markerId: MarkerId(point.toString()),
                position: point,
                icon: BitmapDescriptor.fromBytes(markerIcon!),
                infoWindow:  InfoWindow(
                    title: '${placename}',
                    snippet: facilities
                )
            ));
          }
          else  if(widget.csvListData[i][2].trim().toLowerCase() == 'yes'){
            // Concatenate facility information
            String facilities = '';
            String placename = widget.csvListData[i][9];
            final Uint8List? markerIcon = await getByteFromAssets(iconImage[2], 50);
            for (int j = 14; j <= 19; j++) {
              if (widget.csvListData[i][j].trim().isNotEmpty) {
                facilities += '${widget.csvListData[i][j].trim()}, ';
              }
            }
            // Remove the trailing comma and space
            if (facilities.isNotEmpty) {
              facilities = facilities.substring(0, facilities.length - 2);
            }
            _markers.add(Marker(markerId: MarkerId(point.toString()),
                position: point,
                icon: BitmapDescriptor.fromBytes(markerIcon!),
                infoWindow:  InfoWindow(
                    title: '${placename}',
                    snippet: facilities
                )
            ));
          }
          else  if(widget.csvListData[i][3].trim().toLowerCase() == 'yes'){
            // Concatenate facility information
            String facilities = '';
            String placename = widget.csvListData[i][9];
            final Uint8List? markerIcon = await getByteFromAssets(iconImage[3], 50);
            for (int j = 14; j <= 19; j++) {
              if (widget.csvListData[i][j].trim().isNotEmpty) {
                facilities += '${widget.csvListData[i][j].trim()}, ';
              }
            }
            // Remove the trailing comma and space
            if (facilities.isNotEmpty) {
              facilities = facilities.substring(0, facilities.length - 2);
            }
            _markers.add(Marker(markerId: MarkerId(point.toString()),
                position: point,
                icon: BitmapDescriptor.fromBytes(markerIcon!),
                infoWindow:  InfoWindow(
                    title: '${placename}',
                    snippet: facilities
                )
            ));
          }
          else  if(widget.csvListData[i][4].trim().toLowerCase() == 'yes'){
            // Concatenate facility information
            String facilities = '';
            String placename = widget.csvListData[i][9];
            final Uint8List? markerIcon = await getByteFromAssets(iconImage[4], 50);
            for (int j = 14; j <= 19; j++) {
              if (widget.csvListData[i][j].trim().isNotEmpty) {
                facilities += '${widget.csvListData[i][j].trim()}, ';
              }
            }
            // Remove the trailing comma and space
            if (facilities.isNotEmpty) {
              facilities = facilities.substring(0, facilities.length - 2);
            }
            _markers.add(Marker(markerId: MarkerId(point.toString()),
                position: point,
                icon: BitmapDescriptor.fromBytes(markerIcon!),
                infoWindow:  InfoWindow(
                    title: '${placename}',
                    snippet: facilities
                )
            ));
          }
          else  if(widget.csvListData[i][5].trim().toLowerCase() == 'yes'){
            // Concatenate facility information
            String facilities = '';
            String placename = widget.csvListData[i][9];
            final Uint8List? markerIcon = await getByteFromAssets(iconImage[5], 50);
            for (int j = 14; j <= 19; j++) {
              if (widget.csvListData[i][j].trim().isNotEmpty) {
                facilities += '${widget.csvListData[i][j].trim()}, ';
              }
            }
            // Remove the trailing comma and space
            if (facilities.isNotEmpty) {
              facilities = facilities.substring(0, facilities.length - 2);
            }
            _markers.add(Marker(markerId: MarkerId(point.toString()),
                position: point,
                icon: BitmapDescriptor.fromBytes(markerIcon!),
                infoWindow:  InfoWindow(
                    title: '${placename}',
                    snippet: facilities
                )
            ));
          }
          else  if(widget.csvListData[i][6].trim().toLowerCase() == 'yes'){
            // Concatenate facility information
            String facilities = '';
            String placename = widget.csvListData[i][9];
            final Uint8List? markerIcon = await getByteFromAssets(iconImage[6], 50);
            for (int j = 14; j <= 19; j++) {
              if (widget.csvListData[i][j].trim().isNotEmpty) {
                facilities += '${widget.csvListData[i][j].trim()}, ';
              }
            }
            // Remove the trailing comma and space
            if (facilities.isNotEmpty) {
              facilities = facilities.substring(0, facilities.length - 2);
            }
            _markers.add(Marker(markerId: MarkerId(point.toString()),
                position: point,
                icon: BitmapDescriptor.fromBytes(markerIcon!),
                infoWindow:  InfoWindow(
                    title: '${placename}',
                    snippet: facilities
                )
            ));
          }
          else  if(widget.csvListData[i][7].trim().toLowerCase() == 'yes'){
            // Concatenate facility information
            String facilities = '';
            String placename = widget.csvListData[i][9];
            final Uint8List? markerIcon = await getByteFromAssets(iconImage[7], 50);
            for (int j = 14; j <= 19; j++) {
              if (widget.csvListData[i][j].trim().isNotEmpty) {
                facilities += '${widget.csvListData[i][j].trim()}, ';
              }
            }
            // Remove the trailing comma and space
            if (facilities.isNotEmpty) {
              facilities = facilities.substring(0, facilities.length - 2);
            }
            _markers.add(Marker(markerId: MarkerId(point.toString()),
                position: point,
                icon: BitmapDescriptor.fromBytes(markerIcon!),
                infoWindow:  InfoWindow(
                    title: '${placename}',
                    snippet: facilities
                )
            ));
          }
          else  if(widget.csvListData[i][8].trim().toLowerCase() == 'yes'){
            // Concatenate facility information
            String facilities = '';
            String placename = widget.csvListData[i][9];

            for (int j = 14; j <= 19; j++) {
              if (widget.csvListData[i][j].trim().isNotEmpty) {
                facilities += '${widget.csvListData[i][j].trim()}, ';
              }
            }
            // Remove the trailing comma and space
            if (facilities.isNotEmpty) {
              facilities = facilities.substring(0, facilities.length - 2);
            }
            _markers.add(Marker(markerId: MarkerId(point.toString()),
                position: point,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
                infoWindow:  InfoWindow(
                    title: '${placename}',
                    snippet: facilities
                )
            ));
          }

        }
      }

  }

  bool _isPointNearPolyline(LatLng point) {
    const double tolerance = 5.0; // Tolerance in kilometers
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      LatLng start = polylineCoordinates[i];
      LatLng end = polylineCoordinates[i + 1];
      double distance = _calculateDistanceToLineSegment(point, start, end);
      if (distance < tolerance) {
        return true;
      }
    }
    return false;
  }

  double _calculateDistanceToLineSegment(LatLng point, LatLng start, LatLng end) {
    double x0 = point.latitude;
    double y0 = point.longitude;
    double x1 = start.latitude;
    double y1 = start.longitude;
    double x2 = end.latitude;
    double y2 = end.longitude;

    double A = x0 - x1;
    double B = y0 - y1;
    double C = x2 - x1;
    double D = y2 - y1;

    double dot = A * C + B * D;
    double len_sq = C * C + D * D;
    double param = (len_sq != 0) ? dot / len_sq : -1;

    double xx, yy;

    if (param < 0) {
      xx = x1;
      yy = y1;
    } else if (param > 1) {
      xx = x2;
      yy = y2;
    } else {
      xx = x1 + param * C;
      yy = y1 + param * D;
    }

    double dx = x0 - xx;
    double dy = y0 - yy;

    return _calculateDistance(LatLng(x0, y0), LatLng(xx, yy));
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // Radius of the Earth in kilometers
    double dLat = _degreesToRadians(end.latitude - start.latitude);
    double dLon = _degreesToRadians(end.longitude - start.longitude);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(_degreesToRadians(start.latitude)) *
                cos(_degreesToRadians(end.latitude)) *
                sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rest Area Recommended"),centerTitle: true,elevation: 10,),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.sourceLatLng,
          zoom: 13,
        ),
        markers: Set<Marker>.of(_markers),
        polylines: {
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
    );
  }
}
