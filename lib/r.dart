// void _showMessageUpdateDialog(BuildContext context, String updateMsg) {
//   try {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 15),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         // title
//         title: const Row(
//           children: [
//             Icon(CupertinoIcons.chat_bubble_text, color: Colors.black38, size: 28),
//             Text(" Update message")
//           ],
//         ),
//         // content
//         content: TextFormField(
//           initialValue: updateMsg,
//           decoration: InputDecoration(
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15)
//               )
//           ),
//         ),
//         //action
//         actions: [
//           MaterialButton(
//             onPressed: ()  {
//               Navigator.of(context,rootNavigator: true).pop(); // Await the pop call
//               // try {
//               //   Future.delayed(const Duration(milliseconds: 50), () {
//               //     Navigator.of(context).pop(); // Pop the dialog after delay
//               //   });
//               // } catch (e) {
//               //   print("Error in Cancel button: $e");
//               // }
//             },
//             child: const Text("Cancel", style: TextStyle(color: Colors.orange)),
//           ),
//           MaterialButton(
//             onPressed: ()  {
//               Navigator.of(context,rootNavigator: true).pop(); // Await the pop call
//               // try {
//               //   Future.delayed(const Duration(milliseconds: 50), () {
//               //     Navigator.of(context).pop(); // Pop the dialog after delay
//               //   });
//               // } catch (e) {
//               //   print("Error in Update button: $e");
//               // }
//
//             },
//             child: const Text("Update", style: TextStyle(color: Colors.orange)),
//           ),
//         ],
//       ),
//     );
//   }catch (e) {
//     print("Error showing dialog: $e");
//   }
// }










// ??????????????????????????????????????????????????????????????????????????????????
/*
this is sign out function code
                await APIs.auth.signOut();
                await GoogleSignIn().signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const
                LoginScreen()));
 */


/*
/// Stateful widget to fetch and then display video content.
class VideoApp extends StatefulWidget {
  final String url;
  const VideoApp({required this.url ,super.key});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
              : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

 */