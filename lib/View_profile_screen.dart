
// import 'package:image_loader/image_loader.dart';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter/Dailogs/my_date_util.dart';
import 'package:chatter/Dailogs/snakbar.dart';
import 'package:chatter/Screens/Auth/login_screen.dart';
import 'package:chatter/models/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../main.dart';

class Viewprofilescreen extends StatefulWidget {
  const Viewprofilescreen({super.key, required this.user});

  final ChatUser user;
  @override
  State<Viewprofilescreen> createState() => _ViewprofilescreenState();
}

class _ViewprofilescreenState extends State<Viewprofilescreen> {


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // hiding keyboard
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 100,
          title: Text(widget.user.name),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(left: mq.width * .32,),
          child: Row(
              children:[ Text("Joined on: ",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w500,fontSize: 16),),
                Text(MyDateUtil.getLastMessagetime(context: context, time: widget.user.createdAt,showyear: true), style:
                const TextStyle(color: Colors.black54,fontSize: 16)),
              ]
          ),
        ),
        
        body:Padding(
          padding:  EdgeInsets.symmetric(horizontal: mq.width*.03),
          child: Column(
            children: [

              //for adding some space
              SizedBox(width: mq.width,height: mq.height*.02,),

              //for profile picture
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height*.1),
                child: CachedNetworkImage(
                  height: mq.height * .2,
                  width: mq.height * .2,
                  fit: BoxFit.cover,
                  imageUrl: widget.user.image,
                  // placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const CircleAvatar(child: Icon(Icons.person,size: 50)),
                ),
              ),

              //for adding some space
              SizedBox(width: mq.width,height: mq.height*.02,),
              Text(widget.user.email, style:
              const TextStyle(color: Colors.black87,fontSize: 16)),

              //for adding some space
              SizedBox(height: mq.height*.02,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[ Text("About: ",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w500,fontSize: 16),),
                            Text(widget.user.about, style:
                            const TextStyle(color: Colors.black54,fontSize: 16)),
                ]
              ),


            ],
          ),
        ),
      ),
    );
  }
  // bottom sheet  fro picking a profile picture  for user

}
