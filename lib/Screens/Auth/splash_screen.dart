import 'package:chatter/Screens/Auth/Login_screen.dart';
import 'package:chatter/Screens/home_screen.dart';
import 'package:chatter/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../main.dart';
import '../../api/apis.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  void initState(){
    // Exit full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    //transprent status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.black26,systemNavigationBarColor: Colors.white));
    //navigat to login screen
    super.initState();

    _initializeAppAndNavigate();

    // Future.delayed(const Duration(seconds: 3),(){
    //
    //
    //   if(APIs.auth.currentUser != null){
    //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const Home_Screen()));
    //   }
    //   else{
    //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const LoginScreen()));
    //   }
    // }
    // );



  }
  Future<void> _initializeAppAndNavigate()
  async{
    // Initialize Firebase first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );

    // now you can safely check for the current user
    if(APIs.auth.currentUser != null){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const Home_Screen()));
    }
    else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const LoginScreen()));
    }
  }


  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .4,
              width: mq.width * .4,
              left: mq.width * .30,
              // right: _animeted1 ? mq.width * .30 : -mq.width * .5,
              // left: _animeted1 ? mq.width * .30 : mq.width * .5,

              child: Image.asset("assets/icons/chat.png"
              )
          ),
          Positioned(
            bottom: mq.height * .06,
            // width: mq.width * .7,
            // left: mq.width * .33,
            left: mq.width * .30,
            // right: _animeted4 ? mq.width * .15 : -mq.width * .5,
            height: mq.height * .055,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "MADE BY MOHIT",
                  // textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,

                  ),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
}
