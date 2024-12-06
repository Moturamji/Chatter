import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter/View_profile_screen.dart';
import 'package:chatter/models/chat_user.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key,required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      content: SizedBox(width: mq.width *.6, height: mq.height *.35,
      child: Stack(
        children: [

          // profile piture
          Align(
           alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(mq.height*.25),
              child: CachedNetworkImage(
                // height: mq.height * .2,
                width: mq.width * .5,
                fit: BoxFit.cover,
                imageUrl: user.image,
                // placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => const CircleAvatar(child: Icon(Icons.person,size: 50)),
              ),
            ),
          ),

          // user name
          Positioned(
            left: mq.width*.015,
            top: mq.height *.015,
            width: mq.width *.55,
            child: Text(user.name,
                style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
          ),

          
          // info icon
           Positioned(
             right: mq.width*.000001,
               top: mq.height*.00001,
               child: MaterialButton(onPressed: (){
                 Navigator.pop(context);
                 Navigator.push(context, MaterialPageRoute(builder: (_)=> Viewprofilescreen(user: user)));
               },
                 minWidth: 0,
                 padding: const EdgeInsets.all(0),
               child: const Icon(Icons.info_rounded,color: Colors.black38,size: 30,),)
           )
          
        ],
      ),),
    );
  }
}
