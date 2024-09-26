import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {

  ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController email = TextEditingController();
@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    email.dispose();
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
                controller: email,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  border: OutlineInputBorder()
                ),

              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: ()async{
try
    {
      // aitar use kora ai email database exists(registered user) kina check kora hosse
      final signInMethod = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email.text.trim());
      if(signInMethod.isNotEmpty)
        {
          await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim()).then((value)=>
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reset link send successfully'),backgroundColor: Colors.green,))
          ).catchError((e)=> ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot Send Reset Link'),backgroundColor: Colors.red,)));
        }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You are not registered User'),backgroundColor: Colors.red,));
      }
    }
    catch(e)
              {
                print('error occur');
              }
            }, child: Text('Send Reset Link'))
          ],
        ),
      ),
    );
  }
}
