import 'package:aj_store/login.dart';
import 'package:aj_store/updateProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  Profile({Key? key}) : super(key: key);
  String? name, email, image, phone, place;
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text("Profile"),
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
          elevation: 0,
          actions: [
            PopupMenuButton(
              onSelected: (item) => select(context, item),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 0,
                  child: Text("Edit"),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Text("Delete Account"),
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
                      email = value.data()!['Email'],
                      image = value.data()!['Image'],
                      phone = value.data()!['Phone'],
                      place = value.data()!['Place'],
                    }),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width,
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
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: NetworkImage("${image}"))),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.blue,
                              ),
                              Text(
                                "  ${name}",
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                color: Colors.blue,
                              ),
                              Text(
                                "  ${email}",
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                color: Colors.blue,
                              ),
                              Text(
                                "  ${phone}",
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(
                                Icons.place,
                                color: Colors.blue,
                              ),
                              Text(
                                "  ${place}",
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }

  void select(BuildContext context, var item) {
    switch (item) {
      case 0:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => UpdateProfile()));
        break;
      case 1:
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: Text("Delete Account?"),
                  content: Text("Are you sure to delete your account?"),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "No",
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection("Users")
                                .doc(auth.currentUser!.uid)
                                .delete()
                                .then((value) => {
                                      FirebaseStorage.instance
                                          .ref()
                                          .child("Profile Photos")
                                          .child(auth.currentUser!.uid)
                                          .delete()
                                    })
                                .then((value) => {
                                      auth.currentUser!.delete(),
                                    });
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => Login()),
                                (route) => false);
                          },
                          child: Text(
                            "Yes",
                          ),
                        ),
                      ],
                    ),
                  ]);
            });
        break;
    }
  }
}
