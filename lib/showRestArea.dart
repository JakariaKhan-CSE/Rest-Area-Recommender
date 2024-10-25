import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class ShowRestArea extends StatefulWidget {
  final List<List<dynamic>> csvListData;
  // final List<LatLng> checkPoints;
  LatLng sourceLatLng;
  LatLng destinationLatLng;
  ShowRestArea({
    super.key,
    required this.sourceLatLng,
    required this.destinationLatLng,
     required this.csvListData,
  });

  @override
  State<ShowRestArea> createState() => _ShowRestAreaState();
}

class _ShowRestAreaState extends State<ShowRestArea> {
  final MapController _mapController = MapController();  // very useful
  List<LatLng> polylineCoordinates = [];
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
    try {
      // print("Loading image from path: $path");
      ByteData data = await rootBundle.load(path);
      ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetHeight: width,
      );
      ui.FrameInfo fi = await codec.getNextFrame();
      return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
          ?.buffer
          .asUint8List();
    } catch (e) {
      print("Error loading image: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // print('initState active');
   _setPolyline();
  }

  Future<void> _setPolyline() async {
    // print('polyline call');
    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${widget.sourceLatLng.longitude},${widget.sourceLatLng.latitude};${widget.destinationLatLng.longitude},${widget.destinationLatLng.latitude}?geometries=geojson');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];

      polylineCoordinates = coordinates
          .map((coord) => LatLng(coord[1], coord[0])) // Note: Longitude comes first
          .toList();

      _addMarkers();
      setState(() {});
    } else {
      print('Failed to fetch polyline: ${response.statusCode}');
    }
  }

  _addMarkers() async {
    // print('add marker call');
    //source marker
    markers.add(
        Marker(
            point: widget.sourceLatLng,
            child: IconButton(onPressed: (){
              // open bottom modal sheet show source
              showModalBottomSheet(
                context: context,
                builder: (ctx) {
                  return Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const SizedBox(height: 10),
                        Text(
                          'Source Point',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10,),
                        // Display available facilities or "No facilities available"

                      ],
                    ),
                  );
                },
              );
            }, icon: const Icon(Icons.location_on,color: Colors.blue,size: 40,))
        ));
    // destination marker
    markers.add(
        Marker(
            point: widget.destinationLatLng,
            child: IconButton(onPressed: (){
              // open bottom modal sheet show destination
              showModalBottomSheet(
                context: context,
                builder: (ctx) {
                  return Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const SizedBox(height: 10),
                        Text(
                          'Destination Point',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10,),
                        // Display available facilities or "No facilities available"

                      ],
                    ),
                  );
                },
              );
            }, icon: const Icon(Icons.location_on,color: Colors.red,size: 40,))
        ));
    // print("csv file length is: ${widget.csvListData.length}");  //work well
    for(int i=0, j=0; i<widget.csvListData.length; i++, j++)
    {
      // print("9 number index: ${widget.csvListData[i][9]}  12 number index: ${widget.csvListData[i][12]}");

      LatLng point = LatLng(widget.csvListData[i][9], widget.csvListData[i][12]);
      // LatLng point = widget.checkPoints[j];
    //  LatLng point = LatLng(widget.sourceLatLng as double, widget.destinationLatLng as double); // this is dummy delete later

      if (_isPointNearPolyline(point)) {

        //public toilet
        if(widget.csvListData[i][0].trim().toString().toLowerCase() == 'yes'){

          // Concatenate facility information
          // String facilities = '';
          // String placename = widget.csvListData[i][10];

          final Uint8List? markerIcon = await getByteFromAssets(iconImage[0], 50);


          markers.add(

              Marker(

                  width: 50,
                  height: 50,
                  point: point,
                child:  GestureDetector(
                  onTap: () {
                    // print(placename);
                    // print('public toilet');
                    _showFacilityDialog(context, widget.csvListData[i]);
                  },
                  child: markerIcon != null
                      ? Image.memory(markerIcon)
                      : const Icon(Icons.place, color: Colors.pink, size: 30),
                ),
              ));

        }
        else if(widget.csvListData[i][1].toString().trim().toLowerCase() == 'yes'){

          // String placename = widget.csvListData[i][10];

          final Uint8List? markerIcon = await getByteFromAssets(iconImage[1], 50);


          markers.add(
              Marker(
                width: 50,
                height: 50,
                point: point,
                child:  GestureDetector(
                  onTap: () {
                    // print(placename);
                    // print('hospital');
                    _showFacilityDialog(context, widget.csvListData[i]);
                  },
                  child: markerIcon != null
                      ? Image.memory(markerIcon)
                      : const Icon(Icons.place, color: Colors.pink, size: 30),
                ),
              ));

        }
        else  if(widget.csvListData[i][2].toString().trim().toLowerCase() == 'yes'){

          // String placename = widget.csvListData[i][10];

          final Uint8List? markerIcon = await getByteFromAssets(iconImage[2], 50);


          markers.add(
              Marker(
                width: 50,
                height: 50,
                point: point,
                child:  GestureDetector(
                  onTap: () {
                    // print(placename);
                    // print('park');
                    _showFacilityDialog(context, widget.csvListData[i]);
                  },
                  child: markerIcon != null
                      ? Image.memory(markerIcon)
                      : const Icon(Icons.place, color: Colors.pink, size: 30),
                ),
              ));

        }
        else  if(widget.csvListData[i][3].toString().trim().toLowerCase() == 'yes'){

          // String placename = widget.csvListData[i][10];

          final Uint8List? markerIcon = await getByteFromAssets(iconImage[3], 50);


          markers.add(
              Marker(
                width: 50,
                height: 50,
                point: point,
                child:  GestureDetector(
                  onTap: () {
                    // print(placename);
                    // print('mall');
                    _showFacilityDialog(context, widget.csvListData[i]);
                  },
                  child: markerIcon != null
                      ? Image.memory(markerIcon)
                      : const Icon(Icons.place, color: Colors.pink, size: 30),
                ),
              ));

        }
        else  if(widget.csvListData[i][4].toString().trim().toLowerCase() == 'yes'){

          // String placename = widget.csvListData[i][10];

          final Uint8List? markerIcon = await getByteFromAssets(iconImage[4], 50);


          markers.add(
              Marker(
                width: 50,
                height: 50,
                point: point,
                child:  GestureDetector(
                    onTap: () {
                      // print(placename);
                      // print('hotel');
                      _showFacilityDialog(context, widget.csvListData[i]);
                    },
                  child: markerIcon != null
                      ? Image.memory(markerIcon)
                      : const Icon(Icons.place, color: Colors.pink, size: 30),
                ),
              ));

        }
        else  if(widget.csvListData[i][5].toString().trim().toLowerCase() == 'yes'){

          // String placename = widget.csvListData[i][10];

          final Uint8List? markerIcon = await getByteFromAssets(iconImage[5], 50);


          markers.add(
              Marker(
                width: 50,
                height: 50,
                point: point,
                child:  GestureDetector(
                  onTap: () {
                    // print(placename);
                    // print('resturant');
                    _showFacilityDialog(context, widget.csvListData[i]);
                  },
                  child: markerIcon != null
                      ? Image.memory(markerIcon)
                      : const Icon(Icons.place, color: Colors.pink, size: 30),
                ),
              ));

        }
        else  if(widget.csvListData[i][6].toString().trim().toLowerCase() == 'yes'){

          // String placename = widget.csvListData[i][10];

          final Uint8List? markerIcon = await getByteFromAssets(iconImage[6], 50);


          markers.add(
              Marker(
                width: 50,
                height: 50,
                point: point,
                child:  GestureDetector(
                  onTap: () {
                    // print(placename);
                    // print('petrol station');
                    _showFacilityDialog(context, widget.csvListData[i]);
                  },
                  child: markerIcon != null
                      ? Image.memory(markerIcon)
                      : const Icon(Icons.place, color: Colors.pink, size: 30),
                ),
              ));

        }
        else  if(widget.csvListData[i][7].toString().trim().toLowerCase() == 'yes'){

          // String placename = widget.csvListData[i][10];

          final Uint8List? markerIcon = await getByteFromAssets(iconImage[7], 50);
          // for (int j = 13; j < 19; j++) {
          //   if (widget.csvListData[i][j].trim().isNotEmpty) {
          //     facilities += '${widget.csvListData[0][j].trim()}, ';
          //   }
          // }
          // // Remove the trailing comma and space
          // if (facilities.isNotEmpty) {
          //   facilities = facilities.substring(0, facilities.length - 2);
          // }

          markers.add(
              Marker(
                width: 50,
                height: 50,
                point: point,
                child:  GestureDetector(
                  onTap: () {
                    // print(placename);
                    // print('mosque');
                    _showFacilityDialog(context, widget.csvListData[i]);
                  },
                  child: markerIcon != null
                      ? Image.memory(markerIcon)
                      : const Icon(Icons.place, color: Colors.pink, size: 30),
                ),
              ));

        }
        else  if(widget.csvListData[i][8].toString().trim().toLowerCase() == 'yes'){
          // print('others');

// others mark
          markers.add(
              Marker(
                width: 50,
                height: 50,
                point: point,
                child:  GestureDetector(
                  onTap: () => _showFacilityDialog(context, widget.csvListData[i]),
                  child:const Icon(Icons.location_on_rounded, color: Colors.teal, size: 30),
                ),
              ));

        }

      }
    }
    setState(() {

    });
  }

  bool _isPointNearPolyline(LatLng point) {
// print("point is: $point");
    const double tolerance = 1.0; // Tolerance in kilometers (20 kilometer) 1.0 recommended
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
    double lenSq = C * C + D * D;
    double param = (lenSq != 0) ? dot / lenSq : -1;

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


  void _showFacilityDialog(BuildContext context, List<dynamic> facilityData) {
    // Extract the place name from the List data (assuming it's at index 10)
    String placeName = facilityData[10].toString();

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
              const SizedBox(height: 10,),
              // Display available facilities or "No facilities available"
              if (availableFacilities.isEmpty)
                const ListTile(
                    leading: Icon(Icons.highlight_remove_outlined, color: Colors.redAccent),
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
      appBar: AppBar(title: const Text('Rest Areas Map')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: widget.sourceLatLng,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
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
