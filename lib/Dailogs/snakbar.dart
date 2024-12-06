import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_spinkit/src/fading_cube.dart' show SpinKitFadingCube;

class SSnackbbar{

  static void showSnackbar(BuildContext context,String msg){
   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
       content: Text(msg),
     backgroundColor: Colors.orange.withOpacity(.5),
     behavior: SnackBarBehavior.floating,
     shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(24)
     ),
   ));
  }


  static void showProgressLoder(BuildContext context){
   showDialog(
       context: context,
       builder: (_) => const Center(
         // child: SpinKitPouringHourGlassRefined(
         //     color: Colors.orangeAccent,
         // size: 60,),
         child: SpinKitFadingCube(
           color: Colors.orangeAccent,
           size: 40,

         ),

       ));
  }


}