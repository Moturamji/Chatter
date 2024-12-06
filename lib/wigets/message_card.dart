import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter/Dailogs/my_date_util.dart';
import 'package:chatter/Dailogs/snakbar.dart';
import 'package:chatter/api/apis.dart';
import 'package:chatter/models/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:video_player/video_player.dart';



import '../main.dart';

// for showing Single message details
class MessageCard extends StatefulWidget {

  const MessageCard({super.key, required this.message});

  final ChatMessage message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}


class _MessageCardState extends State<MessageCard> {
  double _videoHeight = 0.0;
  double _videoWidth = 0.0;


  @override
  Widget build(BuildContext context) {

    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: (){
          _showBottomSheet(isMe);
        },
        child: isMe ? _greenMessage() : _blueMessage(),
      );
  }

  // Sender or another user Message
  Widget _blueMessage(){

    // update last read message if sender and receiver are different
    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ?mq.width*.02:mq.width*.04),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width*.04,vertical: mq.height*.01
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(10),
              ),
              border: Border.all(color: Colors.blue,width: 2)
            ),
            child: widget.message.type == Type.text
            ?Text(widget.message.msg,
            style: const TextStyle(fontSize: 15,color: Colors.black87),) :
                widget.message.type == Type.image ?
            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height*.015),
              child: CachedNetworkImage(
                // height: mq.height * .2,
                // width: mq.height * .2,
                fit: BoxFit.cover,
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2,),
                errorWidget: (context, url, error) => const Icon(Icons.image,size: 70),
              ),
            ) :
                    widget.message.type == Type.video ?
                    Container(
                      height: _videoWidth,
                      width: _videoHeight,
                      child: VideoApp(
                        url: widget.message.msg,
                        onVideoDimensions: (height, width) { // Callback to update dimensions
                              setState(() {
                              _videoHeight = height;
                              _videoWidth = width;
                              });
                              },
                      ),
                    )
                        :
                    widget.message.type == Type.file
                        ? Container(
                      height: mq.height * 0.2,
                      width: mq.height * 0.2,
                      child: FilePreviewWidget(
                        url: widget.message.msg,
                        onTap: () async {
                          await OpenFile.open(widget.message.msg);
                        },
                      ),
                    )
                        : const Text('Unknown message type'),

          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width*.04),
          child: Text(MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
            style: const TextStyle(
            fontSize: 15, color: Colors.black54
          ),),
        )
      ],
    );
  }
  // Our or  user Message
  Widget _greenMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Row(

          children: [
            // for adding some space
            SizedBox(width: mq.width*.04,),

            // double tick blue icon for message read
            if(widget.message.read.isNotEmpty)
            const Icon(Icons.done_all_rounded,color: Colors.blue,size: 20,),
            // for adding some space
            SizedBox(width: mq.width*.01,),

            //read time
            Text(MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
              style: const TextStyle(
                fontSize: 15, color: Colors.black54
            ),),
          ],
        ),

        //Message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ?mq.width*.02:mq.width*.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width*.04,vertical: mq.height*.01
            ),
            decoration: BoxDecoration(
                color: const Color(0xFFd1f5bb),
                // color: Colors.green.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
                border: Border.all(color: Colors.green,width: 2)
            ),
            child: widget.message.type == Type.text
                ?Text(widget.message.msg,
              style: const TextStyle(fontSize: 15,color: Colors.black87),) :
            widget.message.type == Type.image ?
            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height*.015),
              child: CachedNetworkImage(
                // height: mq.height * .2,
                // width: mq.height * .2,
                fit: BoxFit.cover,
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2,),
                errorWidget: (context, url, error) => const Icon(Icons.image,size: 70),
              ),
            ) :
            widget.message.type == Type.video ?
            Container(
              height: mq.height*.25,
              width: mq.width*.7,
              child: VideoApp(
                url: widget.message.msg,
                onVideoDimensions:  (height, width) { // Callback to update dimensions
                    setState(() {
                    _videoHeight = height;
                    _videoWidth = width;
                    });
                    },
              ),
            )
                :
            widget.message.type == Type.file
                ? Container(
              height: mq.height * 0.2,
              width: mq.height * 0.2,
              child: FilePreviewWidget(
                url: widget.message.msg,
                onTap: () async {
                  await OpenFile.open(widget.message.msg);
                },
              ),
            )
                : const Text('Unknown message type'),
          ),
        ),

      ],
    );
  }

  // bottom sheet for modifying message details
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


                    widget.message.type == Type.text ?
                    // copy text
                    _OptionItem(
                        icon: const Icon(Icons.copy_rounded,color: Colors.blue,),
                        name: 'Copy',
                        onClick: () async {



                          // try {
                          //   await Clipboard.setData(ClipboardData(text: widget.message.msg));
                          //   // ... rest of your code ...
                          // } catch (e) {
                          //   Flushbar(
                          //     message: 'Error copying text: $e',
                          //     backgroundColor: Colors.red,
                          //     duration: const Duration(seconds: 2),
                          //   ).show(context);
                          // }

                          // try {
                          //   await Clipboard.setData(ClipboardData(text: widget.message.msg));
                          //   // ... rest of your code ...
                          // } catch (e) {
                          //   print("Error copying text: $e"); // Log the error
                          // }


                          // print("Text to copy: ${widget.message.msg}");

                            try{
                              await Clipboard.setData(ClipboardData(text: widget.message.msg)).then((value){
                              Navigator.of(context).pop();
                              // SSnackbbar.showSnackbar(context, 'Text Copied!',);
                              Flushbar(
                                message: 'Text Copied!',
                                backgroundColor: Colors.blue.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(30),
                                flushbarPosition: FlushbarPosition.BOTTOM,
                                margin: const EdgeInsets.all(20.0),
                                icon: const Icon(
                                  Icons.copy_rounded,
                                  size: 28.0,
                                  color: Colors.white,
                                ),

                                duration: const Duration(seconds: 3),
                              ).show(context);
                            });
                            }catch(e){
                              SSnackbbar.showSnackbar(context, '$e');
                            }





                          // scaffoldMessengerKey.currentState?.showSnackBar(
                          //     SnackBar(content: Text('Text Copied!'))
                          // );

                        }
                    )
                        :
                    // save image
                    _OptionItem(
                        icon: const Icon(Icons.save_alt_rounded,color: Colors.blue,),
                        name: 'Save',
                        onClick: (){
                          _saveImage(context,widget.message.msg); // Pass the image URL
                        }),

                    // separator or divider
                    if(isMe)
                      Divider(
                        color: Colors.black38,
                        indent: mq.width*.04,
                        endIndent: mq.width*.04,
                      ),

                    // edit text
                    if( widget.message.type == Type.text && isMe)
                      _OptionItem(
                          icon: const Icon(Icons.edit_rounded,color: Colors.grey,),
                          name: 'Edit Message',
                          onClick: (){
                            Navigator.of(context,rootNavigator: true).pop();
                            showDialog(
                              context: context,
                              builder: (_) => MessageUpdateDialog(updateMsg: widget.message.msg,message: widget.message,),
                            );

                          }),

                    // delete message
                    if(isMe)
                      _OptionItem(
                          icon: const Icon(CupertinoIcons.delete,color: Colors.red,),
                          name: 'Delete Message',
                          onClick: () async {
                            try{
                              await APIs.deleteMessage(widget.message).then((value){
                                Navigator.of(context).pop();
                                Flushbar(
                                  message: 'Message deleted successfully!',
                                  backgroundColor: Colors.red.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(30),
                                  flushbarPosition: FlushbarPosition.BOTTOM,
                                  margin: const EdgeInsets.all(20.0),
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 28.0,
                                    color: Colors.white,
                                  ),
                                  
                                  duration: const Duration(seconds: 3),
                                ).show(context);
                              });

                            }catch(e){
                              SSnackbbar.showSnackbar(context, '$e');
                            }

                          }),

                    // separator or divider
                    Divider(
                      color: Colors.black38,
                      indent: mq.width*.04,
                      endIndent: mq.width*.04,
                    ),


                    // sent time
                    _OptionItem(
                        icon: const Icon(CupertinoIcons.eye_fill,color: Colors.grey,),
                        name: widget.message.read.isEmpty?
                        'Sent At : Not seen yet'
                            :'Sent At : ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                        onClick: (){}),

                    // Read time
                    _OptionItem(
                        icon: const Icon(CupertinoIcons.eye_fill,color: Colors.blue,),
                        name: 'Read At : ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                        onClick: (){}),
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
}







class _OptionItem extends StatefulWidget {
  final Icon icon;
  final String name;
  final VoidCallback onClick;


  const _OptionItem({required this.icon, required this.name, required this.onClick});

  @override
  _OptionItemState createState() => _OptionItemState();
}

class _OptionItemState extends State<_OptionItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {

        widget.onClick();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(
          left: mq.width * 0.05,
          top: mq.height * 0.015,
          bottom: mq.height * 0.015,
        ),
        child: Row(
          children: [
            widget.icon,
            SizedBox(width: mq.width * 0.06),
            Text(
              '${widget.name}',
              style: const TextStyle(fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}





















// class _OptionItem extends StatelessWidget {
//   final Icon icon;
//   final String name;
//   final VoidCallback onClick;
//   const _OptionItem({required this.icon, required this.name,required this.onClick});
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () => onClick,
//       child: Padding(
//         padding: EdgeInsets.only(
//             left: mq.width*.05,
//             top: mq.height*.015,
//             bottom: mq.height*.015
//         ),
//         child: Row(
//           children: [
//             icon,
//             SizedBox(width: mq.width*.06,),
//             Text('$name',
//             style: const TextStyle(fontSize: 17),)
//           ],
//         ),
//       ),
//     );
//   }
// }

Future<void> _saveImage(BuildContext context,String imageUrl) async {
  try {
    if(imageUrl == Type.image) {
      var response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 60,
        name: "Chatter_image", // Or any name you prefe

      );
      print(result);
      Navigator.of(context).pop();
      // SSnackbbar.showSnackbar(context, 'Image Saved!'); // Or use yourpreferred way to show success
      Future.delayed(const Duration(milliseconds: 15), () {
        Flushbar(
          message: 'Image Saved!',
          backgroundColor: Colors.green.withOpacity(0.8),
          borderRadius: BorderRadius.circular(30),
          flushbarPosition: FlushbarPosition.BOTTOM,
          margin: const EdgeInsets.all(20.0),
          icon: const Icon(
            Icons.save,
            size: 28.0,
            color: Colors.white,
          ),

          duration: const Duration(seconds: 3),
        ).show(context);
      });
    }else {
      // _saveNetworkVideoFile() async {
      //   var appDocDir = await getTemporaryDirectory();
      //   String savePath = appDocDir.path + "/temp.mp4";
      //   String fileUrl =
      //       "https://s3.cn-north-1.amazonaws.com.cn/mtab.kezaihui.com/video/ForBiggerBlazes.mp4";
      //   await Dio().download(fileUrl, savePath, onReceiveProgress: (count, total) {
      //     print((count / total * 100).toStringAsFixed(0) + "%");
      //   });
      //   final result = await ImageGallerySaver.saveFile(savePath);
      //   print(result);
      // }
    }

  } catch (e) {
    print('Error saving image: $e');
    // SSnackbbar.showSnackbar(context, 'Error saving image'); // Or handle the error as needed
    Flushbar(
      message: 'Error saving image',
      backgroundColor: Colors.red.withOpacity(0.8),
      borderRadius: BorderRadius.circular(30),
      flushbarPosition: FlushbarPosition.BOTTOM,
      margin: const EdgeInsets.all(20.0),
      icon: const Icon(
        Icons.error_outline,
        size: 28.0,
        color: Colors.white,
      ),

      duration: const Duration(seconds: 3),
    ).show(context);
  }
}




class MessageUpdateDialog extends StatefulWidget {
  final String updateMsg;
  final ChatMessage message;
  const MessageUpdateDialog({required this.updateMsg,required this.message, Key? key}) : super(key: key);

  @override
  _MessageUpdateDialogState createState() => _MessageUpdateDialogState();
}

class _MessageUpdateDialogState extends State<MessageUpdateDialog> {
  @override
  Widget build(BuildContext context) {
    return _showMessageUpdateDialog(context, widget.updateMsg);
  }

  Widget _showMessageUpdateDialog(BuildContext context, String updateMsg) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // title
      title: const Row(
        children: [
          Icon(CupertinoIcons.chat_bubble_text, color: Colors.black38, size: 28),
          Text(" Update message")
        ],
      ),
      // content
      content: TextFormField(
        initialValue: updateMsg,
        maxLines: null,
        onChanged: (value) => updateMsg = value,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15)
            )
        ),
      ),
      //action
      actions: [
        MaterialButton(
          onPressed: ()  {
            Navigator.of(context,rootNavigator: true).pop();// Await the pop call
            Flushbar(
              message: 'Message was not updated!',
              backgroundColor: Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
              flushbarPosition: FlushbarPosition.BOTTOM,
              margin: const EdgeInsets.all(20.0),
              icon: const Icon(
                Icons.update_disabled_rounded,
                size: 28.0,
                color: Colors.white,
              ),

              duration: const Duration(seconds: 3),
            ).show(context);
          },
          child: const Text("Cancel", style: TextStyle(color: Colors.orange)),
        ),
        MaterialButton(
          onPressed: ()  {
            try{
              Navigator.of(context,rootNavigator: true).pop();// Await the pop call
              APIs.updateMessage(widget.message, updateMsg);
              Flushbar(
                message: 'Message was updated',
                backgroundColor: Colors.grey.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
                flushbarPosition: FlushbarPosition.BOTTOM,
                margin: const EdgeInsets.all(20.0),
                icon: const Icon(
                  Icons.update,
                  size: 28.0,
                  color: Colors.white,
                ),

                duration: const Duration(seconds: 3),
              ).show(context);
            }
                catch(e){
              print('update msg error : $e');
              Flushbar(
                message: 'Message was not updated!',
                backgroundColor: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
                flushbarPosition: FlushbarPosition.BOTTOM,
                margin: const EdgeInsets.all(20.0),
                icon: const Icon(
                  Icons.update_disabled_rounded,
                  size: 28.0,
                  color: Colors.white,
                ),

                duration: const Duration(seconds: 3),
              ).show(context);
                }
          },
          child: const Text("Update", style: TextStyle(color: Colors.orange)),
        ),
      ],
    );
  }
}






class VideoApp extends StatefulWidget {
  final String url;
  final Function(double, double) onVideoDimensions;
  const VideoApp({required this.url,required this.onVideoDimensions ,Key? key}) : super(key: key);

  @override
  State<VideoApp> createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {

  late VideoPlayerController _controller;
  bool _isPlaying = false;
  double _videoHeight = 0.0; // To store the video height
  double _videoWidth = 0.0;

  // To store the video width

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    )..initialize().then((_) {
      setState(() {
        _videoHeight = _controller.value.size.height;
        _videoWidth = _controller.value.size.width;

        widget.onVideoDimensions(_videoHeight, _videoWidth);

      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // double videoWidth = _controller.value.size.width;
    // double videoHeight = _controller.value.size.height;


    return Container(

      child: Center(
        child: _controller.value.isInitialized
            ? Stack(
          alignment: Alignment.center,
          children: [
            // Rotate the video by 90 degrees
            Transform.rotate(
              angle: 90 * 3.14159 / 180,
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
            // Floating play/pause button
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause_circle : Icons.play_circle,
                color: Colors.white,
                size: 48.0,
              ),
              onPressed: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                  if (_isPlaying) {
                    _controller.play();
                  } else {
                    _controller.pause();
                  }
                });
              },
            ),
          ],
        )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

/*
class VideoApp extends StatefulWidget {
  final String url;
  const VideoApp({required this.url ,Key? key}) : super(key: key);

  @override
  State<VideoApp> createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.url
    )..initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video App'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? GestureDetector(
          onTap: () {
            setState(() {
              _isPlaying = !_isPlaying;
              if (_isPlaying) {
                _controller.play();
              } else {
                _controller.pause();
              }
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 300,
                height: 200,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
              if (_isPlaying)
                const Icon(
                  Icons.pause_circle,
                  size: 60,
                )
              else
                const Icon(
                  Icons.play_circle,
                  size: 60,
                ),
            ],
          ),
        )
            : const CircularProgressIndicator(),
      ),
    );
  }
}


 */

class FilePreviewWidget extends StatelessWidget {
  final String url;
  final VoidCallback onTap;

  FilePreviewWidget({required this.url, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await OpenFile.open(url);
      },
      child: Container(
        height: mq.height * 0.2,
        width: mq.height * 0.2,
        child: Center(
          child: Icon(Icons.insert_drive_file),
        ),
      ),
    );
  }
}