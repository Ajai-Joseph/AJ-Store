import 'dart:io';

import 'package:aj_store/login.dart';
import 'package:aj_store/profile.dart';
import 'package:aj_store/resetPassword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfile extends StatefulWidget {
  UpdateProfile({Key? key}) : super(key: key);

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final GlobalKey<FormState> formKey = GlobalKey();
  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  String? name, phone, place;
  var image;
  var img;
  var imgUrl;
  int flag = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue,
                Colors.purple,
              ],
            ),
          ),
        ),
        actions: [
          PopupMenuButton(
            onSelected: (item) => select(context, item),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Text("Change Email"),
              ),
              PopupMenuItem(
                value: 1,
                child: Text("Change Password"),
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection("Users")
              .doc(auth.currentUser!.uid)
              .get()
              .then((value) => {
                    name = value.data()!['Name'],
                    image = value.data()!['Image'],
                    phone = value.data()!['Phone'],
                    place = value.data()!['Place'],
                  }),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (builder) => bottomSheet());
                        },
                        child: CircleAvatar(
                          backgroundImage: flag == 0
                              ? NetworkImage(image!)
                              : FileImage(File(img!.path)) as ImageProvider,
                          radius: 70,
                        ),
                      ),
                      TextFormField(
                        controller: nameController..text = name!,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) return "Enter Name";
                        },
                      ),
                      TextFormField(
                        controller: phoneController..text = phone!,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value!.isEmpty) return "Enter phone number";
                          if (value.length != 10)
                            return "Enter valid phone number";
                        },
                      ),
                      TextFormField(
                        controller: placeController..text = place!,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) return "Enter Place";
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    Text(
                                      "Please wait...",
                                      style: TextStyle(
                                        decoration: TextDecoration.none,
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            updateUser(context);
                          }
                        },
                        child: Text(
                          "Update",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: 100,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text("Choose profile photo"),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.camera);
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.camera),
                label: Text("Camera"),
              ),
              TextButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.image),
                label: Text("Gallery"),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> takePhoto(ImageSource source) async {
    img = await ImagePicker().pickImage(source: source);

    setState(() {
      flag = 1;
      image = img;
    });
  }

  Future<void> updateUser(context) async {
    try {
      if (flag == 0) {
        imgUrl = image;
      } else {
        Reference firebaseStorage = FirebaseStorage.instance
            .ref()
            .child("Profile Photos")
            .child(auth.currentUser!.uid);
        UploadTask uploadTask = firebaseStorage.putFile(File(img.path));
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
        await taskSnapshot.ref.getDownloadURL().then((url) => {imgUrl = url});
      }
      await firestore.collection("Users").doc(auth.currentUser!.uid).update({
        'Name': nameController.text,
        'Phone': phoneController.text,
        'Image': imgUrl,
        'Place': placeController.text,
      }).then((value) => {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Profile()))
          });
    } catch (e) {
      Fluttertoast.showToast(msg: "Updation failed");
    }
  }

  void select(BuildContext context, var item) {
    switch (item) {
      case 0:
        // Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (context) => UpdateProfile()));
        break;
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ResetPassword()));

        break;
    }
  }
}
