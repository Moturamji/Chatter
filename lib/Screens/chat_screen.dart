import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter/Dailogs/my_date_util.dart';
import 'package:chatter/View_profile_screen.dart';
import 'package:chatter/models/chat_user.dart';
import 'package:chatter/wigets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../api/apis.dart';
import '../main.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});
  final ChatUser user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}




class _ChatScreenState extends State<ChatScreen> {

  // for storing all messages
  List<ChatMessage> _list=[];

  // for handling message text change
  final _textController = TextEditingController();

  // for storing value of showing or hiding emoji
  bool _showEmoji = false;

  //for checking if image is Uploading or not
  bool _isUploading = false;

  @override

  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: //PopScope(
        // //if emoji are shown & back button is pressed then hide emoji keyboard or  else simple close current screen on back button click
        // canPop: !_showEmoji,
        // onPopInvoked: (_) async{
        //   if(_showEmoji){
        //     setState(() {
        //       _showEmoji=!_showEmoji;
        //     });
        //   }else{
        //     Navigator.of(context).pop();
        //   }
        // },
      WillPopScope(
        onWillPop: () async{
                   if(_showEmoji){
                   setState(() {
                   _showEmoji=!_showEmoji;
                    });
                   return false; // Prevent popping when emoji keyboard is open
                    }else{
                     // Navigator.of(context).pop();
                     return true; // Allow popping when emoji keyboard is closed
                    }
                     },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: mq.height*.08, // Set your desired toolbar height here
            flexibleSpace: SafeArea(child: _appbar()),
          ),
          resizeToAvoidBottomInset: true,
          body:SafeArea(
            // decoration: const BoxDecoration(
            //   image: DecorationImage(image: AssetImage('assets/image/background.jpg'),
            //   fit: BoxFit.cover),
            //
            // ),

             child: Column(
              children: [

                Expanded(
                  child: StreamBuilder(
                    // stream: null,
                    stream:APIs.getallMessages(widget.user),
                    builder: (context, snapshot) {
                      switch(snapshot.connectionState){
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(child: CircularProgressIndicator());
                        case ConnectionState.done:
                        // TODO: Handle this case.
                        case ConnectionState.active:
                        // TODO: Handle this case.



                        final data =snapshot.data?.docs;
                        // print('Data : ${jsonEncode(data![0].data())}');
                        _list = data?.map((e) => ChatMessage.fromJson(e.data())).toList() ?? []; // take data from database and store in list

                          // final _list=['hii ','hello'];

                          if(_list.isNotEmpty){
                            return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: mq.height* .013),
                              physics: const BouncingScrollPhysics(), // bouncing effect in list
                              itemBuilder: (context, index) {
                                return MessageCard(message: _list[index]);
                                // return const ChatUserCard();
                              },);
                          }else{
                            return const Center(
                              //error for not data found
                              child: Text("Say Hello! 👋",
                                style: TextStyle(fontSize: 30,color: Colors.black),),
                            );
                          }
                      }

                    },
                  ),
                ),

                // progress indicator for showing uploading
                if(_isUploading)
                const Align(
                  alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                      child: CircularProgressIndicator(strokeWidth: 2,),
                    )
                ),

                _chatinput(),
                ////////////////////////////////////////

                if(_showEmoji == true)
                SizedBox(
                  height: 300,

                  child: EmojiPicker(
                  onEmojiSelected: (Category? category, Emoji emoji) {
                  // Do something when emoji is tapped (optional)
                  },
                  onBackspacePressed: () {
                  // Do something when the user taps the backspace button (optional)
                  // Set it to null to hide the Backspace-Button
                  },

                  textEditingController: _textController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                  config: Config(
                  height: 326,

                  // bgColor: const Color(0xFFF2F2F2),
                  // bgColor: Colors.orangeAccent,
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(
                    backgroundColor: const  Color(0xFFf0dfc0),

                  // Issue: https://github.com/flutter/flutter/issues/28894
                  emojiSizeMax: 28 *
                  (foundation.defaultTargetPlatform == TargetPlatform.iOS
                      ?  1.20
                          :  1.0),
                      ),

                      swapCategoryAndBottomBar:  false,
                      skinToneConfig: const SkinToneConfig(
                      ),
                      categoryViewConfig: const CategoryViewConfig(
                        // iconColor: Colors.orangeAccent,
                          iconColorSelected: Colors.orangeAccent,
                        backgroundColor: Color(0xFFf0dfc0),

                      ),
                      bottomActionBarConfig: const BottomActionBarConfig(
                        buttonIconColor: Colors.orangeAccent,
                        backgroundColor: Color(0xFFf0dfc0),
                        buttonColor: Color(0xFFf0dfc0),

                      ),
                      searchViewConfig: const SearchViewConfig(
                        backgroundColor: Color(0xFFf0dfc0) ,
                        buttonColor: Color(0xFFf0dfc0) ,
                        buttonIconColor: Colors.orangeAccent,
                      ),
                      ),

                      ),
                )

                  /////////////////////////////////////////////////////////////
              ],
            ),
          ),
        ),
      ),
    );
  }

  // dagine of appbar
  Widget _appbar() {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (_) =>Viewprofilescreen(user: widget.user) ));
      },
      child: Padding(
        padding:  EdgeInsets.only(top: mq.height*.005),
        child: StreamBuilder(stream: APIs.getuserInfo(widget.user) ,builder: (context,snapshot) {

          final data = snapshot.data?.docs;
          final list = data?.map((e)=> ChatUser.fromJson(e.data())).toList()??[];


          return Row(
            children: [
              IconButton(onPressed: (){
                Future.delayed(Duration.zero, () {
                  Navigator.of(context).pop();
                });
              },
                  icon: const Icon(Icons.arrow_back)),
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height*.1),
                  child: CachedNetworkImage(
                    height: mq.height * .05,
                    width: mq.height * .05,
                    fit: BoxFit.cover,
                    imageUrl: list.isNotEmpty ? list[0].image :widget.user.image,
                    // placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const CircleAvatar(child: Icon(Icons.person,size: 50)),
                  ),
                ),
              ),
              SizedBox(width: mq.width*.02,),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [



                    Text(list.isNotEmpty ? list[0].name : widget.user.name,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500
                      ),
                      maxLines: 1, // Limit to one line
                      overflow: TextOverflow.ellipsis, // Truncate if overflow
                    ),

                     // last seen time of user
                     Text(list.isNotEmpty ? list[0].isOnline
                         ? 'Online'
                         : MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                         : MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive)  ,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,

                      ),
                       maxLines: 1, // Limit to one line
                       overflow: TextOverflow.ellipsis, // Truncate if overflow
                     ),

                  ],
                ),
              )
            ],
          );
        },),
      ),
    );
  }

  Widget _chatinput() {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: mq.height*.01,horizontal: mq.width*.02),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50)
              ),
              child: Row(
                children: [
                  IconButton(onPressed: (){
                    setState(() {
                      FocusScope.of(context).unfocus();
                      _showEmoji = !_showEmoji;


                    });
                  },
                      icon: _showEmoji == true ?const Icon(Icons.keyboard)
                      : const Icon(Icons.emoji_emotions)),
                   Expanded(child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if(_showEmoji == true) setState(()=> _showEmoji = !_showEmoji);
                    },
                    decoration: const InputDecoration(

                      hintText: 'Message..',
                      // hintStyle: TextStyle()
                      border: InputBorder.none
                    ),
                  )),

                  // take multiple photos from gallery
                  IconButton(onPressed: () {
                    _showBottomSheet(true);
                    // final ImagePicker picker = ImagePicker();
                    // // Pick an image.
                    // final XFile? image = await picker.pickImage(source: ImageSource.camera,imageQuality: 80);
                    // if(image != null){
                    //   print("image path : ${image.path}");
                    //   _isUploading =true;
                    //   await APIs.sendChatImage(widget.user,File(image.path)).then((e){
                    //     _isUploading =false;
                    //   });
                    //   // setState(() =>  _isUploading =false);
                    // }
                  },
                      icon: const Icon(Icons.attach_file_outlined)),

                  // for take photo from camera
                  IconButton(onPressed: () async {
                    final ImagePicker picker = ImagePicker();

                    // Pick an image
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 70);
                    final XFile? cameraVideo = await picker.pickVideo(source: ImageSource.camera);

                    if (image != null) {
                      print('Image Path: ${image.path}');
                      setState(() => _isUploading = true);

                      await APIs.sendChatImage(
                          widget.user, File(image.path));
                      setState(() => _isUploading = false);
                    }else if(cameraVideo != null){
                      print('Image Path: ${cameraVideo.path}');
                      setState(() => _isUploading = true);

                      await APIs.sendChatVideo(
                          widget.user, File(cameraVideo.path));
                      setState(() => _isUploading = false);
                    }
                  },
                      icon: const Icon(CupertinoIcons.photo_camera)),
                  SizedBox(width: mq.width*.01,)
                ],
              ),
            ),
          ),

          MaterialButton(
            padding: const EdgeInsets.only(left: 10,top: 10,bottom: 10,right: 5),
            onPressed: (){
              if(_textController.text.isNotEmpty){
                if(_list.isEmpty){
                  APIs.sendFirstMessage(widget.user, _textController.text,Type.text);
                  _textController.text='';
                }
                else {
                  APIs.sendMessage(
                      widget.user, _textController.text, Type.text);
                  _textController.text = '';
                }

              }
            },
            child: const Icon(Icons.send),
          color: Colors.greenAccent.shade400,
          shape: const CircleBorder(),
          minWidth: 1,)
        ],
      ),
    );
  }


  void _showBottomSheet(bool isMe){
    showModalBottomSheet(
        context: context,
        builder: (_){

          return StatefulBuilder(
              builder: (context,setState){
                return ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: mq.height*.01,bottom: mq.height*.02),
                  children: [
                    // black line
                    Container(
                      height: 4,
                      margin: EdgeInsets.symmetric(vertical: mq.height*.015,horizontal: mq.width*.37),
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8)
                      ),
                    ),

                  Row(
                    children: [
                      // for image gallery icon
                      SizedBox(
                        height: mq.height*.07,
                        child: IconButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              // final ImagePicker picker = ImagePicker();
                              // // Picking a multiple image.
                              // final List<XFile> images = await picker.pickMultiImage(imageQuality: 80);
                              //
                              // // uploading & sending  images one by one
                              // for (var i in images){
                              //
                              //   print("image path : ${i.path}");
                              //   setState(() =>  _isUploading =true);
                              //   await APIs.sendChatImage(widget.user,File(i.path));
                              //   setState(() =>  _isUploading =false);
                              // }
                            },
                            icon: const Icon(Icons.photo),
                            iconSize: 30,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.red; // Red background when pressed
                                  }
                                  return Colors.blue; // Default blue background
                                },
                              ),
                              shape: MaterialStateProperty.all<OutlinedBorder>(CircleBorder()), // Make the button round


                            )
                        ),
                      ),

                      // for video gallery icon
                      SizedBox(
                        height: mq.height*.07,
                        child: IconButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              pickAndSendMedia(widget.user);

                                /*
                              for (var i in medias){

                                print("image path : ${i.path}");
                                // setState(() =>  _isUploading =true);
                                _isUploading =true;
                                await APIs.sendChatImage(widget.user,File(i.path)).then((e){
                                  _isUploading =false;
                                });
                                // setState(() =>  _isUploading =false);
                              }

                               */
                              },
                              icon: const Icon(Icons.video_call),
                              iconSize:30,
                              style:
                              ButtonStyle(
                                backgroundColor: MaterialStateProperty
                                    .resolveWith<Color?>(
                                      (Set<MaterialState> states) {
                                    if (states.contains(
                                        MaterialState.pressed)) {
                                      return Colors
                                          .red; // Red background when pressed
                                    }
                                    return Colors
                                        .blue; // Default blue background
                                  },
                                ),
                                shape: MaterialStateProperty.all<
                                    OutlinedBorder>(
                                    CircleBorder()), // Make the button round


                              ),
                            )
                      ),
                    ],
                  )


                  ],
                );
              }
          );
        }).then((_){
      // Unfocus the current focus node to prevent the keyboard from appearing
      // WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      if (mounted) {
        try {
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        } catch (e) {
          print('Error unfocusing primary focus: $e');
        }
      }});
  }

  Future<void> pickAndSendMedia(ChatUser user) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> medias = await picker.pickMultipleMedia();

    for (var media in medias) {
      _isUploading = true; // Set uploading state

      if (media.path.endsWith('.jpg') || media.path.endsWith('.jpeg') || media.path.endsWith('.png')) {
        print("Image path: ${media.path}");
        await APIs.sendChatImage(user, File(media.path));
      } else if (media.path.endsWith('.mp4') || media.path.endsWith('.mov') || media.path.endsWith('.avi')) {
        print("Video path: ${media.path}");
        await APIs.sendChatVideo(user, File(media.path));
      }

      _isUploading = false; // Reset uploading state after each file
    }
  }

}






class ImgVideoPick extends StatefulWidget {
  @override
  _ImgVideoPickState createState() => _ImgVideoPickState();
}

class _ImgVideoPickState extends State<ImgVideoPick> {
  List<AssetEntity>? _assets;

  @override
  void initState() {
    super.initState();
    _pickAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Img Video Pick'),
        ),
        body: Center(
        child: _assets != null
        ? ListView.builder(
        itemCount: _assets!.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_assets![index].type == AssetType.video
                ? "Video"
                : "Image"),
          );
        })

              : Center(child: CircularProgressIndicator()),
          ),
          );
        }

        Future<void> _pickAssets() async {
      final List<AssetEntity>? assets = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(),
      );

      setState(() {
        _assets = assets;
      });
    }
  }

