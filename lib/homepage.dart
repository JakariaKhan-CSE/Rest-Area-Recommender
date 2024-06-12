import 'dart:convert';


import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rest_area_recommended/showRestArea.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<List<dynamic>> csvData = [];
  bool _showSuggest = true;
  TextEditingController _destinationController = TextEditingController();
  var uuid = const Uuid();
  String seassion_token = "123456";
  List<dynamic> placesList = [];
 // String? locality;
  String? district;
  String? sourcelocation_name;
  String? targetlocation_name;
  LatLng? sourcelatlng;
  LatLng? destinationlatlng;

  Future<Position> _currentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
  // csv file convert to list
Future<void> _loadCSV()async{
final csvString = await rootBundle.loadString('assets/data/data.csv');
List<List<dynamic>> rowAsListOfValues = const CsvToListConverter().convert(csvString);
setState(() {
  csvData = rowAsListOfValues;
  print(csvData);
});
}
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
_loadCSV();
    _destinationController.addListener(
      onChange
    );
  }
  void onChange(){
    // print('onChange called');
    if(seassion_token == null)
    {
      setState(() {
        seassion_token = uuid.v4();

      });
    }
    getSuggestion(_destinationController.text);
  }

  void getSuggestion(String input)async{



    final String kPLACES_API_KEY = 'AIzaSyDtrIULtBZpbwdbvDlMiwf8W9u8Zem1T1g';  //my api
    String baseURL   = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$seassion_token';

    var response = await http.get(Uri.parse(request));
    print(response.body.toString());
    if(response.statusCode == 200)
    {
      setState(() {
        placesList = jsonDecode(response.body.toString()) ['predictions'];
      });
    }
    else{
      throw Exception('Failed to load data. Response not 200');
    }

  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _destinationController.dispose();
  }
  void _resetState() {
    setState(() {
      _destinationController.clear();
      placesList.clear();
      _showSuggest = true;
      targetlocation_name = null;
      destinationlatlng = null;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rest Area Recommended"),centerTitle: true,elevation: 10,),
      body: Padding(

        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
sourcelatlng!=null?Padding(
  padding: const EdgeInsets.all(12.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Text('${district}'),
      const Icon(Icons.arrow_forward,size: 20,),
      targetlocation_name!=null?Text('${targetlocation_name}'):Container()
    ],
  ),
):Container(),
            const SizedBox(height: 20,),
            ElevatedButton(onPressed: (){
              _currentPosition().then((value) async {
                List<Placemark> placemarks = await placemarkFromCoordinates(value.latitude, value.longitude);
                var firstAddress = placemarks[0];
                var secondAddress = placemarks[1];
                var thirdAddress = placemarks[2];

                setState(() {
                  sourcelatlng = LatLng(value.latitude, value.longitude);

                  //locality = firstAddress.locality != null?firstAddress.locality:secondAddress.locality!=null?secondAddress.locality:thirdAddress.locality;
                  district = firstAddress.subAdministrativeArea!=null?firstAddress.subAdministrativeArea:secondAddress.subAdministrativeArea;

                });
              });
            }, child: const Text("Get Current Location")),
            const SizedBox(height: 10,),
            TextFormField(
              controller: _destinationController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                hintText: "Type target place name"
              ),
            ),
            if(_showSuggest)
                Expanded(child: ListView.builder(
                  itemCount: placesList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        List<Location> locations = await locationFromAddress(placesList[index]['description']);

                        // print(locations.first.latitude);
                        // print(locations.first.longitude);
                        _destinationController.text = placesList[index]['description'];
                        setState(() {
_showSuggest = false;
destinationlatlng = LatLng(locations.first.latitude, locations.first.longitude);
targetlocation_name = placesList[index]['description'];
                        });

                      },
                      child: ListTile(title: Text(placesList[index]['description']),),
                    );
                  },))
              ,
            const SizedBox(height: 20,),

            ElevatedButton(
                onPressed: sourcelatlng == null
                    ? null
                    : destinationlatlng == null
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowRestArea(
                        sourceLatLng: sourcelatlng!,
                        destinationLatLng: destinationlatlng!,
                      ),
                    ),
                  ).then((value) {
                    // Reset state when returning from second page
                    _resetState();
                  });
                },
                child: const Text("Find Rest Area")),
            // ElevatedButton(onPressed: sourcelatlng==null?null:destinationlatlng==null?null:
            // (){
            //   Navigator.push(context, MaterialPageRoute(builder: (context) =>  ShowRestArea(sourceLatLng: sourcelatlng!,destinationLatLng: destinationlatlng!,),));
            // },
            //  child: const Text("Find Rest Area")),
          ],
        ),
      ),
    );
  }
}
