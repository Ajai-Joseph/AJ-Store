import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class EditProductDetails extends StatefulWidget {
  String productId;
  EditProductDetails({required this.productId});

  @override
  _EditProductDetailsState createState() => _EditProductDetailsState();
}

class _EditProductDetailsState extends State<EditProductDetails> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> alertFormKey = GlobalKey<FormState>();
  List<XFile> images = [];
  List imageUrl = [];
  late String userId;
  List<TextFormField> textFormFieldList = [];
  List newTitleList = [];
  List newSubtitleList = [];
  TextEditingController alertTitleController = TextEditingController();
  TextEditingController alertSubtitleController = TextEditingController();
  TextEditingController newTitleController = TextEditingController();
  Map moreDetailsMap = {};
  Map moreDetailsMap2 = {};
  late String title, description, place, price;
  List<String> deletedImagesList = [];
  @override
  Widget build(BuildContext context) {
    userId = auth.currentUser!.uid;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit"),
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
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: FutureBuilder(
            future: firestore
                .collection("Products")
                .doc(widget.productId)
                .get()
                .then((value) => {
                      title = value.data()!['Title'],
                      description = value.data()!['Description'],
                      place = value.data()!['Place'],
                      price = value.data()!['Price'],
                      moreDetailsMap = value.data()!['Map'],
                      imageUrl = value.data()!['Images'],
                    }),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: titleController..text = title,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          label: Text("Title"),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return "Enter Title";
                        },
                      ),
                      TextFormField(
                        controller: descriptionController..text = description,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          label: Text("Description"),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return "Enter description";
                        },
                      ),
                      TextFormField(
                        controller: placeController..text = place,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          label: Text("Place"),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return "Enter place";
                        },
                      ),
                      TextFormField(
                        controller: priceController..text = price,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          label: Text("Price"),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return "Enter price";
                        },
                      ),
                      moreDetailsMap.isNotEmpty
                          ? Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              // height: 150,
                              child: ListView.separated(
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  newTitleList = moreDetailsMap.keys.toList();
                                  newSubtitleList =
                                      moreDetailsMap.values.toList();

                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "${newTitleList[index]}",
                                                maxLines: null,
                                                overflow: TextOverflow.fade,
                                              ),
                                            ),
                                            Text("  :  "),
                                            Flexible(
                                              child: Text(
                                                "${newSubtitleList[index]}",
                                                maxLines: null,
                                                overflow: TextOverflow.fade,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          if (moreDetailsMap.length != 1) {
                                            moreDetailsMap
                                                .remove(newTitleList[index]);
                                            newTitleList.removeAt(index);
                                            newSubtitleList.removeAt(index);
                                            await firestore
                                                .collection("Products")
                                                .doc(widget.productId)
                                                .update({
                                              "Map": moreDetailsMap,
                                              // FieldValue.arrayRemove([
                                              //   moreDetailsMap[
                                              //       newTitleList[index]]
                                              // ])
                                            });
                                            await firestore
                                                .collection("Sellers")
                                                .doc(userId)
                                                .collection("Products")
                                                .doc(widget.productId)
                                                .update({
                                              "Map": moreDetailsMap,
                                            });

                                            setState(() {});
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  content: Text(
                                                    "Field can't be deleted",
                                                  ),
                                                  actions: [
                                                    Center(
                                                      child: TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("OK"),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.delete),
                                      ),
                                    ],
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    thickness: 1,
                                  );
                                },
                                itemCount: moreDetailsMap.length,
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          alertBox(context);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(
                            Icons.add,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      if (imageUrl.isNotEmpty)
                        SizedBox(
                          height: 150,
                          child: ListView(
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: [
                              ListView.separated(
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (imageUrl.length == 1) {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  content: Text(
                                                    "Image can't be deleted",
                                                  ),
                                                  actions: [
                                                    Center(
                                                      child: TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("OK"),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  content: Text(
                                                    "Sure to delete?",
                                                  ),
                                                  actions: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text("No"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            //Navigator.of(context).pop();
                                                            showDialog(
                                                              barrierDismissible:
                                                                  false,
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    CircularProgressIndicator(),
                                                                    Text(
                                                                      "Deleting,\nPlease wait...",
                                                                      style:
                                                                          TextStyle(
                                                                        decoration:
                                                                            TextDecoration.none,
                                                                        fontSize:
                                                                            20,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                            deleteImages(index);
                                                          },
                                                          child: Text("Yes"),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.delete),
                                      ),
                                      Image.network(
                                        imageUrl[index],
                                        width: 60,
                                        height: 60,
                                      ),
                                    ],
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return SizedBox(width: 5);
                                },
                                itemCount: imageUrl.length,
                              ),
                              ListView.separated(
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          images.removeAt(index);
                                          setState(() {});
                                        },
                                        icon: Icon(Icons.delete),
                                      ),
                                      Image.file(
                                        File(
                                          images[index].path,
                                        ),
                                        width: 60,
                                        height: 60,
                                      ),
                                    ],
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return SizedBox(width: 5);
                                },
                                itemCount: images.length,
                              ),
                              images.length != 0 || imageUrl.length != 0
                                  ? CircleAvatar(
                                      backgroundColor: Colors.grey.shade300,
                                      child: IconButton(
                                        onPressed: () {
                                          selectImages();
                                        },
                                        icon: Icon(
                                          Icons.add_a_photo,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          images.isEmpty ? selectImages() : upload();
                        },
                        child: images.isEmpty && imageUrl.isEmpty
                            ? Text("Add Images")
                            : Text("Update"),
                      ),
                    ],
                  ),
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

  void selectImages() async {
    if (formKey.currentState!.validate()) {
      List<XFile>? selectedImages = await ImagePicker().pickMultiImage();
      if (selectedImages == null) {
      } else {
        images.addAll(selectedImages);
      }
      setState(() {});
    }
  }

  void upload() async {
    try {
      showLoading();
      for (int i = 0; i < deletedImagesList.length; i++) {
        await firebaseStorage.refFromURL(deletedImagesList[i]).delete();
      }
      for (int i = 0; i < images.length; i++) {
        Reference reference = firebaseStorage
            .ref()
            .child("Seller Product Images")
            .child(userId)
            .child(images[i].name);
        UploadTask uploadTask = reference.putFile(File(images[i].path));
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});

        await taskSnapshot.ref
            .getDownloadURL()
            .then((value) => {imageUrl.add(value)});
      }
      await firestore
          .collection("Products")
          .doc(widget.productId)
          .update(
            {
              'Title': titleController.text,
              'Place': placeController.text,
              'Price': priceController.text,
              'Description': descriptionController.text,
              'Images': imageUrl,
            },
          )
          .then(
            (value) => {
              firestore
                  .collection("Sellers")
                  .doc(userId)
                  .collection("Products")
                  .doc(widget.productId)
                  .update(
                {
                  'Title': titleController.text,
                  'Description': descriptionController.text,
                  'Place': placeController.text,
                  'Price': priceController.text,
                  'Images': imageUrl,
                },
              )
            },
          )
          .then((value) => {Fluttertoast.showToast(msg: "Updation completed")})
          .then((value) =>
              {Navigator.of(context).pop(), Navigator.of(context).pop()});
    } catch (e) {
      Fluttertoast.showToast(msg: "Updation failed")
          .then((value) => {Navigator.of(context).pop()});
    }
  }

  void showLoading() {
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
  }

  void alertBox(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: SingleChildScrollView(
            child: AlertDialog(
              title: Text("Add Field"),
              content: Form(
                key: alertFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: alertTitleController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Title",
                      ),
                      validator: (value) {
                        if (alertTitleController.text.isEmpty)
                          return "Enter Title";
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: alertSubtitleController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Description",
                      ),
                      validator: (value) {
                        if (alertSubtitleController.text.isEmpty)
                          return "Field cannot be empty";
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (alertFormKey.currentState!.validate()) {
                          moreDetailsMap[alertTitleController.text] =
                              alertSubtitleController.text;
                          await firestore
                              .collection("Products")
                              .doc(widget.productId)
                              .update({
                            "Map": moreDetailsMap,
                          });
                          await firestore
                              .collection("Sellers")
                              .doc(userId)
                              .collection("Products")
                              .doc(widget.productId)
                              .update({
                            "Map": moreDetailsMap,
                          });
                          alertTitleController.clear();
                          alertSubtitleController.clear();
                          Navigator.of(context).pop();
                          setState(() {});
                        }
                      },
                      child: Text("Add"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void deleteImages(int index) async {
    await firebaseStorage.refFromURL(imageUrl[index]).delete();

    await firestore.collection("Products").doc(widget.productId).update({
      "Images": FieldValue.arrayRemove([imageUrl[index]])
    });
    imageUrl.removeAt(index);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    setState(() {});
  }
}
