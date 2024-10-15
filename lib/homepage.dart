import 'dart:async';
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rest_area_recommended/login_page.dart';
import 'package:rest_area_recommended/showRestArea.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<List<dynamic>> csvData = [];
  List<LatLng> checkPoints = [];
  bool _showSuggest = true;
  bool _showSuggest1 = true;
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  var uuid = const Uuid();
  bool sourceTextField = false;
  bool destinationTextField = false;
  List<dynamic> placesListSource = [];
  List<dynamic> placesListTarget = [];
  String? sourcelocation_name;
  String? targetlocation_name;
  LatLng? sourcelatlng;
  LatLng? destinationlatlng;
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;

  // Hive box
  late Box destinationBox;

  @override
  void initState() {
    super.initState();
    _loadCSV();
    _destinationController.addListener(() => onChangeTarget(_destinationController.text));
    _sourceController.addListener(() => onChangeSource(_sourceController.text));
    internetConnectionCheck();

    // Initialize Hive box
    destinationBox = Hive.box('destinations');
  }

  Future<Position> _currentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Future.error('Location services are disabled.');
      openAppSettings();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _loadCSV() async {
    try {
      final csvString = await rootBundle.loadString('assets/another_data/final_data.csv');
      List<List<dynamic>> rowAsListOfValues = const CsvToListConverter().convert(csvString);
      setState(() {
        csvData = rowAsListOfValues;
      });
      if (csvData.isNotEmpty) {
        for (int i = 1; i < csvData.length; i++) {
          try {
            checkPoints.add(LatLng(csvData[i][10], csvData[i][11]));
          } catch (e) {
            debugPrint('Error processing row $i: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('***************error is $e');
    }
    setState(() {});
  }

  void internetConnectionCheck() {
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (result.contains(ConnectivityResult.none)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Internet Connection Alert'),
            content: const Text('You have no Internet Connection. Turn on the internet connection to use this app'),
            backgroundColor: Colors.grey,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'),
              ),
            ],
          ),
        );
      }
    });
  }

  void onChangeSource(String input) {
    getSuggestionSource(input);
  }

  void onChangeTarget(String input) {
    getSuggestionTarget(input);
  }

  Future<void> getSuggestionSource(String input) async {
    String baseURL = 'https://nominatim.openstreetmap.org/search';
    String request = '$baseURL?q=$input&format=json&addressdetails=1&limit=5';

    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        placesListSource = jsonDecode(response.body.toString());
      });
    } else {
      throw Exception('Failed to load data. Response not 200');
    }
  }

  Future<void> getSuggestionTarget(String input) async {
    String baseURL = 'https://nominatim.openstreetmap.org/search';
    String request = '$baseURL?q=$input&format=json&addressdetails=1&limit=5';

    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        placesListTarget = jsonDecode(response.body.toString());
      });
    } else {
      throw Exception('Failed to load data. Response not 200');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _destinationController.dispose();
    _sourceController.dispose();
    connectivitySubscription.cancel();
  }

  void _resetState() {
    setState(() {
      _destinationController.clear();
      _sourceController.clear();
      placesListSource.clear();
      placesListTarget.clear();
      _showSuggest = true;
      _showSuggest1 = true;
      targetlocation_name = null;
      sourcelocation_name = null;
      destinationlatlng = null;
      sourcelatlng = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rest Area Recommended"),
        centerTitle: true,
        elevation: 10,
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'home') {
                // open home page
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomePage()));
              } else if (value == 'login') {
                // open login functionality
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
              } else if (value == 'about') {
                // show developer about
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('Home'), value: 'home'),
              const PopupMenuItem(child: Text('Login'), value: 'login'),
              const PopupMenuItem(child: Text('About'), value: 'about'),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              sourcelatlng != null
                  ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('$sourcelocation_name', style: const TextStyle(color: Colors.blue)),
                      const Icon(Icons.arrow_forward, size: 20),
                      targetlocation_name != null
                          ? Text('$targetlocation_name', style: const TextStyle(color: Colors.pink))
                          : Container(),
                    ],
                  ),
                ),
              )
                  : Container(),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.withOpacity(0.7), foregroundColor: Colors.black),
                onPressed: () {
                  _sourceController.clear();
                  _currentPosition().then((value) async {
                    List<Placemark> placemarks = await placemarkFromCoordinates(value.latitude, value.longitude);
                    var firstAddress = placemarks[0];
                    setState(() {
                      sourcelatlng = LatLng(value.latitude, value.longitude);
                      sourcelocation_name = firstAddress.subAdministrativeArea ?? firstAddress.locality;
                    });
                  });
                },
                child: const Text("Get Current Location"),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10)),
                child: TextFormField(
                  onTap: () {
                    sourceTextField = true;
                    destinationTextField = false;
                  },
                  controller: _sourceController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Type source place name",
                  ),
                ),
              ),
              if (_showSuggest && sourceTextField)
                SizedBox(
                  height: 200, // Adjust height according to your needs
                  child: ListView.builder(
                    itemCount: placesListSource.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(placesListSource[index]['display_name']),
                        onTap: () {
                          setState(() {
                            sourcelocation_name = placesListSource[index]['display_name'];
                            sourcelatlng = LatLng(placesListSource[index]['lat'], placesListSource[index]['lon']);
                            _sourceController.text = sourcelocation_name!;
                            _showSuggest = false;
                          });
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10)),
                child: TextFormField(
                  onTap: () {
                    destinationTextField = true;
                    sourceTextField = false;
                  },
                  controller: _destinationController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Type destination place name",
                  ),
                ),
              ),
              if (_showSuggest1 && destinationTextField)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: placesListTarget.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(placesListTarget[index]['display_name']),
                        onTap: () {
                          setState(() {
                            targetlocation_name = placesListTarget[index]['display_name'];
                            destinationlatlng = LatLng(double.parse(placesListTarget[index]['lat']),
                                double.parse(placesListTarget[index]['lon']));
                            _destinationController.text = targetlocation_name!;
                            _showSuggest1 = false;
                          });
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed:  sourcelatlng == null
                    ? null
                    : destinationlatlng == null
                    ? null
                    : () {
                  internetConnectionCheck();
                  if (sourcelatlng != null && destinationlatlng != null) {
                    // Navigate to the ShowRestArea page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowRestArea(
                          checkPoints: checkPoints,
                          sourceLatLng: sourcelatlng!,
                          destinationLatLng: destinationlatlng!,
                          csvListData: csvData, // Pass your actual CSV data here
                        ),
                      ),
                    ).then((val){
                      _resetState(); // next page jawar age sob kisu remove kore jabe
                    });

                  } else {
                    // Display error or handle the case where latlng is null
                  }
                },
                child: const Text("Search Rest Area"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
