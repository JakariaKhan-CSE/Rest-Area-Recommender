import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rest_area_recommended/login_page.dart';
import 'package:rest_area_recommended/showRestArea.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

import 'add data to firebase.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loggedIn = false;
  List<List<dynamic>> csvData = [];
  // List<LatLng> checkPoints = [];
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
    loadCacheMemory();  // load loggedIn data in shared preference
   // _loadCSV();
    _loadCSVFromFirebase(); // when app open it gets data from firebase
    _destinationController.addListener(() => onChangeTarget(_destinationController.text));
    _sourceController.addListener(() => onChangeSource(_sourceController.text));
    internetConnectionCheck();

    // Initialize Hive box
    destinationBox = Hive.box('destinations');
  }

  void loadCacheMemory()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedIn= await prefs.getBool('loggedIn')??false;
  }

// return device current position
  Future<Position> _currentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Future.error('Location services are disabled.');
      openAppSettings();  // very useful
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

  // Future<void> _loadCSV() async {
  //   try {
  //     final csvString = await rootBundle.loadString('assets/another_data/final_data.csv');
  //     List<List<dynamic>> rowAsListOfValues = const CsvToListConverter().convert(csvString);
  //     setState(() {
  //       csvData = rowAsListOfValues;
  //     });
  //     if (csvData.isNotEmpty) {
  //       for (int i = 1; i < csvData.length; i++) {
  //         try {
  //           checkPoints.add(LatLng(csvData[i][10], csvData[i][11]));
  //         } catch (e) {
  //           debugPrint('Error processing row $i: $e');
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('***************error is $e');
  //   }
  //   setState(() {});
  // }
  Future<void> _loadCSVFromFirebase() async {
    // print('load data called');
    try {
      // References to the collections
      CollectionReference collectionReference =  FirebaseFirestore.instance.collection('alldata');
    //  CollectionReference checkpointReference = FirebaseFirestore.instance.collection('checkpoints');


      // Fetch all documents from 'alldata' collection
      QuerySnapshot allDatasnapShot = await collectionReference.get();
      // print('allDatasnapShot length: ${allDatasnapShot.docs.length}');  // work well
      // csvData.add([
      //   doc.id, // Add document ID if needed
      //   ...doc.data().values, // Add all values of the document
      // ]);
      // csvData.add([doc.id, ...data.values]); ensures that both the document ID and its values are added to the CSV data.
      // doc er vitore ekekta alldata collection er document add hobe
      for(var doc in allDatasnapShot.docs)
        {
          // Cast doc data to a Map and extract values
          final data = doc.data() as Map<String, dynamic>;
          // print("data is: $data");  // this line work well

          final publicToilet = data['public_toilet'];
          final hospital = data['hospital'];
          final park = data['park'];
          final shoppingMall = data['shopping_mall'];
          final hotel = data['hotel'];
          final restaurant = data['restaurant'];
          final petrolStation = data['petrol_station'];
          final mosque = data['mosque'];
          final others = data['others'];

          final latitude = data['latitude'];
          final nameOfThePalace = data['name_of_the_palace'];
          final location = data['location'];
          final longitude = data['longitude'];

          final separateFemaleWashroom = data['separate_female_washroom'];
          final handicappedWashroomFacility = data['handicapped_washroom_facility'];
          final kidsFeedingCorner = data['kids_feeding_corner'];
          final separateFemalePrayerRoom = data['separate_female_prayer_room'];
          final kidsAndWomenRefreshingArea = data['kids_and_women_refreshing_area'];
          final otherss = data['otherss'];
// be careful to add data index in 2D list
          csvData.add([  // this is importnat ignore to get error next page
            publicToilet, hospital, park, shoppingMall, hotel, restaurant, petrolStation, mosque, others,
            latitude, nameOfThePalace, location, longitude, separateFemaleWashroom, handicappedWashroomFacility,
            kidsFeedingCorner, separateFemalePrayerRoom, kidsAndWomenRefreshingArea, otherss
          ]);
          // double latitude = data['latitude'];
          // double longitude = data['longitude'];
          // checkPoints.add(LatLng(latitude, longitude));
        }

// checkpoint document and alldata document mismatch occur
      // // Fetch all documents from 'checkpoints' collection
      // QuerySnapshot checkPointSnapshot = await checkpointReference.get();
      // for(var doc in checkPointSnapshot.docs)
      //   {
      //     final data = doc.data() as Map<String,dynamic>;
      //     // the document contains 'lat' and 'lon' fields
      //     double latitude = data['lat'];
      //     double longitude = data['lng'];
      //     // Add LatLng point to the checkPoints list
      //     checkPoints.add(LatLng(latitude, longitude));
      //   }

      // Output the fetched data for testing purposes
      // print('CSV Data: $csvData');
      // print('Checkpoints: $checkPoints');
      // print(csvData.length);
      // print(checkPoints.length);
    } catch (e) {
      debugPrint('***************error is $e');
    }
    // setState(() {});
  }

  // all time internet connectivity check
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

  // use openstreet api to get free place suggest api
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

  // use openstreet api to get free target suggest api
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

  // user show rest area page navigate hoyar somoi ai function take trigger kore sob kisu reset kore dibe
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
            onSelected: (value) async{
              if (value == 'home') {
                // open home page
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
              } else if (value == 'login') {
                if(loggedIn){  // if user loogedIn data in cache memory redirect to add page
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AddDataFirebase(),));
                }
                else{
                  // open login functionality
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                }
              } else if (value == 'about') {
                // show developer about
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'home', child: Text('Home')),
              const PopupMenuItem(value: 'login', child: Text('Login')),
              const PopupMenuItem(value: 'about', child: Text('About')),
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
                    setState(() {
                      sourceTextField = true;
                      destinationTextField = false;
                    });
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
              // ai listview builder ta jokhon user kisu type korbe tokhon show korbe
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
                            sourcelatlng = LatLng(double.parse(placesListSource[index]['lat']),  // see carefully
                                double.parse(placesListSource[index]['lon']));
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
                    setState(() {  // setState so that when user click another textfield other field listbuilder close
                      destinationTextField = true;
                      sourceTextField = false;
                    });
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
                        builder: (context) {
                          // next page a jawar age check korbe csvdata ase kina na thakle(internet issue karone first time data get na hole) button click korar somoi abar dat get korbe firebase theke
                          if(csvData.isEmpty) {
                            _loadCSVFromFirebase();
                          }
                          return ShowRestArea(
                            // checkPoints: checkPoints,
                            sourceLatLng: sourcelatlng!,
                            destinationLatLng: destinationlatlng!,
                            csvListData: csvData, // Pass your actual CSV data here
                          );
                        },
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
