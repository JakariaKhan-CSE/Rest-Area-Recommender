import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';

class AddDataFirebase extends StatefulWidget {
  const AddDataFirebase({super.key});

  @override
  State<AddDataFirebase> createState() => _AddDataFirebaseState();
}

class _AddDataFirebaseState extends State<AddDataFirebase> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Data Firebase"),centerTitle: true,
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
    );
  }
}
