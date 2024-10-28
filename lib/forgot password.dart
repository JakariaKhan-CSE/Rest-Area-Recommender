import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController email = TextEditingController();
  bool isEnabled = true;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    email.dispose();
  }

  Future<bool> isUserRegistered(String email) async {
    try {
// Query the Firestore collection to check if the email exists
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs.isNotEmpty; // Returns true if the user exists
    } catch (e) {
      print('Error checking user registration: $e');
      return false;
    }
  }

  Future<void> sendResetLink()async{
    // print('click');
    final userEmail = email.text.trim();
    if(userEmail.isEmpty)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your email'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

    bool isRegistered = await isUserRegistered(userEmail);
    if(isRegistered)
      {
        // print('registered user');
        try{
          await FirebaseAuth.instance
              .sendPasswordResetEmail(email: userEmail)
              .then((value) {
                email.clear();
                email.text = 'Please Check your email';
setState(() {
  isEnabled = false; // when send email this controller is disabled
});
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(
              content: Text('Reset link send successfully'),
              backgroundColor: Colors.green,
            ));
          })
              .catchError((e) => ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(
            content: Text('Cannot Send Reset Link'),
            backgroundColor: Colors.orangeAccent,
          )));
        }catch(e)
    {
      print('Error sending reset link: $e');
    }
      }else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are not a registered user'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                enabled: isEnabled,  // when send email this controller is disabled
                controller: email,
                decoration: const InputDecoration(
                    hintText: 'Enter your email', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: sendResetLink,
                child: const Text('Send Reset Link'))
          ],
        ),
      ),
    );
  }
}
