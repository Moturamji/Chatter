
import 'dart:io';

import 'package:chatter/Screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../../api/apis.dart';
import '../../main.dart';
import 'package:chatter/Dailogs/snakbar.dart';
import 'package:chatter/Dailogs/UI.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
TextEditingController email =TextEditingController();
TextEditingController password =TextEditingController();

class _LoginScreenState extends State<LoginScreen> {

  bool _animeted1 =false;
  bool _animeted2 =false;
  bool _animeted3 =false;
  bool _animeted4 =false;

  void initState(){
    super.initState();
    Future.delayed(const Duration(milliseconds: 550),(){
      setState(() {
        _animeted1 = true;
      });
    }
    );
    Future.delayed(const Duration(milliseconds: 550),(){
      setState(() {
        _animeted2 = true;
      });
    }
    );
    Future.delayed(const Duration(milliseconds: 1000),(){
      setState(() {
        _animeted3 = true;
      });
    }
    );
    Future.delayed(const Duration(milliseconds: 1000),(){
      setState(() {
        _animeted4 = true;
      });
    }
    );


  }
// for user login
  login(String emails, String passwords)async{
    if(emails=="" && passwords==""){
      return UI.alertBox(context, "Please Enter All Feilds");
    }
    else{
      UserCredential? u;
      try{
        u = await APIs.auth.signInWithEmailAndPassword(email: emails, password: passwords).then((value) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const Home_Screen()));
        });
      }on FirebaseAuthException catch(e){
        return UI.alertBox(context, e.code.toString());
      }
    }
  }


// for google login loder
  void _handelgooglebtnclick(){
    //start prograss Indicator
    BuildContext capturedContext = context; // Capture the context
    SSnackbbar.showProgressLoder(capturedContext);
    signInWithGoogle().then((user) async {
      //End prograss Indicator
      Navigator.pop(capturedContext);
      if(user != null){
        print('\n\nUser : ${user.user}');
        print ('\n\nUseradditionalInfo : ${user.additionalUserInfo}');
        if((await APIs.userExists())) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const Home_Screen()));
        }else{
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const Home_Screen()));
          });
        }
      }

    });
  }

// for google authentication login
  Future<UserCredential?> signInWithGoogle() async {
    // future: Firebase.initializeApp();
    try{
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    }catch(e){
      print('\n\nsignInWithGoogle : $e}');
      SSnackbbar.showSnackbar(context, 'Something Went Wrong (Check Internet!)${e.toString()}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // mq = MediaQuery.of(context).size;
    return Scaffold(
      body:  Stack(
          children: [
            AnimatedPositioned(
              top: mq.height * .20,
                width: mq.width * .4,
                // left: mq.width * .30,
                right: _animeted1 ? mq.width * .30 : -mq.width * .5,
                // left: _animeted1 ? mq.width * .30 : mq.width * .5,
                duration: const Duration(seconds: 1),
                child: Image.asset("assets/icons/chat.png"
                )
            ),
            AnimatedPositioned(
              top: mq.height * .40,
              // left: mq.width * .20,
              left: _animeted2 ? mq.width * .20 : -mq.width * .5,
              duration: const Duration(seconds: 1),
                child:GradientText("Wellcome To Chatter",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 25),
                    colors:[
                      const Color(0xFFE9413A),
                      const Color(0xFFFED218),
                    ]),
            ),
            AnimatedPositioned(
              bottom: _animeted3 ? mq.height * .45 : -mq.height *.6,
              // top: mq.height * .50,
                left: mq.width * .10,
                // right: _animeted3 ? mq.width * .10 : -mq.width * .5,
                duration: const Duration(seconds: 2),
                child: Container(
                  height: mq.height * .06,
                  width: mq.width * .8,
                  child: TextField(
                    controller: email,
                    decoration: InputDecoration(
                      hintText: "Enter Email",
                      fillColor: Colors.white10,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 2
                        ),

                      ),
                      labelText: "Email",
                      focusedBorder: OutlineInputBorder(

                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                            color: Colors.black87,
                            width: 3
                        ),
                      ),
                    ),

                  ),
                )
            ),
            AnimatedPositioned(
              // top: mq.height * .59,
              bottom: _animeted3 ? mq.height * .37 : -mq.height * .5,
                left: mq.width * .10,
                duration: const Duration(seconds: 2),
                child: Container(
                  height: mq.height * .06,
                  width: mq.width * .8,
                  child: TextField(
                    controller: password,
                    obscureText: true,
                    obscuringCharacter: "*",
                    decoration: InputDecoration(
                      hintText: "Enter Password",
                      fillColor: Colors.white10,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 2
                        ),

                      ),
                      labelText: "Password",
                      focusedBorder: OutlineInputBorder(

                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                            color: Colors.black87,
                            width: 3
                        ),
                      ),
                    ),

                  ),
                )
            ),
            // Positioned(child:),
            AnimatedPositioned(
              bottom: mq.height * .20,
              width: mq.width * .7,
              // left: mq.width * .07,
              right: _animeted4 ? mq.width * .15 : mq.width * .8,
              height: mq.height * .055,
                duration: const Duration(seconds: 2),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange
                ),
                onPressed: (){
                  login(email.text.toString(), password.text.toString());
                  email.clear();
                  password.clear();
                },
                child: const Text(
                    "Login",
                  style: TextStyle(fontSize: 20,color: Colors.black87),
                ),
              )
            ),
            Positioned(
              left: mq.width * .48,
              bottom: mq.height * .16,
                child: const Text(
                    "or",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold
                  ),
                ),
            ),
            AnimatedPositioned(
              bottom: mq.height * .10,
                width: mq.width * .7,
                // left: mq.width * .07,
                right: _animeted4 ? mq.width * .15 : -mq.width * .5,
                height: mq.height * .055,
              duration: const Duration(seconds: 2),
                child: ElevatedButton.icon(
                    onPressed: (){
                      _handelgooglebtnclick();
                    },
                    icon: Image.asset("assets/icons/google.png",height: mq.height * .04,),
                    label: RichText(text: const TextSpan(
                      style: TextStyle(color: Colors.black,fontSize: 15),
                      children: [

                        TextSpan(text: "LogIn with "),
                        TextSpan(text: "Google",style: TextStyle(fontWeight: FontWeight.w600)),
                      ]
                    )),
            ),
            ),
          ],
        ),

    );
  }
}
