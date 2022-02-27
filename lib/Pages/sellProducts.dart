import 'package:aj_store/selectCategory.dart';
import 'package:aj_store/sellerProductDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SellProducts extends StatelessWidget {
  SellProducts({Key? key}) : super(key: key);
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection("Sellers")
                .doc(auth.currentUser!.uid)
                .collection("Products")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot x = snapshot.data!.docs[index];
                    List li = x['Images'];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SellerProductDetails(
                                productId: x['Product ID'])));
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              Image(
                                image: NetworkImage(li.first),
                                width: 90,
                                height: 90,
                              ),
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "₹ ${x['Price']}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        fontSize: 15),
                                  )),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  x['Title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 18,
                                  ),
                                  Text(
                                    x['Place'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: snapshot.data!.docs.length,
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ),
        Positioned(
          height: 50,
          width: 50,
          bottom: 10,
          right: 10,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      SelectCategory(fromWhichPage: "sellProducts")));
            },
            child: Icon(
              Icons.add,
            ),
          ),
        )
      ],
    );
  }
}
