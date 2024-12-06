
// import 'package:image_loader/image_loader.dart';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter/Dailogs/snakbar.dart';
import 'package:chatter/Screens/Auth/login_screen.dart';
import 'package:chatter/models/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../main.dart';

class profilescreen extends StatefulWidget {
  const profilescreen({super.key, required this.user});

  final ChatUser user;
  @override
  State<profilescreen> createState() => _profilescreenState();
}

class _profilescreenState extends State<profilescreen> {

  final _formkey =GlobalKey<FormState>();
  String? _image;
  @override

  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      // hiding keyboard
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 100,
          title: const Text("Profile"),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 30,right: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            shape: const StadiumBorder(),
            onPressed: ()async{
              SSnackbbar.showProgressLoder(context);
              await APIs.updateActiveStatus(false);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  // for remove progress loader
                  Navigator.pop(context);
                  //for remove home screen from background
                  Navigator.pop(context);

                  // APIs.auth = FirebaseAuth.instance;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const
                  LoginScreen()));
                });

              });

            },
            icon: const Icon(Icons.logout_outlined),
            label: const Text("Logout"),),
        ),
        body:Form(
          key: _formkey,
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: mq.width*.03),
            child: Column(
              children: [
          
                //for adding some space
                SizedBox(width: mq.width,height: mq.height*.02,),
          
                //for profile picture
                Stack(
                  children: [
                    _image != null ?
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height*.1),
                      child: Image.file(
                        File(_image!),
                        height: mq.height * .2,
                        width: mq.height * .2,
                        fit: BoxFit.cover,
                      ),
                    )
                    :
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
                    Positioned(
                      bottom: mq.height*.025,
                      right: -mq.width*.06,
          
                      child: MaterialButton(
                        onPressed: (){
                          _showBottomSheet();
                        },
                        elevation: 4,
                        color: Colors.white,
                        shape: const CircleBorder(),
                      child: const Icon(Icons.edit),),
                    )
                  ],
                ),
          
                //for adding some space
                SizedBox(width: mq.width,height: mq.height*.02,),
                Text(widget.user.email, style:
                const TextStyle(color: Colors.black54,fontSize: 16)),
          
                //for adding some space
                SizedBox(height: mq.height*.05,),
          
                //name input field
                TextFormField(
                  initialValue: widget.user.name,
                  onSaved: (val)=> APIs.me.name = val ?? '',
                  validator: (val)=> val != null && val.isNotEmpty ? null : 'Required Field',
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person,color: Colors.orangeAccent,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                    label: const Text("Name"),
                    hintText: 'eg. Happy Singh',
                  ),
                ),
                SizedBox(height: mq.height*.02,),
          
                //about input field
                TextFormField(
                  initialValue: widget.user.about,
                  onSaved: (val)=> APIs.me.about = val ?? '',
                  validator: (val)=> val != null && val.isNotEmpty ? null : 'Required Field',
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.info_outline,color: Colors.orangeAccent,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                    label: const Text("about"),
                    hintText: 'eg. Feeling Happy ',
                  ),
                ),
          
                //for adding some space
                SizedBox(height: mq.height*.025,),
          
                //update button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(mq.width*.4, mq.height*.055)
                  ),
                    onPressed: () async {
                    if(_formkey.currentState!.validate()){
                      _formkey.currentState!.save();
                      try {

                        await APIs.updateUserInfo();
                        SSnackbbar.showSnackbar(context, 'Profile Updated Successfully!');//"Shrey Kothari"
                      } catch (error) {
                        SSnackbbar.showSnackbar(context, 'Failed to update profile: $error');
                      }
                      // print('variyed');
                    }
                    },
                    icon: const Icon(Icons.edit,size: 25,),
                    label: const Text("Update",style: TextStyle(fontSize: 16),)),
          
              ],
            ),
          ),
        ),
      ),
    );
  }
  // bottom sheet  fro picking a profile picture  for user
  void _showBottomSheet(){
    showModalBottomSheet(
        context: context,
        builder: (_){
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: mq.height*.03,bottom: mq.height*.05),
            children: [
              const Text(
                "Pick Profile Picture",textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500),),
              SizedBox(height: mq.height*.01,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                        if(image != null){
                          print("image path : ${image.path}");
                          setState(() {
                            _image =image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize: Size(mq.width*.2, mq.height*.1),
                      ),
                      child: Image.asset("assets/icons/gallery.png")),
                  ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery,imageQuality: 80);
                        if(image != null){
                          print("image path : ${image.path}");
                          setState(() {
                            _image =image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize: Size(mq.width*.2, mq.height*.1),
                      ),
                      child: Image.asset("assets/icons/camera.png")),
                ],
              )
            ],
          );
        });
  }
}
