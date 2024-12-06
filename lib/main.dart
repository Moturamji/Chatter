// import 'package:chatter/Screens/Auth/Login_screen.dart';
// import 'package:chatter/Screens/Home_Screen.dart';
import 'package:chatter/Screens/Auth/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
// import 'package:flutter_notification_channel/flutter_notification_channel.dart';
// import 'package:flutter_notification_channel/notification_importance.dart';
import 'firebase_options.dart';

// global object for accessing device screen size
late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // for fullsccreen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // SystemChrome.setSystemUIOverlayStyle(
  //     const SystemUiOverlayStyle(
  //       statusBarColor: Colors.transparent, // Optional: Set status bar color
  //       systemNavigationBarColor: Colors.transparent, // Optional: Set navigation bar color
  //       systemNavigationBarIconBrightness: Brightness.dark, // Optional: Set navigation bar icon brightness
  //       systemNavigationBarDividerColor: Colors.transparent, // Optional: Set navigation bar divider color
  //       systemNavigationBarContrastEnforced: false, // Optional: Enforce contrast on navigation bar
  //     )
  //     );//immersive, immersiveSticky
  // for setting orinentation to portrait only
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]).then((value) {
      _initializeFirebase();
      runApp(const MyApp());
  });
  // _initializeFirebase();
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        primaryColor: Colors.orange,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 5,
            iconTheme: IconThemeData(
              color: Colors.black
            ),
            titleTextStyle: TextStyle(fontWeight: FontWeight.normal,
            fontSize: 22,
            color: Colors.black),
          backgroundColor: Colors.orange,
        )
        // useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var result = await FlutterNotificationChannel().registerNotificationChannel(
    description: 'chat notification channel',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  print(result);
}


