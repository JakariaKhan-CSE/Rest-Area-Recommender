import 'dart:async';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  String session_token1 = "123456";
  String session_token2 = "789546";
  bool sourceTextField = false;
  bool destinationTextField = false;
  List<dynamic> placesListSource = [];
  List<dynamic> placesListTarget = [];
  String? district;
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

      const String kplacesApiKey = 'AIzaSyDtrIULtBZpbwdbvDlMiwf8W9u8Zem1T1g';
      String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request = '$baseURL?input=$input&key=$kplacesApiKey&sessiontoken=$session_token1';

      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        setState(() {
          placesListSource = jsonDecode(response.body.toString())['predictions'];
        });
      } else {
        throw Exception('Failed to load data. Response not 200');
      }

  }
  Future<void> getSuggestionTarget(String input) async {

    const String kplacesApiKey = 'AIzaSyDtrIULtBZpbwdbvDlMiwf8W9u8Zem1T1g';
    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=$input&key=$kplacesApiKey&sessiontoken=$session_token2';

    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        placesListTarget = jsonDecode(response.body.toString())['predictions'];
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
            onSelected: (value){
              if(value == 'home')
              {
                // open home page
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(),));
              }
             else if(value == 'login')
                {
                  // open login functionality
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                }
              else if(value == 'about')
                {
                  // show developer about
                }
            },

              itemBuilder: (context) => [
                PopupMenuItem(child: Text('Home'),value: 'home',),  // value same as condition check value
                PopupMenuItem(child: Text('Login'),value: 'login',),
                PopupMenuItem(child: Text('About'),value: 'about',),
              ],)
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
                    var secondAddress = placemarks[1];
                    var thirdAddress = placemarks[2];

                    setState(() {
                      sourcelatlng = LatLng(value.latitude, value.longitude);
                      sourcelocation_name = firstAddress.subAdministrativeArea ?? secondAddress.subAdministrativeArea;
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
                  onTap: (){
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
                      return GestureDetector(
                        onTap: () async {
                          List<Location> locations = await locationFromAddress(placesListSource[index]['description']);
                          if (_sourceController.text.isNotEmpty) {
                            _sourceController.text = placesListSource[index]['description'];
                            setState(() {
                              _showSuggest = false;
                              sourcelatlng = LatLng(locations.first.latitude, locations.first.longitude);
                              sourcelocation_name = placesListSource[index]['description'];


                            });
                          }


                        },
                        child: ListTile(title: Text(placesListSource[index]['description'])),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10)),
                child: TextFormField(
                  onTap: (){
                    destinationTextField = true;
                    sourceTextField = false;
                  },
                  controller: _destinationController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Type target place name",
                  ),
                ),
              ),
              if (_showSuggest1 && destinationTextField)
                SizedBox(
                  height: 200, // Adjust height according to your needs
                  child: ListView.builder(
                    itemCount: placesListTarget.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          List<Location> locations = await locationFromAddress(placesListTarget[index]['description']);
                          if (_destinationController.text.isNotEmpty) {
                            _destinationController.text = placesListTarget[index]['description'];
                            setState(() {
                              _showSuggest1 = false;
                              destinationlatlng = LatLng(locations.first.latitude, locations.first.longitude);
                              targetlocation_name = placesListTarget[index]['description'];


                            });
                          }
                        },
                        child: ListTile(title: Text(placesListTarget[index]['description'])),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.withOpacity(0.7), foregroundColor: Colors.black),
                onPressed: sourcelatlng == null
                    ? null
                    : destinationlatlng == null
                    ? null
                    : () {
                  internetConnectionCheck();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowRestArea(
                        sourceLatLng: sourcelatlng!,
                        destinationLatLng: destinationlatlng!,
                        csvListData: csvData,
                        checkPoints: checkPoints,
                      ),
                    ),
                  ).then((value) {
                    _resetState();
                  });
                },
                child: const Text("Find Rest Area"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
