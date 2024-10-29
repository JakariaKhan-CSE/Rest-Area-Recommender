import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rest_area_recommended/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';

class AddDataFirebase extends StatefulWidget {


  const AddDataFirebase({super.key});

  @override
  State<AddDataFirebase> createState() => _AddDataFirebaseState();
}

class _AddDataFirebaseState extends State<AddDataFirebase> {
  // text editing controller
  final TextEditingController nameOfPlaceController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  //radio group
  // 1 = Yes and 2 = No
  int _Separate_female_washroom = 1;   // when user No select this value setState is 2
  int _Handicapped_washroom_facility = 1;
  int _Kids_Feeding_corner  = 1;
  int _Separate_female_prayer_room  = 1;
  int _kids_and_women_refreshing_area  = 1;
  int _Others  = 1;

  // This is type place list
  List<String> typePlace = ['Public toilet', 'Hospital', 'Park', 'Shopping mall', 'Hotel', 'Restaurant',
    'Petrol Station', 'Mosque', 'Others'
  ];
  String typePlaceValue = "Select Place";
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Data Firebase"),centerTitle: true,
      // home icon when click go to homepage
        leading: IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
        },icon: Icon(Icons.home,size: 30,color: Colors.blue,),),
      actions: [
        Padding(padding: EdgeInsets.only(right: 5),
        child: IconButton(onPressed: ()async{
          // remove cache memory for logout
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.clear();  // cache memory clean
          // await prefs.setBool('loggedIn', false);
          await FirebaseAuth.instance.signOut();  // also firebase logout
          // go to login page
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
        },icon: Icon(Icons.logout,size: 20,color: Colors.orangeAccent,),),)
      ],
      ),

      body: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Type of Place:',style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black
                    ),),
            DropdownMenu<String>(
            initialSelection: typePlace.first,  // initially public toilet select
                onSelected: (String? val){
                  // This is called when the user selects an item.
              setState(() {
                typePlaceValue = val!;
              });
                },
                dropdownMenuEntries: typePlace.map<DropdownMenuEntry<String>>((String value){
                  return DropdownMenuEntry<String>(value: value, label: value);
                }).toList()
            )
                  ],
                ),
                SizedBox(height: 10,),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
validator: (value) {
  if(value!.isEmpty)
    {
      return "Name of the Place Required";
    }
  return null;
},
                    controller: nameOfPlaceController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Name of the Place",
                      hintText: "Type Name of the Place",
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    validator: (value) {
                      if(value!.isEmpty)
                      {
                        return "Map Location Required";
                      }
                      return null;
                    },
                    controller: locationController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Map Location",
                      hintText: "Paste here google map location link",
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    validator: (value) {
                      if(value!.isEmpty)
                      {
                        return "Latitude Required";
                      }
                      return null;
                    },
                    controller: latitudeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Latitude",
                      hintText: "type latitude value",
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    validator: (value) {
                      if(value!.isEmpty)
                      {
                        return "Longitude Required";
                      }
                      return null;
                    },
                    controller: longitudeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Longitude",
                      hintText: "type longitude value",
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                Center(
                  child: Text('Available facilities',style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black
                  ),),
                ),
                SizedBox(height: 10,),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Separate female washroom',style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black
                      ),),
                      Row(
                        children: [
                          // group er je kono akta select hobe 1 (yes) 2(no)
                          Radio(value: 1, groupValue: _Separate_female_washroom, onChanged: (Separate_female_washroomGroup) {
                            setState(() {
                              _Separate_female_washroom = Separate_female_washroomGroup!;
                            });
                          },),
                          SizedBox(width: 5,),
                          Text('Yes',style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                          ),),
                          SizedBox(width: 15,),
                          Radio(value: 2, groupValue: _Separate_female_washroom, onChanged: (Separate_female_washroomGroup) {
                            setState(() {
                              _Separate_female_washroom = Separate_female_washroomGroup!;
                            });
                          },),
                          SizedBox(width: 5,),
                          Text('No',style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                          ),),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Handicapped washroom facility',style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black
                      ),),
                      Row(
                        children: [
                          // group er je kono akta select hobe 1 (yes) 2(no)
                          Radio(value: 1, groupValue: _Handicapped_washroom_facility, onChanged: (value) {
                            setState(() {
                              _Handicapped_washroom_facility = value!;
                            });
                          },),
                          SizedBox(width: 2,),
                          Text('Yes',style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                          ),),
                          SizedBox(width: 20,),
                          Radio(value: 2, groupValue: _Handicapped_washroom_facility, onChanged: (value) {
                            setState(() {
                              _Handicapped_washroom_facility = value!;
                            });
                          },),
                          SizedBox(width: 2,),
                          Text('No',style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                          ),),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kids Feeding corner ',style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black
                      ),),
                      Row(
                        children: [
                          // group er je kono akta select hobe 1 (yes) 2(no)
                          Radio(value: 1, groupValue: _Kids_Feeding_corner, onChanged: (value) {
                            setState(() {
                              _Kids_Feeding_corner = value!;
                            });
                          },),
                          SizedBox(width: 5,),
                          Text('Yes',style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                          ),),
                          SizedBox(width: 15,),
                          Radio(value: 2, groupValue: _Kids_Feeding_corner, onChanged: (value) {
                            setState(() {
                              _Kids_Feeding_corner = value!;
                            });
                          },),
                          SizedBox(width: 5,),
                          Text('No',style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                          ),),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Separate female prayer room',style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black
                      ),),
                      Row(
                        children: [
                          // group er je kono akta select hobe 1 (yes) 2(no)
                          Radio(value: 1, groupValue: _Separate_female_prayer_room, onChanged: (value) {
                            setState(() {
                              _Separate_female_prayer_room = value!;
                            });
                          },),
                          SizedBox(width: 5,),
                          Text('Yes',style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                          ),),
                          SizedBox(width: 15,),
                          Radio(value: 2, groupValue: _Separate_female_prayer_room, onChanged: (value) {
                            setState(() {
                              _Separate_female_prayer_room = value!;
                            });
                          },),
                          SizedBox(width: 5,),
                          Text('No',style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                          ),),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('kids and women refreshing area',style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black
                      ),),
                      Row(
                        children: [
                          // group er je kono akta select hobe 1 (yes) 2(no)
                          Radio(value: 1, groupValue: _kids_and_women_refreshing_area, onChanged: (value) {
                            setState(() {
                              _kids_and_women_refreshing_area = value!;
                            });
                          },),
                          SizedBox(width: 5,),
                          Text('Yes',style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                          ),),
                          SizedBox(width: 15,),
                          Radio(value: 2, groupValue: _kids_and_women_refreshing_area, onChanged: (value) {
                            setState(() {
                              _kids_and_women_refreshing_area = value!;
                            });
                          },),
                          SizedBox(width: 5,),
                          Text('No',style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                          ),),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Others',style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black
                      ),),
                      Row(
                        children: [
                          // group er je kono akta select hobe 1 (yes) 2(no)
                          Radio(value: 1, groupValue: _Others, onChanged: (value) {
                            setState(() {
                              _Others = value!;
                            });
                          },),
                          SizedBox(width: 5,),
                          Text('Yes',style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                          ),),
                          SizedBox(width: 15,),
                          Radio(value: 2, groupValue: _Others, onChanged: (value) {
                            setState(() {
                              _Others = value!;
                            });
                          },),
                          SizedBox(width: 5,),
                          Text('No',style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                          ),),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: (){
                          // data save to firestore database
                          // latlng data must convert to double when save to database
                        }, child: Text('Save Data to Firebase')),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
