import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class AddProduct extends StatefulWidget {
  String categoryName;
  AddProduct({required this.categoryName});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
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
  List<String> imageUrl = [];
  late String userId, productId;
  List<TextFormField> textFormFieldList = [];
  List newTitleList = [];
  List newSubtitleList = [];
  TextEditingController alertTitleController = TextEditingController();
  TextEditingController alertSubtitleController = TextEditingController();
  TextEditingController newTitleController = TextEditingController();
  Map<String, String> moreDetailsMap = {};
  bool moreDetails = false;
  List buyers = [];
  @override
  Widget build(BuildContext context) {
    userId = auth.currentUser!.uid;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Product"),
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
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    label: Text("Title"),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "Enter Title";
                  },
                ),
                TextFormField(
                  controller: descriptionController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    label: Text("Description"),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "Enter description";
                  },
                ),
                TextFormField(
                  controller: placeController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    label: Text("Place"),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "Enter place";
                  },
                ),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    label: Text("Price"),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "Enter price";
                  },
                ),
                moreDetails == true
                    ? Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        // height: 150,
                        child: ListView.separated(
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            newTitleList = moreDetailsMap.keys.toList();
                            newSubtitleList = moreDetailsMap.values.toList();

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  onPressed: () {
                                    moreDetailsMap.remove(newTitleList[index]);
                                    newTitleList.removeAt(index);
                                    newSubtitleList.removeAt(index);

                                    if (newTitleList.isEmpty) {
                                      setState(() {
                                        moreDetails = false;
                                      });
                                    }
                                    setState(() {});
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
                if (images.isNotEmpty)
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
                        images.length != 0
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
                  child: images.isEmpty ? Text("Upload Images") : Text("NEXT"),
                ),
              ],
            ),
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
      DateTime dateTime = DateTime.now();
      String? productId;
      showLoading();

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
          .add(
            {
              'Title': titleController.text,
              'Place': placeController.text,
              'Price': priceController.text,
              'Description': descriptionController.text,
              'Images': imageUrl,
              'Seller ID': userId,
              'Product ID': "",
              'Posted Date': dateTime.toString(),
              'Map': moreDetailsMap,
              'Buyers': buyers,
              'Category': widget.categoryName,
            },
          )
          .then(
            (value) => {
              productId = value.id,
              firestore
                  .collection("Products")
                  .doc(productId)
                  .update({'Product ID': productId})
            },
          )
          .then(
            (value) => {
              firestore
                  .collection("Sellers")
                  .doc(userId)
                  .collection("Products")
                  .doc(productId)
                  .set(
                {
                  'Title': titleController.text,
                  'Description': descriptionController.text,
                  'Place': placeController.text,
                  'Price': priceController.text,
                  'Images': imageUrl,
                  'Product ID': productId,
                  'Posted Date': dateTime.toString(),
                  'Map': moreDetailsMap,
                  'Category': widget.categoryName,
                },
              )
            },
          )
          .then((value) => {Fluttertoast.showToast(msg: "upload completed")})
          .then((value) =>
              {Navigator.of(context).pop(), Navigator.of(context).pop()});
    } catch (e) {
      Fluttertoast.showToast(msg: "Uploading failed")
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
                      onPressed: () {
                        if (alertFormKey.currentState!.validate()) {
                          moreDetailsMap.addEntries([
                            MapEntry(alertTitleController.text,
                                alertSubtitleController.text)
                          ]);
                          alertTitleController.clear();
                          alertSubtitleController.clear();
                          Navigator.of(context).pop();
                          setState(() {
                            moreDetails = true;
                          });
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
}
