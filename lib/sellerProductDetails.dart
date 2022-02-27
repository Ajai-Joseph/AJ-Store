import 'package:aj_store/editProductDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class SellerProductDetails extends StatelessWidget {
  String productId;
  SellerProductDetails({required this.productId});
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? title, price, place, userId, description, postedDate;
  Map moreDetailsMap = {};
  List images = [];
  List l = [];

  @override
  Widget build(BuildContext context) {
    userId = auth.currentUser!.uid;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Product Details"),
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
                  child: Text(
                    "Edit",
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: FutureBuilder(
                future: firestore
                    .collection("Products")
                    .doc(productId)
                    .get()
                    .then((value) => {
                          title = value.data()!['Title'],
                          images = value.data()!['Images'],
                          price = value.data()!['Price'],
                          place = value.data()!['Place'],
                          description = value.data()!['Description'],
                          moreDetailsMap = value.data()!['Map'],
                          postedDate = value.data()!['Posted Date'],
                        }),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: ListView.separated(
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Image(
                                  image: NetworkImage(images[index]),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  width: 5,
                                );
                              },
                              itemCount: images.length),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "₹ $price",
                                  style: TextStyle(
                                    fontSize: 23,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "$title",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 15,
                                        ),
                                        Text(
                                          "$place",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(DateFormat.yMMMd()
                                        .format(DateTime.parse(postedDate!))),
                                  ],
                                ),
                              ),
                              Divider(
                                thickness: 0.3,
                                color: Colors.black,
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Description",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "$description",
                                ),
                              ),
                              Divider(
                                thickness: 0.3,
                                color: Colors.black,
                              ),
                              if (moreDetailsMap.isNotEmpty)
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "More Details",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ListView.builder(
                                scrollDirection: Axis.vertical,
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  String key =
                                      moreDetailsMap.keys.elementAt(index);
                                  return Flexible(
                                    child: Row(
                                      children: [
                                        Flexible(child: Text(key)),
                                        Text("  :  "),
                                        Flexible(
                                            child: Text(moreDetailsMap[key])),
                                      ],
                                    ),
                                  );
                                },
                                itemCount: moreDetailsMap.length,
                              ),
                              SizedBox(
                                height: 40,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Delete Product?"),
                            content: Text("Are you sure to delete product?"),
                            actions: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("No"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      //Navigator.of(context).pop();
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(),
                                              Text(
                                                "Deleting,\nPlease wait...",
                                                style: TextStyle(
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      delete(context);
                                      // Navigator.of(context).pop();
                                      // Navigator.of(context).pop();
                                    },
                                    child: Text("Yes"),
                                  ),
                                ],
                              )
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Remove"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void delete(BuildContext context) async {
    // try {
    List buyers = [];
    for (int i = 0; i < images.length; i++) {
      await FirebaseStorage.instance.refFromURL(images[i]).delete();
    }

    await firestore
        .collection("Products")
        .doc(productId)
        .get()
        .then((value) => {buyers = value.data()!['Buyers']});

    for (int i = 0; i < buyers.length; i++) {
      await firestore
          .collection("Buy Chats")
          .doc(productId + buyers[i] + userId!)
          .collection('Messages')
          .get()
          .then((value) => {
                value.docs.forEach((element) {
                  firestore
                      .collection("Buy Chats")
                      .doc(productId + buyers[i] + userId!)
                      .collection('Messages')
                      .doc(element.id)
                      .delete();
                })
              });

      await firestore
          .collection("Sell Chats")
          .doc(productId + userId! + buyers[i])
          .collection('Messages')
          .get()
          .then((value) => {
                value.docs.forEach((element) {
                  firestore
                      .collection("Sell Chats")
                      .doc(productId + userId! + buyers[i])
                      .collection('Messages')
                      .doc(element.id)
                      .delete();
                })
              });
    }
    for (int j = 0; j < buyers.length; j++) {
      await firestore
          .collection("Buy Last Message")
          .doc(buyers[j])
          .collection("Messages")
          .doc(productId + userId!)
          .update({
        "Last Message": "This ad has been deleted by seller",
      });
      await firestore
          .collection("Sell Last Message")
          .doc(userId)
          .collection("Messages")
          .doc(productId + buyers[j])
          .delete();
    }
    await firestore.collection("Products").doc(productId).delete();
    // .then((value) => {
    await firestore
        .collection("Sellers")
        .doc(userId)
        .collection("Products")
        .doc(productId)
        .delete();
    //    })
    //.then((value) => {
    Fluttertoast.showToast(msg: "Deleted Successfully");
    //    })
    //.then((value) => {
    Navigator.of(context).pop();
    // //    })
    // //.then((value) => {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    //  });

    // } catch (e) {
    //   Fluttertoast.showToast(msg: "Deletion Failed")
    //       .then((value) => {Navigator.of(context).pop()});
    // }
  }

  void select(BuildContext context, var item) {
    switch (item) {
      case 0:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditProductDetails(
                  productId: productId,
                )));
        break;
    }
  }
}
