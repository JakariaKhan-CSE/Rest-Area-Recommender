import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Csvfileaddfirebase extends StatefulWidget {
  const Csvfileaddfirebase({super.key});

  @override
  State<Csvfileaddfirebase> createState() => _CsvfileaddfirebaseState();
}

class _CsvfileaddfirebaseState extends State<Csvfileaddfirebase> {
  List<List<dynamic>> csvData = [];
  List<LatLng> checkPoints = [];
  Future<void> _loadCSVtoFirebase() async {
    // create firebase collection so that store data
    final CollectionReference alldata = FirebaseFirestore.instance.collection('alldata');
    try {
      final csvString = await rootBundle.loadString('assets/another_data/final_data.csv');
      List<List<dynamic>> rowAsListOfValues = const CsvToListConverter().convert(csvString);
      setState(() {
        csvData = rowAsListOfValues;
      });
      // use 1 instead 0 because first raw has column name not data
for(var i=1; i<csvData.length; i++)
  {
    // use this map so that easily added to firebase one document all keys
    var record ={
"public_toilet" : csvData[i][0],
      "hospital":csvData[i][1],
      "park":csvData[i][2],
      "shopping_mall":csvData[i][3],
      "hotel":csvData[i][4],
      "restaurant":csvData[i][5],
      "petrol_station":csvData[i][6],
      "mosque":csvData[i][7],
      "others":csvData[i][8],
      "name_of_the_palace":csvData[i][9],
      "latitude":csvData[i][10],
      "longitude":csvData[i][11],
      "location":csvData[i][12],
      "separate_female_washroom":csvData[i][13],
      "handicapped_washroom_facility":csvData[i][14],
      "kids_feeding_corner":csvData[i][15],
      "separate_female_prayer_room": csvData[i][16],
      "kids_and_women_refreshing_area":csvData[i][17],
      "otherss":csvData[i][18]   // see creafully

    };
    // 1 document all column akbare save hobe for each loop
    alldata.add(record);
  }

    } catch (e) {
      debugPrint('***************error is $e');
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Csv data store in Firebase'),centerTitle: true,),
      body: Center(
        child: ElevatedButton(onPressed: _loadCSVtoFirebase, child: Text('CSV file save Firebase')),
      ),
    );
  }
}
