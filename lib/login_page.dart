import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rest_area_recommended/add%20data%20to%20firebase.dart';
import 'package:rest_area_recommended/forgot%20password.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> login(BuildContext context)async{
    try
        {
          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email.text.trim(),
              password: password.text);
          var authCredential = userCredential.user;

          if(authCredential!.uid.isNotEmpty)
            {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddDataFirebase(),));
            }
          else
            {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid user or password'),backgroundColor: Colors.red,));
            }
        }catch(e)
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid user or password'),backgroundColor: Colors.red,));
    }
  }
  final _formkey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    email.dispose();
    password.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/login background.jpg'),
                        fit: BoxFit.cover // very important image ta full display use korar jonno
                    )
                ),
                child: Stack(
                  children: [

                    Positioned(child: FadeInUpBig(duration: Duration(milliseconds: 1600),child: Container(
                      margin: EdgeInsets.only(top: 50),
                      child: Center(
                        child: Text('Login',style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                          letterSpacing: 2
                        ),),
                      ),
                    ),)
                    )
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(20),

                child: Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.indigo.shade200,
                                  offset: Offset(0,10),
                                  blurRadius: 20
                              )
                            ]
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade100))
                              ),
                              child: TextFormField(

                                controller: email,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey.shade400),
                                    hintText: 'Type email here',

                                ),
                                validator: (value){
                                  if(value!.isEmpty)
                                    return "Enter your email";
                                },


                              ),
                            ),
                            SizedBox(height: 2,),

                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade100))
                              ),
                              child: TextFormField(
                                controller: password,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey.shade400),
                                    hintText: 'Password'
                                ),
                                validator: (value){
                                  if(value!.isEmpty)
                                    return "Enter your password";
                                },
                              ),
                            ),


                          ],
                        ),
                      ),
                      SizedBox(height: 30,),
                      GestureDetector(
                        onTap: (){

                          if(_formkey.currentState!.validate())
                            {
                              // go to add form page which admin can add data
login(context);
                            }
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.blue,

                                    Colors.green,
                                    Colors.yellowAccent
                                  ]

                              )
                          ),
                          child: Center(child: Text('Login',style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                          ),),),
                        ),
                      ),
                      SizedBox(height: 50,),
                      FadeInUp(duration: Duration(seconds: 2),child: GestureDetector(
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ForgotPassword(),));
                        },
                        child: Text('Forgot Password?',style: TextStyle(
                            color: Colors.indigo
                        ),),
                      ))
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
