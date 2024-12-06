import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter/Dailogs/my_date_util.dart';
import 'package:chatter/api/apis.dart';
import 'package:chatter/models/chat_user.dart';
import 'package:chatter/wigets/dialogs/profile_dailog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Screens/chat_screen.dart';
import '../main.dart';
import '../models/message.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.user});
  final ChatUser user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last message info ( if null --> no message )
  ChatMessage? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: mq.width*.01,horizontal: 7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user,)));
        },
        child: StreamBuilder(stream: APIs.getLastMessage(widget.user), builder: (context,snapshot){

          final data = snapshot.data?.docs;
          final list = data?.map((e)=> ChatMessage.fromJson(e.data())).toList()??[];
          if(list.isNotEmpty) _message = list[0];

          return ListTile(
            // for user profile picture
            // leading: const CircleAvatar(child: Icon(Icons.person),),
            leading: InkWell(
              onTap: ()=> showDialog(context: context,builder: (_)=> ProfileDialog(user: widget.user,)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height*.03),
                child: CachedNetworkImage(
                  height: mq.height * .06,
                  width: mq.height * .06,
                  fit: BoxFit.fill,
                  imageUrl: widget.user.image,
                  // placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const CircleAvatar(child: Icon(Icons.person)),
                ),
              ),
            ),
            //for user profile name
            title: Text(widget.user.name),
            // for Subtitle
            subtitle: Text(
              _message != null
                  ?_message!.type  == Type.image?
                  'image'
              :_message!.msg
                  :widget.user.about,maxLines: 1,
            ),
            //last massege time
            // trailing: const Text("12:00 PM",
            // style: TextStyle(color: Colors.black54),),

            //last message time
            trailing: _message== null //show nothing when no message is sent
                ? null :_message!.read.isEmpty && _message!.fromId != APIs.user.uid
                ? //show for unread message
            Container(
              width: mq.width*.03,
              height: mq.height*.03,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.greenAccent.shade400
              ),
            ):
            //message sent time
            Text(MyDateUtil.getLastMessagetime(context: context, time: _message!.sent)
            ),


          );
        }),
      ),
    );
  }
}
