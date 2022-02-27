import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class SignUp extends StatefulWidget {
  SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();

  TextEditingController password1Controller = TextEditingController();

  TextEditingController nameController = TextEditingController();

  TextEditingController password2Controller = TextEditingController();

  TextEditingController phoneController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  var image, imageUrl;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
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
          title: Text("SignUp"),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        context: context, builder: (Builder) => bottomSheet());
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: image == null
                        ? AssetImage("assets/pic.png")
                        : FileImage(File(image!.path)) as ImageProvider,
                  ),
                ),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: "Name"),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value!.isEmpty) return "Enter Name";
                  },
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(hintText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) return "Enter Email";
                  },
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(hintText: "Mobile Number"),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value!.isEmpty) return "Enter Mobile Number";
                    if (value.length != 10) return "Enter valid mobile number";
                  },
                ),
                TextFormField(
                  controller: placeController,
                  decoration: InputDecoration(hintText: "Place"),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) return "Enter your place";
                  },
                ),
                TextFormField(
                  controller: password1Controller,
                  decoration: InputDecoration(hintText: "Password"),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) return "Enter Password";
                    if (value.length < 6) return "Minimum 6 characters";
                  },
                ),
                TextFormField(
                  controller: password2Controller,
                  decoration: InputDecoration(hintText: "Re-Enter Password"),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) return "Re-Enter Password";
                    if (value.length < 6) return "Minimum 6 characters";
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (image != null) {
                        if (password1Controller.text ==
                            password2Controller.text) {
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
                          registerUser(context);
                        } else {
                          Fluttertoast.showToast(msg: "Password do not match");
                        }
                      } else {
                        Fluttertoast.showToast(msg: "Please upload your photo");
                      }
                    }
                  },
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    primary: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> registerUser(BuildContext context) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: emailController.text, password: password1Controller.text);
      Reference reference = firebaseStorage
          .ref()
          .child("Profile Photos")
          .child(auth.currentUser!.uid);

      UploadTask uploadTask = reference.putFile(File(image.path));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});

      await taskSnapshot.ref
          .getDownloadURL()
          .then((value) => {imageUrl = value});

      await firebaseFirestore
          .collection("Users")
          .doc(auth.currentUser!.uid)
          .set({
            'Name': nameController.text,
            'Email': emailController.text,
            'Image': imageUrl,
            'Password': password1Controller.text,
            'Id': auth.currentUser!.uid,
            'Phone': phoneController.text,
            'Place': placeController.text,
          })
          .then((value) =>
              {Fluttertoast.showToast(msg: "Registration Successful")})
          .then((value) => {
                Navigator.of(context).pop(),
              })
          .then((value) => {
                Navigator.of(context).pop(),
              });
    } catch (e) {
      Fluttertoast.showToast(msg: "Registration failed");
      Navigator.of(context).pop();
    }
  }

  Future<void> takePhoto(ImageSource source) async {
    var img = await ImagePicker().pickImage(source: source);
    setState(() {
      image = img;
    });
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
}
