import 'package:aj_store/buyChatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerProductDetails extends StatelessWidget {
  String productId;
  CustomerProductDetails({required this.productId});
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? title, sellerId, price, place, userId, description, postedDate;
  Map moreDetailsMap = {};
  List images = [];
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
                          sellerId = value.data()!['Seller ID'],
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
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => BuyChatScreen(
                                receiverId: sellerId!,
                                productId: productId,
                                productName: title!,
                                productPrice: price!,
                              )));
                    },
                    child: Text("CHAT"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
