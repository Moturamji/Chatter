import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chatter/models/chat_user.dart';
import 'package:chatter/models/message.dart' ;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import '../Dailogs/snakbar.dart';
import 'notification_access_token.dart';


class APIs{

  // for authentication
  static FirebaseAuth get auth => FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing cloud firestore Storage
  static FirebaseStorage storage = FirebaseStorage.instance;


  // to return current user
  static User get user => auth.currentUser!;

  // for user id
  String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async{
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t){
      if(t != null){
        me.pushToken =t;
        print("PushToken : $t");
      }

      // for Foreground massage handle
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
        }
      });


    });
  }


  // Helper function to display the notification
  static Future<void> _showNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('chats', // Your channel ID
      'Chats', // Your channel name
      channelDescription: 'chat notification channel',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('assets/sound/notification_sound/fredo_santana_no_hook.mp3')
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, // Notification ID (can be any unique number)
        message.notification?.title ?? me.name, // Notification title
        message.notification?.body ?? 'msg', // Notification body
        platformChannelSpecifics,
        payload: 'item x' // Optional payload
    );
  }

  // for sending push notification
  static Future<void> sendPushNotification(ChatUser chatUser, String msg) async{

    try {
      final body = {
        "message": {
          "token": chatUser.pushToken,
          "notification": {
            "title": me.name, //our name should be send
            "body": msg,


          },
          "data": {
            "some_data": "User ID ${me.id}",
            "android_channel_id": "chats",
            "sound": "default"
          },
        }
      };

      // Firebase Project > Project Settings > General Tab > Project ID
      const projectID = 'chatter-36175';

      // get firebase admin token
      final bearerToken = await NotificationAccessToken.getToken;

      print('bearerToken: $bearerToken');

      // handle null token
      if (bearerToken == null) return;

      var res = await post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$projectID/messages:send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $bearerToken'
        },
        body: jsonEncode(body),
      );

      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
    } catch (e) {
      print('\nsendPushNotificationE: $e');
    }

  }

  // for checking user exist or not
  static Future<bool> userExists() async{
    return (
        await firestore
            .collection('Users')
            .doc(
            user.uid
                )
            .get())
        .exists;
  }

  // for adding an chat user for our conversation 
  static Future<bool> addChatUser(String email) async{
    
   final data =  await firestore
                .collection('Users')
                .where('email', isEqualTo:  email).get();

   if(data.docs.isNotEmpty && data.docs.first.id != user.uid){
     //user exists

      firestore.collection('Users').doc(user.uid).collection('my_Users').doc(data.docs.first.id).set({});
     return true;
     }else {
     //user doesn't exists
     return false;
   }
  }

  static  ChatUser me = ChatUser(
      image: user.photoURL.toString(),
      name: user.displayName.toString(),
      about: "Hey, I'm using Chatter ",
      createdAt: '',
      id: user.uid,
      isOnline: false,
      lastActive: '',
      email: user.email.toString(),
      pushToken: '',
  );

  //to return current user
  static Future<void> getSelfInfo() async{


    await firestore.collection('Users').doc(user.uid).get().then((user) async {
          if(user.exists){
            me=ChatUser.fromJson(user.data()!);
            await getFirebaseMessagingToken();
            // for setting user status to active
            APIs.updateActiveStatus(true);
          }else{
            await createUser().then((value) => getSelfInfo());
          }
        });

  }

  // for creating user
  static Future<void> createUser() async{
    final time=DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser =ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey , I'am useing Chatter!",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,

        pushToken: '');

    return
      await firestore
          .collection('Users')
          .doc(user.uid)
          .set(chatUser.toJson());
  }

  // for getting id's of knows users from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId(){
    return firestore.collection('Users').doc(user.uid).collection('my_Users').snapshots();//it's access our collection in database
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds){
    return
      firestore.collection('Users')
      .where('id',whereIn: userIds)
          // .where('id',isNotEqualTo: user.uid)
          .snapshots();//it's access our collection in database
  }


  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(ChatUser chatUser,String msg,Type type) async {

    await firestore
        .collection('Users')
        .doc(chatUser.id)
        .collection('my_Users')
        .doc(user.uid)
        .set({})
        .then((value) => sendMessage(chatUser, msg, type));

  }


  /*
  static Future<void> updateUserInfo() async{
        await firestore
            .collection('Users').doc(user.uid).update({
          // 'name': user.displayName,
          'name': me.name,
          // 'about': user.about,
          'about': me.about,

        });
  }

   */

  // for updating user info
  static Future<void> updateUserInfo() async {
    // Check if the user document exists
    DocumentSnapshot userSnapshot = await firestore.collection('Users').doc(user.uid).get();
    if (userSnapshot.exists) {
      // Update the user document if it exists
        await firestore.collection('Users').doc(user.uid).update({
          'name': me.name,
          'about': me.about,
        } );

    } else {
      // Create a new user document if it does not exist
      await firestore.collection('Users').doc(user.uid).set({
        'name': me.name,
        'about': me.about,
      });
    }
  }

  // update profile picture  of user
  static Future<void> updateProfilePicture(File file) async{
    //getting file extension
    final ext =file.path.split('.').last;
    print('Extension : $ext ');

    // storage file reference with path
    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');

    // uploading image
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0){
      print('DataTransferred: ${p0.bytesTransferred /1000} kb');
    });

    // updating image in firestore database
    me.image =await ref.getDownloadURL();
    await firestore.collection('Users').doc(user.uid).update({'image': me.image});
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String,dynamic>>> getuserInfo(ChatUser chatUser){
    return firestore.collection('Users').where('id',isEqualTo: chatUser.id).snapshots();
  }

  // update online and last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async{
    firestore.collection('Users').doc(user.uid).update({'is_online': isOnline,
      'last_active':DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }



  // deleteUser message
  // static Future<void> deleteUser(ChatUser chatUser) async {
  //   await firestore.collection('Users/${user.uid}/my_Users/${chatUser.id}').doc(chatUser.id).delete();
  //
  // }

  static Future<void> deleteUser(ChatUser chatUser) async {
    try {
      // Get the current user's ID
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      await firestore.collection('Users/$currentUserId/my_Users')
          .doc(chatUser.id)
          .delete();

      print('User ${chatUser.name} deleted successfully');
    } catch (e) {
      print('Error deleting user: $e');
      // Handle the error appropriately (e.g., show a message tothe user)
    }
  }



  // my_User user is exists or not
  static Future<bool> my_UsercheckUserExists(String userIdToCheck) async {
    try {
      // Get the current user's ID
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Construct the document reference forthe user to check
      DocumentReference userRef = firestore.collection('Users/$currentUserId/my_Users')
          .doc(userIdToCheck);

      // Check if the document exists
      DocumentSnapshot userSnapshot = await userRef.get();

      // Return true if the document exists, false otherwise
      return userSnapshot.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      // Handle the error appropriately (e.g., return false or throw an exception)
      return false; // Or throw an exception if you prefer
    }}



  ///************* Chat Screen Related APIs *************


  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      :'${id}_${user.uid}';

  // for getting all  messages of a specific conversation from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getallMessages(ChatUser user){
    return firestore.collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent',descending: true)
        .snapshots();
  }

  // for sending Message
  static Future<void> sendMessage(ChatUser chatUser,String msg,Type type) async {
    // message sending time (also use as id )
    final time =DateTime.now().millisecondsSinceEpoch.toString();

    // message to  send
    final ChatMessage message = ChatMessage(msg: msg, read: '', told: chatUser.id, type: type, fromId: user.uid, sent: time);

    final ref= firestore.collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value)=> sendPushNotification(chatUser, type == Type.text ? msg : "image" ));
  }

  // Update read status of message
  static Future<void> updateMessageReadStatus(ChatMessage message)async{
    firestore.collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent).update({'read':DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only last message of specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user){
    return firestore.collection('chats/${getConversationID(user.id)}/messages/')
    .orderBy('sent' ,descending: true)
        .limit(1).snapshots();
  }

  // send chat image
  static Future<void> sendChatImage(ChatUser chatUser,File file) async  {
    //getting file extension
    final ext =file.path.split('.').last;
    print('Extension : $ext ');

    // storage file reference with path
    final ref = storage.ref().child('images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    // uploading image
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0){
      print('DataTransferred: ${p0.bytesTransferred /1000} kb');
    });

    // updating image in firestore database
    final imageUrl =await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  // send chat video
  // static Future<void> sendChatVideo(ChatUser chatUser,File file) async {
  //   //getting file extension
  //   final ext =file.path.split('.').last;
  //   print('Extension : $ext ');
  //
  //   // storage file reference with path
  //   final ref = storage.ref().child('video/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
  //
  //   // uploading video
  //   await ref.putFile(file, SettableMetadata(contentType: 'video/$ext')).then((p0){
  //     print('DataTransferred: ${p0.bytesTransferred /5000} kb');
  //   });
  //
  //   // updating video in firestore database
  //   final videoUrl =await ref.getDownloadURL();
  //   await sendMessage(chatUser, videoUrl, Type.video);
  // }

  // delete message
  static Future<void> sendChatVideo(ChatUser chatUser, File file) async {
    // Generate a random ID for the video
    final videoId = Random.secure().nextInt(1000000).toString();

    // Get the file extension
    final ext = file.path.split('.').last;

    // Create the storage reference with a different path
    final ref = storage.ref().child('video/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}/$videoId.$ext');

    // Upload the video
    await ref.putFile(file, SettableMetadata(contentType: 'video/$ext')).then((p0) {
      print('DataTransferred: ${p0.bytesTransferred / 5000} kb');
    });

    // Get the download URL
    final videoUrl = await ref.getDownloadURL();

    // Send the message with the video URL
    await sendMessage(chatUser, videoUrl, Type.video);
  }


  static Future<void> deleteMessage(ChatMessage message) async {
    await firestore.collection('chats/${getConversationID(message.told)}/messages/')
        .doc(message.sent).delete();

    if(message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }



  // update message
  static Future<void> updateMessage(ChatMessage message, String updateMsg) async {
    await firestore.collection('chats/${getConversationID(message.told)}/messages/')
        .doc(message.sent).update({'msg': updateMsg});
    
  }

}

