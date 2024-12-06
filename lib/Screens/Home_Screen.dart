
import 'package:another_flushbar/flushbar.dart';
import 'package:chatter/Screens/profile_screen.dart';
import 'package:chatter/wigets/chat_wiget_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  // for storing all user
  // late var list =[];
  List<ChatUser> _list=[];

  // for storing search item
  final List<ChatUser> _searchlist=[];
  // for storing search status
  bool _isSearching =false;
  @override
  void initState(){
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);// for hide navigation bar
    APIs.getSelfInfo();



    // for updating user active status according to lifecycle event
    // resume -- active or online
    // pause -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      // print('message : $message');
      if(APIs.auth.currentUser != null){
        if(message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if(message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard when a tap is detected on screen
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: PopScope(
        /* if search is on & back button is pressed  then close search
           or else simple close current screen on back  button click */
        canPop: !_isSearching,
        onPopInvoked: (_) async{
          if(_isSearching){
            setState(() {
              _isSearching=!_isSearching;
            });
          }else{
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 100,
            leading: IconButton(onPressed: (){}, icon: const Icon(CupertinoIcons.home)),
            title: _isSearching ?  TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,hintText: 'Name,Email,...'
              ),
              autofocus: true,
              style: const TextStyle(fontSize: 16,letterSpacing: 0.5),
              onChanged: (val){
                _searchlist.clear();
                for(var i in _list){
                  if(i.name.toLowerCase().contains(val.toLowerCase()) || i.email.toLowerCase().contains(val.toLowerCase())){
                    _searchlist.add(i);
                  }
                  setState(() {
                    _searchlist;
                  });
                }
              },
            ): const Text("Chatter"),
            actions: [
              IconButton(onPressed: (){
                _searchlist.clear();
                setState(() {
                  _isSearching=!_isSearching;
                });
              }, icon: Icon(_isSearching ? CupertinoIcons.clear_circled_solid:Icons.search)),
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>  profilescreen(user: APIs.me)));
              }, icon: const Icon(Icons.more_vert)),

            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 30,right: 10),
            child: FloatingActionButton(
              onPressed: ()async{
                _addChatUserDialog(context);
              },
              child: const Icon(Icons.add_comment_rounded),),
          ),
          body: StreamBuilder(
              stream: APIs.getMyUsersId(),

              // get id of known users
              builder: (context,snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: SpinKitFadingCube(
                      color: Colors.orangeAccent,
                      size: 40,

                    ),);
                  case ConnectionState.done:
                  // TODO: Handle this case.
                  case ConnectionState.active:
                  // TODO: Handle this case.

                  return StreamBuilder(
                    stream:APIs.getAllUsers(
                      snapshot.data?.docs.map((e) => e.id).toList() ?? [],
                    ),

                    // get only those users, who's ids are provided
                    builder: (context, snapshot) {
                      switch(snapshot.connectionState){
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(child: SpinKitFadingCube(
                            color: Colors.orangeAccent,
                            size: 40,

                          ),);
                        case ConnectionState.done:
                        // TODO: Handle this case.
                        case ConnectionState.active:
                          // TODO: Handle this case.



                          final data =snapshot.data?.docs;
                          _list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? []; // take data from database and store in list

                          if(_list.isNotEmpty){
                            return ListView.builder(
                              itemCount: _isSearching? _searchlist.length :_list.length,
                              padding: EdgeInsets.only(top: mq.height* .013),
                              physics: const BouncingScrollPhysics(), // bouncing effect in list
                              itemBuilder: (context, index) {
                                return  Slidable(
                                  key: const ValueKey(0),

                                  startActionPane: ActionPane(
                                      motion:  const StretchMotion(),
                                      dismissible: DismissiblePane(onDismissed: () => _onDismissed(index)),
                                      children: [
                                        SlidableAction(
                                            onPressed: (context) {
                                              _onDismissed(index);
                                            },
                                          backgroundColor: Colors.red,
                                          icon: CupertinoIcons.delete,
                                          label: 'Delete',
                                        )
                                      ]),
                                  endActionPane: ActionPane(
                                      motion:  const StretchMotion(),
                                      dismissible: DismissiblePane(onDismissed: () => _onDismissed(index)),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            _onDismissed(index);
                                          },
                                          backgroundColor: Colors.red,
                                          icon: CupertinoIcons.delete,
                                          label: 'Delete',
                                        )
                                      ]),
                                  child: ChatUserCard(user:
                                  _isSearching ? _searchlist[index]: _list[index],),
                                ); // our user card
                              // return const ChatUserCard();
                                // return Text('Name : ${list[index]}');
                              },);
                          }else{
                            return const Center(
                            //error for not data found
                              child: Text("No Connections Found!",
                                style: TextStyle(fontSize: 20),),
                            );
                          }
                      }

                      // if(snapshot.hasData){
                      //   final data =snapshot.data?.docs;
                      //   for(var i in data!){
                      //     print('Data : ${jsonEncode(i.data())}');
                      //     // print('Data : ${i.data()}');
                      //     list.add(i.data()['name']);
                      //   }
                      // }
                      //
                      // return ListView.builder(
                      //   itemCount: list.length,
                      //   padding: EdgeInsets.only(top: mq.height* .013),
                      //   physics: const BouncingScrollPhysics(),
                      //   itemBuilder: (context, index) {
                      //     // return const ChatUserCard();
                      //     return Text('Name : ${list[index]}');
                      //   },);
                    },
                  );
                }
                return const Center(
                  // child: SpinKitPouringHourGlassRefined(
                  //     color: Colors.orangeAccent,
                  // size: 60,),
                  child: SpinKitFadingCube(
                    color: Colors.orangeAccent,
                    size: 40,

                  ),

                );
              }
          )
        ),
      ),
    );
  }

// add user
void _addChatUserDialog(BuildContext context, ) {
  String email = '';
  try {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
// title
        title: const Row(
          children: [
            Icon(CupertinoIcons.person_add_solid, color: Colors.black38, size: 28),
            Text("  Add User")
          ],
        ),
// content
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => email = value,
          decoration: InputDecoration(
            hintText: 'Email Id',
              prefixIcon: const Icon(Icons.email,color: Colors.orange,),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15)
              )
          ),
        ),
//action
        actions: [
// cancel button
          MaterialButton(
            onPressed: ()  {
              Navigator.of(context,rootNavigator: true).pop(); // Await the pop call
              Flushbar(
                message: "User Can't be Added",
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
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.orange)),
          ),

// Add button
          MaterialButton(
            onPressed: ()  async {
              try{
                Navigator.of(context,rootNavigator: true).pop();// Await the pop call

                if(email.isNotEmpty){
                await APIs.addChatUser(email).then((value) {
                  if(!value){
                    Flushbar(
                      message: "User Doesn't Exist!",
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
                  }else{
                    Flushbar(
                      message: 'User can Added Successfully ',
                      backgroundColor: Colors.orange.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                      flushbarPosition: FlushbarPosition.BOTTOM,
                      margin: const EdgeInsets.all(20.0),
                      icon: const Icon(
                        Icons.verified_user,
                        size: 28.0,
                        color: Colors.white,
                      ),

                      duration: const Duration(seconds: 3),
                    ).show(context);
                  }

                });
                }


                
              }
              catch(e){
                print('update msg error : $e');
                Flushbar(
                  message: 'Some Technical Error is Occur User cant be add',
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
            },
            child: const Text("Add", style: TextStyle(color: Colors.orange)),
          ),
        ],
      )
    );
  }catch (e) {
    print("Error showing dialog: $e");
  }
}




void _onDismissed(int index ) {
    final user = _list[index];
    APIs.deleteUser(user);
    APIs.my_UsercheckUserExists(user.id).then((exists) {
      if(exists == false) {
        // Show success Flushbar
        Flushbar(
          message: 'User Deleted Successfully',
          backgroundColor: Colors.green.withOpacity(0.8),
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
      }else{
        // Show error Flushbar
        Flushbar(
          message: "User Doesn't Delete",
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
    });
}







}


